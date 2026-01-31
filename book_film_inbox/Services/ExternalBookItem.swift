//
//  ExternalBookItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 05.12.2025.
//

import Foundation

struct ExternalBookItem: ExternalMediaItem {
    
    var id: UUID = UUID()
    var itemDescription: String? = nil
    var isFavorite: Bool = false
    var rating: Double? = nil
    var sourceUrl: URL
    var coverUrl: URL? = nil
    var status: MediaStatus = MediaStatus.planned
    var title: String
    var isbn: String? = nil
    var author: String? = nil
    var year: Int? = nil
    var sourceName: String

    public init(
        title: String,
        sourceUrl: URL,
        sourceName: String,
    ) {
        self.title = title
        self.sourceUrl = sourceUrl
        self.sourceName = sourceName
    }
    
    public init(
        title: String,
        sourceUrl: URL,
        sourceName: String,
        description: String? = nil,
        rating: Double? = nil,
        coverUrl: URL? = nil,
        status: MediaStatus = .planned,
        isbn: String? = nil,
        author: String? = nil,
        year: Int? = nil,
    ) {
        self.title = title
        self.itemDescription = description
        self.rating = rating
        self.sourceUrl = sourceUrl
        self.coverUrl = coverUrl
        self.status = status
        self.year = year
        self.isbn = isbn
        self.author = author
        self.sourceName = sourceName
    }
    
}


