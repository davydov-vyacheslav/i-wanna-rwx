//
//  AppState.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 26.11.2025.
//

import SwiftUI
import Foundation
import Combine

class AppState: ObservableObject {
    @Published var showDescription = false
    @Published var selectedDescription: String?
    
    func showDescriptionOverlay(_ description: String) {
        selectedDescription = description
        showDescription = true
    }
    
    func hideDescriptionOverlay() {
        showDescription = false
        selectedDescription = nil
    }
}
