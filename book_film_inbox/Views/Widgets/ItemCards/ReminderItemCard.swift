//
//  SubscriptionItemCard.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import SwiftUI

struct ReminderItemCard: View {
    
    let iconGenerator: IconGenerator = IconGenerator.shared
    let item: ReminderItem
    
    var body: some View {
        HStack(spacing: 14) {

            Text(iconGenerator.suggestIcon(for: item.name))
                .font(.largeTitle)
                .frame(width: 56, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(item.statusColor.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(16)
                .grayscale(item.isExpired ? 1 : 0)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .opacity(item.isExpired ? 0.6 : 1)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if !item.cost.isEmpty {
                        Text(item.cost)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .opacity(item.isExpired ? 0.4 : 1)
                    }
                }
                
                // Badges
                HStack(spacing: 8) {
                    
                    if let days = item.daysUntilExpiry {
                        StatusBadge(
                            icon: "calendar",
                            text: item.isExpired ? ".label.reminder.expired" : ".label.reminder.expired_in_days \(days)",
                            color: item.statusColor
                        )
                    } else { // FIXME
                        StatusBadge(
                            icon: "infinity",
                            text: nil,
                            color: Color.green
                        )
                    }
                    
                    Spacer()
                    
                    StatusBadge(
                        icon: ReminderItem.ReminderType(rawValue: item.type)!.icon,
                        text: ReminderItem.ReminderType(rawValue: item.type)!.displayName,
                        color: Color.gray,
                    )
                    
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
    }
}


#Preview {
    ReminderItemCard(item: ReminderItem(
        type: ReminderItem.ReminderType.license,
        name: "Soma name",
        description: "Description",
        renewalType: ReminderItem.RenewalType.monthly,
        customPeriodValue: 3,
        customPeriodUnit: ReminderItem.PeriodUnit.days,
        expiryDate: Calendar.current.date(
            from: DateComponents(year: 2027, month: 1, day: 28)
        ),
        licenseKey: "secret one",
        reminderDays: 3,
        cost: "100500",
        notes: "notes"))
    ReminderItemCard(item: ReminderItem(
        type: ReminderItem.ReminderType.subscription,
        name: "Soma name",
        description: "Description",
        renewalType: ReminderItem.RenewalType.lifetime,
        customPeriodValue: 3,
        customPeriodUnit: ReminderItem.PeriodUnit.days,
        expiryDate: Calendar.current.date(
            from: DateComponents(year: 2027, month: 1, day: 28)
        ),
        licenseKey: "secret one",
        reminderDays: 3,
        cost: "100500",
        notes: "notes"))
    ReminderItemCard(item: ReminderItem(
        type: ReminderItem.ReminderType.subscription,
        name: "Soma name",
        description: "Description",
        renewalType: ReminderItem.RenewalType.custom,
        customPeriodValue: 3,
        customPeriodUnit: ReminderItem.PeriodUnit.days,
        expiryDate: Calendar.current.date(
            from: DateComponents(year: 2026, month: 1, day: 31)
        ),
        licenseKey: "secret one",
        reminderDays: 3,
        cost: "100500",
        notes: "notes"))
}
