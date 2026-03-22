//
//  InputBarView.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 21.03.2026.
//

import SwiftUI

struct InputBarView: View {
    private enum Constants {
        static let stopIcon: String = "stop.fill"
        static let sendIcon: String = "arrow.up.circle.fill"
    }

    @Binding var text: String
    let isGenerating: Bool
    let canSend: Bool
    let onSend: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            inputView
            primaryButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var primaryButton: some View {
        Button(action: isGenerating ? onStop : onSend) {
            Image(systemName: isGenerating ? Constants.stopIcon : Constants.sendIcon)
                .font(.system(size: 28))
                .foregroundStyle(
                    isGenerating ? .red : (canSend ? Color.accentColor : .secondary)
                )
                .animation(.easeInOut(duration: 0.15), value: isGenerating)
        }
        .buttonStyle(.plain)
        .disabled(!isGenerating && !canSend)
        .keyboardShortcut(.return, modifiers: [])
    }

    private var inputView: some View {
        TextField("Enter your message...", text: $text, axis: .vertical)
            .textFieldStyle(.plain)
            .lineLimit(1 ... 6)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .onSubmit {
                if !NSEvent.modifierFlags.contains(.shift) {
                    onSend()
                }
            }
    }
}

#Preview {
    InputBarView(
        text: .init(
            get: { "" },
            set: { _ in }
        ),
        isGenerating: true,
        canSend: false,
        onSend: {},
        onStop: {}
    )
}
