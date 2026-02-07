//
//  OpenLibraryService.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation

class OpenLibraryService: BookSearchService {
    
    static var serviceName: String = "Open Library"
    static var requiresToken: Bool = false
    static var tokenPlaceholder: String? = nil
    static var helpURL: String? = nil

    let client: OpenLibraryClient
    
    init() {
        client = OpenLibraryClient()
    }
    
    // MARK: - Search Books
    
    func search(query: String, limit: Int) async throws -> [ExternalBookItem] {
        let searchResponse = try await client.search(query: query, limit: limit)
        return try searchResponse.docs.map { doc in
            try convertToBook(from: doc)
        }
    }
    
    // MARK: - Get Book Details

    func getDetails(item: ExternalBookItem) async throws -> ExternalBookItem {
        // Extract work key from source URL
        if let workKey = item.sourceUrl.absoluteString.components(separatedBy: "/works/").last {
            if let detailedBook = try? await getBookDetails(workKey: workKey) {
                // Merge search data with detailed data
                
                let mergedBook = ExternalBookItem(
                    title: item.title,
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
        
    private func getBookDetails(workKey: String) async throws -> DetailedBookInfo? {
        
        let workDetailResponse = try await client.getBookDetails(workKey: workKey)
        
        guard let workDetail = workDetailResponse else { return nil }
        
        let year = extractYear(from: workDetail.firstPublishDate)
        
        return DetailedBookInfo(
                itemDescription: workDetail.description?.value,
                coverUrl: try workDetail.covers?.first.flatMap { try client.getCoverUrl($0) },
                year: year
            )
    }
    
    
    // MARK: - Helper Methods
    
    private func convertToBook(from doc: OLSearchDoc) throws -> ExternalBookItem {
        
        return ExternalBookItem(
            title: doc.title,
            sourceUrl: URL(string: "\(client.baseURL)\(doc.key)")!,
            sourceName: OpenLibraryService.serviceName,
            rating: doc.ratingsAverage,
            coverUrl: try doc.coverI.flatMap { try client.getCoverUrl($0) },
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

    
    private struct DetailedBookInfo {
        let itemDescription: String?
        let coverUrl: URL?
        let year: Int?
    }

}

