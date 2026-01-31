//
//  MediaPersistenceService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 31.01.2026.
//

protocol MediaPersistenceService {
    associatedtype Item
    func findByType(_ filter: FilterType) -> [Item]
    func count(_ filter: FilterType) -> Int
    func add(_ item: Item)
    func delete(_ item: Item)
    func toggleFavorite(_ item: Item)
    func changeStatus(_ item: Item, to status: MediaStatus)
}
