//
//  LogService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 30.01.2026.
//

import os
import Foundation

enum Log {
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let db = Logger(subsystem: subsystem, category: "database")
    static let net = Logger(subsystem: subsystem, category: "network")
    static let notification = Logger(subsystem: subsystem, category: "notification")

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.javanix.i-wanna-rwx"
}
