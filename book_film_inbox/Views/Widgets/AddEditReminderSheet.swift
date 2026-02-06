//
//  AddEditReminderSheet.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import SwiftUI

struct AddEditReminderSheet: View {
    let persistenceService: ReminderPersistenceService
    let item: ReminderItem?
    
    @Environment(\.dismiss) private var dismiss
    @State private var form: ReminderForm
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    init(persistenceService: ReminderPersistenceService, item: ReminderItem?) {
        self.persistenceService = persistenceService
        self.item = item
        _form = State(wrappedValue: ReminderForm(item: item))
    }
    
    private var isEdit: Bool {
        item != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(".label.reminder.common_info")) {
                    if !isEdit {
                        Picker(".label.reminder.type", selection: $form.type) {
                            ForEach(ReminderType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    TextField(".label.reminder.name", text: $form.name)
                        .limitText($form.name, to: 50)
                    TextField(".label.reminder.description", text: $form.description)
                        .limitText($form.description, to: 100)
                    TextField(".label.reminder.price", text: $form.cost)
                        .limitText($form.cost, to: 10)
                }
                
                Section(header: Text(".label.reminder.renew_info")) {
                    Picker(".label.reminder.renewal_reccurrence", selection: $form.renewalType) {
                        Text(RenewalType.monthly.displayName).tag(RenewalType.monthly)
                        Text(RenewalType.yearly.displayName).tag(RenewalType.yearly)
                        Text(RenewalType.lifetime.displayName).tag(RenewalType.lifetime)
                        Text(RenewalType.custom.displayName).tag(RenewalType.custom)
                        Text(RenewalType.none.displayName).tag(RenewalType.none)
                    }
                    .pickerStyle(.menu)
                    
                    if form.renewalType == .custom {
                        Stepper(".label.reminder.renewal_amount \(form.customPeriodValue) \(form.customPeriodUnit.displayNameSuffix)", value: $form.customPeriodValue, in: 0...365)
                        
                        Picker(".label.common.empty_value", selection: $form.customPeriodUnit) {
                            Text(PeriodUnit.days.displayNameSuffix).tag(PeriodUnit.days)
                            Text(PeriodUnit.months.displayNameSuffix).tag(PeriodUnit.months)
                            Text(PeriodUnit.years.displayNameSuffix).tag(PeriodUnit.years)
                        }
                        .pickerStyle(.menu)
                    }
                    
                    if form.renewalType != .lifetime {
                        Stepper(".label.reminder.remind_in_days \(form.reminderDays)", value: $form.reminderDays, in: 1...14)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            DatePicker(
                                ".label.reminder.renewal_date",
                                selection: $form.expiryDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            
                            Text(".label.reminder.renewal_date.note")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                if form.type == .license {
                    Section(header: Text(".label.reminder.license_key")) {
                        TextEditor(text: $form.licenseKey)
                            .font(.system(.body, design: .monospaced))
                            .frame(height: 100)
                    }
                }
                
                Section(header: Text(".label.reminder.notes")) {
                    TextEditor(text: $form.notes)
                        .frame(height: 80)
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
                    .disabled(form.name.isEmpty)
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
        let id = item?.id ?? UUID()
        let newItem = form.makeReminder(id: id)
        
        do {
            if isEdit {
                try persistenceService.update(newItem)
            } else {
                persistenceService.add(newItem)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
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
