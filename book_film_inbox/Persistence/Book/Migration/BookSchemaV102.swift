//
//  SchemaV2.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 04.12.2025.
//

import SwiftData
import Foundation

enum BookSchemaV102: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 2)
    static var models: [any PersistentModel.Type] {
        [BookItem.self]
    }
    
    @Model class BookItem: CommonMediaItem {
        
        @Attribute(.unique) var id: UUID
        var itemDescription: String?
        var isFavorite: Bool = false
        var rating: Double = 0.0
        var sourceUrl: URL
        var coverImageUrl: URL?
        var statusRaw: String
        var title: String
        var mainAuthor: String?
        var isbn: String?
        var year: Int?
        var sourceName: String
        
        public init(
            id: UUID? = UUID(),
            description: String? = nil,
            isFavorite: Bool? = false,
            rating: Double? = 0.0,
            sourceUrl: URL,
            coverImageUrl: URL? = nil,
            status: MediaStatus = MediaStatus.planned,
            title: String,
            year: Int? = nil,
            isbn: String?,
            author: String?,
            sourceName: String
        ) {
            self.id = id ?? UUID()
            self.title = title
            self.itemDescription = description
            self.isFavorite = isFavorite ?? false
            self.rating = rating ?? 0.0
            self.sourceUrl = sourceUrl
            self.coverImageUrl = coverImageUrl
            self.statusRaw = status.rawValue
            self.year = year
            self.isbn = isbn
            self.mainAuthor = author
            self.sourceName = sourceName
        }
        
    }
}
