//
//  LogService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 30.01.2026.
//

import OSLog
import Foundation

// MARK: - Logger Categories
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.javanix.i-wanna-rwx"
    
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let db = Logger(subsystem: subsystem, category: "Database")
    static let net = Logger(subsystem: subsystem, category: "Network")
    static let notification = Logger(subsystem: subsystem, category: "Notification")
    static let general = Logger(subsystem: subsystem, category: "General")
}

// MARK: - Log Service

enum Log {
    
    static func setup() {
        Logger.general.info("📱 OSLog initialized")
    }
    
}

extension Log {
    /// Логирование с контекстом
    static func debug(_ message: String, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
#if DEBUG
        let filename = (file as NSString).lastPathComponent
        let contextString = context.isEmpty ? "" : " | \(formatContext(context))"
        Logger.general.debug("🔵 [\(filename):\(line)] \(function) - \(message)\(contextString)")
#endif
    }
    
    static func info(_ message: String, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        let contextString = context.isEmpty ? "" : " | \(formatContext(context))"
        Logger.general.info("🟢 [\(filename):\(line)] \(function) - \(message)\(contextString)")
    }
    
    static func warning(_ message: String, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        let contextString = context.isEmpty ? "" : " | \(formatContext(context))"
        Logger.general.warning("🟡 [\(filename):\(line)] \(function) - \(message)\(contextString)")
    }
    
    static func error(_ message: String, error: Error? = nil, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        var fullContext = context
        if let error = error {
            fullContext["error"] = String(describing: error)
        }
        let contextString = fullContext.isEmpty ? "" : " | \(formatContext(fullContext))"
        Logger.general.error("🔴 [\(filename):\(line)] \(function) - \(message)\(contextString)")
    }
    
    static func verbose(_ message: String, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
#if DEBUG
        let filename = (file as NSString).lastPathComponent
        let contextString = context.isEmpty ? "" : " | \(formatContext(context))"
        Logger.general.trace("⚪️ [\(filename):\(line)] \(function) - \(message)\(contextString)")
#endif
    }
    
    private static func formatContext(_ context: [String: Any]) -> String {
        context.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
    }
}
