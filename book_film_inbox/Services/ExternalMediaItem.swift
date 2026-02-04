//
//  ExternalMediaItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 26.01.2026.
//

import Foundation

protocol ExternalMediaItem: Identifiable {
    associatedtype MediaItem: CommonMediaItem
    
    var itemDescription: String? { get }
    var title: String { get }
    var sourceUrl: URL { get }
    var sourceName: String { get }
    var status: MediaStatus { get }
    var coverUrl: URL? { get }
    var year: Int? { get }
    var rating: Double? { get }
    
    func toCommonMediaItem() -> MediaItem
  
}

extension ExternalMediaItem {

    var ratingText : String {
        rating.map { String(format: "%.1f", $0) } ?? "N/A"
    }

}
