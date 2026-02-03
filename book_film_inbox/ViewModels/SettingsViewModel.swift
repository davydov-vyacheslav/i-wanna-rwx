//
//  SettingsViewModel.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation
import Combine

@Observable
class SettingsViewModel: ObservableObject {
    var expandedSources: Set<String> = []
    var editingSource: String? = nil
    var tempToken: String = ""
    var showToken: Set<String> = []
    
    private let service: SettingsService
    
    init(service: SettingsService = SettingsService.shared) {
        self.service = service
    }
    
    func getToken(for source: String) -> String? {
        return service.getToken(for: source)
    }
    
    func hasToken(for source: String) -> Bool {
        return getToken(for: source) != nil
    }
    
    func saveToken(for source: String, token: String) {
        service.saveToken(for: source, token: token)
        SettingsSourceStore.shared.reloadSources()
    }
    
    func removeToken(for source: String) {
        service.removeToken(for: source)
        SettingsSourceStore.shared.reloadSources()
    }
    
    func toggleExpanded(for source: String) {
        if expandedSources.contains(source) {
            expandedSources.remove(source)
        } else {
            expandedSources.insert(source)
        }
    }
    
    func startEditing(for source: String) {
        editingSource = source
        tempToken = ""
    }
    
    func cancelEditing() {
        editingSource = nil
        tempToken = ""
    }
    
    func saveEditing(for searchService: any SearchService) async -> Bool {
        guard !tempToken.isEmpty else { return false }
        
        if await searchService.isTokenValid(token: tempToken) == false {
            return false
        }
        let serviceName = type(of: searchService).serviceName
        
        saveToken(for: serviceName, token: tempToken)
        editingSource = nil
        tempToken = ""
        toggleExpanded(for: serviceName)
        return true
    }
    
    func toggleShowToken(for source: String) {
        if showToken.contains(source) {
            showToken.remove(source)
        } else {
            showToken.insert(source)
        }
    }
    
    func getDisplayToken(for source: String) -> String {
        guard let token = getToken(for: source) else { return "" }
        
        if showToken.contains(source) {
            return token
        } else {
            return String(repeating: "•", count: min(token.count, 20))
        }
    }
}
