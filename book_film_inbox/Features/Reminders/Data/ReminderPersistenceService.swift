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
    }
    
    func findById(_ itemId: UUID) -> ReminderItem? {
        let predicate = #Predicate<ReminderItem> { $0.id == itemId }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            Log.error("Error finding reminder by ID", error: error, context: ["id": itemId.uuidString])
            return nil
        }
    }
    
    func add(_ item: ReminderItem) {
        modelContext.insert(item)
        
        do {
            try modelContext.save()
            Log.info("📝 Reminder added", context: ["name": item.name])
            
            Task {
                await notificationService.scheduleNotification(for: item)
            }
        } catch {
            Log.error("Failed to add reminder", error: error, context: ["name": item.name])
        }
    }

    func update(_ item: ReminderItem) throws {
        
        let targetID = item.id
        let descriptor = FetchDescriptor<ReminderItem>(
            predicate: #Predicate { $0.id == targetID }
        )
        
        guard let dbItem = try modelContext.fetch(descriptor).first else {
            Log.error("Reminder not found for update", context: ["id": item.id.uuidString])
            throw ReminderError.notFound
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
            
        try modelContext.save()
        Log.info("✏️ Reminder updated", context: ["name": item.name])
        
        Task {
            await notificationService.scheduleNotification(for: dbItem)
        }
        
    }
    
    func delete(_ item: ReminderItem) {
        modelContext.delete(item)
        
        do {
            try modelContext.save()
            Log.info("🗑️ Reminder deleted", context: ["name": item.name])
            
            Task {
                await notificationService.cancelNotification(for: item.id)
            }
        } catch {
            Log.error("Failed to delete reminder", error: error, context: ["name": item.name])
        }
    }
    
    func prolongate(_ item: ReminderItem) throws {
        guard let nextDate = item.nextExpiryDate else {
            Log.error("Cannot prolongate: no next expiry date", context: ["name": item.name])
            throw ReminderError.cannotProlongate
        }
        
        item.expiryDate = nextDate
        try update(item)
        
        Log.info("🔄 Reminder prolongated", context: [
            "name": item.name,
            "newDate": nextDate
        ])
    }

}

enum ReminderError: LocalizedError {
    case notFound
    case cannotProlongate
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return String(localized: ".error.reminder.not_found")
        case .cannotProlongate:
            return String(localized: ".error.reminder.cannot_prolongate")
        }
    }
}
