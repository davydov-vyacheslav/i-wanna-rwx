//
//  MoviePersistenceService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import Foundation
import SwiftData
import os

@MainActor
class MoviePersistenceService: MediaPersistenceService {

    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }
    
    
    // MARK: - Main methods
    func findByType(_ filter: FilterType) -> [MovieItem] {
        var predicate: Predicate<MovieItem>?
        let pendingState = MediaStatus.planned.rawValue
        let draftServiceName = DraftMovieService.serviceName
        
        switch filter {
        case .all:
            predicate = nil // No filter, fetch all
        case .favorite:
            predicate = #Predicate<MovieItem> { item in
                item.isFavorite == true
            }
        case .planned:
            predicate = #Predicate<MovieItem> { item in
                item.statusRaw == pendingState
            }
        case .draft:
            predicate = #Predicate<MovieItem> { item in
                item.sourceName == draftServiceName
            }
        }
        
        let descriptor = FetchDescriptor<MovieItem>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.title)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            Log.db.error("Error fetching Movies by filter: \(error)")
            return []
        }
    }
    
    func add(_ item: MovieItem) {
        modelContext.insert(item)
        saveContext()
    }
    
    func delete(_ item: MovieItem) {
        modelContext.delete(item)
        saveContext()
    }
    
    func toggleFavorite(_ item: MovieItem) {
        item.isFavorite.toggle()
        saveContext()
    }
    
    func changeStatus(_ item: MovieItem, to status: MediaStatus) {
        item.statusRaw = status.rawValue
        saveContext()
    }

    func isInLibrary(sourceId: Int?, sourceName: String) -> Bool {
        let predicate = #Predicate<MovieItem> { movie in
            movie.sourceId == sourceId &&
            movie.sourceName == sourceName
        }
        let descriptor = FetchDescriptor<MovieItem>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            return !results.isEmpty
        } catch {
            Log.db.error("Error checking if movie exists by isbn: \(error)")
            return false
        }
    }
    
    // MARK: Private Helper
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            Log.db.error("Error saving context: \(error)")
        }
    }

}
