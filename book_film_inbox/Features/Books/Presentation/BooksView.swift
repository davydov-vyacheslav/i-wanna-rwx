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
    
    @State private var bookFilter: MediaFilterState = {
        var state = MediaFilterState<BookTypeFilter>()
        state.isNotSeen = true
        return state
    }()
    @State private var showingAddSheet = false
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // List with dynamic filtering
                MediaListContent<BookItem, ExternalBookItem, BookPersistenceService>(
                    customPredicate: makePredicate(bookFilter),
                    persistenceService: persistenceService,
                    sortDescriptors: [SortDescriptor(\BookItem.title)],
                    placeholderIcon: "book.fill",
                    itemDetailedTypeIconFunc: { item in "book" },
                    isDraft: { DraftBookService.shared.isDraft(item: $0) },
                    onDelete: { persistenceService.delete($0) },
                    extraMetaView: { _ in EmptyView() }
                )
            }
            .navigationTitle(Tab.books.title)
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        FilterToolbarButton(filterState: $bookFilter) {
                            showingFilterSheet = true
                        }
                        
                        Button {
                            showingAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .accessibilityHidden(true)
                        }
                        .accessibilityLabel(Text(".accessibility.books.add"))
                    }
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                MediaFilterSheet(filterState: $bookFilter)
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
    
    private func makePredicate(_ filterState: MediaFilterState<BookTypeFilter>) -> Predicate<BookItem>? {
        guard filterState.isActive else { return nil }
        
        let checkFav = filterState.isFavourite
        let checkSeen = filterState.isSeen
        let checkNotSeen = filterState.isNotSeen
        let checkDraft = filterState.isDraft
        
        let draftServiceName = DraftMovieService.serviceName
        let statusDone = MediaStatus.done.rawValue
        
        return #Predicate<BookItem> { item in
               (!checkFav || item.isFavorite)
            && (!checkSeen || item.statusRaw == statusDone)
            && (!checkNotSeen || item.statusRaw != statusDone)
            && (!checkDraft || item.sourceName == draftServiceName)
        }
    }
}

enum BookTypeFilter: String, FilterTypeOption {
    case all

    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: return String(localized: ".type.common.all")
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "rectangle.stack.fill"
        }
    }
}

