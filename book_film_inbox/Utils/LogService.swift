//
//  LogService.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 30.01.2026.
//

import SwiftyBeaver
import Foundation

let log = SwiftyBeaver.self

enum Log {
    
    static func setup() {
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d [$C$L$c] $N.$F:$l - $M"
        console.levelColor.verbose = "⚪️ "
        console.levelColor.debug = "🔵 "
        console.levelColor.info = "🟢 "
        console.levelColor.warning = "🟡 "
        console.levelColor.error = "🔴 "
#if DEBUG
        console.minLevel = .verbose
#else
        console.minLevel = .info
#endif
        log.addDestination(console)
        
//        let file = FileDestination()
//        file.format = "$DHH:mm:ss.SSS$d $L [$N.$F:$l] - $M"
//        file.logFileURL = URL(fileURLWithPath: "/tmp/IWannaRWX.log")
//        file.minLevel = .debug
//        log.addDestination(file)

        log.info("📱 SwiftyBeaver initialized")
    }
    
}

extension Log {
    /// Логирование с контекстом
    static func debug(_ message: String, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        let contextString = context.isEmpty ? "" : " | \(context)"
        log.debug("\(message)\(contextString)", file: file, function: function, line: line)
    }
    
    static func info(_ message: String, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        let contextString = context.isEmpty ? "" : " | \(context)"
        log.info("\(message)\(contextString)", file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        let contextString = context.isEmpty ? "" : " | \(context)"
        log.warning("\(message)\(contextString)", file: file, function: function, line: line)
    }
    
    static func error(_ message: String, error: Error? = nil, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        var fullContext = context
        if let error = error {
            fullContext["error"] = String(describing: error)
        }
        let contextString = fullContext.isEmpty ? "" : " | \(fullContext)"
        log.error("\(message)\(contextString)", file: file, function: function, line: line)
    }
    
    static func verbose(_ message: String, context: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        let contextString = context.isEmpty ? "" : " | \(context)"
        log.verbose("\(message)\(contextString)", file: file, function: function, line: line)
    }
}
