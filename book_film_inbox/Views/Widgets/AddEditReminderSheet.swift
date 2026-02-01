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
    
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    @State private var type: ReminderType
    @State private var name: String
    @State private var description: String
    @State private var renewalType: RenewalType
    @State private var customPeriodValue: Int
    @State private var customPeriodUnit: PeriodUnit
    @State private var expiryDate: Date
    @State private var licenseKey: String
    @State private var reminderDays: Int
    @State private var cost: String
    @State private var notes: String
    
    init(viewModel: ReminderViewModel, item: ReminderItem?) {
        self.viewModel = viewModel
        self.item = item
        
        // Initialize state from item or defaults
        _type = State(initialValue: item?.type ?? .subscription)
        _name = State(initialValue: item?.name ?? "")
        _description = State(initialValue: item?.itemDescription ?? "")
        _renewalType = State(initialValue: item?.renewalType ?? .monthly)
        _customPeriodValue = State(initialValue: item?.customPeriodValue ?? 0)
        _customPeriodUnit = State(initialValue: item?.customPeriodUnit ?? .days)
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
                            ForEach(ReminderType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    TextField(".label.reminder.name", text: $name)
                        .limitText($name, to: 50)
                    TextField(".label.reminder.description", text: $description)
                        .limitText($description, to: 100)
                    TextField(".label.reminder.price", text: $cost)
                        .limitText($cost, to: 10)
                }

                // Renewal Type
                Section(header: Text(".label.reminder.renew_info")) {
                    Picker(".label.reminder.renewal_reccurrence", selection: $renewalType) {
                        Text(RenewalType.monthly.displayName).tag(RenewalType.monthly)
                        Text(RenewalType.yearly.displayName).tag(RenewalType.yearly)
                        Text(RenewalType.lifetime.displayName).tag(RenewalType.lifetime)
                        Text(RenewalType.custom.displayName).tag(RenewalType.custom)
                        Text(RenewalType.none.displayName).tag(RenewalType.none)
                    }
                    .pickerStyle(.menu)
                    
                    if renewalType == .custom {
                        Stepper(".label.reminder.renewal_amount \(customPeriodValue) \(customPeriodUnit.displayNameSuffix)", value: $customPeriodValue, in: 0...365)
                        
                        Picker(".label.common.empty_value", selection: $customPeriodUnit) {
                            Text(PeriodUnit.days.displayNameSuffix).tag(PeriodUnit.days)
                            Text(PeriodUnit.months.displayNameSuffix).tag(PeriodUnit.months)
                            Text(PeriodUnit.years.displayNameSuffix).tag(PeriodUnit.years)
                        }
                        .pickerStyle(.menu)
                    }
                    
                    if renewalType != .lifetime {
                        Stepper(".label.reminder.remind_in_days \(reminderDays)", value: $reminderDays, in: 1...14)
                        
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
            .alert(".title.error", isPresented: $showError) {
                Button(".button.ok", role: .cancel) {}
            } message: {
                Text(errorMessage)
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

        do {
            if isEdit {
                try viewModel.updateItem(newItem)
            } else {
                viewModel.addItem(newItem)
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        dismiss()
    }

}


extension View {
    func limitText(_ text: Binding<String>, to limit: Int) -> some View {
        self.onChange(of: text.wrappedValue) { oldValue, newValue in
            if newValue.count > limit {
                text.wrappedValue = String(newValue.prefix(limit))
            }
        }
    }
}
