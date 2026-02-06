//
//  DraftBookService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 31.01.2026.
//

import Foundation

class DraftBookService: SearchService {
    
    static let shared = DraftBookService()
    typealias SearchResultItem = ExternalBookItem
    
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
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return ExternalBookItem(
            title: query,
            sourceUrl: URL(string: "https://google.com/search?q=\(encoded)")!,
            sourceName: DraftBookService.serviceName
        )
    }
    
    func isDraft(item: any CommonMediaItem) -> Bool {
        return item.sourceName == DraftBookService.serviceName
    }

    
}
