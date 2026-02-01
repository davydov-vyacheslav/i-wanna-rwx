//
//  PersistenceController.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 01.02.2026.
//

import SwiftData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: ModelContainer
    
    private init() {
        do {

            let schema = Schema([
                BookItem.self,
                MovieItem.self,
                ReminderItem.self
            ])
            
            let configuration = ModelConfiguration(
                schema: schema,
                url: URL.applicationSupportDirectory.appending(path: "inbox.store"),
                allowsSave: true,
                cloudKitDatabase: .automatic
            )
            
            self.container = try ModelContainer(
                for: schema,
                configurations: [configuration],
            )
            
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
