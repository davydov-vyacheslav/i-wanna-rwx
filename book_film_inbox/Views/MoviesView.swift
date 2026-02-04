//
//  MoviesView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftUI

struct MoviesView: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    @State private var selectedFilter: FilterType = .all
    @State private var showingAddSheet = false
    
    var filteredItems: [MovieItem] {
        viewModel.filteredItems(filter: selectedFilter)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            FilterButton(
                                iconName: filter.iconName,
                                count: viewModel.count(filter: filter),
                                isSelected: selectedFilter == filter,
                                isFavorite: filter == .favorite
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(uiColor: .systemBackground))
                
                // List
                if filteredItems.isEmpty {
                    Spacer()
                    Text(".label.common.list_empty")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            MediaItemCard<MovieItem, MoviesViewModel>(
                                    item: item,
                                    placeholderIcon: "film.fill",
                                    itemDetailedTypeIcon: item.type == VideoType.tvSeries ? "tv" : "film",
                                    isDraft: { DraftMovieService.shared.isDraft(item: $0) }
                            )
                                .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewModel.deleteItem(item)
                                    } label: {
                                        Label(".button.delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                        
                    }
                    .listStyle(.plain)
                    .padding(.horizontal)
                }
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
                AddMediaSheet<ExternalMovieItem, MoviesViewModel>(
                    title: ".title.movie.add",
                    cantFindMessage: ".label.movie.cant_find",
                    emptyStateIcon: "film.stack.fill",
                    placeholderIcon: "film.fill",
                    getItemDetailedTypeIcon: { $0?.type == .tvSeries ? "tv" : "film" },
                    isItemInLibrary: { viewModel.isInLibrary(sourceId: $0.sourceId, sourceName: $0.sourceName) },
                    getAuthorInfo: { item in nil },
                    getDraftItem: { DraftMovieService.shared.single(query: $0) },
                    sourcesKeyPath: \.availableVideoSources
                )

            }
        }
    }
}


