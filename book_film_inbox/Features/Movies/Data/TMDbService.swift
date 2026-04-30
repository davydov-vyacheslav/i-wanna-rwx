//
//  TMDbService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

import TMDb
import Foundation

class TMDbService: MovieSearchService {
    
    static var serviceName: String = "TMDb"
    static var requiresToken: Bool = true
    static var tokenPlaceholder: String? = String(localized: ".placeholder.services.tmdb_token")
    static var helpURL: String? = "https://developer.themoviedb.org/docs/faq"

    private var tmdbClient: TMDbClient
    private var cachedImagesConfig: ImagesConfiguration?
    
    init() {
        let currentToken = SettingsService.shared.getToken(for: TMDbService.serviceName)
        tmdbClient = TMDbClient(apiKey: currentToken ?? "")
    }
    
    func isTokenValid(token: String?) async -> Bool {
        do {
            let client = token.map { TMDbClient(apiKey: $0) } ?? tmdbClient
            return try await client.authentication.validateKey()
        } catch {
            return false
        }
    }
    
    func search(query: String, limit: Int) async throws -> [ExternalMovieItem] {

        // Search across movies, TV shows, and people
        async let searchResults = tmdbClient.search.searchAll(query: query)
        async let imagesConfig = imagesConfig()
        let (results, config) = try await (searchResults, imagesConfig)
        
        let movies: [ExternalMovieItem] = results.results.compactMap { result in
            switch result {
            case .movie(let movie):
                return toExternalMovieItem(movie: movie, imagesConfiguration: config)
            case .tvSeries(let tvSeries):
                return toExternalMovieItem(tvSeries: tvSeries, imagesConfiguration: config)
            default:
                return nil
            }
        }
        
        return Array(movies.prefix(limit))
    }
    
    func getDetails(item: ExternalMovieItem) async throws -> ExternalMovieItem {
        guard let sourceRaw = item.sourceId else { return item }
        guard let sourceId = Int(sourceRaw) else { return item }

        var creator : String? = nil
        var tvSeriesStatus: TvSeriesStatus? = nil
        var tvFetchedSeasons: Int? = nil
        switch item.type {
        case .movie:
            let credits = try? await tmdbClient.movies.credits(forMovie: sourceId)
            creator = credits?.crew.first(where: { $0.job == "Director" })?.name
        case .tvSeries:
            let credits = try? await tmdbClient.tvSeries.credits(forTVSeries: sourceId)
            creator = credits?.crew.first(where: {
                $0.job == "Executive Producer" || $0.job == "Director" || $0.department == "Production"
            })?.name
            let show = try await tmdbClient.tvSeries.details(forTVSeries: sourceId)
            if show.status == "Ended" || show.status == "Canceled" {
                tvSeriesStatus = .ended
            } else if show.status != nil {
                tvSeriesStatus = .ongoing
            }
            tvFetchedSeasons = show.numberOfSeasons
        }
        
        return ExternalMovieItem(
            id: item.id,
            title: item.title,
            sourceName: item.sourceName,
            description: item.itemDescription,
            rating: item.rating,
            coverUrl: item.coverUrl,
            status: item.status,
            author: creator,
            year: item.year,
            type: item.type,
            sourceId: item.sourceId,
            originalTitle: item.originalTitle,
            tvSeriesStatus: tvSeriesStatus,
            tvNumberOfSeasons: tvFetchedSeasons,
        )
        
    }
    
    private func toExternalMovieItem(movie: MovieListItem, imagesConfiguration: ImagesConfiguration) -> ExternalMovieItem {
        let coverUrl = movie.posterPath.map { imagesConfiguration.posterURL(for: $0, idealWidth: 250) } ?? nil
        let releaseYear = movie.releaseDate.map { CommonConstants.calendar.component(.year, from: $0) } ?? nil
        
        return ExternalMovieItem(
            title: movie.title,
            sourceName: TMDbService.serviceName,
            description: movie.overview,
            rating: movie.voteAverage,
            coverUrl: coverUrl,
            status: .planned,
            author: nil,
            year: releaseYear,
            type: .movie,
            sourceId: String(movie.id),
            originalTitle: movie.originalTitle
        )
    }
    
    private func toExternalMovieItem(tvSeries: TVSeriesListItem, imagesConfiguration: ImagesConfiguration) -> ExternalMovieItem {
        let coverUrl = tvSeries.posterPath.map { imagesConfiguration.posterURL(for: $0, idealWidth: 250) } ?? nil
        let releaseYear = tvSeries.firstAirDate.map { CommonConstants.calendar.component(.year, from: $0) } ?? nil

        return ExternalMovieItem(
            title: tvSeries.name,
            sourceName: TMDbService.serviceName,
            description: tvSeries.overview,
            rating: tvSeries.voteAverage,
            coverUrl: coverUrl,
            status: .planned,
            author: nil,
            year: releaseYear,
            type: .tvSeries,
            sourceId: String(tvSeries.id),
            originalTitle: tvSeries.originalName
        )

    }
    
    private func imagesConfig() async throws -> ImagesConfiguration {
        if let cached = cachedImagesConfig { return cached }
        let config = try await tmdbClient.configurations.apiConfiguration().images
        cachedImagesConfig = config
        return config
    }
    
    func getSourceUrl(item: any CommonMediaItem) throws -> URL {
        guard let id = item.sourceId else { throw OLError.invalidURL }
        guard let movie = item as? MovieItem else {
            throw OLError.invalidURL
        }
        
        switch MediaItemHelper.getVideoType(from: movie) {
        case .movie:
            guard let url = URL(string: "https://www.themoviedb.org/movie/\(id)") else {
                throw OLError.invalidURL
            }
            return url
        case .tvSeries:
            guard let url = URL(string: "https://www.themoviedb.org/tv/\(id)") else {
                throw OLError.invalidURL
            }
            return url
        }
    }

}
