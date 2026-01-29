//
//  ReminderViewModel.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

import Foundation
import Combine

class ReminderViewModel: ObservableObject {
    private let storageService = ReminderPersistenceService(context: ReminderPersistenceController.shared.context)
    
    func filteredItems(typeFilter: ReminderItem.ReminderType?, isExpiring: Bool, text: String = "") -> [ReminderItem] {
        storageService.findByTypeAndExpiration(typeFilter, isExpiring, text)
    }
    
    func count(typeFilter: ReminderItem.ReminderType?, isExpiring: Bool) -> Int {
        filteredItems(typeFilter: typeFilter, isExpiring: isExpiring).count
    }

    func addItem(_ item: ReminderItem) {
        storageService.add(item)
        objectWillChange.send()
    }
    
    func updateItem(_ item: ReminderItem) {
        storageService.update(item)
        objectWillChange.send()
    }
    
    func deleteItem(_ item: ReminderItem) {
        storageService.delete(item)
        objectWillChange.send()
    }
    
}


