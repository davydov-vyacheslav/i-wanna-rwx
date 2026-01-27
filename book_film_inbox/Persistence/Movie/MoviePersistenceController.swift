//
//  BookPersistenceController.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftData
import Foundation

@MainActor
final class MoviePersistenceController {

    static let shared = MoviePersistenceController()

    let container: ModelContainer
    let context: ModelContext

    private init() {
        do {
            let configuration = ModelConfiguration(
                url: URL.applicationSupportDirectory
                    .appending(path: "movies.store")
            )

            container = try ModelContainer(
                for: MovieItem.self,
                configurations: configuration
            )

            context = ModelContext(container)
            context.autosaveEnabled = true
        } catch {
            fatalError("Movie store init failed: \(error)")
        }
    }
}
