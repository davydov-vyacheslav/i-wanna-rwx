//
//  VideoType.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import Foundation

enum VideoType: String, CaseIterable {
    case movie = "movie"
    case tvSeries = "tv"
}

enum TvSeriesStatus: String, CaseIterable {
    case ongoing = "ongoing"
    case ended = "ended"
    
    var displayName: String {
        switch self {
        case .ongoing: return String(localized: ".type.movies.tv.status.ongoing")
        case .ended: return String(localized: ".type.movies.tv.status.ended")
        }
    }
}
