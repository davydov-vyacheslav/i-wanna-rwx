//
//  SettingsViewModel.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var expandedSources: Set<String> = []
    @Published var editingSource: String? = nil
    @Published var tempToken: String = ""
    @Published var showToken: Set<String> = []
    
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
        objectWillChange.send()
        SettingsSourceStore.shared.reloadSources()
    }
    
    func removeToken(for source: String) {
        service.removeToken(for: source)
        objectWillChange.send()
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
    
    func saveEditing(for source: String) {
        guard !tempToken.isEmpty else { return }
        saveToken(for: source, token: tempToken)
        editingSource = nil
        tempToken = ""
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
