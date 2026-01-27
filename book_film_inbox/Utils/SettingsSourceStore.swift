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

    init() {
        reloadSources()
    }
    
    func reloadSources() {
        availableBookSources = [
            SettingsSourceEntity(instance: OpenLibraryService()),
            SettingsSourceEntity(instance: XDummyBookSearchService())
        ]
        
        availableVideoSources = [
            SettingsSourceEntity(instance: OpenLibraryService()),
        ]
    }
}

struct SettingsSourceEntity: Identifiable, Equatable {
    let id: UUID = UUID()
    let instance: any SearchService
    
    static func == (lhs: SettingsSourceEntity, rhs: SettingsSourceEntity) -> Bool {
        lhs.instance.serviceName == rhs.instance.serviceName
    }
}
