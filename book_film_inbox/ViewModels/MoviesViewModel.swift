//
//  MoviesViewModel.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import Foundation
import Combine
import os

@MainActor
class MoviesViewModel: ObservableObject {
    private let storageService = MoviePersistenceService(context: MoviePersistenceController.shared.context)
    
    func filteredItems(filter: FilterType) -> [MovieItem] {
        storageService.findByType(filter)
    }
    
    func count(filter: FilterType) -> Int {
        storageService.count(filter)
    }
    
    func addItem(_ item: MovieItem, _ coverUrlRaw: URL? = nil) async {
        // Download image if URL exists
        if let coverUrl = coverUrlRaw {
            do {
                let (data, _) = try await URLSession.shared.data(from: coverUrl)
                item.coverImageData = data
            } catch {
                Log.ui.error("Failed to download cover image: \(error)")
            }
        }
        
        storageService.add(item)
        objectWillChange.send()
    }
    
    func deleteItem(_ item: MovieItem) {
        storageService.delete(item)
        objectWillChange.send()
    }
    
    func toggleFavorite(_ item: MovieItem) {
        storageService.toggleFavorite(item)
        objectWillChange.send()
    }
    
    func changeStatus(_ item: MovieItem, to status: MediaStatus) {
        storageService.changeStatus(item, to: status)
        objectWillChange.send()
    }
    
    func isInLibrary(sourceId: Int?, sourceName: String) -> Bool {
        storageService.isInLibrary(sourceId: sourceId, sourceName: sourceName)
    }
}
