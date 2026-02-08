//
//  MovieSchemaV100.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import SwiftData
import Foundation

enum MovieSchemaV100: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [MovieItem.self]
    }
    
    @Model class MovieItem: CommonMediaItem {
        
        @Attribute(.unique) var id: UUID = UUID()
        var itemDescription: String?
        var isFavorite: Bool = false
        var rating: Double
        var coverImageUrl: URL?
        var statusRaw: String = MediaStatus.planned.rawValue
        var title: String
        var mainAuthor: String?
        var year: Int?
        var sourceName: String
        var typeRaw: String = VideoType.movie.rawValue
        var sourceId: String?
        var originalTitle: String?
        
        public init(
            description: String? = nil,
            isFavorite: Bool? = false,
            rating: Double,
            coverImageUrl: URL? = nil,
            status: MediaStatus = .planned,
            title: String,
            year: Int? = nil,
            author: String?,
            sourceName: String,
            type: VideoType,
            sourceId: String?,
            originalTitle: String?
        ) {
            self.title = title
            self.itemDescription = description
            self.isFavorite = isFavorite ?? false
            self.rating = rating
            self.coverImageUrl = coverImageUrl
            self.statusRaw = status.rawValue
            self.year = year
            self.mainAuthor = author
            self.sourceName = sourceName
            self.typeRaw = type.rawValue
            self.originalTitle = originalTitle
            self.sourceId = sourceId
        }
     
    }
}
