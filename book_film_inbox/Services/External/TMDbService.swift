//
//  TMDbService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

import TMDb
import Foundation

class TMDbService: SearchService {
    
    typealias SearchResultItem = ExternalMovieItem
    
    static var serviceName: String = "TMDb"
    static var requiresToken: Bool = true
    static var tokenPlaceholder: String? = "Enter API Key"
    static var helpURL: String? = "https://www.themoviedb.org/settings/api"

    private var tmdbClient: TMDbClient
    private var cachedImagesConfig: ImagesConfiguration?
    
    init() {
        let currentToken = SettingsService.shared.getToken(for: TMDbService.serviceName)
        tmdbClient = TMDbClient(apiKey: currentToken ?? "foo token")
    }
    
    func search(query: String, limit: Int) async throws -> [ExternalMovieItem] {

        // Search across movies, TV shows, and people
        let searchResults = try await tmdbClient.search.searchAll(query: query)
        let imagesConfig = try await imagesConfig()
        
        let movies: [ExternalMovieItem] = searchResults.results.compactMap { result in
            switch result {
            case .movie(let movie):
                return toExternalMovieItem(movie: movie, imagesConfiguration: imagesConfig)
            case .tvSeries(let tvSeries):
                return toExternalMovieItem(tvSeries: tvSeries, imagesConfiguration: imagesConfig)
            default:
                return nil
            }
        }
        
        return Array(movies.prefix(limit))
    }
    
    func getDetails(item: ExternalMovieItem) async throws -> ExternalMovieItem {
        guard let sourceId = item.sourceId else { return item }

        var creator : String? = nil
        switch item.type {
        case .movie:
            let credits = try? await tmdbClient.movies.credits(forMovie: sourceId)
            creator = credits?.crew.first(where: { $0.job == "Director" })?.name
        case .tvSeries:
            let credits = try? await tmdbClient.tvSeries.credits(forTVSeries: sourceId)
            creator = credits?.crew.first(where: {
                $0.job == "Executive Producer" || $0.job == "Director" || $0.department == "Production"
            })?.name
        }
        
        return ExternalMovieItem(
            id: item.id,
            title: item.title,
            sourceUrl: item.sourceUrl,
            sourceName: item.sourceName,
            description: item.itemDescription,
            rating: item.rating,
            coverUrl: item.coverUrl,
            status: item.status,
            author: creator,
            year: item.year,
            type: item.type,
            sourceId: item.sourceId,
            originalTitle: item.originalTitle
        )
        
    }
    
    private func toExternalMovieItem(movie: MovieListItem, imagesConfiguration: ImagesConfiguration) -> ExternalMovieItem {
        let coverUrl = movie.posterPath.map { imagesConfiguration.posterURL(for: $0, idealWidth: 250) } ?? nil
        let releaseYear = movie.releaseDate.map { Calendar.current.component(.year, from: $0) } ?? nil
        
        return ExternalMovieItem(
            title: movie.title,
            sourceUrl: URL(string: "https://www.themoviedb.org/movie/\(movie.id)")!,
            sourceName: TMDbService.serviceName,
            description: movie.overview,
            rating: movie.voteAverage,
            coverUrl: coverUrl,
            status: .planned,
            author: nil,
            year: releaseYear,
            type: .movie,
            sourceId: movie.id,
            originalTitle: movie.originalTitle
        )
    }
    
    private func toExternalMovieItem(tvSeries: TVSeriesListItem, imagesConfiguration: ImagesConfiguration) -> ExternalMovieItem {
        let coverUrl = tvSeries.posterPath.map { imagesConfiguration.posterURL(for: $0, idealWidth: 250) } ?? nil
        let releaseYear = tvSeries.firstAirDate.map { Calendar.current.component(.year, from: $0) } ?? nil

        return ExternalMovieItem(
            title: tvSeries.name,
            sourceUrl: URL(string: "https://www.themoviedb.org/tv/\(tvSeries.id)")!,
            sourceName: TMDbService.serviceName,
            description: tvSeries.overview,
            rating: tvSeries.voteAverage,
            coverUrl: coverUrl,
            status: .planned,
            author: nil,
            year: releaseYear,
            type: .tvSeries,
            sourceId: tvSeries.id,
            originalTitle: tvSeries.originalName
        )

    }
    
    private func imagesConfig() async throws -> ImagesConfiguration {
        if let cached = cachedImagesConfig { return cached }
        let config = try await tmdbClient.configurations.apiConfiguration().images
        cachedImagesConfig = config
        return config
    }
}
