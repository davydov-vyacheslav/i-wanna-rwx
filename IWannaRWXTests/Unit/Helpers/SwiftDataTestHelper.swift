//
//  SwiftDataTestHelper.swift
//  book_film_inboxTests
//

import SwiftData
import Foundation
@testable import IWannaRWX

enum SwiftDataTestHelper {

    static func makeContainer(for models: any PersistentModel.Type...) throws -> ModelContainer {
        let schema = Schema(models)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    static func reminderContainer() throws -> ModelContainer {
        try makeContainer(for: ReminderItem.self)
    }

    @discardableResult
    static func insert<T: PersistentModel>(_ item: T, into context: ModelContext) -> T {
        context.insert(item)
        return item
    }
}
