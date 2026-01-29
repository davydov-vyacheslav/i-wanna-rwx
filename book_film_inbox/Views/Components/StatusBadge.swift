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
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            
            if let key = text {
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
