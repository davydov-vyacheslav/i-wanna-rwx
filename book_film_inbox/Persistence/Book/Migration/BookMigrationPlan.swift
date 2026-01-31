//
//  BookMigrationPlan.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 04.12.2025.
//

import SwiftData


enum BookMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BookSchemaV100.self, BookSchemaV101.self, BookSchemaV102.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV100toV101, migrateV101toV102]
    }
    
    static let migrateV100toV101 = MigrationStage.custom(
        fromVersion: BookSchemaV100.self,
        toVersion: BookSchemaV101.self,
        willMigrate: { context in
            
            Log.db.info(">> Migration from V100 to V101")
            
            // Fetch all books from V1
            let books = try context.fetch(FetchDescriptor<BookSchemaV100.BookItem>())
            
            // Migrate each book
            for oldBook in books {
                
                // Map old status to new status
               let newStatus: MediaStatus
               switch oldBook.status {
               case "DONE", "COMPLETED":
                   newStatus = .done
               case "PENDING", "IN_PROGRESS":
                   newStatus = .planned
               default:
                   newStatus = .planned
               }
                
                // Create new book with migrated data
                let newBook = BookSchemaV101.BookItem(
                    id: oldBook.id,
                    description: oldBook.itemDescription,
                    isFavorite: oldBook.isFavorite,
                    rating: oldBook.rating,
                    sourceUrl: oldBook.sourceUrl,
                    coverImageData: oldBook.coverImageData,
                    status: newStatus,
                    title: oldBook.title,
                    year: oldBook.year
                )
                
                context.insert(newBook)
                context.delete(oldBook)
            }
            
            try context.save()
        },
        didMigrate: nil
    )
    
    static let migrateV101toV102 = MigrationStage.custom(
        fromVersion: BookSchemaV101.self,
        toVersion: BookSchemaV102.self,
        willMigrate: { context in
            
            Log.db.info(">> Migration from V101 to V102")
            
            // Fetch all books from V1
            let books = try context.fetch(FetchDescriptor<BookSchemaV101.BookItem>())
            
            // Migrate each book
            for oldBook in books {
                
                // Create new book with migrated data
                let newBook = BookSchemaV102.BookItem(
                    id: oldBook.id,
                    description: oldBook.itemDescription,
                    isFavorite: oldBook.isFavorite,
                    rating: oldBook.rating,
                    sourceUrl: oldBook.sourceUrl,
                    coverImageData: oldBook.coverImageData,
                    status: oldBook.status,
                    title: oldBook.title,
                    year: oldBook.year,
                    isbn: nil,
                    author: nil,
                    sourceName: CommonConstants.draftSourceType
                )
                
                context.insert(newBook)
                context.delete(oldBook)
            }
            
            try context.save()
        },
        didMigrate: nil
    )
    
    // static let migrateV101toV102 = MigrationStage.lightweight(
    //fromVersion: SchemaV101.self,
    //toVersion: SchemaV102.self
    //)
}
