//
//  AddEditReminderSheet.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import SwiftUI

struct AddEditReminderSheet: View {
    @ObservedObject var viewModel: ReminderViewModel
    let item: ReminderItem?
    @Environment(\.dismiss) private var dismiss
    
    @State private var type: ReminderItem.ReminderType
    @State private var name: String
    @State private var description: String
    @State private var renewalType: ReminderItem.RenewalType
    @State private var customPeriodValue: Int
    @State private var customPeriodUnit: ReminderItem.PeriodUnit
    @State private var expiryDate: Date
    @State private var licenseKey: String
    @State private var reminderDays: Int
    @State private var cost: String
    @State private var notes: String
    
    init(viewModel: ReminderViewModel, item: ReminderItem?) {
        self.viewModel = viewModel
        self.item = item
        
        // Initialize state from item or defaults
        _type = State(initialValue: ReminderItem.ReminderType(rawValue: item?.type ?? "") ?? .subscription)
        _name = State(initialValue: item?.name ?? "")
        _description = State(initialValue: item?.itemDescription ?? "")
        _renewalType = State(initialValue: ReminderItem.RenewalType(rawValue: item?.renewalType ?? "") ?? .monthly)
        _customPeriodValue = State(initialValue: item?.customPeriodValue ?? 0)
        _customPeriodUnit = State(initialValue: ReminderItem.PeriodUnit(rawValue: item?.customPeriodUnit ?? "") ?? .days)
        _expiryDate = State(initialValue: item?.expiryDate ?? Date().addingTimeInterval(24*60*60))
        _licenseKey = State(initialValue: item?.licenseKey ?? "")
        _reminderDays = State(initialValue: item?.reminderDays ?? 3)
        _cost = State(initialValue: item?.cost ?? "")
        _notes = State(initialValue: item?.notes ?? "")
    }
    
    var isEdit: Bool {
        item != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(".label.reminder.common_info")) {
                    // Type selector. We won't be able to change type on flight
                    if !isEdit {
                        Picker(".label.reminder.type", selection: $type) {
                            ForEach(ReminderItem.ReminderType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    TextField(".label.reminder.name", text: $name)
                    TextField(".label.reminder.description", text: $description)

                }

                // Renewal Type
                Section(header: Text(".label.reminder.renew_info")) {
                    Picker(".label.reminder.renewal_reccurrence", selection: $renewalType) {
                        Text(ReminderItem.RenewalType.monthly.displayName).tag(ReminderItem.RenewalType.monthly)
                        Text(ReminderItem.RenewalType.yearly.displayName).tag(ReminderItem.RenewalType.yearly)
                        Text(ReminderItem.RenewalType.lifetime.displayName).tag(ReminderItem.RenewalType.lifetime)
                        Text(ReminderItem.RenewalType.custom.displayName).tag(ReminderItem.RenewalType.custom)
                        Text(ReminderItem.RenewalType.none.displayName).tag(ReminderItem.RenewalType.none)
                    }
                    .pickerStyle(.menu)
                    
                    if renewalType == .custom {
                        Stepper(".label.reminder.renewal_amount \(customPeriodValue) \(customPeriodUnit.displayNameSuffix)", value: $customPeriodValue, in: 0...365)
                        
                        Picker(".label.common.empty_value", selection: $customPeriodUnit) {
                            Text(ReminderItem.PeriodUnit.days.displayNameSuffix).tag(ReminderItem.PeriodUnit.days)
                            Text(ReminderItem.PeriodUnit.months.displayNameSuffix).tag(ReminderItem.PeriodUnit.months)
                            Text(ReminderItem.PeriodUnit.years.displayNameSuffix).tag(ReminderItem.PeriodUnit.years)
                        }
                        .pickerStyle(.menu)
                    }
                    
                    if renewalType != .lifetime {
                        Stepper(".label.reminder.remind_in_days \(reminderDays)", value: $reminderDays, in: 1...90)
                        
                        DatePicker(
                            ".label.reminder.renewal_date",
                            selection: $expiryDate,
                            displayedComponents: .date
                        )
                    }

                }

                if type == .license {
                    Section(header: Text(".label.reminder.license_key")) {
                        TextEditor(text: $licenseKey)
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 100)
                    }

                }
                
                Section(header: Text(".label.reminder.price")) {
                    TextField(".placeholder.reminder.price", text: $cost)
                }

                
                Section(header: Text(".label.reminder.notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }

            }
            .scrollContentBackground(.hidden)
            .navigationTitle(isEdit ? ".title.reminder.edit" : ".title.reminder.new")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(".button.cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEdit ? ".button.save" : ".button.add") {
                        saveItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        
        let newItem = ReminderItem(
            id: item?.id ?? UUID(),
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
        
        if isEdit {
            viewModel.updateItem(newItem)
        } else {
            viewModel.addItem(newItem)
        }
        
        dismiss()
    }

}
