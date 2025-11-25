//
//  BookService.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation
import SwiftData


@MainActor
class BookPersistenceService {
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        do {
            modelContainer = try ModelContainer(for: BookItem.self)
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        
        // TODO: remove me
//        if let url = modelContainer.configurations.first?.url {
//                    print("📁 SwiftData DataiftData Database Location:")
//                    print(url.path)
//                }
    }
    
    
    func findByType(_ filter: FilterType) -> [BookItem] {
        var predicate: Predicate<BookItem>?
        let pendingState = MediaStatus.PENDING.rawValue
        let inProgressState = MediaStatus.IN_PROGRESS.rawValue
        let doneState = MediaStatus.DONE.rawValue
        
        
        switch filter {
        case .ALL:
            predicate = nil // No filter, fetch all
        case .FAVOURITES:
            predicate = #Predicate<BookItem> { book in
                book.isFavourite == true
            }
        case .PENDING:
            predicate = #Predicate<BookItem> { book in
                book.status == pendingState
            }
        case .IN_PROGRESS:
            predicate = #Predicate<BookItem> { book in
                book.status == inProgressState
            }
        case .COMPLETED:
            predicate = #Predicate<BookItem> { book in
                book.status == doneState
            }
        }
        
        let descriptor = FetchDescriptor<BookItem>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.title)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching books by filter: \(error)")
            return []
        }
    }
    
    func count(_ filter: FilterType) -> Int {
        findByType(filter).count
    }
    
    func addBook(_ book: BookItem) {
        modelContext.insert(book)
        saveContext()
    }
    
    func deleteBook(_ book: BookItem) {
        modelContext.delete(book)
        saveContext()
    }
    
    func toggleFavorite(_ book: BookItem) {
        book.isFavourite.toggle()
        saveContext()
    }
    
    func changeStatus(_ book: BookItem, to status: MediaStatus) {
        book.status = status.rawValue
        saveContext()
    }
    
    func isInLibrary(_ title: String) -> Bool {
        let predicate = #Predicate<BookItem> { book in
            book.title == title
        }
        let descriptor = FetchDescriptor<BookItem>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            return !results.isEmpty
        } catch {
            print("Error checking if book exists by title: \(error)")
            return false
        }
    }
    
    // MARK: - Private Helper
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
