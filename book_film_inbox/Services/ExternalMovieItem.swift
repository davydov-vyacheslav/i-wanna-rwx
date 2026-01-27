//
//  ExternalMovieItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 05.12.2025.
//


import Foundation
import SwiftData


struct ExternalMovieItem: ExternalMediaItem {
    
    var id: UUID = UUID()
    var itemDescription: String?
    var isFavourite: Bool = false
    var rating: String?
    var sourceUrl: URL
    var coverUrl: URL?
    var coverImageData: Data?
    var status: MediaStatus = MediaStatus.PLANNED
    var title: String
    var author: String?
    var year: Int?
    var type: VideoType
    var sourceId: Int?
    var originalTitle: String?
    var sourceName: String

    public init(
        title: String,
        sourceUrl: URL,
        sourceName: String,
        description: String? = nil,
        rating: String? = nil,
        coverUrl: URL? = nil,
        coverImageData: Data? = nil,
        status: MediaStatus = .PLANNED,
        author: String? = nil,
        year: Int? = nil,
        type: VideoType = .MOVIE,
        sourceId: Int? = nil,
        originalTitle: String? = nil,
    ) {
        self.title = title
        self.itemDescription = description
        self.rating = rating
        self.sourceUrl = sourceUrl
        self.coverUrl = coverUrl
        self.coverImageData = coverImageData
        self.status = status
        self.year = year
        self.author = author
        self.sourceName = sourceName
        self.type = type
        self.sourceId = sourceId
        self.originalTitle = originalTitle
    }
    
    static func draft(searchText: String) -> ExternalMovieItem {
        ExternalMovieItem(
            title: searchText,
            sourceUrl: URL(string: "https://google.com/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!,
            sourceName: CommonConstants.DraftSourceType,
        )
    }
    
    func isDraft() -> Bool {
        return sourceName == CommonConstants.DraftSourceType
    }
    
}


