//
//  ReminderForm.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 05.02.2026.
//

import Foundation
import Combine

@Observable
final class ReminderForm {

    var type: ReminderType = .subscription
    var name: String = ""
    var description: String = ""
    var renewalType: RenewalType = .monthly

    var customPeriodValue: Int = 0
    var customPeriodUnit: PeriodUnit = .days

    var expiryDate: Date = Date().addingTimeInterval(86400)
    var licenseKey: String = ""
    var reminderDays: Int = 3
    var cost: String = ""
    var notes: String = ""

    init(item: ReminderItem?) {
        guard let item else { return }

        type = item.type
        name = item.name
        description = item.itemDescription
        renewalType = item.renewalType
        customPeriodValue = item.customPeriodValue ?? 0
        customPeriodUnit = item.customPeriodUnit ?? .days
        expiryDate = item.expiryDate ?? expiryDate
        licenseKey = item.licenseKey ?? ""
        reminderDays = item.reminderDays ?? reminderDays
        cost = item.cost
        notes = item.notes
    }

    func makeReminder(id: UUID) -> ReminderItem {
        ReminderItem(
            id: id,
            type: type,
            name: name,
            description: description,
            renewalType: renewalType,
            customPeriodValue: renewalType == .custom ? customPeriodValue : nil,
            customPeriodUnit: renewalType == .custom ? customPeriodUnit : nil,
            expiryDate: renewalType != .lifetime ? expiryDate : nil,
            licenseKey: licenseKey,
            reminderDays: renewalType != .lifetime ? reminderDays : nil,
            cost: cost,
            notes: notes
        )
    }

    var isValid: Bool {
        !name.isEmpty
    }
}
