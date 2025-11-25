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
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverI = "cover_i"
        case ratingsAverage = "ratings_average"
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

class OpenLibraryService {
    
    static let shared = OpenLibraryService()
    
    private let baseURL = "https://openlibrary.org"
    private let session: URLSession
    private var lastRequestTime: Date?
    private let minimumDelay: TimeInterval = 1.0 // 1 second between requests
    
    init() {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
    }
    
   
    // MARK: - Search Books
    
    func searchBooks(query: String, limit: Int = 10) async throws -> [BookItem] {
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let searchURL = "\(baseURL)/search.json?q=\(encodedQuery)&limit=\(limit)&fields=key,cover_i,title,subtitle,author_name,editions,name ,ratings_average,first_publish_year"
        
        guard let url = URL(string: searchURL) else {
            throw OLError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OLError.invalidResponse
        }
        
        if httpResponse.statusCode == 429 {
            throw OLError.rateLimitExceeded
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
    
    func getBookDetails(workKey: String) async throws -> BookItem? {
        
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
        
        if httpResponse.statusCode == 429 {
            throw OLError.rateLimitExceeded
        }
        
        guard httpResponse.statusCode == 200 else {
            return nil
        }
        
        let workDetail = try JSONDecoder().decode(OLWorkDetail.self, from: data)
        
        let coverUrl = workDetail.covers?.first.map { coverId in
            "https://covers.openlibrary.org/b/id/\(coverId)-L.jpg"
        }
        
        let year = extractYear(from: workDetail.firstPublishDate)
        
        return BookItem(
            description: workDetail.description?.value,
            sourceUrl: URL(string: "\(baseURL)/works/\(cleanKey)")!,
            coverUrl: URL(string: coverUrl ?? ""),
            title: workDetail.title ?? "",
            year: year
        )
    }
    
    
    // MARK: - Helper Methods
    
    private func convertToBook(from doc: OLSearchDoc) -> BookItem {
        let coverUrl = doc.coverI.map { "https://covers.openlibrary.org/b/id/\($0)-L.jpg" }
    
        return BookItem(
            rating: doc.ratingsAverage,
            sourceUrl: URL(string: "\(baseURL)\(doc.key)")!,
            coverUrl: URL(string: coverUrl ?? ""),
            title: doc.title,
            year: doc.firstPublishYear
        )
    }
    
    private func extractYear(from dateString: String?) -> Int? {
        guard let dateString = dateString else { return nil }
        
        // Try to extract 4-digit year
        let yearPattern = #"(\d{4})"#
        guard let regex = try? NSRegularExpression(pattern: yearPattern),
              let match = regex.firstMatch(in: dateString, range: NSRange(dateString.startIndex..., in: dateString)) else {
            return nil
        }
        
        let yearString = (dateString as NSString).substring(with: match.range(at: 1))
        return Int(yearString)
    }
    
    // MARK: - Search with Full Details
    
    func searchBooksWithDetails(query: String, limit: Int = 10) async throws -> [BookItem] {
        let books = try await searchBooks(query: query, limit: limit)
        
        var detailedBooks: [BookItem] = []
        
        for book in books {
            // Extract work key from source URL
            if let workKey = book.sourceUrl.absoluteString.components(separatedBy: "/works/").last {
                if let detailedBook = try? await getBookDetails(workKey: workKey) {
                    // Merge search data with detailed data
                    
                    let mergedBook = BookItem(
                        description: detailedBook.itemDescription,
                        rating: book.rating,
                        sourceUrl: book.sourceUrl,
                        coverUrl: detailedBook.coverUrl ?? book.coverUrl,
                        title: detailedBook.title,
                        year: detailedBook.year ?? book.year
                    )
                    detailedBooks.append(mergedBook)
                } else {
                    detailedBooks.append(book)
                }
            } else {
                detailedBooks.append(book)
            }
        }
        
        return detailedBooks
    }
}

// MARK: - Error Handling

enum OLError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case rateLimitExceeded
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
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please wait before making more requests."
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
