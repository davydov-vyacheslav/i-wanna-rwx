//
//  ExternalMediaItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 26.01.2026.
//

import Foundation

protocol ExternalMediaItem: Identifiable {
    
    // mostly for draft item creation
    init(title: String, sourceUrl: URL, sourceName: String)
    func isDraft() -> Bool

    var itemDescription: String? { get }
    var title: String { get }
    var sourceUrl: URL { get }
    var sourceName: String { get }
    var status: MediaStatus { get }
    var coverUrl: URL? { get }
    var year: Int? { get }
    var rating: Double? { get }
  
}

extension ExternalMediaItem {
    func isDraft() -> Bool {
        sourceName == CommonConstants.draftSourceType
    }
    
    var ratingText : String {
        rating.map { String(format: "%.1f", $0) } ?? "N/A"
    }
    
    static func draft(searchText: String) -> Self {
        let encoded = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        return Self(
            title: searchText,
            sourceUrl: URL(string: "https://google.com/search?q=\(encoded)")!,
            sourceName: CommonConstants.draftSourceType
        )
    }

}
