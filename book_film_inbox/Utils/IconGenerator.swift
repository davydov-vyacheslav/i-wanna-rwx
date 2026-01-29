//
//  IconGenerator.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 28.01.2026.
//

struct IconGenerator {
    
    static let shared: IconGenerator = IconGenerator()
    
    struct IconRule {
        let keywords: [String]
        let icon: String
    }

    let rules: [IconRule] = [
        .init(keywords: ["netflix", "video", "movie"], icon: "🎬"),
        .init(keywords: ["spotify", "music", "audio"], icon: "🎵"),
        .init(keywords: ["git", "code", "intellij"], icon: "💻"),
        .init(keywords: ["design", "figma", "sketch", "photoshop"], icon: "🎨"),
        .init(keywords: ["cloud", "drive", "dropbox", "azure", "aws", "gcp"], icon: "☁️"),
        .init(keywords: ["note", "notion", "docs"], icon: "📝"),
        .init(keywords: ["chat", "slack", "discord"], icon: "💬")
    ]
    
    let icons = ["📦", "📁", "🔧", "📎", "🧩", "🗂️", "🔒", "⚙️"]

    
    func suggestIcon(for name: String) -> String {
        if let icon = categorizedIcon(for: name) {
            return icon
        }
        return hashedIcon(for: name)
    }
    
    private func hashedIcon(for name: String) -> String {
        let hash = abs(name.hashValue)
        return icons[hash % icons.count]
    }
    
    private func categorizedIcon(for name: String) -> String? {
        let text = name.lowercased()
        
        for rule in rules {
            if rule.keywords.contains(where: text.contains) {
                return rule.icon
            }
        }
        return nil
    }
    
    
    
}
