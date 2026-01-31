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
        
        var id: UUID = UUID()
        var itemDescription: String?
        var isFavorite: Bool = false
        var rating: String
        var sourceUrl: URL
        @Attribute(.externalStorage) var coverImageData: Data?
        var status: String = MediaStatus.planned.rawValue
        var title: String
        var mainAuthor: String?
        var year: Int?
        var sourceName: String
        var type: String = VideoType.MOVIE.rawValue
        var sourceId: Int?
        var originalTitle: String?
        
        public init(
            description: String? = nil,
            isFavorite: Bool? = false,
            rating: String,
            sourceUrl: URL,
            coverImageData: Data? = nil,
            status: MediaStatus = .planned,
            title: String,
            year: Int? = nil,
            author: String?,
            sourceName: String,
            type: VideoType,
            sourceId: Int?,
            originalTitle: String?
        ) {
            self.title = title
            self.itemDescription = description
            self.isFavorite = isFavorite ?? false
            self.rating = rating
            self.sourceUrl = sourceUrl
            self.coverImageData = coverImageData
            self.status = status.rawValue
            self.year = year
            self.mainAuthor = author
            self.sourceName = sourceName
            self.type = type.rawValue
            self.originalTitle = originalTitle
        }
        
    }
}
