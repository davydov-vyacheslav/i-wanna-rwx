//
//  MediaPersistenceService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 31.01.2026.
//

import Foundation

protocol MediaPersistenceService {
    associatedtype Item: CommonMediaItem
    func add(_ item: Item)
    func delete(_ item: Item)
    func toggleFavorite(_ item: Item)
    func changeStatus(_ item: Item, to status: MediaStatus)
}
