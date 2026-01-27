//
//  BookItem.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//
//

import Foundation
import SwiftData

@Model class BookItem: Identifiable {
    
    var id: UUID = UUID()
    var itemDescription: String?
    var isFavourite: Bool = false
    var rating: Double = 0.0
    var sourceUrl: URL
    @Attribute(.externalStorage) var coverImageData: Data?
    var status: String = MediaStatus.PLANNED.rawValue
    var title: String
    var mainAuthor: String?
    var isbn: String?
    var year: Int?
    var sourceName: String
    
    public init(
        description: String? = nil,
        isFavourite: Bool? = false,
        rating: Double? = 0.0,
        sourceUrl: URL,
        coverImageData: Data? = nil,
        status: MediaStatus = .PLANNED,
        title: String,
        year: Int? = nil,
        isbn: String?,
        author: String?,
        sourceName: String
    ) {
        self.id = UUID()
        self.title = title
        self.itemDescription = description
        self.isFavourite = isFavourite!
        self.rating = rating ?? 0.0
        self.sourceUrl = sourceUrl
        self.coverImageData = coverImageData
        self.status = status.rawValue
        self.title = title
        self.year = year
        self.isbn = isbn
        self.mainAuthor = author
        self.sourceName = sourceName
    }
    
}

extension BookItem {

    var mediaStatus: MediaStatus {
        get { MediaStatus(rawValue: status) ?? .PLANNED }
        set { status = newValue.rawValue }
    }

    func isDraft() -> Bool {
        return sourceName == CommonConstants.DraftSourceType
    }
}


