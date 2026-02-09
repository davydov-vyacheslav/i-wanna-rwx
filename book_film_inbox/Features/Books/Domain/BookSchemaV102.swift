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
        @Attribute(.spotlight) var isFavorite: Bool = false
        var rating: Double = 0.0
        var coverImageUrl: URL?
        @Attribute(.spotlight) var statusRaw: String
        @Attribute(.spotlight) var title: String
        var mainAuthor: String?
        @Attribute(.spotlight) var isbn: String?
        var year: Int?
        @Attribute(.spotlight) var sourceName: String
        var sourceId: String?
        
        public init(
            id: UUID? = UUID(),
            itemDescription: String? = nil,
            isFavorite: Bool? = false,
            rating: Double? = 0.0,
            coverImageUrl: URL? = nil,
            status: MediaStatus = MediaStatus.planned,
            title: String,
            year: Int? = nil,
            isbn: String?,
            mainAuthor: String?,
            sourceName: String,
            sourceId: String?
        ) {
            self.id = id ?? UUID()
            self.title = title
            self.itemDescription = itemDescription
            self.isFavorite = isFavorite ?? false
            self.rating = rating ?? 0.0
            self.coverImageUrl = coverImageUrl
            self.statusRaw = status.rawValue
            self.year = year
            self.isbn = isbn
            self.mainAuthor = mainAuthor
            self.sourceName = sourceName
            self.sourceId = sourceId
        }
        
    }
}
