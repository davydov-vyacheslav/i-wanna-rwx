//
//  IconGenerator.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

enum IconGenerator {
    
    struct IconRule {
        let keywords: [String]
        let icon: String
    }

    private static let rules: [IconRule] = [
        .init(keywords: ["mail", "outlook"], icon: "📧"),
        .init(keywords: ["steam", "games", "xbox"], icon: "🎮"),
        .init(keywords: ["netflix", "video", "movie", "youtube", "twitch"], icon: "🎬"),
        .init(keywords: ["spotify", "music", "audio", "tidal"], icon: "🎵"),
        .init(keywords: ["chatgpt", "claude", "copilot", "midjourney"], icon: "🤖"),
        .init(keywords: ["git", "code", "intellij"], icon: "💻"),
        .init(keywords: ["canva", "tableau"], icon: "📈"),
        .init(keywords: ["design", "figma", "sketch", "photoshop"], icon: "🎨"),
        .init(keywords: ["cloud", "drive", "dropbox", "azure", "aws", "gcp"], icon: "☁️"),
        .init(keywords: ["note", "notion", "docs", "sublime", "confluence"], icon: "📝"),
        .init(keywords: ["chat", "slack", "discord", "telegram", "message"], icon: "💬")
    ]
    
    private static let icons = ["📦", "📁", "🔧", "📎", "🧩", "🗂️", "🔒", "⚙️"]

    static func suggestIcon(for name: String) -> String {
        if let icon = categorizedIcon(for: name) {
            return icon
        }
        return hashedIcon(for: name)
    }
    
    private static func hashedIcon(for name: String) -> String {
        let hash = abs(name.hashValue)
        return icons[hash % icons.count]
    }
    
    private static func categorizedIcon(for name: String) -> String? {
        let text = name.lowercased()
        
        for rule in rules {
            if rule.keywords.contains(where: text.contains) {
                return rule.icon
            }
        }
        return nil
    }
    
    
    
}
