//
//  FilmixService.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 12.03.2026.
//

import Foundation

@MainActor
final class FilmixClient {

    static let shared = FilmixClient()

    // MARK: Config

    let baseURL = "https://filmix.my"
    var requestDelayRange: ClosedRange<TimeInterval> = 0.5...1.5

    // MARK: Session

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 20
        config.timeoutIntervalForResource = 60
        config.httpCookieAcceptPolicy     = .always
        config.httpShouldSetCookies       = true
        config.httpCookieStorage          = .shared
        return URLSession(configuration: config)
    }()

    private init() {}

    // MARK: - Public API

    func search(query: String) async throws -> [FilmixMovieBaseInfo] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }

        var components = URLComponents(string: "\(baseURL)/api/v2/suggestions")!
        components.queryItems = [URLQueryItem(name: "search_word", value: q)]
        guard let url = components.url else { throw FilmixError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyBrowserHeaders(to: &request)
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("\(baseURL)/",    forHTTPHeaderField: "Referer")
        request.setValue("application/json, text/javascript, */*; q=0.01",
                         forHTTPHeaderField: "Accept")

        let data = try await perform(request)
        return try parsePost(data)
    }

    func movieDetail(url urlString: String) async throws -> FilmixMovieDetail {
        guard let url = URL(string: urlString) else { throw FilmixError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyBrowserHeaders(to: &request)
        request.setValue("\(baseURL)/", forHTTPHeaderField: "Referer")

        let data = try await perform(request)

        guard let html = String(data: data, encoding: .windowsCP1251) else {
            throw FilmixError.parseError("Can't decode HTML page :/")
        }
        return try parseMovieDetail(html: html, sourceURL: urlString)
    }

    // MARK: - Networking

    private func perform(_ request: URLRequest) async throws -> Data {
        let delay = TimeInterval.random(in: requestDelayRange)
        try await Task.sleep(for: .seconds(delay))

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw FilmixError.networkError(error)
        }

        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            throw FilmixError.unexpectedStatusCode(http.statusCode)
        }
        return data
    }

    /// Emulate Chrome 124 on iPhone
    private func applyBrowserHeaders(to request: inout URLRequest) {
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) "
            + "AppleWebKit/605.1.15 (KHTML, like Gecko) "
            + "CriOS/124.0.6367.111 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue(
            "text/html,application/xhtml+xml,application/xml;q=0.9,"
            + "image/avif,image/webp,image/apng,*/*;q=0.8",
            forHTTPHeaderField: "Accept"
        )
        request.setValue("ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
                         forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br",
                         forHTTPHeaderField: "Accept-Encoding")
        request.setValue("keep-alive",  forHTTPHeaderField: "Connection")
        request.setValue("document",    forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("navigate",    forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue(baseURL,       forHTTPHeaderField: "Origin")
    }

    // MARK: - JSON Parser (suggestions)

    private func parsePost(_ data: Data) throws -> [FilmixMovieBaseInfo] {
        let json: Any
        do { json = try JSONSerialization.jsonObject(with: data) }
        catch { throw FilmixError.parseError("JSON decode failed: \(error)") }

        let items: [[String: Any]]
        if let wrapper = json as? [String: Any],
           let arr = wrapper["posts"] as? [[String: Any]] {
            items = arr
        } else {
            Log.error("Unexpected map format in JSON response", context: ["json": json])
            throw FilmixError.parseError("Something went wrong with JSON. See logs for details.")
        }

        return items.compactMap { dict -> FilmixMovieBaseInfo? in
            guard let id = (dict["id"] as? Int)
                        ?? (dict["id"] as? String).flatMap(Int.init)
            else { return nil }

            let title = (dict["title"] as? String) ?? ""

            let year   = (dict["year"] as? Int)
                      ?? (dict["year"] as? String).flatMap(Int.init)

            let categories = (dict["categories"] as? String) ?? ""
            let originalName = (dict["original_name"] as? String) ?? ""
            let link = (dict["link"] as? String) ?? ""
            let poster: String? = dict["poster"] as? String

            let lastSerie = (dict["last_serie"] as? String).flatMap {
                $0.isEmpty ? nil : $0
            }

            return FilmixMovieBaseInfo(
                id: id,
                title: title,
                year: year,
                link: link,
                poster: poster,
                categories: categories,
                originalName: originalName,
                lastSerie: lastSerie
            )
        }
    }

    // MARK: - HTML Parser (movie detail)

    private func parseMovieDetail(html: String, sourceURL: String) throws -> FilmixMovieDetail {

        // <div class="about" itemprop="description"><div class="full-story">
        let description = extractTag(html, tag: "div", className: "full-story")
            .flatMap { $0.isEmpty ? nil : $0 }
        let director = extractDirector(from: html)
            .flatMap { $0.isEmpty ? nil : $0.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) }
        let rating = extractKinopoiskRating(from: html)

            // TODO: poster
//      <article class="fullstory news-168721" data-id="168721" itemscope itemtype="http://schema.org/Movie">
//        <div class="short min">
//            <span class=""><a class="fancybox" rel="group" href="https://thumbs.filmix.my/posters/3353/orig/silachka-kan-nam-sun-2023_168721.jpg">
//                <img src="https://thumbs.filmix.my/posters/3353/thumbs/w220/silachka-kan-nam-sun-2023_168721.jpg" class="poster poster-tooltip" itemprop="image" alt="Силачка Кан Нам-сун, 2023" title="Силачка Кан Нам-сун" loading="lazy"/>
//            </a></span>
//        
        let contentType = resolveContentType(url: sourceURL, html: html)

        return FilmixMovieDetail(
            description: description,
            rating: rating,
            director: director,
            contentType: contentType
        )
    }

    // MARK: - Helper: Specific Fields

    private func resolveContentType(url: String, html: String) -> FilmixContentType {
        let u = url.lowercased()
        if u.contains("/seria") || u.contains("/serial") { return .series }
        if u.contains("/films") || u.contains("/filmy")  { return .film }
        if u.contains("/mult")                           { return .cartoon }
        if u.contains("/anime")                         { return .anime }
        return .unknown
    }

    // <div class="item directors"><span class="label">Режиссер:</span><span class="item-content"><span>Target value</.....
    func extractDirector(from html: String) -> String? {
        let pattern = #"<div class="item directors">.*?<span class="item-content"><span>(.*?)</span>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html)
        else { return nil }
        
        return String(html[range])
    }
    
    //    <footer>
    //        <span class="kinopoisk btn-tooltip icon-kinopoisk" title='Рейтинг фильма по 10 бальной шкале по версии сайта "Кинопоиск"'>
    //            <p>7.077</p>
    //            <span class="hidden">10</span>
    //            <span class="hidden">0</span>
    //            <p>11717</p>
    //        </span>
    //        <span class="imdb btn-tooltip icon-imdb" title='Рейтинг фильма по 10 бальной шкале по версии сайта “IMDB”'>
    //            <p>6.6</p>
    //            <p>4000</p>
    //        </span>
    //    </footer>
    func extractKinopoiskRating(from html: String) -> Double? {
        let pattern = #"<span class="kinopoisk[^"]*"[^>]*>.*?<p>([\d.]+)</p>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html)
        else { return nil }
        
        return Double(html[range])
    }
    
    private func extractTag(_ html: String, tag: String, className: String?) -> String? {
        let classConstraint: String
        if let cn = className {
            let esc = NSRegularExpression.escapedPattern(for: cn)
            classConstraint = #"[^>]*class=["'][^"']*"# + esc + #"[^"']*["']"#
        } else {
            classConstraint = "[^>]*"
        }
        let pattern = "<\(tag)\(classConstraint)\\s*>((?:[^<]|<(?!/?\(tag)))*?)</\(tag)>"
        guard let raw = extractRegex(html, pattern: pattern) else { return nil }
        let stripped = raw.replacingOccurrences(of: "<[^>]+>", with: "",
                                                options: .regularExpression)
        let clean = stripped
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
        return clean.isEmpty ? nil : clean
    }

    private func extractRegex(_ text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        ),
        let match = regex.firstMatch(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ),
        match.numberOfRanges > 1,
        let range = Range(match.range(at: 1), in: text)
        else { return nil }
        return String(text[range])
    }

}

enum FilmixError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case unexpectedStatusCode(Int)
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:                  return "Wrong URL"
        case .networkError(let e):         return "Network Error: \(e.localizedDescription)"
        case .unexpectedStatusCode(let c): return "HTTP \(c)"
        case .parseError(let msg):         return "Parse error: \(msg)"
        }
    }
}

enum FilmixContentType: String {
    case film    = "film"
    case series  = "series"
    case cartoon = "cartoon"
    case anime   = "anime"
    case unknown = "unknown"
}

struct FilmixMovieBaseInfo: Identifiable {
    let id: Int
    let title: String
    let year: Int?
    let link: String
    let poster: String?
    let categories: String?
    let originalName: String?
    let lastSerie: String?
}

struct FilmixMovieDetail {
    let description: String?
    let rating: Double?
    let director: String?
    let contentType: FilmixContentType
}
