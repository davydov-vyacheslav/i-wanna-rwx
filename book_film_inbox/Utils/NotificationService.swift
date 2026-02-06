//
//  NotificationService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 30.01.2026.
//

import UserNotifications
import Foundation
import Combine
import os

@Observable
class NotificationService {
    
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationHour = 9 // notify at 9:00 AM
    
    var isAuthorized = false
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        setupNotificationCategories()
        Task { [weak self] in
            guard let self else { return }
            await checkAuthorizationStatus()
        }
    }
    
    @discardableResult
    func requestAuthorization() async -> Bool {
        await checkAuthorizationStatus()
        
        if authorizationStatus == .authorized {
            return true
        }
        if authorizationStatus == .denied {
            return false
        }
        if authorizationStatus == .notDetermined {
            do {
                let granted = try await notificationCenter.requestAuthorization(
                    options: [.alert, .sound, .badge]
                )
                await MainActor.run {
                    self.isAuthorized = granted
                    self.authorizationStatus = granted ? .authorized : .denied
                }
                return granted
            } catch {
                Log.notification.error("❌ Authorization error: \(error)")
                await MainActor.run {
                    self.isAuthorized = false
                }
                return false
            }
        }
        return false
    }
    
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
            self.isAuthorized = (settings.authorizationStatus == .authorized)
        }
    }

    private func setupNotificationCategories() {
        
        let prolongateAction = UNNotificationAction(
            identifier: NotificationAction.prolongate.rawValue,
            title: NotificationAction.prolongate.displayName,
            options: .foreground // opens the application
        )
        
        let commonCategory = UNNotificationCategory(
            identifier: NotificationCategory.common.rawValue,
            actions: [ prolongateAction ],
            intentIdentifiers: [],
            options: []
        )

        let noActionsCategory = UNNotificationCategory(
            identifier: NotificationCategory.na.rawValue,
            actions: [ ],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([commonCategory, noActionsCategory])
    }
    
    // MARK: - Schedule Notification
    
    func scheduleNotification(for item: ReminderItem) async {
        
        guard item.renewalType != .lifetime else {
            return
        }
        
        guard isAuthorized else {
            Log.notification.warning("⚠️ Notifications not authorized, skipping schedule for \(item.name)")
            return
        }
        
        await cancelNotification(for: item.id)
        
        guard let expiryDate = item.expiryDate,
              let reminderDays = item.reminderDays else {
            return
        }
        
        guard let scheduledDate = computeScheduledNotificationDate(
            expiryDate: expiryDate,
            reminderDays: reminderDays,
            notificationHour: notificationHour
        ) else {
            Log.notification.info("⏭️ No valid notification time for \(item.name), skipping")
            return
        }
        
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ddMMMyyyy")
        formatter.timeZone = .current
        let expiryDateStr: String = formatter.string(from: expiryDate)

        
        // Создаём контент
        let content = UNMutableNotificationContent()
        content.title = String(localized: ".notification.reminder.title")
        content.body =  String(localized: ".notification.reminder.body \(item.name) \(expiryDateStr)")
        content.sound = .default
        content.categoryIdentifier = (item.renewalType == .none)
            ? NotificationCategory.na.rawValue
            : NotificationCategory.common.rawValue
        content.userInfo = [
            "itemId": item.id.uuidString,
            "itemName": item.name,
            "expiryDate": expiryDate.timeIntervalSince1970
        ]

        let triggerDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: scheduledDate
        )

        // 5 seconds delay
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )

        Task { [weak self] in
            guard let self else { return }
            try await notificationCenter.add(request)

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            Log.notification.info("📅 Scheduled notification for \(item.name) at \(formatter.string(from: scheduledDate))")
        }
        
    }
    
    // MARK: - Cancel Notification
    
    func cancelNotification(for itemId: UUID) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [itemId.uuidString])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [itemId.uuidString])
        Log.notification.info("🗑️ Cancelled notification for \(itemId)")
    }
    
    
    // MARK: - Helper
    
    func computeScheduledNotificationDate(
        expiryDate: Date,
        reminderDays: Int,
        notificationHour: Int,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Date? {
        
        let today = calendar.startOfDay(for: now)
        let expiryDay = calendar.startOfDay(for: expiryDate)
        
        guard expiryDay >= today else { return nil } // уже истекло
        
        func notificationDate(for day: Date) -> Date? {
            var comps = calendar.dateComponents([.year, .month, .day], from: day)
            comps.hour = notificationHour
            comps.minute = 0
            return calendar.date(from: comps)
        }
        
        // Идеальная дата
        let idealDay = calendar.date(byAdding: .day, value: -reminderDays, to: expiryDay)!
        
        // Список кандидатов в порядке приоритета
        var candidates: [Date] = []
        
        if calendar.isDate(expiryDay, inSameDayAs: today) {
            // expiry сегодня — только today @ notificationHour
            if let todayTime = notificationDate(for: today) {
                candidates.append(todayTime)
            }
        } else {
            // expiry в будущем — сначала идеальная дата, потом today, потом завтра
            if let ideal = notificationDate(for: idealDay) { candidates.append(ideal) }
            if let todayTime = notificationDate(for: today) { candidates.append(todayTime) }
            if let tomorrow = notificationDate(for: calendar.date(byAdding: .day, value: 1, to: today)!) { candidates.append(tomorrow) }
        }
        
        // Ограничитель — expiryDay @ notificationHour
        guard let expiryLimit = notificationDate(for: expiryDay) else { return nil }
        
        // Берём первую допустимую дату >= now && <= expiryLimit
        return candidates.first(where: { $0 >= now && $0 <= expiryLimit })
    }
}

enum NotificationCategory: String {
    case common = "REMINDER_COMMON"
    case na = "REMINDER_NO_ACTIONS"
    
}

enum NotificationAction: String {
    case prolongate = "PROLONGATE_ACTION"
    
    var displayName: String {
        switch self {
        case .prolongate: return String(localized: ".notification.action.renewed")
        }
    }
}
