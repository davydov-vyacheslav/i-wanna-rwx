//
//  BookMigrationPlan.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 04.12.2025.
//

import SwiftData

enum BookMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV100.self, SchemaV101.self, SchemaV102.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV100toV101, migrateV101toV102]
    }
    
    static let migrateV100toV101 = MigrationStage.custom(
        fromVersion: SchemaV100.self,
        toVersion: SchemaV101.self,
        willMigrate: { context in
            
            print(">> Migration from V100 to V101")
            
            // Fetch all books from V1
            let books = try context.fetch(FetchDescriptor<SchemaV100.BookItem>())
            
            // Migrate each book
            for oldBook in books {
                
                // Map old status to new status
               let newStatus: MediaStatus
               switch oldBook.status {
               case "DONE", "COMPLETED":
                   newStatus = .DONE
               case "PENDING", "IN_PROGRESS":
                   newStatus = .PLANNED
               default:
                   newStatus = .PLANNED
               }
                
                // Create new book with migrated data
                let newBook = SchemaV101.BookItem(
                    id: oldBook.id,
                    description: oldBook.itemDescription,
                    isFavourite: oldBook.isFavourite,
                    rating: oldBook.rating,
                    sourceUrl: oldBook.sourceUrl,
                    coverImageData: oldBook.coverImageData,
                    status: newStatus,
                    title: oldBook.title,
                    year: oldBook.year
                )
                
                context.insert(newBook)
            }
            
            // Delete old books
            for oldBook in books {
                context.delete(oldBook)
            }
            
            try context.save()
        },
        didMigrate: nil
    )
    
    static let migrateV101toV102 = MigrationStage.custom(
        fromVersion: SchemaV101.self,
        toVersion: SchemaV102.self,
        willMigrate: { context in
            
            print(">> Migration from V101 to V102")
            
            // Fetch all books from V1
            let books = try context.fetch(FetchDescriptor<SchemaV101.BookItem>())
            
            // Migrate each book
            for oldBook in books {
                
                // Create new book with migrated data
                let newBook = SchemaV102.BookItem(
                    id: oldBook.id,
                    description: oldBook.itemDescription,
                    isFavourite: oldBook.isFavourite,
                    rating: oldBook.rating,
                    sourceUrl: oldBook.sourceUrl,
                    coverImageData: oldBook.coverImageData,
                    status: oldBook.status,
                    title: oldBook.title,
                    year: oldBook.year,
                    isbn: nil,
                    author: nil,
                    isDraft: false
                )
                
                context.insert(newBook)
            }
            
            // Delete old books
            for oldBook in books {
                context.delete(oldBook)
            }
            
            try context.save()
        },
        didMigrate: nil
    )
}
