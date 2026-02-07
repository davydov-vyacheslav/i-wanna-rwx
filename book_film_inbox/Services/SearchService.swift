//
//  SearchService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

protocol SearchService<SearchResultItem> {
    associatedtype SearchResultItem: ExternalMediaItem
    
    func isTokenValid(token: String) async -> Bool
    func search(query: String, limit: Int) async throws -> [SearchResultItem]
    func getDetails(item: SearchResultItem) async throws -> SearchResultItem

    static var serviceName: String { get }
    static var requiresToken: Bool { get }
    
    static var tokenPlaceholder: String? { get }
    static var helpURL: String? { get }

}

protocol MovieSearchService: SearchService where SearchResultItem == ExternalMovieItem {
    func search(query: String, limit: Int) async throws -> [ExternalMovieItem]
    func getDetails(item: ExternalMovieItem) async throws -> ExternalMovieItem
}

protocol BookSearchService: SearchService where SearchResultItem == ExternalBookItem {
    func search(query: String, limit: Int) async throws -> [ExternalBookItem]
    func getDetails(item: ExternalBookItem) async throws -> ExternalBookItem
}


extension SearchService {
    func isTokenValid(token: String) async -> Bool {
        return true
    }
}
