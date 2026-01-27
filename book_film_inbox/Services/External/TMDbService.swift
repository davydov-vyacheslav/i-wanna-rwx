//
//  TMDbService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

import TMDb

class TMDbService {
    
    //typealias SearchResultItem = ExternalBookItem
    //tokenPlaceholder: "Enter API Key",
    // helpURL: "https://www.themoviedb.org/settings/api"
    func search(name: String) async throws -> [Movie] {
        // return Movie, MediaPageableList,
        let tmdbClient = TMDbClient(apiKey: "YOUR_API_KEY")
        
        // Discover movies with filters
        let popularMovies = try await tmdbClient.discover.movies(
            sortedBy: .popularity(descending: true)
        ).results

        // Get movie details
        let fightClub = try await tmdbClient.movies.details(forMovie: 550)
        print("Title: \(fightClub.title)")
        print("Release Date: \(fightClub.releaseDate)")
        print("Rating: \(fightClub.voteAverage)/10")

        // Search across movies, TV shows, and people
        let searchResults = try await tmdbClient.search.searchAll(query: name)

        // Generate poster image URL
        let config = try await tmdbClient.configurations.apiConfiguration()
        if let posterPath = fightClub.posterPath {
            let posterURL = config.images.posterURL(for: posterPath, idealWidth: 500)
        }
        
        return []
    }
    
    
}
