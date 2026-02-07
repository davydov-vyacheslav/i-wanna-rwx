//
//  MoviesView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftUI

struct MoviesView: View {
    @Environment(MoviePersistenceService.self) private var persistenceService
    
    @State private var selectedFilter: FilterType = .all
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Filters
                MediaFilterBar<MoviePersistenceService, MovieItem>(
                    persistenceService: persistenceService,
                    selectedFilter: $selectedFilter
                )
                
                // List with dynamic filtering
                MediaListContent<MovieItem, MoviePersistenceService>(
                    filter: selectedFilter,
                    persistenceService: persistenceService,
                    sortDescriptors: [SortDescriptor(\MovieItem.title)],
                    placeholderIcon: "film.fill",
                    itemDetailedTypeIconFunc: { MediaItemHelper.getVideoType(from: $0) == VideoType.tvSeries ? "tv" : "film" },
                    isDraft: { DraftMovieService.shared.isDraft(item: $0) },
                    onDelete: { persistenceService.delete($0) },
                )
                
            }
            .navigationTitle(".title.movie.list")
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
                AddMediaSheet<ExternalMovieItem, MoviePersistenceService>(
                    title: ".title.movie.add",
                    cantFindMessage: ".label.movie.cant_find",
                    emptyStateIcon: "film.stack.fill",
                    placeholderIcon: "film.fill",
                    getItemDetailedTypeIcon: { $0?.type == .tvSeries ? "tv" : "film" },
                    isItemInLibrary: { persistenceService.isInLibrary(sourceId: $0.sourceId, sourceName: $0.sourceName) },
                    getAuthorInfo: { item in nil },
                    getDraftItem: { DraftMovieService.shared.single(query: $0) },
                    sourcesKeyPath: \.availableVideoSources,
                    persistenceService: persistenceService
                )

            }
        }
    }
}


