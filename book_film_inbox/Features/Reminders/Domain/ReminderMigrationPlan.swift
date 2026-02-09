//
//  ReminderMigrationPlan.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 08.02.2026.
//

import SwiftData

enum ReminderMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ReminderSchemaV100.self]
    }
    
    static var stages: [MigrationStage] {
        []
    }
}
