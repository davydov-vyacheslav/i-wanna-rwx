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
        
        @Attribute(.unique) var id: UUID
        var typeRaw: String
        var name: String
        var itemDescription: String
        var renewalTypeRaw: String
        var customPeriodValue: Int?
        var customPeriodUnitRaw: String?
        var expiryDate: Date?
        var licenseKey: String?
        var reminderDays: Int?
        var cost: String
        var notes: String
        

        init(id: UUID = UUID(),
             type: ReminderTypeV100,
             name: String,
             description: String,
             renewalType: RenewalTypeV100,
             customPeriodValue: Int? = nil,
             customPeriodUnit: PeriodUnitV100? = nil,
             expiryDate: Date? = nil,
             licenseKey: String? = nil,
             reminderDays: Int? = nil,
             cost: String,
             notes: String) {
            self.id = id
            self.typeRaw = type.rawValue
            self.name = name
            self.itemDescription = description
            self.renewalTypeRaw = renewalType.rawValue
            self.customPeriodValue = customPeriodValue
            self.customPeriodUnitRaw = customPeriodUnit?.rawValue
            self.expiryDate = expiryDate
            self.licenseKey = licenseKey
            self.reminderDays = reminderDays
            self.cost = cost
            self.notes = notes
        }

        // MARK: - Computed Properties
        
        @Transient
        var nextExpiryDate : Date? {
            
            let calendar: Calendar = .current
            let renewedExpirationDate: Date?
            guard let expiryDate = expiryDate else { return nil }
            
            switch renewalType {
            case .monthly:
                renewedExpirationDate = calendar.date(
                    byAdding: .month,
                    value: 1,
                    to: expiryDate
                )

            case .yearly:
                renewedExpirationDate = calendar.date(
                    byAdding: .year,
                    value: 1,
                    to: expiryDate
                )

            case .custom:
                renewedExpirationDate = calendar.date(
                    byAdding: customPeriodUnit?.asCalendarUnit ?? .day,
                    value: customPeriodValue ?? 0,
                    to: expiryDate
                )
            
            default: renewedExpirationDate = expiryDate
            }

            return renewedExpirationDate
        }
        
        @Transient
        var daysUntilExpiry: Int? {
            guard renewalType != RenewalTypeV100.lifetime, let expiryDate = expiryDate else { return nil }
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let expiryDay = calendar.startOfDay(for: expiryDate)
            return calendar.dateComponents([.day], from: today, to: expiryDay).day
        }
        
        @Transient
        var expirationStatus: ExpirationStatusV100 {
            ExpirationStatus.of(self)
        }

        @Transient
        var isExpired: Bool {
            expirationStatus == .expired
        }
        
        @Transient
        var isExpiringSoon: Bool {
            expirationStatus == .expiringSoon
        }

        @Transient
        var isExpiringCriticalSoon: Bool {
            expirationStatus == .expiringCritical
        }
        
        @Transient
        var isExpiringOrExpired: Bool {
            expirationStatus == .expired || expirationStatus == .expiringSoon || expirationStatus == .expiringCritical
        }

        @Transient
        var type: ReminderTypeV100 {
            get { ReminderTypeV100(rawValue: typeRaw) ?? .license }
            set { typeRaw = newValue.rawValue }
        }
        
        @Transient
        var renewalType: RenewalTypeV100 {
            get { RenewalTypeV100(rawValue: renewalTypeRaw) ?? .none }
            set { renewalTypeRaw = newValue.rawValue }
        }
        
        @Transient
        var customPeriodUnit: PeriodUnitV100? {
            get { guard let customPeriodUnitValue = customPeriodUnitRaw else { return nil }
                return PeriodUnitV100(rawValue: customPeriodUnitValue) }
            set { customPeriodUnitRaw = newValue?.rawValue }
        }
        
        @Transient
        var formattedRenewalType: String {
            let prefix = String(localized: ".label.reminder.renew_policy_prefix")
            
            switch renewalType {
            case .custom:
                guard let periodValue = customPeriodValue,
                      let unit = customPeriodUnit else {
                    return prefix
                }
                
                let each = String(localized: ".label.reminder.renew_policy_each")
                let unitName = String.localizedStringWithFormat(
                    NSLocalizedString(unit.displayNameSuffix, comment: ""),
                    periodValue
                )
                
                return "\(prefix) \(each) \(periodValue) \(unitName)"
                
            default:
                return "\(prefix) \(renewalType.displayName)"
            }
        }
    }
    


}


enum ReminderTypeV100: String, CaseIterable {
    case subscription = "subscription"
    case license = "license"
    
    var icon: String {
        switch self {
        case .subscription: return "arrow.triangle.2.circlepath"
        case .license: return "key.fill"
        }
    }
}

enum RenewalTypeV100: String, CaseIterable {
    case monthly = "monthly"
    case yearly = "yearly"
    case lifetime = "lifetime"
    case custom = "custom"
    case none = "-"
}

enum PeriodUnitV100: String, CaseIterable {
    case days = "days"
    case months = "months"
    case years = "years"
    
    var asCalendarUnit: Calendar.Component {
        let calendarUnit : Calendar.Component
        switch self {
        case .days:
            calendarUnit = .day
        case .months:
            calendarUnit = .month
        case .years:
            calendarUnit = .year
        }
        return calendarUnit
    }
}

enum ExpirationStatusV100: String, CaseIterable {
    case lifetime
    case active
    case expiringSoon
    case expiringCritical
    case expired
    
    static func of(_ item: ReminderItem) -> ExpirationStatus {
        if item.renewalType == RenewalType.lifetime {
            return .lifetime
        }
        
        guard let days = item.daysUntilExpiry else {
            return .active
        }
        
        if days < 0 {
            return .expired
        }
        
        guard let reminderDays = item.reminderDays else {
            return .active
        }
        
        if days <= reminderDays {
            return .expiringCritical
        } else if days <= (reminderDays * 2) {
            return .expiringSoon
        }
        
        return .active
    }
}
