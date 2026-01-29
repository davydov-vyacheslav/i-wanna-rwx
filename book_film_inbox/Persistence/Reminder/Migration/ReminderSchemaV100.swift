//
//  ReminderSchemaV100.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import SwiftData
import Foundation

enum ReminderSchemaV100: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [ReminderItem.self]
    }
    
    @Model class ReminderItem {
        
        var id: UUID
        var type: String
        var name: String
        var itemDescription: String
        var renewalType: String
        var customPeriodValue: Int?
        var customPeriodUnit: String?
        var expiryDate: Date?
        var licenseKey: String?
        var reminderDays: Int?
        var cost: String
        var notes: String
        

        init(id: UUID = UUID(),
             type: ReminderType,
             name: String,
             description: String,
             renewalType: RenewalType,
             customPeriodValue: Int? = nil,
             customPeriodUnit: PeriodUnit? = nil,
             expiryDate: Date? = nil,
             licenseKey: String? = nil,
             reminderDays: Int? = nil,
             cost: String,
             notes: String) {
            self.id = id
            self.type = type.rawValue
            self.name = name
            self.itemDescription = description
            self.renewalType = renewalType.rawValue
            self.customPeriodValue = customPeriodValue
            self.customPeriodUnit = customPeriodUnit?.rawValue
            self.expiryDate = expiryDate
            self.licenseKey = licenseKey
            self.reminderDays = reminderDays
            self.cost = cost
            self.notes = notes
        }

        // MARK: - Enums
        
        enum ReminderType: String, Codable, CaseIterable {
            case subscription = "subscription"
            case license = "license"
            
            var icon: String {
                switch self {
                case .subscription: return "arrow.triangle.2.circlepath"
                case .license: return "key.fill"
                }
            }
        }
        
        enum RenewalType: String, Codable, CaseIterable {
            case monthly = "monthly"
            case yearly = "yearly"
            case lifetime = "lifetime"
            case custom = "custom"
            case none = "-"
        }
        
        enum PeriodUnit: String, Codable, CaseIterable {
            case days = "days"
            case months = "months"
            case years = "years"
        }
        
        // MARK: - Computed Properties
        
        var daysUntilExpiry: Int? {
            guard renewalType != RenewalType.lifetime.rawValue, let expiryDate = expiryDate else { return nil }
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: Date(), to: expiryDate)
            return components.day
        }
        
        var isExpired: Bool {
            guard
                let days = daysUntilExpiry,
                let reminderDays = reminderDays
            else {
                return false
            }
            return days < 0
        }
        
        var isExpiringSoon: Bool {
            guard
                let days = daysUntilExpiry,
                let reminderDays = reminderDays
            else {
                return false
            }
            return days > 0 && days <= reminderDays * 2
        }

        var isExpiringCriticalSoon: Bool {
            guard
                let days = daysUntilExpiry,
                let reminderDays = reminderDays
            else {
                return false
            }
            return days > 0 && days <= reminderDays
        }
        
        var isExpiringOrExpired: Bool {
            guard
                let days = daysUntilExpiry,
                let reminderDays = reminderDays
            else {
                return false
            }
            return days <= reminderDays * 2
        }

    }
}
