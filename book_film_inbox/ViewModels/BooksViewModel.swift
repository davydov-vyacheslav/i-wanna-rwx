//
//  MediaViewModel.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftData
import Foundation
import Combine
import os

final class BooksViewModel: MediaViewModel<BookItem, BookPersistenceService> {
    init() {
        super.init(
            storageService: BookPersistenceService(context: ModelContext(PersistenceController.shared.container))
        )
    }

    func isInLibrary(isbn: String) -> Bool {
        storageService.isInLibrary(isbn)
    }
}
