//
//  ChatView.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 22.03.2026.
//

import SwiftUI

struct ChatView: View {
    private enum Constants {
        static let bubbleIcon: String = "bubble.left.and.bubble.right"
        static let viewId: String = "bottom"
    }

    @Binding var text: String
    let isGenerating: Bool
    let messages: [ChatMessage]
    let canSend: Bool
    let onSend: () -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            messagesView
            Divider()
            inputView
        }
    }

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if messages.isEmpty {
                        emptyStateView
                    }

                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(Constants.viewId)
                }
                .padding()
                .animation(.easeOut(duration: 0.2), value: messages.count)
            }
            .onChange(of: messages.last?.content) { _, _ in
                withAnimation {
                    proxy.scrollTo(Constants.viewId, anchor: .bottom)
                }
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation {
                    proxy.scrollTo(Constants.viewId, anchor: .bottom)
                }
            }
        }
    }

    private var inputView: some View {
        InputBarView(
            text: $text,
            isGenerating: isGenerating,
            canSend: canSend,
            onSend: onSend,
            onStop: onStop
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 60)
            Image(systemName: Constants.bubbleIcon)
                .font(.system(size: 48))
                .foregroundStyle(.quaternary)
            Text("Start a Dialogue")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Llama 3.2 runs locally on your Mac.")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity)
    }
}
