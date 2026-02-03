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

extension SearchService {
    func isTokenValid(token: String) async -> Bool {
        return true
    }
}
