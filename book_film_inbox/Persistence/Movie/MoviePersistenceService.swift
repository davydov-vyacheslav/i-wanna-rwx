//
//  MoviePersistenceService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import Foundation
import SwiftData

@MainActor
@Observable
class MoviePersistenceService: MediaPersistenceService {
    typealias Item = MovieItem
    
    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }
    
    
    // MARK: - Main methods
    func findByType(_ filter: FilterType) -> [MovieItem] {
        let predicate: Predicate<MovieItem>? = makeFilterPredicate(for: filter)
        
        let descriptor = FetchDescriptor<MovieItem>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.title)]
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            return results
        } catch {
            Log.error("Error fetching Movies by filter", error: error, context: [
                "filter": filter
            ])
            return []
        }
    }
    
    func makeFilterPredicate(for filter: FilterType) -> Predicate<MovieItem>? {
        let pendingState = MediaStatus.planned.rawValue
        let draftServiceName = DraftMovieService.serviceName
        
        switch filter {
        case .all:
            return nil // No filter, fetch all
        case .favorite:
            return #Predicate<MovieItem> { item in
                item.isFavorite == true
            }
        case .planned:
            return #Predicate<MovieItem> { item in
                item.statusRaw == pendingState
            }
        case .draft:
            return #Predicate<MovieItem> { item in
                item.sourceName == draftServiceName
            }
        }

    }
    
    func count(filter: FilterType) -> Int {
        findByType(filter).count
    }
    
    func add(_ item: MovieItem) {
        modelContext.insert(item)
        try? modelContext.save()
    }
    
    func delete(_ item: MovieItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
    
    func toggleFavorite(_ item: MovieItem) {
        item.isFavorite.toggle()
        try? modelContext.save()
    }
    
    func changeStatus(_ item: MovieItem, to status: MediaStatus) {
        item.statusRaw = status.rawValue
        try? modelContext.save()
    }

    func isInLibrary(sourceId: String?, sourceName: String) -> Bool {
        guard let sourceId else { return false }
        
        let predicate = #Predicate<MovieItem> { movie in
            movie.sourceId == sourceId &&
            movie.sourceName == sourceName
        }
        let descriptor = FetchDescriptor<MovieItem>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            return !results.isEmpty
        } catch {
            Log.error("Error checking if movie exists by source id / name", error: error, context: [
                "sourceId": sourceId,
                "sourceName": sourceName
            ])
            return false
        }
    }

}
