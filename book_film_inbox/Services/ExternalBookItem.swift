//
//  ExternalBookItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 05.12.2025.
//

import Foundation

struct ExternalBookItem: ExternalMediaItem {
    typealias MediaItem = BookItem
    
    var id: UUID = UUID()
    var itemDescription: String? = nil
    var isFavorite: Bool = false
    var rating: Double? = nil
    var sourceId: String?
    var coverUrl: URL? = nil
    var status: MediaStatus = MediaStatus.planned
    var title: String
    var isbn: String? = nil
    var author: String? = nil
    var year: Int? = nil
    var sourceName: String

    public init(
        title: String,
        sourceId: String?,
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
        self.sourceId = sourceId
        self.coverUrl = coverUrl
        self.status = status
        self.year = year
        self.isbn = isbn
        self.author = author
        self.sourceName = sourceName
    }
    
    func toCommonMediaItem() -> BookItem {
        return BookItem(
            itemDescription: self.itemDescription,
            isFavorite: self.isFavorite,
            rating: self.rating,
            coverImageUrl: self.coverUrl,
            status: MediaStatus.planned,
            title: self.title,
            year: self.year,
            isbn: self.isbn,
            mainAuthor: self.author,
            sourceName: self.sourceName,
            sourceId: self.sourceId,
        )
    }

    
}


