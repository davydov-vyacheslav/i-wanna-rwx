//
//  ExternalMovieItem.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 05.12.2025.
//


import Foundation

struct ExternalMovieItem: ExternalMediaItem {
    typealias MediaItem = MovieItem
    
    var id: UUID = UUID()
    var itemDescription: String? = nil
    var isFavorite: Bool = false
    var rating: Double? = nil
    var coverUrl: URL? = nil
    var status: MediaStatus = MediaStatus.planned
    var title: String
    var author: String? = nil
    var year: Int? = nil
    var type: VideoType = .movie
    var sourceId: String? = nil
    var originalTitle: String? = nil
    var sourceName: String
    var tvSeriesStatus: TvSeriesStatus? = nil

    public init(
        id: UUID = UUID(),
        title: String,
        sourceName: String,
        description: String? = nil,
        rating: Double? = nil,
        coverUrl: URL? = nil,
        status: MediaStatus = .planned,
        author: String? = nil,
        year: Int? = nil,
        type: VideoType = .movie,
        sourceId: String? = nil,
        originalTitle: String? = nil,
        tvSeriesStatus: TvSeriesStatus? = nil
    ) {
        self.id = id
        self.title = title
        self.itemDescription = description
        self.rating = rating
        self.coverUrl = coverUrl
        self.status = status
        self.year = year
        self.author = author
        self.sourceName = sourceName
        self.type = type
        self.sourceId = sourceId
        self.originalTitle = originalTitle
        self.tvSeriesStatus = tvSeriesStatus
    }
   
    func toCommonMediaItem() -> MovieItem {
        return MovieItem(
            description: self.itemDescription,
            isFavorite: self.isFavorite,
            rating: self.rating ?? 0.0,
            coverImageUrl: self.coverUrl,
            status: .planned,
            title: self.title,
            year: self.year,
            author: self.author,
            sourceName: self.sourceName,
            type: self.type,
            sourceId: self.sourceId,
            originalTitle: self.originalTitle,
            tvSeriesStatus: self.tvSeriesStatus
        )
    }
   
    static func fromMovieItem(item: MovieItem) -> Self {
        return .init(id: item.id,
                     title: item.title,
                     sourceName: item.sourceName,
                     description: item.itemDescription,
                     rating: item.rating,
                     coverUrl: item.coverImageUrl,
                     status: MediaItemHelper.getStatus(from: item),
                     author: item.mainAuthor,
                     year: item.year,
                     type: MediaItemHelper.getVideoType(from: item),
                     sourceId: item.sourceId,
                     originalTitle: item.originalTitle,
                     tvSeriesStatus: MediaItemHelper.getTvSeriesStatus(from: item))
            
            
    }
    
}


