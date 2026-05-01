//
//  TriStateCheckbox.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 30.04.2026.
//

import SwiftUI

struct TriStateCheckbox: View {
    let icon: String
    let label: LocalizedStringKey
    let iconTint: Color
    @Binding var state: TriState

    var body: some View {
        Button { state.cycle() } label: {
            HStack {
                Label(label, systemImage: icon)
                    .foregroundStyle(state == .all ? .primary : iconTint)
                Spacer()
                indicatorIcon
            }
        }
        .foregroundStyle(.primary)
        .animation(.spring(duration: 0.2), value: state)
        .sensoryFeedback(.selection, trigger: state)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var indicatorIcon: some View {
        switch state {
        case .all:
            Image(systemName: "minus.circle")
                .foregroundStyle(.secondary)
        case .include:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(iconTint)
        case .exclude:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        }
    }
}
