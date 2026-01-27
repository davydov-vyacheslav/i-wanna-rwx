//
//  ExternalBookItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 05.12.2025.
//

//
//  BookItem.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//
//

import Foundation
import SwiftData


struct ExternalBookItem: ExternalMediaItem {
    
    var id: UUID
    var itemDescription: String?
    var isFavourite: Bool = false
    var rating: Double = 0.0
    var sourceUrl: URL
    var coverUrl: URL?
    var coverImageData: Data?
    var status: MediaStatus = MediaStatus.PLANNED
    var title: String
    var isbn: String?
    var author: String?
    var year: Int?
    var sourceName: String

    public init(
        description: String? = nil,
        rating: Double? = 0.0,
        sourceUrl: URL,
        coverUrl: URL? = nil,
        coverImageData: Data? = nil,
        status: MediaStatus = .PLANNED,
        title: String,
        isbn: String?,
        author: String?,
        year: Int? = nil,
        sourceName: String
    ) {
        self.id = UUID()
        self.title = title
        self.itemDescription = description
        self.rating = rating ?? 0.0
        self.sourceUrl = sourceUrl
        self.coverUrl = coverUrl
        self.coverImageData = coverImageData
        self.status = status
        self.year = year
        self.isbn = isbn
        self.author = author
        self.sourceName = sourceName
    }
    
    static func draft(searchText: String) -> ExternalBookItem {
        ExternalBookItem(
            sourceUrl: URL(string: "https://google.com/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!,
            status: MediaStatus.PLANNED,
            title: searchText,
            isbn: "NoISBN",
            author: nil,
            sourceName: CommonConstants.DraftSourceType
        )
    }
    
    func isDraft() -> Bool {
        return sourceName == CommonConstants.DraftSourceType
    }
    
}


