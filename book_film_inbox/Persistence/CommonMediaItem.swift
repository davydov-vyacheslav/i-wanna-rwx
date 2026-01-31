//
//  CommonMediaItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import Foundation

protocol CommonMediaItem {
    
    var itemDescription: String? { get }
    var title: String { get }
    var sourceUrl: URL { get }
    var sourceName: String { get }
    var statusRaw: String { get set }
    var coverImageUrl: URL? { get }
    var year: Int? { get }
    var isFavorite: Bool { get set }
    var rating: Double { get set }

}

extension CommonMediaItem {

    var status: MediaStatus {
        get { MediaStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
    }

    func isDraft() -> Bool {
        return sourceName == CommonConstants.draftSourceType
    }
    
    var ratingText : String {
        rating == 0 ? "N/A" : String(format: "%.1f", rating)
    }

}

