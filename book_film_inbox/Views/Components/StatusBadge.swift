//
//  StatusBadge.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 26.11.2025.
//

import SwiftUI

struct StatusBadge: View {
    let icon: String
    let text: LocalizedStringKey?
    let textVerbatim: String?
    let color: Color

    init(icon: String, text: LocalizedStringKey?, color: Color) {
        self.icon = icon
        self.text = text
        self.textVerbatim = nil
        self.color = color
    }

    init(icon: String, textVerbatim: String?, color: Color) {
        self.icon = icon
        self.text = nil
        self.textVerbatim = textVerbatim
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            
            if let verbatim = textVerbatim {
                Text(verbatim: verbatim)
            } else if let key = text {
                Text(key)
            }
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}
