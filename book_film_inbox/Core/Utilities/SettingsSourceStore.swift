//
//  SettingsSourceEntity.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

import Foundation
import Combine

@Observable
class SettingsSourceStore {
    
    static let shared = SettingsSourceStore()
    private let draftBookSource = SettingsSourceEntity(id: DraftBookService.serviceName, instance: DraftBookService.shared)
    private let draftMovieSource = SettingsSourceEntity(id: DraftMovieService.serviceName, instance: DraftMovieService.shared)
    
    var availableBookSources: [SettingsSourceEntity] = [ ]
    var availableVideoSources: [SettingsSourceEntity] = [ ]

    private init() {
        reloadSources()
    }
    
    func reloadSources() {
        availableBookSources = [
            SettingsSourceEntity(id: OpenLibraryService.serviceName, instance: OpenLibraryService()),
        ]
        
        availableVideoSources = [
            SettingsSourceEntity(id: TMDbService.serviceName,  instance: TMDbService()),
        ]
    }
    
    func getSource<Item: CommonMediaItem>(_ name: String, for item: Item) -> SettingsSourceEntity? {
        switch Item.self {
        case is BookItem.Type:
            if DraftBookService.shared.isDraft(item: item) {
                return draftBookSource
            }
            return availableBookSources.first { $0.id == name }
        case is MovieItem.Type:
            if DraftMovieService.shared.isDraft(item: item) {
                return draftMovieSource
            }
            return availableVideoSources.first { $0.id == name }
        default:
            return nil
        }
    }
}

struct SettingsSourceEntity: Identifiable, Equatable {
    let id: String
    let instance: any SearchService
    
    static func == (lhs: SettingsSourceEntity, rhs: SettingsSourceEntity) -> Bool {
        type(of: lhs.instance).serviceName == type(of: lhs.instance).serviceName
    }
}
