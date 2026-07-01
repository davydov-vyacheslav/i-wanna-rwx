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
    
    @State private var bookFilter: MediaFilterState<BookTypeFilter>
    @State private var bookSort: MediaSortOption
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var showingFilterSheet = false
    @State private var counts = ListCounts()

    init() {
        _bookFilter = State(initialValue: FilterStore.load(FilterStore.Key.books, default: .appDefault))
        _bookSort = State(initialValue: FilterStore.load(FilterStore.Key.booksSort, default: .titleAsc))
    }

    private var sortDescriptors: [SortDescriptor<BookItem>] {
        switch bookSort {
        case .titleAsc: return [SortDescriptor(\BookItem.title, order: .forward)]
        case .updatedDesc: return [SortDescriptor(\BookItem.updatedAt, order: .reverse)]
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // List with dynamic filtering
                MediaListContent<BookItem, ExternalBookItem, BookPersistenceService>(
                    customPredicate: makePredicate(bookFilter),
                    persistenceService: persistenceService,
                    sortDescriptors: sortDescriptors,
                    placeholderIcon: "draft_book",
                    itemDetailedTypeIconFunc: { item in "book" },
                    isDraft: { DraftBookService.shared.isDraft(item: $0) },
                    onDelete: { persistenceService.delete($0) },
                    searchText: searchText,
                    extraMetaView: { _ in EmptyView() }
                )
                .onPreferenceChange(ListCountsKey.self) { counts = $0 }
            }
            .navigationTitle(Tab.books.title)
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: bookFilter) { _, new in FilterStore.save(new, forKey: FilterStore.Key.books) }
            .onChange(of: bookSort) { _, new in FilterStore.save(new, forKey: FilterStore.Key.booksSort) }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        ListCountLabel(counts: counts)

                        SortMenu(selection: $bookSort)

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
                    placeholderIcon: "draft_book",
                    getItemDetailedTypeIcon: { item in "book" },
                    isItemInLibrary: { persistenceService.isInLibrary($0.isbn ?? "NoISBN") },
                    isDraftItemInLibrary: { persistenceService.isDraftInLibrary($0) },
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
        
        let checkFavInclude = filterState.favouriteState == .include
        let checkFavExclude = filterState.favouriteState == .exclude
        
        let checkSeenInclude = filterState.seenState == .include
        let checkSeenExclude = filterState.seenState == .exclude

        let checkDraftInclude = filterState.draftState == .include
        let checkDraftExclude = filterState.draftState == .exclude

        let draftServiceName = DraftBookService.serviceName
        let statusDone = MediaStatus.done.rawValue
        
        return #Predicate<BookItem> { item in
            (!checkFavInclude || item.isFavorite) && (!checkFavExclude  || !item.isFavorite)
            && (!checkSeenInclude || item.statusRaw == statusDone) && (!checkSeenExclude || item.statusRaw != statusDone)
            && (!checkDraftInclude || item.sourceName == draftServiceName) && (!checkDraftExclude  || item.sourceName != draftServiceName)
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

