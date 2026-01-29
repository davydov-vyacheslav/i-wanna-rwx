//
//  ReminderPersistenceService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import Foundation
import SwiftData

@MainActor
class ReminderPersistenceService {

    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }
    
    func findByTypeAndExpiration(_ typeFilter: ReminderItem.ReminderType?, _ isExpiring: Bool, _ text: String) -> [ReminderItem] {

        
        var predicate: Predicate<ReminderItem>? = nil

        if let typeFilter, !text.isEmpty {
            let raw = typeFilter.rawValue
            predicate = #Predicate { item in
                item.type == raw &&
                (
                    item.name.contains(text) ||
                    item.itemDescription.contains(text)
                )
            }
        } else if let typeFilter {
            let raw = typeFilter.rawValue
            predicate = #Predicate { item in
                item.type == raw
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
            print("Error fetching Reminders by filter: \(error)")
            return []
        }
    }
    
    func update(_ item: ReminderItem) {
        
        let targetID = item.id
        if let dbItem = try? modelContext.fetch(FetchDescriptor<ReminderItem>(
            predicate: #Predicate { $0.id == targetID }
        )).first {
            dbItem.name = item.name
            dbItem.itemDescription = item.itemDescription
            dbItem.renewalType = item.renewalType
            dbItem.customPeriodValue = item.customPeriodValue
            dbItem.customPeriodUnit = item.customPeriodUnit
            dbItem.expiryDate = item.expiryDate
            dbItem.licenseKey = item.licenseKey
            dbItem.reminderDays = item.reminderDays
            dbItem.cost = item.cost
            dbItem.notes = item.notes
            
            saveContext()
        }
        
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
            print("Error saving context: \(error)")
        }
    }

}
