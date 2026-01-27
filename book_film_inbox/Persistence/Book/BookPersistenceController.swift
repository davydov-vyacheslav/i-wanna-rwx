//
//  BookPersistenceController.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftData
import Foundation

@MainActor
final class BookPersistenceController {

    static let shared = BookPersistenceController()

    let container: ModelContainer
    let context: ModelContext

    private init() {
        do {

            let configuration = ModelConfiguration(
                schema: Schema(versionedSchema: BookSchemaV102.self),
                url: URL.applicationSupportDirectory.appending(path: "books.store")
            )
            
            container = try ModelContainer(
                for: BookSchemaV102.BookItem.self,
                migrationPlan: BookMigrationPlan.self,
                configurations: configuration
            )
            
            context = ModelContext(container)
            context.autosaveEnabled = true
        } catch {
            fatalError("Book store init failed: \(error)")
        }
    }
}
