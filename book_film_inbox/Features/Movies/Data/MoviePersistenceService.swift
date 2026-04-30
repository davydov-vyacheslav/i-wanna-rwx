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
    
    func saveContext() {
        do {
            try modelContext.save()
            Log.info("Movies context is saved")
        } catch {
            Log.error("Failed to update movies metadata", error: error)
        }
    }
    
    func fetchAllTvSeries() -> [MovieItem] {
        let descriptor = FetchDescriptor<MovieItem>()
        return ((try? modelContext.fetch(descriptor)) ?? [])
            .filter { MediaItemHelper.getVideoType(from: $0) == .tvSeries }
    }
    
}
