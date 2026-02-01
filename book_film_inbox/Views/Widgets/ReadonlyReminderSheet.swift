//
//  ReadonlyReminderSheet.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import SwiftUI

struct ReadonlyReminderSheet: View {
    
    @ObservedObject var viewModel: ReminderViewModel
    let item: ReminderItem
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header: Icon + Name + Type Badge
                    HStack(spacing: 16) {
                        Text(IconGenerator.suggestIcon(for: item.name))
                            .font(.largeTitle)
                            .grayscale(item.isExpired ? 1 : 0)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name)
                                .font(.title)
                                .opacity(item.isExpired ? 0.6 : 1)
                            
                            HStack(spacing: 16) {
                                StatusBadge(
                                    icon: item.type.icon,
                                    text: item.type.displayName,
                                    color: Color.gray,
                                )
                                
                                Spacer()

                                if !item.cost.isEmpty {
                                    StatusBadge(
                                        icon: "dollarsign.circle",
                                        textVerbatim: item.cost,
                                        color: Color.green,
                                    )
                                }
                            }
                        }
                        
                    }
                    .padding(.bottom, 8)
                    
                    if !item.itemDescription.isEmpty {
                        Text(item.itemDescription)
                            .font(.body)
                            .opacity(0.6)
                            .padding(.bottom, 8)
                    }
                    
                    ReminderSimpleInfoField(title: ".label.reminder.price", text: item.cost)
                    
                    
                    // Expiry + Periodicity (combined)
                    if item.renewalType == RenewalType.lifetime {
                        HStack(spacing: 8) {
                            Image(systemName: "infinity")
                            Text(RenewalType.lifetime.displayName)
                        }
                        .foregroundColor(Color.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                    } else {
                        ReminderInfoField(title: ".label.reminder.renew_info") {
                           
                            if item.expiryDate == nil {
                                Text(".label.reminder.expiration_date_not_set")
                            } else if let date = item.expiryDate {
                                let formattedDate = date.formatted(
                                    Date.FormatStyle()
                                        .day(.defaultDigits)
                                        .month(.wide)
                                        .year(.defaultDigits)
                                )
                                Text(".label.reminder.expiration_date \(formattedDate)")
                            }
                            
                            Text(item.formattedRenewalType)

                            if (item.reminderDays ?? -1) > 0 {
                                Text(".label.reminder.remind_in_days \(item.reminderDays!)")
                            }

                            if let days = item.daysUntilExpiry {
                                StatusBadge(icon: "calendar", text: item.isExpired
                                            ? ".label.reminder.expired"
                                            : days == 0
                                                ? ".label.reminder.expire_today"
                                                : ".label.reminder.expire_left_days \(days)",
                                            color: item.statusColor)
                            }
                                
                            
                        }
                        
                    }
                    
                    if item.type == ReminderType.license,
                        let licenseKey = item.licenseKey,
                        !licenseKey.isEmpty {
                        
                        ReminderInfoField(title: ".label.reminder.license_key") {
                            CopyableText(text: licenseKey)
                        }
                    }
                    
                    ReminderSimpleInfoField(title: ".label.reminder.notes", text: item.notes)
                    
                    // Action Buttons
                    HStack(spacing: 8) {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label(".button.edit", systemImage: "pencil")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 32)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .controlSize(.large)
                        .lineLimit(1)
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label(".button.delete", systemImage: "trash")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 32)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .controlSize(.large)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(".button.close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                AddEditReminderSheet(viewModel: viewModel, item: item)
            }
            .alert(".label.common.remove \(item.name)", isPresented: $showingDeleteAlert) {
                Button(".button.cancel", role: .cancel) { }
                Button(".button.delete", role: .destructive) {
                    viewModel.deleteItem(item)
                    dismiss()
                }
            }
        }
    }

}


// MARK: - Field representation

struct ReminderSimpleInfoField: View {
    let title: LocalizedStringKey
    let text: String
    
    init(title: LocalizedStringKey, text: String) {
        self.title = title
        self.text = text
    }
    
    var body: some View {
        if !text.isEmpty {
            ReminderInfoField(title: title) {
                Text(text)
            }
        }
    }
}

struct ReminderInfoField<Content: View>: View {
    let title: LocalizedStringKey
    let content: Content
    
    init(title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .opacity(0.5)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

   
#Preview {
    ReadonlyReminderSheet(viewModel: ReminderViewModel(), item: ReminderItem(
        type: ReminderType.license,
        name: "Item Name",
        description: "Item Description",
        renewalType: RenewalType.custom,
        customPeriodValue: 3,
        customPeriodUnit: PeriodUnit.days,
        expiryDate: Date(),
        licenseKey: "asdfghjkl;lkjhgfdsassdsasdsadasdasdasdasddfghjkl",
        reminderDays: 4,
        cost: "$100",
        notes: "Some Notes"
    ))
    
//    ReadonlyReminderSheet(viewModel: ReminderViewModel(), item: ReminderItem(
//        type: ReminderItem.ReminderType.license,
//        name: "Item Name",
//        description: "",
//        renewalType: ReminderSchemaV100.ReminderItem.RenewalType.lifetime,
//        reminderDays: 0,
//        cost: "",
//        notes: ""
//    ))
    
}
