//
//  HeaderView.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 22.03.2026.
//

import SwiftUI

struct HeaderView: View {
    private enum Constants {
        static let bubbleIcon: String = "bubble.left.and.bubble.right.fill"
        static let trashIcon: String = "trash"
    }

    let hasMessages: Bool
    let isModelLoading: Bool
    let clearChat: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: Constants.bubbleIcon)
                    .foregroundStyle(.indigo)
                Text("MacPaw Chat")
                    .font(.headline)
            }

            Spacer()

            if !isModelLoading {
                Button(action: clearChat) {
                    Label("Clear", systemImage: Constants.trashIcon)
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .disabled(!hasMessages)
            }
        }
    }
}

#Preview {
    HeaderView(hasMessages: false, isModelLoading: false, clearChat: {})
}
