//
//  CommonMediaItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import Foundation
import SwiftData

protocol CommonMediaItem: PersistentModel {
    
    var itemDescription: String? { get }
    var title: String { get }
    var sourceUrl: URL { get }
    var sourceName: String { get }
    var statusRaw: String { get set }
    var coverImageUrl: URL? { get }
    var year: Int? { get }
    var isFavorite: Bool { get set }
    var rating: Double { get set }
    var mainAuthor: String? { get set }

}

struct MediaItemHelper {
    static func getStatus(from item: any CommonMediaItem) -> MediaStatus {
        MediaStatus(rawValue: item.statusRaw) ?? .planned
    }

    static func getRatingText(from item: any CommonMediaItem) -> String {
        item.rating == 0 ? "N/A" : String(format: "%.1f", item.rating)
    }
    
    static func getVideoType(from item: MovieItem) -> VideoType {
        VideoType(rawValue: item.typeRaw) ?? .movie
    }

}
