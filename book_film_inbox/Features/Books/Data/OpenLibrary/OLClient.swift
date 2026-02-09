//
//  OpenLibraryKit.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 07.02.2026.
//

import Foundation

class OpenLibraryClient {
    
    let baseURL = "https://openlibrary.org"
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
    }
    
    func search(query: String, limit: Int) async throws -> OLSearchResponse {
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
        
        return try JSONDecoder().decode(OLSearchResponse.self, from: data)
        
    }
    
    // MARK: - Get Book Details

    func getBookDetails(workKey: String) async throws -> OLWorkDetail? {
        
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
        
        return try JSONDecoder().decode(OLWorkDetail.self, from: data)
        
    }
    
    func getCoverUrl(_ id: Int) throws -> URL {
        guard let url = URL(string: "https://covers.openlibrary.org/b/id/\(id)-L.jpg") else {
            throw OLError.invalidURL
        }
        return url
    }
    
}
