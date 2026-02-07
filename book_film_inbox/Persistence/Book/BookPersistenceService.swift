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
    
    // Этот метод теперь используется только для count()
    // Основная выборка данных происходит через @Query в view
    func findByType(_ filter: FilterType) -> [BookItem] {
        let predicate = makeFilterPredicate(for: filter)
        
        let descriptor = FetchDescriptor<BookItem>(
            predicate: predicate ?? #Predicate { _ in true },
            sortBy: [SortDescriptor(\.title)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            Log.error("Error fetching books by filter", error: error, context: [
                "filter": filter
            ])
            return []
        }
    }
     
    func makeFilterPredicate(for filter: FilterType) -> Predicate<BookItem>? {
        let pendingState = MediaStatus.planned.rawValue
        let draftServiceName = DraftBookService.serviceName
        
        switch filter {
        case .all:
            return nil
        case .favorite:
            return #Predicate<BookItem> { item in
                item.isFavorite == true
            }
        case .planned:
            return #Predicate<BookItem> { item in
                item.statusRaw == pendingState
            }
        case .draft:
            return #Predicate<BookItem> { item in
                item.sourceName == draftServiceName
            }
        }
    }
    
    func count(filter: FilterType) -> Int {
        findByType(filter).count
    }
    
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

}
