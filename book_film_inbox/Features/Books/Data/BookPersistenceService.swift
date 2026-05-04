//
//  BookService.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation
import SwiftData

@MainActor
@Observable
class BookPersistenceService: MediaPersistenceService {
    typealias Item = BookItem
    
    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Main methods
    
    func add(_ item: BookItem) {
        modelContext.insert(item)
        try? modelContext.save()
    }
    
    func delete(_ item: BookItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
    
    func toggleFavorite(_ item: BookItem) {
        item.isFavorite.toggle()
        try? modelContext.save()
    }
    
    func changeStatus(_ item: BookItem, to status: MediaStatus) {
        item.statusRaw = status.rawValue
        try? modelContext.save()
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
            Log.error("Error checking if book exists by isbn", error: error, context: [
                "isbn": isbn
            ])
            return false
        }
    }
    
    func isDraftInLibrary(_ title: String) -> Bool {
        // we shouldn't add draft book with the title already added to the list...
        let predicate = #Predicate<BookItem> { book in
            book.title == title
        }
        let descriptor = FetchDescriptor<BookItem>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            return !results.isEmpty
        } catch {
            Log.error("Error checking if book exists by title", error: error, context: [
                "title": title
            ])
            return false
        }
    }
    

}
