//
//  SubscriptionItemCard.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import SwiftUI

struct ReminderItemCard: View {
    
    let item: ReminderItem
    
    var body: some View {
        HStack(spacing: 14) {

            Text(IconGenerator.suggestIcon(for: item.name))
                .font(.largeTitle)
                .frame(width: 56, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ReminderItemHelper.getColor(item).opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(16)
                .grayscale(item.isExpired ? 1 : 0)
                .accessibilityHidden(true)

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
                            text: item.isExpired ? ".label.reminder.expired" : nil,
                            textVerbatim: item.isExpired ? nil : PeriodUnit.days.displayNamePluralSuffix(amount: days),
                            color: ReminderItemHelper.getColor(item)
                        )
                    } else {
                        StatusBadge(
                            icon: "infinity",
                            text: nil,
                            color: Color.green
                        )
                    }
                    
                    Spacer()
                    
                    StatusBadge(
                        icon: item.type.icon,
                        text: item.type.displayName,
                        color: Color.gray,
                    )
                    
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(reminderAccessibilityLabel)
    }

    private var reminderAccessibilityLabel: String {
        var parts: [String] = [item.name]
        if !item.cost.isEmpty { parts.append(item.cost) }
        if item.isExpired {
            parts.append(String(localized: ".label.reminder.expired"))
        } else if let days = item.daysUntilExpiry {
            parts.append(PeriodUnit.days.displayNamePluralSuffix(amount: days))
        } else {
            parts.append(RenewalType.lifetime.displayName)
        }
        return parts.joined(separator: ", ")
    }
}


#Preview {
    ReminderItemCard(item: ReminderItem(
        type: ReminderType.license,
        name: "Soma name",
        description: "Description",
        renewalType: RenewalType.monthly,
        customPeriodValue: 3,
        customPeriodUnit: PeriodUnit.days,
        expiryDate: CommonConstants.calendar.date(
            from: DateComponents(year: 2027, month: 1, day: 28)
        ),
        licenseKey: "secret one",
        reminderDays: 3,
        cost: "100500",
        notes: "notes"))
}
