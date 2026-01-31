//
//  OpenLibraryService.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation

struct OLSearchResponse: Codable {
    let numFound: Int
    let start: Int
    let docs: [OLSearchDoc]
    
    enum CodingKeys: String, CodingKey {
        case numFound = "numFound"
        case start
        case docs
    }
}

struct OLSearchDoc: Codable {
    let key: String
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverI: Int?
    let ratingsAverage: Double?
    let isbn: [String]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverI = "cover_i"
        case ratingsAverage = "ratings_average"
        case isbn
    }
}

struct OLWorkDetail: Codable {
    let description: OLDescription?
    let title: String?
    let covers: [Int]?
    let firstPublishDate: String?
    
    enum CodingKeys: String, CodingKey {
        case description
        case title
        case covers
        case firstPublishDate = "first_publish_date"
    }
}

struct OLDescription: Codable {
    let value: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let dictValue = try? container.decode([String: String].self) {
            self.value = dictValue["value"]
        } else {
            self.value = nil
        }
    }
}

// MARK: - Open Library Service

class OpenLibraryService: SearchService {
    
    typealias SearchResultItem = ExternalBookItem
    
    static var serviceName: String = "Open Library"
    static var requiresToken: Bool = false
    static var tokenPlaceholder: String? = nil
    static var helpURL: String? = nil
    
    private let baseURL = "https://openlibrary.org"
    private let session: URLSession
    private var lastRequestTime: Date?
    private let minimumDelay: TimeInterval = 1.0 // 1 second between requests
    
    init() {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
    }
    
    
    // MARK: - Search Books
    
    // @Override
    func search(query: String, limit: Int) async throws -> [ExternalBookItem] {
        var components = URLComponents(string: "\(baseURL)/search.json")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "fields", value: "key,cover_i,title,subtitle,author_name,editions,name,ratings_average,first_publish_year,isbn")
        ]
        
        guard let url = components?.url else {
            throw OLError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OLError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OLError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let searchResponse = try JSONDecoder().decode(OLSearchResponse.self, from: data)
        
        return searchResponse.docs.map { doc in
            convertToBook(from: doc)
        }
    }
    
    // MARK: - Get Book Details

    func getDetails(item: ExternalBookItem) async throws -> ExternalBookItem {
        // Extract work key from source URL
        if let workKey = item.sourceUrl.absoluteString.components(separatedBy: "/works/").last {
            if let detailedBook = try? await getBookDetails(workKey: workKey) {
                // Merge search data with detailed data
                
                let mergedBook = ExternalBookItem(
                    title: detailedBook.title.isEmpty ? item.title : detailedBook.title,
                    sourceUrl: item.sourceUrl,
                    sourceName: item.sourceName,
                    description: detailedBook.itemDescription,
                    rating: item.rating,
                    coverUrl: detailedBook.coverUrl ?? item.coverUrl,
                    isbn: item.isbn,
                    author: item.author,
                    year: detailedBook.year ?? item.year,
                )
                
                return mergedBook
            } else {
                return item
            }
        } else {
            return item
        }

    }
        
    private func getBookDetails(workKey: String) async throws -> ExternalBookItem? {
        
        // Clean the work key (remove /works/ if present)
        let cleanKey = workKey.replacingOccurrences(of: "/works/", with: "")
        let detailURL = "\(baseURL)/works/\(cleanKey).json"
        
        guard let url = URL(string: detailURL) else {
            throw OLError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OLError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            return nil
        }
        
        let workDetail = try JSONDecoder().decode(OLWorkDetail.self, from: data)
        
        let coverUrl = workDetail.covers?.first.map { coverId in
            "https://covers.openlibrary.org/b/id/\(coverId)-L.jpg"
        }
        
        let year = extractYear(from: workDetail.firstPublishDate)
        
        return ExternalBookItem(
            title: workDetail.title ?? "",
            sourceUrl: URL(string: "\(baseURL)/works/\(cleanKey)")!,
            sourceName: OpenLibraryService.serviceName,
            description: workDetail.description?.value,
            coverUrl: coverUrl.flatMap { URL(string: $0) },
            year: year,
        )
    }
    
    
    // MARK: - Helper Methods
    
    private func convertToBook(from doc: OLSearchDoc) -> ExternalBookItem {
        let coverUrl = doc.coverI.map { "https://covers.openlibrary.org/b/id/\($0)-L.jpg" }
        
        return ExternalBookItem(
            title: doc.title,
            sourceUrl: URL(string: "\(baseURL)\(doc.key)")!,
            sourceName: OpenLibraryService.serviceName,
            rating: doc.ratingsAverage,
            coverUrl: coverUrl.flatMap { URL(string: $0) },
            isbn: doc.isbn?.first,
            author: doc.authorName?.joined(separator: ", "),
            year: doc.firstPublishYear,
        )
    }
    
    private func extractYear(from dateString: String?) -> Int? {
        guard let dateString = dateString else { return nil }
        
        let regex = /(\d{4})/
        if let match = dateString.firstMatch(of: regex) {
            return Int(match.1)
        } else {
            return nil
        }
    }
    
}
// MARK: - Error Handling

enum OLError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
}

extension OLError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
