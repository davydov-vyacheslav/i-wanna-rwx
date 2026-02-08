//
//  BooksView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI
import SwiftData

struct BooksView: View {
    @Environment(BookPersistenceService.self) private var persistenceService
    
    @State private var selectedFilter: FilterType = .all
    @State private var showingAddSheet = false
    
    var body: some View {
         NavigationStack {
             VStack(spacing: 0) {
                 // Filters
                 MediaFilterBar<BookPersistenceService, BookItem>(
                     persistenceService: persistenceService,
                     selectedFilter: $selectedFilter
                 )
                 
                 // List with dynamic filtering
                 MediaListContent<BookItem, BookPersistenceService>(
                     filter: selectedFilter,
                     persistenceService: persistenceService,
                     sortDescriptors: [SortDescriptor(\BookItem.title)],
                     placeholderIcon: "book.fill",
                     itemDetailedTypeIconFunc: { item in "book" },
                     isDraft: { DraftBookService.shared.isDraft(item: $0) },
                     onDelete: { persistenceService.delete($0) },
                 )
             }
             .navigationTitle(Tab.books.title)
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button {
                         showingAddSheet = true
                     } label: {
                         Image(systemName: "plus")
                     }
                 }
             }
             .sheet(isPresented: $showingAddSheet) {
                 AddMediaSheet<ExternalBookItem, BookPersistenceService>(
                     title: ".title.book.add",
                     cantFindMessage: ".label.book.cant_find",
                     emptyStateIcon: "books.vertical",
                     placeholderIcon: "book.fill",
                     getItemDetailedTypeIcon: { item in "book" },
                     isItemInLibrary: { persistenceService.isInLibrary($0.isbn ?? "NoISBN") },
                     getAuthorInfo: { $0.author ?? String(localized: ".label.common_media.no_author") },
                     getDraftItem: { DraftBookService.shared.single(query: $0) },
                     sourcesKeyPath: \.availableBookSources,
                     persistenceService: persistenceService
                 )
             }
         }
     }
 }

