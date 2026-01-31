//
//  ExternalBookItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 05.12.2025.
//

import Foundation
import SwiftData


struct ExternalBookItem: ExternalMediaItem {
    
    var id: UUID = UUID()
    var itemDescription: String?
    var isFavorite: Bool = false
    var rating: Double = 0.0
    var sourceUrl: URL
    var coverUrl: URL?
    var coverImageData: Data?
    var status: MediaStatus = MediaStatus.planned
    var title: String
    var isbn: String?
    var author: String?
    var year: Int?
    var sourceName: String

    public init(
        title: String,
        sourceUrl: URL,
        sourceName: String,
        description: String? = nil,
        rating: Double? = 0.0,
        coverUrl: URL? = nil,
        coverImageData: Data? = nil,
        status: MediaStatus = .planned,
        isbn: String? = nil,
        author: String? = nil,
        year: Int? = nil,
    ) {
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
            title: searchText,
            sourceUrl: URL(string: "https://google.com/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!,
            sourceName: CommonConstants.draftSourceType,
        )
    }
    
    func isDraft() -> Bool {
        return sourceName == CommonConstants.draftSourceType
    }
    
}


