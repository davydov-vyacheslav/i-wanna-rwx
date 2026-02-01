//
//  ReminderPersistenceService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import Foundation
import SwiftData
import os

@MainActor
class ReminderPersistenceService {

    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }
    
    func findById(_ itemId: UUID) -> ReminderItem? {
        let predicate = #Predicate<ReminderItem> { $0.id == itemId }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        guard let item = try? modelContext.fetch(descriptor).first else { return nil }
        return item
    }
    
    func findByTypeAndExpiration(_ typeFilter: ReminderType?, _ isExpiring: Bool, _ text: String) -> [ReminderItem] {

        
        var predicate: Predicate<ReminderItem>? = nil

        if let typeFilter, !text.isEmpty {
            let raw = typeFilter.rawValue
            predicate = #Predicate { item in
                item.typeRaw == raw &&
                (
                    item.name.contains(text) ||
                    item.itemDescription.contains(text)
                )
            }
        } else if let typeFilter {
            let raw = typeFilter.rawValue
            predicate = #Predicate { item in
                item.typeRaw == raw
            }
        } else if !text.isEmpty {
            predicate = #Predicate { item in
                item.name.contains(text) ||
                item.itemDescription.contains(text)
            }
        }

        
        let descriptor = FetchDescriptor<ReminderItem>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            let items = try modelContext.fetch(descriptor)
            
            let filtered = items.filter {
                !isExpiring || $0.isExpiringOrExpired
            }
            
            return filtered
        } catch {
            Log.db.error("Error fetching Reminders by filter: \(error)")
            return []
        }
    }
    
    func update(_ item: ReminderItem) throws {
        
        let targetID = item.id
        let descriptor = FetchDescriptor<ReminderItem>(
            predicate: #Predicate { $0.id == targetID }
        )
        
        guard let dbItem = try modelContext.fetch(descriptor).first else {
            Log.db.error("Reminder not found for update")
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
            
        saveContext()
        
    }
    func add(_ item: ReminderItem) {
        modelContext.insert(item)
        saveContext()
    }
    
    func delete(_ item: ReminderItem) {
        modelContext.delete(item)
        saveContext()
    }
    
    // MARK: - Private Helper
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            Log.db.error("Error saving context: \(error)")
        }
    }

}
