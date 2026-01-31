//
//  SettingsSourceEntity.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

import Foundation
import Combine

class SettingsSourceStore: ObservableObject {
    
    static let shared = SettingsSourceStore()
    
    @Published var availableBookSources: [SettingsSourceEntity] = [ ]
    @Published var availableVideoSources: [SettingsSourceEntity] = [ ]

    private init() {
        reloadSources()
    }
    
    func reloadSources() {
        availableBookSources = [
            SettingsSourceEntity(id: OpenLibraryService.serviceName, instance: OpenLibraryService()),
            //SettingsSourceEntity(instance: XDummyBookSearchService())
        ]
        
        availableVideoSources = [
            SettingsSourceEntity(id: TMDbService.serviceName,  instance: TMDbService()),
        ]
    }
}

struct SettingsSourceEntity: Identifiable, Equatable {
    let id: String
    let instance: any SearchService
    
    static func == (lhs: SettingsSourceEntity, rhs: SettingsSourceEntity) -> Bool {
        type(of: lhs.instance).serviceName == type(of: lhs.instance).serviceName
    }
}
