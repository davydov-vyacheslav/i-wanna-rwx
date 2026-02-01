//
//  BookService.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation
import SwiftData
import os

@MainActor
class BookPersistenceService: MediaPersistenceService {
    
    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Main methods
    func findByType(_ filter: FilterType) -> [BookItem] {
        var predicate: Predicate<BookItem>?
        let pendingState = MediaStatus.planned.rawValue
        let draftServiceName = DraftBookService.serviceName
        
        switch filter {
        case .all:
            predicate = nil // No filter, fetch all
        case .favorite:
            predicate = #Predicate<BookItem> { item in
                item.isFavorite == true
            }
        case .planned:
            predicate = #Predicate<BookItem> { item in
                item.statusRaw == pendingState
            }
        case .draft:
            predicate = #Predicate<BookItem> { item in
                item.sourceName == draftServiceName
            }
        }
        
        let descriptor = FetchDescriptor<BookItem>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.title)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            Log.db.error("Error fetching books by filter: \(error)")
            return []
        }
    }
    
    func add(_ item: BookItem) {
        modelContext.insert(item)
        saveContext()
    }
    
    func delete(_ item: BookItem) {
        modelContext.delete(item)
        saveContext()
    }
    
    func toggleFavorite(_ item: BookItem) {
        item.isFavorite.toggle()
        saveContext()
    }
    
    func changeStatus(_ item: BookItem, to status: MediaStatus) {
        item.statusRaw = status.rawValue
        saveContext()
    }
    
    func isInLibrary(_ isbn: String) -> Bool {
        let predicate = #Predicate<BookItem> { book in
            book.isbn == isbn
        }
        let descriptor = FetchDescriptor<BookItem>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            return !results.isEmpty
        } catch {
            Log.db.error("Error checking if book exists by isbn: \(error)")
            return false
        }
    }
    
    // MARK: - Private Helper
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            Log.db.error("Error saving context: \(error)")
        }
    }
}
