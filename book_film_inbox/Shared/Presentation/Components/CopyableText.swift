//
//  CopyableText.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 29.01.2026.
//

import SwiftUI

struct CopyableText: View {
    let text: String
    @State private var copiedToClipboard = false
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        Button {
            UIPasteboard.general.string = text
            copiedToClipboard = true
        } label: {
            
            HStack(alignment: .top) {
                Text(text)
                    .font(.system(.footnote, design: .monospaced))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(0.7)
                
                Image(systemName: copiedToClipboard ? "checkmark" : "doc.on.doc")
                    .foregroundColor(copiedToClipboard
                                     ? Color.green
                                     : Color.blue)
                    .scaledToFit()
                    .frame(height: 18)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .tint(.blue)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(text))
        .accessibilityHint(copiedToClipboard
            ? Text(".accessibility.copyable_text.hint_copied")
            : Text(".accessibility.copyable_text.hint")
        )
        .accessibilityValue(copiedToClipboard ? Text(".accessibility.copyable_text.hint_copied") : Text(".label.common.empty_value"))
        .task(id: copiedToClipboard) {
            guard copiedToClipboard else { return }
            try? await Task.sleep(for: .seconds(2))
            copiedToClipboard = false
        }
    }
    
}


#Preview {
    CopyableText(text: "Some maginc text Some maginc text Some maginc text Some maginc text")
}
