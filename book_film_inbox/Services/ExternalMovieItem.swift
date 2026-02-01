//
//  ExternalMovieItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 05.12.2025.
//


import Foundation

struct ExternalMovieItem: ExternalMediaItem {
    
    var id: UUID = UUID()
    var itemDescription: String? = nil
    var isFavorite: Bool = false
    var rating: Double? = nil
    var sourceUrl: URL
    var coverUrl: URL? = nil
    var status: MediaStatus = MediaStatus.planned
    var title: String
    var author: String? = nil
    var year: Int? = nil
    var type: VideoType = .movie
    var sourceId: Int? = nil
    var originalTitle: String? = nil
    var sourceName: String

    public init(
        id: UUID = UUID(),
        title: String,
        sourceUrl: URL,
        sourceName: String,
        description: String? = nil,
        rating: Double? = nil,
        coverUrl: URL? = nil,
        status: MediaStatus = .planned,
        author: String? = nil,
        year: Int? = nil,
        type: VideoType = .movie,
        sourceId: Int? = nil,
        originalTitle: String? = nil,
    ) {
        self.id = id
        self.title = title
        self.itemDescription = description
        self.rating = rating
        self.sourceUrl = sourceUrl
        self.coverUrl = coverUrl
        self.status = status
        self.year = year
        self.author = author
        self.sourceName = sourceName
        self.type = type
        self.sourceId = sourceId
        self.originalTitle = originalTitle
    }
    
   
}


