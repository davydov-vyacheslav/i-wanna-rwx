//
//  MoviesView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftUI
import SwiftData

struct MoviesView: View {
    @Environment(MoviePersistenceService.self) private var persistenceService
    
    @State private var movieFilter: MediaFilterState = {
        var state = MediaFilterState<VideoTypeFilter>()
        state.seenState = .exclude
        return state
    }()
    @State private var showingAddSheet = false
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // List with dynamic filtering
                MediaListContent<MovieItem, ExternalMovieItem, MoviePersistenceService>(
                    customPredicate: makePredicate(movieFilter),
                    persistenceService: persistenceService,
                    sortDescriptors: [SortDescriptor(\MovieItem.title)],
                    placeholderIcon: "film.fill",
                    itemDetailedTypeIconFunc: { MediaItemHelper.getVideoType(from: $0) == VideoType.tvSeries ? "tv" : "film" },
                    isDraft: { DraftMovieService.shared.isDraft(item: $0) },
                    onDelete: { persistenceService.delete($0) },
                    onRefresh: {
                        let allItems = persistenceService.fetchAllTvSeries()
                        for item in allItems {
                            guard let source = SettingsSourceStore.shared.getSource(
                                item.sourceName, for: item, as: ExternalMovieItem.self
                            ) else { continue }
                            let ext = ExternalMovieItem.fromMovieItem(item: item)
                            guard let updated = try? await source.instance.getDetails(item: ext) else { continue }

                            item.tvSeriesStatusRaw = updated.tvSeriesStatus?.rawValue
                            item.tvNumberOfSeasons = updated.tvNumberOfSeasons
                        }
                        persistenceService.saveContext()
                    },
                    extraMetaView: {
                        if let status = MediaItemHelper.getTvSeriesStatus(from: $0),
                               let seasons = $0.tvNumberOfSeasons,
                               MediaItemHelper.getVideoType(from: $0) == .tvSeries {
                            HStack(spacing: 8) {
                                Text(".label.movies.tv_series.status \(status.displayName)")
                                Text(verbatim: " • ")
                                Text(".label.movies.tv_series.seasons \(seasons)")
                            }
                        } else if let status = MediaItemHelper.getTvSeriesStatus(from: $0) {
                            Text(".label.movies.tv_series.status \(status.displayName)")
                        } else if let seasons = $0.tvNumberOfSeasons,
                                  MediaItemHelper.getVideoType(from: $0) == .tvSeries {
                            Text(".label.movies.tv_series.seasons \(seasons)")
                        } else {
                            EmptyView()
                        }
                    },
                )
            }
            .navigationTitle(Tab.movies.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        FilterToolbarButton(filterState: $movieFilter) {
                            showingFilterSheet = true
                        }

                        Button {
                            showingAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .accessibilityHidden(true)
                        }
                        .accessibilityLabel(Text(".accessibility.movies.add"))
                    }
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                MediaFilterSheet(filterState: $movieFilter)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddMediaSheet<ExternalMovieItem, MoviePersistenceService>(
                    title: ".title.movie.add",
                    cantFindMessage: ".label.movie.cant_find",
                    emptyStateIcon: "film.stack.fill",
                    placeholderIcon: "film.fill",
                    getItemDetailedTypeIcon: { $0?.type == .tvSeries ? "tv" : "film" },
                    isItemInLibrary: { persistenceService.isInLibrary(sourceId: $0.sourceId, sourceName: $0.sourceName) },
                    isDraftItemInLibrary: { persistenceService.isDraftInLibrary($0) },
                    getAuthorInfo: { item in nil },
                    getDraftItem: { DraftMovieService.shared.single(query: $0) },
                    sourcesKeyPath: \.availableVideoSources,
                    persistenceService: persistenceService
                )
            }
        }
    }
    
    private func makePredicate(_ filterState: MediaFilterState<VideoTypeFilter>) -> Predicate<MovieItem>? {
        guard filterState.isActive else { return nil }

        let wantMovies = (filterState.itemType == .movies)
        let wantSeries = (filterState.itemType == .series)
        let filterType = (filterState.itemType != .all)
        
        let checkFavInclude = filterState.favouriteState == .include
        let checkFavExclude = filterState.favouriteState == .exclude
        
        let checkSeenInclude = filterState.seenState == .include
        let checkSeenExclude = filterState.seenState == .exclude

        let checkDraftInclude = filterState.draftState == .include
        let checkDraftExclude = filterState.draftState == .exclude

        let draftServiceName = DraftMovieService.serviceName
        let statusDone = MediaStatus.done.rawValue
        let tvSeriesType = VideoType.tvSeries.rawValue
        
        return #Predicate<MovieItem> { item in
            (!filterType || (wantMovies ? item.typeRaw != tvSeriesType : (wantSeries ? item.typeRaw == tvSeriesType : true)))
            && (!checkFavInclude || item.isFavorite) && (!checkFavExclude  || !item.isFavorite)
            && (!checkSeenInclude || item.statusRaw == statusDone) && (!checkSeenExclude || item.statusRaw != statusDone)
            && (!checkDraftInclude || item.sourceName == draftServiceName) && (!checkDraftExclude || item.sourceName != draftServiceName)
        }
    }
}

enum VideoTypeFilter: String, FilterTypeOption {
    case all
    case movies
    case series

    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: return String(localized: ".type.common.all")
        case .movies: return String(localized: ".type.movie.movies")
        case .series: return String(localized: ".type.movie.tvSeries")
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "rectangle.stack.fill"
        case .movies: return "film"
        case .series: return "tv"
        }
    }
}
