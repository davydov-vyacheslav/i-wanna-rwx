//
//  DraftBookService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 31.01.2026.
//

import Foundation

class DraftBookService: BookSearchService {
    
    static let shared = DraftBookService()
    
    static var serviceName: String = "Draft"
    static var requiresToken: Bool = false
    static var tokenPlaceholder: String? = nil
    static var helpURL: String? = nil

    private init() {

    }
    
    func search(query: String, limit: Int) async throws -> [ExternalBookItem] {
        return [ single(query: query) ]
    }
    
    func getDetails(item: ExternalBookItem) async throws -> ExternalBookItem {
        return item
    }
    
    func single(query: String) -> ExternalBookItem {
        return ExternalBookItem(
            title: query,
            sourceId: nil,
            sourceName: DraftBookService.serviceName
        )
    }
    
    func isDraft(item: any CommonMediaItem) -> Bool {
        return item.sourceName == DraftBookService.serviceName
    }

    func getSourceUrl(item: any CommonMediaItem) throws -> URL {
        let encoded = item.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://google.com/search?q=\(encoded)") else {
            throw OLError.invalidURL
        }
        return url
    }
    
}
