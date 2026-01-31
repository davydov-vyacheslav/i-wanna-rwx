//
//  SchemaV2.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 04.12.2025.
//

import SwiftData
import Foundation

enum BookSchemaV101: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 1)
    static var models: [any PersistentModel.Type] {
        [BookItem.self]
    }
    
    @Model class BookItem {
        
        var id: UUID
        var itemDescription: String?
        var isFavorite: Bool = false
        var rating: Double = 0.0
        var sourceUrl: URL
        var coverUrl: URL?
        @Attribute(.externalStorage) var coverImageData: Data?
        var status: String = MediaStatus.planned.rawValue
        var title: String
        var year: Int?
        var type: String = "Book"
        
        public init(
            id: UUID? = UUID(),
            description: String? = nil,
            isFavorite: Bool? = false,
            rating: Double? = 0.0,
            sourceUrl: URL,
            coverUrl: URL? = nil,
            coverImageData: Data? = nil,
            status: MediaStatus = .planned,
            title: String,
            year: Int?
        ) {
            self.id = id ?? UUID()
            self.title = title
            self.itemDescription = description
            self.isFavorite = isFavorite ?? false
            self.rating = rating ?? 0.0
            self.sourceUrl = sourceUrl
            self.coverUrl = coverUrl
            self.coverImageData = coverImageData
            self.status = status.rawValue
            self.year = year
        }
        
    }
}
