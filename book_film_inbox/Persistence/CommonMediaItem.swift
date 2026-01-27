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
    var status: String { get set }
    var coverImageData: Data? { get }
    var year: Int? { get }
    var isFavourite: Bool { get set }

}

extension CommonMediaItem {

    var mediaStatus: MediaStatus {
        get { MediaStatus(rawValue: status) ?? .PLANNED }
        set { status = newValue.rawValue }
    }

    func isDraft() -> Bool {
        return sourceName == CommonConstants.DraftSourceType
    }
}

