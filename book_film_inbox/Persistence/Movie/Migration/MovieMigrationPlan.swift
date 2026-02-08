//
//  MovieMigrationPlan.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 08.02.2026.
//

import SwiftData

enum MovieMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [MovieSchemaV100.self]
    }
    
    static var stages: [MigrationStage] {
        []
    }
}
