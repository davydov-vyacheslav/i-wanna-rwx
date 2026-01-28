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
    
    var serviceName: String = "TMDb"
    var requiresToken: Bool = true
    var tokenPlaceholder: String? = "Enter API Key"
    var helpURL: String? = "https://www.themoviedb.org/settings/api"

    var tmdbClient: TMDbClient
    
    init() {
        let currentToken = SettingsService.shared.getToken(for: serviceName)
        tmdbClient = TMDbClient(apiKey: currentToken ?? "foo token")
    }
    
    func search(query: String, token: String?, limit: Int) async throws -> [ExternalMovieItem] {

        // Search across movies, TV shows, and people
        let searchResults = try await tmdbClient.search.searchAll(query: query)
        
        let imagesConfig = try await tmdbClient.configurations.apiConfiguration().images
        
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
        var creator : String? = nil
        switch item.type {
        case .MOVIE:
            let credits = try? await tmdbClient.movies.credits(forMovie: item.sourceId!)
            creator = credits?.crew.first(where: { $0.job == "Director" })?.name
        case .TV_SERIES:
            let credits = try? await tmdbClient.tvSeries.credits(forTVSeries: item.sourceId!)
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
            coverImageData: item.coverImageData,
            status: item.status,
            author: creator,
            year: item.year,
            type: item.type,
            sourceId: item.sourceId,
            originalTitle: item.originalTitle
        )
        
    }
    
    func toExternalMovieItem(movie: MovieListItem, imagesConfiguration: ImagesConfiguration) -> ExternalMovieItem {
        let coverUrl = movie.posterPath.map { imagesConfiguration.posterURL(for: $0, idealWidth: 250) } ?? nil
        let releaseYear = movie.releaseDate.map { Calendar.current.component(.year, from: $0) } ?? nil
        let rating = movie.voteAverage.map {String(format: "%.1f / 10", $0) } ?? nil
        
        return ExternalMovieItem(
            title: movie.title,
            sourceUrl: URL(string: "https://www.themoviedb.org/movie/\(movie.id)")!,
            sourceName: serviceName,
            description: movie.overview,
            rating: rating,
            coverUrl: coverUrl,
            coverImageData: nil,
            status: .PLANNED,
            author: nil,
            year: releaseYear,
            type: .MOVIE,
            sourceId: movie.id,
            originalTitle: movie.originalTitle
        )
    }
    
    func toExternalMovieItem(tvSeries: TVSeriesListItem, imagesConfiguration: ImagesConfiguration) -> ExternalMovieItem {
        let coverUrl = tvSeries.posterPath.map { imagesConfiguration.posterURL(for: $0, idealWidth: 250) } ?? nil
        let releaseYear = tvSeries.firstAirDate.map { Calendar.current.component(.year, from: $0) } ?? nil
        let rating = tvSeries.voteAverage.map {String(format: "%.1f / 10", $0) } ?? nil

        return ExternalMovieItem(
            title: tvSeries.name,
            sourceUrl: URL(string: "https://www.themoviedb.org/movie/\(tvSeries.id)")!,
            sourceName: serviceName,
            description: tvSeries.overview,
            rating: rating,
            coverUrl: coverUrl,
            coverImageData: nil,
            status: .PLANNED,
            author: nil,
            year: releaseYear,
            type: .TV_SERIES,
            sourceId: tvSeries.id,
            originalTitle: tvSeries.originalName
        )

    }
    
}
