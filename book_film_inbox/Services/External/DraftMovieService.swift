//
//  DraftMovieService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 31.01.2026.
//

import Foundation

class DraftMovieService: MovieSearchService {
    
    static let shared = DraftMovieService()
    
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
        return ExternalMovieItem(
            title: query,
            sourceName: DraftMovieService.serviceName,
            sourceId: nil
        )
    }
    
    func isDraft(item: any CommonMediaItem) -> Bool {
        return item.sourceName == DraftMovieService.serviceName
    }
    
    func getSourceUrl(item: any CommonMediaItem) throws -> URL {
        let encoded = item.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://google.com/search?q=\(encoded)") else {
            throw OLError.invalidURL
        }
        return url
    }

}
