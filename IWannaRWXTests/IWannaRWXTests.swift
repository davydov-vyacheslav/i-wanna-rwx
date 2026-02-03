//
//  IWannaRWXTests.swift
//  IWannaRWXTests
//
//  Created by Slava Davydov on 02.02.2026.
//

import Testing
import XCTest
import Foundation
@testable import IWannaRWX


struct IWannaRWXTests {

    let calendar = Calendar.current
    let notificationHour = 11

    func makeDate(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: string)!
    }

    @Test func testScheduledDateCasesDontAdd() {
        // 1️⃣ Сейчас 10:00, notificationHour = 9, expireDate = today → не добавляем
        let now = makeDate("2026-02-02 10:00")
        let expiry = makeDate("2026-02-02 00:00")
        let result = NotificationService.shared.computeScheduledNotificationDate(
            expiryDate: expiry,
            reminderDays: 0,
            notificationHour: 9,
            now: now
        )
        XCTAssertNil(result, "Дата уведомления должна быть nil, так как время уже прошло")

    }

    @Test func testScheduledDateCasesAddUpcomingHour() {
        // 2️⃣ Сейчас 10:00, notificationHour = 11, expireDate = today → 11:00 сегодня
        let now = makeDate("2026-02-02 10:00")
        let expiry = makeDate("2026-02-02 00:00")
        let result = NotificationService.shared.computeScheduledNotificationDate(
            expiryDate: expiry,
            reminderDays: 0,
            notificationHour: 11,
            now: now
        )
        XCTAssertEqual(result, makeDate("2026-02-02 11:00"))
    }
    
    @Test func testScheduledDateCasesAddUpcomingHourEvenNextDay() {
        // 3️⃣ 2 февраля 10:00, notificationHour = 11, expiry 3 февраля, reminderDays = 3 → сегодня 11:00
        let now = makeDate("2026-02-02 10:00")
        let expiry = makeDate("2026-02-03 00:00")
        let result = NotificationService.shared.computeScheduledNotificationDate(
            expiryDate: expiry,
            reminderDays: 3,
            notificationHour: 11,
            now: now
        )
        XCTAssertEqual(result, makeDate("2026-02-02 11:00"))
    }
    
    @Test func testScheduledDateCasesAddNextDayIfTodayTimeMissed() {
        // 4️⃣ 2 февраля 12:00, notificationHour = 11, expiry 3 февраля, reminderDays = 3 → завтра 11:00
        let now = makeDate("2026-02-02 12:00")
        let expiry = makeDate("2026-02-03 00:00")
        let result = NotificationService.shared.computeScheduledNotificationDate(
            expiryDate: expiry,
            reminderDays: 3,
            notificationHour: 11,
            now: now
        )
        XCTAssertEqual(result, makeDate("2026-02-03 11:00"))
    }
    
    @Test func testScheduledDateReminderInLotDays() {
        
        // 5️⃣ 2 февраля 12:00, notificationHour = 11, expiry 10 февраля, reminderDays = 3 → 7 февраля 11:00
        let now = makeDate("2026-02-02 12:00")
        let expiry = makeDate("2026-02-10 00:00")
        let result = NotificationService.shared.computeScheduledNotificationDate(
            expiryDate: expiry,
            reminderDays: 3,
            notificationHour: 11,
            now: now
        )
        XCTAssertEqual(result, makeDate("2026-02-07 11:00"))
    }

}
