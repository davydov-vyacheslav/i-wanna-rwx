//
//  DraftMovieService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 31.01.2026.
//

import Foundation

class DraftMovieService: SearchService {
    
    static let shared = DraftMovieService()
    typealias SearchResultItem = ExternalMovieItem
    
    static var serviceName: String = "Draft"
    static var requiresToken: Bool = false
    static var tokenPlaceholder: String? = nil
    static var helpURL: String? = nil

    private init() {

    }
    
    func search(query: String, limit: Int) async throws -> [ExternalMovieItem] {
        return [ single(query: query) ]
    }
    
    func getDetails(item: ExternalMovieItem) async throws -> ExternalMovieItem {
        return item
    }
    
    func single(query: String) -> ExternalMovieItem {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return ExternalMovieItem(
            title: query,
            sourceUrl: URL(string: "https://google.com/search?q=\(encoded)")!,
            sourceName: DraftMovieService.serviceName
        )
    }
    
    func isDraft(item: CommonMediaItem) -> Bool {
        return item.sourceName == DraftMovieService.serviceName
    }

}
