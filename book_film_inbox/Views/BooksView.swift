//
//  BooksView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct BooksView: View {
    @EnvironmentObject var viewModel: BooksViewModel
    @State private var selectedFilter: FilterType = .ALL
    @State private var showingAddSheet = false
    
    var filteredItems: [BookItem] {
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
                                isFavorite: filter == .FAVOURITES
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
                            BookItemCard(item: item)
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
            .navigationTitle(".title.book.list")
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
                AddBookSheet()
            }
        }
    }
}


