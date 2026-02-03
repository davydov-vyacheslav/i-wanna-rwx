//
//  AppDelegate.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 01.02.2026.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        Task {
            await NotificationService.shared.requestAuthorization()
        }
        
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let itemIdString = userInfo["itemId"] as? String,
              let itemId = UUID(uuidString: itemIdString) else {
            completionHandler()
            return
        }
        
        
        Task {
            switch response.actionIdentifier {
                
            case NotificationAction.prolongate.rawValue:
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .switchToRemindersTab,
                        object: nil
                    )
                    
                    NotificationCenter.default.post(
                        name: .prolongateReminder,
                        object: nil,
                        userInfo: ["itemId": itemId]
                    )
                    
                    NotificationCenter.default.post(
                        name: .openReminderDetails,
                        object: nil,
                        userInfo: ["itemId": itemId]
                    )
                }
                
            default:
                NotificationCenter.default.post(
                    name: .switchToRemindersTab,
                    object: nil
                )
                
                NotificationCenter.default.post(
                    name: .openReminderDetails,
                    object: nil,
                    userInfo: ["itemId": itemId]
                )
            }
            
            completionHandler()
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let switchToRemindersTab = Notification.Name("switchToRemindersTab")
    static let prolongateReminder = Notification.Name("prolongateReminder")
    static let openReminderDetails = Notification.Name("openReminderDetails")
}
