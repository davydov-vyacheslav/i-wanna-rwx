//
//  BooksSearchService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

protocol SearchService<SearchResultItem> {
    associatedtype SearchResultItem: ExternalMediaItem
    func search(query: String, token: String?, limit: Int) async throws -> [SearchResultItem]

    var serviceName: String { get }
    var requiresToken: Bool { get }
    
    var tokenPlaceholder: String? { get }
    var helpURL: String? { get }

}
