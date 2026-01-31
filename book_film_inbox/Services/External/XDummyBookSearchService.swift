//
//  XDummyBookSearchService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import Foundation

// Dummy Service to search the books
class XDummyBookSearchService: SearchService {
    
    typealias SearchResultItem = ExternalBookItem
    
    static var serviceName: String = "Dummy Book Library"
    static var requiresToken: Bool = true
    static var tokenPlaceholder: String? = "Dummy token info placeholder"
    static var helpURL: String? = "https://dummy.url"

    var currentToken: String?
    var settingsService = SettingsService.shared
    
    init() {
        currentToken = settingsService.getToken(for: XDummyBookSearchService.serviceName)
    }
    
    func search(query: String, limit: Int) async throws -> [ExternalBookItem] {
        // network latency emulation
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec

        let randomCount = Int.random(in: 0...3)
        return (0..<randomCount).map { index in
            ExternalBookItem(
                title: "\(query) - Book \(index + 1)",
                sourceUrl: URL(string: "https://example.com/book/\(UUID().uuidString)")!,
                sourceName: XDummyBookSearchService.serviceName,
                description: "A fascinating book about \(query). This is result #\(index + 1).",
                rating: Double.random(in: 3.0...5.0),
                coverUrl: URL(string: "https://picsum.photos/200/300?random=\(index)"),
                status: MediaStatus.planned,
                isbn: String(format: "978%010d", Int.random(in: 1000000000...9999999999)),
                author: ["John Doe", "Jane Smith", "Bob Johnson", "Alice Williams"].randomElement()!,
                year: Int.random(in: 1990...2024),
            )
        }
    }
    
    func getDetails(item: ExternalBookItem) async throws -> ExternalBookItem {
        return item
    }
    
}
