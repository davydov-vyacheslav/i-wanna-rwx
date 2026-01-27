//
//  MediaViewModel.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import Foundation
import Combine

class BooksViewModel: ObservableObject {
    private let storageService = BookPersistenceService()
    
    func filteredItems(filter: FilterType) -> [BookItem] {
        storageService.findByType(filter)
    }
    
    func count(filter: FilterType) -> Int {
        storageService.count(filter)
    }
    
    func addItem(_ item: BookItem, _ coverUrlRaw: URL? = nil) async {
        // Download image if URL exists
        if let coverUrl = coverUrlRaw {
            do {
                let (data, _) = try await URLSession.shared.data(from: coverUrl)
                item.coverImageData = data
            } catch {
                print("Failed to download cover image: \(error)")
            }
        }
        
        storageService.addBook(item)
        objectWillChange.send()
    }
    
    func deleteItem(_ item: BookItem) {
        storageService.deleteBook(item)
        objectWillChange.send()
    }
    
    func toggleFavorite(_ item: BookItem) {
        storageService.toggleFavorite(item)
        objectWillChange.send()
    }
    
    func changeStatus(_ item: BookItem, to status: MediaStatus) {
        storageService.changeStatus(item, to: status)
        objectWillChange.send() 
    }
    
    func isInLibrary(isbn: String) -> Bool {
        storageService.isInLibrary(isbn)
    }
}
