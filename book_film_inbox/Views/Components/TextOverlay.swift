//
//  TextOverlay.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 26.11.2025.
//

import SwiftUI

struct TextOverlay: View {
    let description: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            ScrollView {
                Text(description)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(40)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
        }
        .onTapGesture {
            onDismiss()
        }
        .transition(.opacity)
    }
}
