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
    var coverUrl: URL?
    @Attribute(.externalStorage) var coverImageData: Data?
    var status: String = MediaStatus.PENDING.rawValue
    var title: String
    var year: Int?
    var type: String = "Book"
    
    public init(
        description: String? = nil,
        isFavourite: Bool? = false,
        rating: Double? = 0.0,
        sourceUrl: URL,
        coverUrl: URL? = nil,
        coverImageData: Data? = nil,
        status: MediaStatus = .PENDING,
        title: String,
        year: Int?
    ) {
        self.id = UUID()
        self.title = title
        self.itemDescription = description
        self.isFavourite = isFavourite!
        self.rating = rating ?? 0.0
        self.sourceUrl = sourceUrl
        self.coverUrl = coverUrl
        self.coverImageData = coverImageData
        self.status = status.rawValue
        self.title = title
        self.year = year
    }
    
}

extension BookItem {

    // TODO: icon = book.fill

    var mediaStatus: MediaStatus {
        get { MediaStatus(rawValue: status) ?? .PENDING }
        set { status = newValue.rawValue }
    }

}


