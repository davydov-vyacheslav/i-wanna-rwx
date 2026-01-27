//
//  MoviePersistenceService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import Foundation
import SwiftData

@MainActor
class MoviePersistenceService {

    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }
    
    
    // MARK: - Main methods
    func findByType(_ filter: FilterType) -> [MovieItem] {
        var predicate: Predicate<MovieItem>?
        let pendingState = MediaStatus.PLANNED.rawValue
        
        switch filter {
        case .ALL:
            predicate = nil // No filter, fetch all
        case .FAVOURITES:
            predicate = #Predicate<MovieItem> { item in
                item.isFavourite == true
            }
        case .PLANNED:
            predicate = #Predicate<MovieItem> { item in
                item.status == pendingState
            }
        }
        
        let descriptor = FetchDescriptor<MovieItem>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.title)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching Movies by filter: \(error)")
            return []
        }
    }
    
    func count(_ filter: FilterType) -> Int {
        findByType(filter).count
    }
    
    func add(_ item: MovieItem) {
        modelContext.insert(item)
        saveContext()
    }
    
    func delete(_ item: MovieItem) {
        _ = item.coverImageData // lazy data load to avoid 'This backing data was detached from a context without resolving attribute faults'
        modelContext.delete(item)
        saveContext()
    }
    
    func toggleFavorite(_ item: MovieItem) {
        item.isFavourite.toggle()
        saveContext()
    }
    
    func changeStatus(_ item: MovieItem, to status: MediaStatus) {
        item.status = status.rawValue
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
            print("Error checking if movie exists by isbn: \(error)")
            return false
        }
    }
    
    // MARK: Private Helper
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

}
