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
    
    var availableBookSources: [SettingsSourceEntity<ExternalBookItem>] = [ ]
    var availableVideoSources: [SettingsSourceEntity<ExternalMovieItem>] = [ ]

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
    
    func getSource<ExternalItem: ExternalMediaItem>(_ name: String, for item: ExternalItem.MediaItem, as: ExternalItem.Type) -> SettingsSourceEntity<ExternalItem>? {
        switch ExternalItem.MediaItem.self {
        case is BookItem.Type:
            if DraftBookService.shared.isDraft(item: item) {
                return draftBookSource as? SettingsSourceEntity<ExternalItem>
            }
            return availableBookSources.first { $0.id == name } as? SettingsSourceEntity<ExternalItem>
        case is MovieItem.Type:
            if DraftMovieService.shared.isDraft(item: item) {
                return draftMovieSource as? SettingsSourceEntity<ExternalItem>
            }
            return availableVideoSources.first { $0.id == name } as? SettingsSourceEntity<ExternalItem>
        default:
            return nil
        }
    }
}

struct SettingsSourceEntity<ExternalItem: ExternalMediaItem>: Identifiable, Equatable, Hashable {
    let id: String
    let instance: any SearchService<ExternalItem>
    
    static func == (lhs: SettingsSourceEntity, rhs: SettingsSourceEntity) -> Bool {
        type(of: lhs.instance).serviceName == type(of: rhs.instance).serviceName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
