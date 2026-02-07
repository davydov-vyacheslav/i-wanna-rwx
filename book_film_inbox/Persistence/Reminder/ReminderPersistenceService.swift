//
//  ReminderPersistenceService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import Foundation
import SwiftData

@MainActor
@Observable
class ReminderPersistenceService {

    private let modelContext: ModelContext
    private let notificationService = NotificationService.shared

    init(context: ModelContext) {
        self.modelContext = context
        
        // Обрабатываем prolongate запросы напрямую в сервисе
        NotificationCenter.default.addObserver(
            forName: .prolongateReminder,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let itemId = notification.userInfo?["itemId"] as? UUID else { return }
            
            Task { @MainActor [weak self] in
                guard let self = self,
                      let item = self.findById(itemId) else { return }
                
                do {
                    try self.prolongate(item)
                } catch {
                    Log.error("Error prolongating reminder", error: error)
                }
            }
        }
    }
    
    func makeFilterPredicate(typeFilter: ReminderType?, text: String) -> Predicate<ReminderItem>? {
        if let typeFilter, !text.isEmpty {
            let raw = typeFilter.rawValue
            return #Predicate { item in
                item.typeRaw == raw &&
                (item.name.contains(text) || item.itemDescription.contains(text))
            }
        } else if let typeFilter {
            let raw = typeFilter.rawValue
            return #Predicate { item in
                item.typeRaw == raw
            }
        } else if !text.isEmpty {
            return #Predicate { item in
                item.name.contains(text) || item.itemDescription.contains(text)
            }
        }
        return nil
    }
    
    func findById(_ itemId: UUID) -> ReminderItem? {
        let predicate = #Predicate<ReminderItem> { $0.id == itemId }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        guard let item = try? modelContext.fetch(descriptor).first else { return nil }
        return item
    }
    
    func findByTypeAndExpiration(_ typeFilter: ReminderType?, _ isExpiring: Bool, _ text: String) -> [ReminderItem] {

        let predicate = makeFilterPredicate(typeFilter: typeFilter, text: text)
        
        let descriptor: FetchDescriptor<ReminderItem>
        if let predicate = predicate {
            descriptor = FetchDescriptor<ReminderItem>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.name)]
            )
        } else {
            descriptor = FetchDescriptor<ReminderItem>(
                sortBy: [SortDescriptor(\.name)]
            )
        }
        
        do {
            let items = try modelContext.fetch(descriptor)
            
            let filtered = items.filter {
                !isExpiring || $0.isExpiringOrExpired
            }
            
            return filtered
        } catch {
            Log.error("Error fetching Reminders by filter", error: error)
            return []
        }
    }
    
    func update(_ item: ReminderItem) throws {
        
        let targetID = item.id
        let descriptor = FetchDescriptor<ReminderItem>(
            predicate: #Predicate { $0.id == targetID }
        )
        
        guard let dbItem = try modelContext.fetch(descriptor).first else {
            Log.error("Reminder not found for update")
            return
        }
        
        dbItem.name = item.name
        dbItem.itemDescription = item.itemDescription
        dbItem.renewalTypeRaw = item.renewalTypeRaw
        dbItem.customPeriodValue = item.customPeriodValue
        dbItem.customPeriodUnitRaw = item.customPeriodUnitRaw
        dbItem.expiryDate = item.expiryDate
        dbItem.licenseKey = item.licenseKey
        dbItem.reminderDays = item.reminderDays
        dbItem.cost = item.cost
        dbItem.notes = item.notes
            
        try? modelContext.save()
        Task {
            await notificationService.scheduleNotification(for: item)
        }
        
    }
    func add(_ item: ReminderItem) {
        modelContext.insert(item)
        try? modelContext.save()
        Task {
            await notificationService.scheduleNotification(for: item)
        }
    }
    
    func delete(_ item: ReminderItem) {
        modelContext.delete(item)
        try? modelContext.save()
        Task {
            await notificationService.cancelNotification(for: item.id)
        }
    }
    
    func prolongate(_ item: ReminderItem) throws {
        item.expiryDate = item.nextExpiryDate
        try update(item)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
