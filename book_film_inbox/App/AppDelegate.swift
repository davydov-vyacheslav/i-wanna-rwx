//
//  AppDelegate.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 01.02.2026.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    @MainActor
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        Log.setup()
        Log.info("🚀 Application launched")
        UNUserNotificationCenter.current().delegate = self
        
        Task { @MainActor in
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
        
        Task { @MainActor in
            let navigation = NavigationManager.shared
            switch response.actionIdentifier {
            case NotificationAction.prolongate.rawValue:
                navigation.prolongateAndOpenReminder(id: itemId)
                Log.info("🔔 Opening reminder with prolongate", context: ["id": itemId.uuidString])
            default:
                navigation.openReminderDetails(id: itemId)
                Log.info("🔔 Opening reminder details", context: ["id": itemId.uuidString])
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

enum NotificationAction: String {
    case prolongate = "PROLONGATE_ACTION"
    
    var displayName: String {
        switch self {
        case .prolongate: return String(localized: ".notification.action.renewed")
        }
    }
}
