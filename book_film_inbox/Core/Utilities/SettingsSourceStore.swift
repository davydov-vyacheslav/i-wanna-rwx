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
    
    func validateTokensOnStartup() async {
        Log.info(">> validateTokensOnStartup")
        let settingsService = SettingsService.shared

        let allSources: [any SearchService] =
            availableBookSources.map { $0.instance } +
            availableVideoSources.map { $0.instance }

        for source in allSources {
            let name = type(of: source).serviceName
            guard type(of: source).requiresToken else { continue }
            let token = settingsService.getToken(for: name)
            let isValid = await source.isTokenValid(token: token)
            if !isValid {
                Log.info("Token invalid on startup, removing", context: ["source": name])
                settingsService.removeToken(for: name)
            }
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
