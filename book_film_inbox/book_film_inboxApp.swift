//
//  book_film_inboxApp.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI
import SwiftData

@main
struct InboxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            switch PersistenceController.shared {
            case .success(let controller):
                ContentView()
                    .environment(SettingsService.shared)
                    .environment(BookPersistenceService(context: controller.container.mainContext))
                    .environment(MoviePersistenceService(context: controller.container.mainContext))
                    .environment(ReminderPersistenceService(context: controller.container.mainContext))
                    .modelContainer(controller.container)
            case .failure(let error):
                PersistenceErrorView(error: error)
            }
        }
    }
}
