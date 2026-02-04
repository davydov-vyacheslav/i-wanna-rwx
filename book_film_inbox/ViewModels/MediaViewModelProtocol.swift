//
//  MediaViewModelProtocol.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 04.02.2026.
//

import Foundation

protocol MediaViewModelProtocol: ObservableObject {
    associatedtype Item: CommonMediaItem
    
    func filteredItems(filter: FilterType) -> [Item]

    func count(filter: FilterType) -> Int

    func addItem(_ item: Item)

    func deleteItem(_ item: Item)

    func toggleFavorite(_ item: Item)

    func changeStatus(_ item: Item, to status: MediaStatus)
}
