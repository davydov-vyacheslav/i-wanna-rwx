//
//  MediaViewModel.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import Foundation
import Combine
import os

final class BooksViewModel: MediaViewModel<BookItem, BookPersistenceService> {
    init() {
        super.init(
            storageService: BookPersistenceService(context: BookPersistenceController.shared.context)
        )
    }

    func isInLibrary(isbn: String) -> Bool {
        storageService.isInLibrary(isbn)
    }
}
