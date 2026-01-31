//
//  ReminderPersistenceController.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import SwiftData
import Foundation

@MainActor
final class ReminderPersistenceController {

    static let shared = ReminderPersistenceController()

    let container: ModelContainer
    let context: ModelContext

    private init() {
        do {
            let configuration = ModelConfiguration(
                url: URL.applicationSupportDirectory
                    .appending(path: "reminders.store")
            )

            container = try ModelContainer(
                for: ReminderItem.self,
                configurations: configuration
            )

            context = ModelContext(container)
            context.autosaveEnabled = true
        } catch {
            fatalError("Reminder store init failed: \(error)")
        }
    }
}
