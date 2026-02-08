//
//  NavigationManager.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 07.02.2026.
//

import SwiftUI
import Foundation

@Observable
class NavigationManager {
    static let shared = NavigationManager()
    
    var _selectedTab: Tab
    var selectedTab: Tab {
        get { _selectedTab }
        set {
            _selectedTab = newValue
            saveSelectedTab(newValue)
        }
    }
    
    var booksPath = NavigationPath()
    var moviesPath = NavigationPath()
    var remindersPath = NavigationPath()
    var settingsPath = NavigationPath()
    
    private init() {
        self._selectedTab = Self.loadSelectedTab()
    }
    
    // MARK: - Tab Persistence
    
    private static let selectedTabKey = "selectedTab"
    
    private static func loadSelectedTab() -> Tab {
        guard let rawValue = UserDefaults.standard.string(forKey: selectedTabKey),
              let tab = Tab(rawValue: rawValue) else {
            return .books // Default tab
        }
        return tab
    }
    
    private func saveSelectedTab(_ tab: Tab) {
        UserDefaults.standard.set(tab.rawValue, forKey: Self.selectedTabKey)
        Log.debug("💾 Saved selected tab", context: ["tab": tab.rawValue])
    }
    
    // MARK: - Tab Navigation
    
    func switchToTab(_ tab: Tab) {
        selectedTab = tab
        Log.debug("📱 Switched to tab", context: ["tab": tab.rawValue])
    }
    
    // MARK: - Reminder Navigation
    
    func openReminderDetails(id: UUID) {
        switchToTab(.reminders)
        remindersPath.append(ReminderRoute.details(id))
        Log.debug("📱 Navigating to reminder details", context: ["id": id.uuidString])
    }
    
    func prolongateAndOpenReminder(id: UUID) {
        switchToTab(.reminders)
        remindersPath.append(ReminderRoute.prolongateAndView(id))
        Log.debug("📱 Prolongating and opening reminder", context: ["id": id.uuidString])
    }
    
    // MARK: - Reset Navigation
    
    func resetCurrentTabNavigation() {
        switch selectedTab {
        case .books:
            booksPath = NavigationPath()
        case .movies:
            moviesPath = NavigationPath()
        case .reminders:
            remindersPath = NavigationPath()
        case .settings:
            settingsPath = NavigationPath()
        }
    }
    
    func resetAllNavigation() {
        booksPath = NavigationPath()
        moviesPath = NavigationPath()
        remindersPath = NavigationPath()
        settingsPath = NavigationPath()
    }
}

// MARK: - Tab Enum

enum Tab: String, CaseIterable {
    case books = "books"
    case movies = "movies"
    case reminders = "reminders"
    case settings = "settings"
    
    var title: LocalizedStringKey {
        switch self {
        case .books: return ".title.book.list"
        case .movies: return ".title.movie.list"
        case .reminders: return ".title.reminder.list"
        case .settings: return ".title.settings"
        }
    }
    
    var icon: String {
        switch self {
        case .books: return "book"
        case .movies: return "film"
        case .reminders: return "repeat"
        case .settings: return "gear"
        }
    }
}

// MARK: - Navigation Routes

enum ReminderRoute: Hashable {
    case details(UUID)
    case prolongateAndView(UUID)
    case edit(UUID)
}

enum BookRoute: Hashable {
    
}

enum MovieRoute: Hashable {
    
}

enum SettingsRoute: Hashable {
    
}
