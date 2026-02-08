//
//  ProlongateReminderView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 08.02.2026.
//

import SwiftUI

struct ProlongateReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationManager.self) private var navigation
    
    let persistenceService: ReminderPersistenceService
    let item: ReminderItem
    
    @State private var isProlongating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ReadonlyReminderSheet(
            persistenceService: persistenceService,
            item: item
        )
        .task {
            await prolongate()
        }
        .alert(".title.error", isPresented: $showError) {
            Button(".button.ok") {
                navigation.remindersPath.removeLast()
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func prolongate() async {
        isProlongating = true
        
        do {
            try persistenceService.prolongate(item)
            Log.info("🔄 Reminder prolongated from notification", context: ["name": item.name])
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            Log.error("Failed to prolongate reminder", error: error, context: ["name": item.name])
        }
        
        isProlongating = false
    }
}
