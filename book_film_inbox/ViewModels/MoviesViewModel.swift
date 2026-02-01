//
//  MoviesViewModel.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftData
import Foundation
import Combine
import os

final class MoviesViewModel: MediaViewModel<MovieItem, MoviePersistenceService> {
    init() {
        super.init(
            storageService: MoviePersistenceService(context: ModelContext(PersistenceController.shared.container))
        )
    }

    func isInLibrary(sourceId: Int?, sourceName: String) -> Bool {
        storageService.isInLibrary(sourceId: sourceId, sourceName: sourceName)
    }
}
