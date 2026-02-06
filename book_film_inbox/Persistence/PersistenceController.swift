//
//  PersistenceController.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 01.02.2026.
//

import SwiftData
import Foundation

class PersistenceController {
    static let shared: Result<PersistenceController, PersistenceError> = {
        do {
            let controller = try PersistenceController()
            return .success(controller)
        } catch {
            return .failure(.containerCreationFailed(error))
        }
    }()
    
    let container: ModelContainer
    
    private init() throws {
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
    }
}

enum PersistenceError: Error {
    case containerCreationFailed(Error)
}
