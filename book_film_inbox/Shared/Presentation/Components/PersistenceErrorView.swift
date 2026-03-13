//
//  PersistenceErrorView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 05.02.2026.
//

import SwiftUI

struct PersistenceErrorView: View {
    let error: PersistenceError
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .accessibilityHidden(true)
            
            Text(".label.error.database")
                .font(.title)
            
            Text(errorDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(".button.reset_app", role: .destructive) {
                exit(0)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint(Text(".accessibility.error.reset_app_hint"))
        }
        .padding()
    }
    
    private var errorDescription: LocalizedStringKey {
        switch error {
        case .containerCreationFailed(let underlyingError):
            return ".label.error.database_init: \(underlyingError.localizedDescription)"
        }
    }
}
