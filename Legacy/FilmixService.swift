//
//  FilmixService.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 12.03.2026.
//

import Foundation

class FilmixService: MovieSearchService {
    
    static var serviceName: String = "Filmix"
    static var requiresToken: Bool = false
    static var tokenPlaceholder: String? = nil
    static var helpURL: String? = nil

    func getDescriptionText() -> String? {
        return nil // String(localized: ".label.settings.service.filmix.description") // Experimental Russian-languaged token-less service. Better obtain (for free) TMDb API Key and use one.
    }
    
    let client: FilmixClient
    
    init() {
        client = FilmixClient.shared
    }
    
    // MARK: - Search Movies
    
    func search(query: String, limit: Int) async throws -> [ExternalMovieItem] {
        let searchResponse = try await client.search(query: query)
        return searchResponse.map { movie in
            ExternalMovieItem(
                title: movie.title,
                sourceName: FilmixService.serviceName,
                coverUrl: movie.poster.flatMap { URL(string: $0) },
                year: movie.year,
                type: movie.lastSerie == nil ? .movie : .tvSeries,
                sourceId: movie.link
            )
        }
    }
    
    // MARK: - Get Movie Details

    func getDetails(item: ExternalMovieItem) async throws -> ExternalMovieItem {
        if let movieLink = item.sourceId {
            if let detailedMovie = try? await getMovieDetails(link: movieLink) {
                
                let mergedMovie = ExternalMovieItem(
                    title: item.title,
                    sourceName: item.sourceName,
                    description: detailedMovie.itemDescription,
                    rating: detailedMovie.rating,
                    coverUrl: item.coverUrl,
                    author: detailedMovie.director,
                    year: item.year,
                    type: detailedMovie.contentType == .series ? .tvSeries : .movie,
                    sourceId: item.sourceId,
                    originalTitle: item.originalTitle,
                    tvSeriesStatus: nil // Won't process for this service
                )
                
                return mergedMovie
            } else {
                return item
            }
        } else {
            return item
        }

    }
    
    // sourceId is the link to the movie page
    func getSourceUrl(item: any CommonMediaItem) throws -> URL {
        guard let id = item.sourceId else { throw FilmixError.invalidURL }
        guard let url = URL(string: id) else {
            throw FilmixError.invalidURL
        }
        return url
    }
        
    private func getMovieDetails(link: String) async throws -> DetailedMovieInfo? {
        let movieDetail = try await client.movieDetail(url: link)
        return DetailedMovieInfo(
                itemDescription: movieDetail.description,
                director: movieDetail.director,
                contentType: movieDetail.contentType,
                rating: movieDetail.rating,
            )
    }
    
    private struct DetailedMovieInfo {
        let itemDescription: String?
        let director: String?
        let contentType: FilmixContentType
        let rating: Double?
    }

}
