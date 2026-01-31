//
//  MediaViewModel.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 31.01.2026.
//

import Foundation
import Combine
import os

@MainActor
class MediaViewModel<Item, Persistence: MediaPersistenceService>: ObservableObject
where Persistence.Item == Item
{
    let storageService: Persistence

    init(storageService: Persistence) {
        self.storageService = storageService
    }

    func filteredItems(filter: FilterType) -> [Item] {
        storageService.findByType(filter)
    }

    func count(filter: FilterType) -> Int {
        storageService.count(filter)
    }

    func addItem(_ item: Item) {
        storageService.add(item)
        objectWillChange.send()
    }

    func deleteItem(_ item: Item) {
        storageService.delete(item)
        objectWillChange.send()
    }

    func toggleFavorite(_ item: Item) {
        storageService.toggleFavorite(item)
        objectWillChange.send()
    }

    func changeStatus(_ item: Item, to status: MediaStatus) {
        storageService.changeStatus(item, to: status)
        objectWillChange.send()
    }
}

