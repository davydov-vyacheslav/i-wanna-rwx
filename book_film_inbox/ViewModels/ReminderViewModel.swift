//
//  ReminderViewModel.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import SwiftData
import Foundation
import Combine

@MainActor
class ReminderViewModel: ObservableObject {
    private let storageService = ReminderPersistenceService(context: ModelContext(PersistenceController.shared.container))
    private let notificationService = NotificationService.shared
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProlongateRequest),
            name: .prolongateReminder,
            object: nil
        )
    }
    
    @objc private func handleProlongateRequest(_ notification: Notification) throws {
        guard let itemId = notification.userInfo?["itemId"] as? UUID else { return }
        guard let item = storageService.findById(itemId) else { return }
        try prolongate(item)
    }

    func filteredItems(typeFilter: ReminderType?, isExpiring: Bool, text: String = "") -> [ReminderItem] {
        storageService.findByTypeAndExpiration(typeFilter, isExpiring, text)
    }
    
    func count(typeFilter: ReminderType?, isExpiring: Bool) -> Int {
        filteredItems(typeFilter: typeFilter, isExpiring: isExpiring).count
    }

    func addItem(_ item: ReminderItem) {
        storageService.add(item)
        objectWillChange.send()
        Task {
            await notificationService.scheduleNotification(for: item)
        }
    }
    
    func updateItem(_ item: ReminderItem) throws {
        try storageService.update(item)
        objectWillChange.send()
        Task {
            await notificationService.scheduleNotification(for: item)
        }
    }
    
    func deleteItem(_ item: ReminderItem) {
        storageService.delete(item)
        objectWillChange.send()
        Task {
            await notificationService.cancelNotification(for: item.id)
        }
    }
    
    func prolongate(_ item: ReminderItem) throws {
        item.expiryDate = item.nextExpiryDate
        try updateItem(item)
    }
    
    func findById(_ id: UUID) -> ReminderItem? {
        storageService.findById(id)
    }
}


