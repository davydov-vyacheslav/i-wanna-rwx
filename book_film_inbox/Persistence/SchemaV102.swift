//
//  SchemaV2.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 04.12.2025.
//

import SwiftData
import Foundation

enum SchemaV102: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 2)
    static var models: [any PersistentModel.Type] {
        [BookItem.self]
    }
    
    @Model class BookItem {
        
        var id: UUID
        var itemDescription: String?
        var isFavourite: Bool = false
        var rating: Double = 0.0
        var sourceUrl: URL
        @Attribute(.externalStorage) var coverImageData: Data?
        var status: String = MediaStatus.PLANNED.rawValue
        var title: String
        var year: Int?
        var isbn: String?
        var mainAuthor: String?
        var sourceName: String
        
        public init(
            id: UUID? = UUID(),
            description: String? = nil,
            isFavourite: Bool? = false,
            rating: Double? = 0.0,
            sourceUrl: URL,
            coverImageData: Data? = nil,
            status: String = "PLANNED",
            title: String,
            year: Int?,
            isbn: String?,
            author: String?,
            sourceName: String
        ) {
            self.id = id!
            self.title = title
            self.itemDescription = description
            self.isFavourite = isFavourite!
            self.rating = rating ?? 0.0
            self.sourceUrl = sourceUrl
            self.coverImageData = coverImageData
            self.status = status
            self.title = title
            self.year = year
            self.isbn = isbn
            self.mainAuthor = author
            self.sourceName = sourceName
        }
        
    }
}
