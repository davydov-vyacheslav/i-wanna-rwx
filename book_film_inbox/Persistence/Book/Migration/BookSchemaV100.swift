//
//  SchemaV1.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 04.12.2025.
//

import SwiftData
import Foundation

// MARK: - Schema V1 (Old)
enum BookSchemaV100: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [BookItem.self]
    }
    
    @Model
    class BookItem {
        @Attribute(.unique) var id: UUID
        var itemDescription: String?
        var isFavorite: Bool
        var rating: Double
        var sourceUrl: URL
        var coverUrl: URL?  // Will be removed
        var coverImageData: Data?
        var status: String  // Old values: PENDING, IN_PROGRESS, DONE
        var title: String
        var year: Int?
        var type: String  // Will be removed
        
        init(id: UUID = UUID(), itemDescription: String? = nil, isFavorite: Bool = false,
             rating: Double = 0.0, sourceUrl: URL, coverUrl: URL? = nil,
             coverImageData: Data? = nil, status: String = "PENDING",
             title: String, year: Int? = nil, type: String = "Book") {
            self.id = id
            self.itemDescription = itemDescription
            self.isFavorite = isFavorite
            self.rating = rating
            self.sourceUrl = sourceUrl
            self.coverUrl = coverUrl
            self.coverImageData = coverImageData
            self.status = status
            self.title = title
            self.year = year
            self.type = type
        }
    }
}

