//
//  MessageBubbleView.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 21.03.2026.
//

import Foundation
import SwiftUI

struct MessageBubbleView: View {
    private enum Constants {
        static let cpuIcon: String = "cpu"
        static let personIcon: String = "person.fill"
    }

    let message: ChatMessage
    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !isUser {
                avatarView(icon: Constants.cpuIcon, color: .indigo)
            }

            if isUser {
                Spacer()
            }

            messageView

            if !isUser {
                Spacer()
            }

            if isUser {
                avatarView(icon: Constants.personIcon, color: .blue)
            }
        }
    }

    private var messageView: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
            Text(message.content.isEmpty ? "▋" : message.content)
                .textSelection(.enabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser ? Color.accentColor : Color(.controlBackgroundColor))
                .foregroundColor(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .animation(.default, value: message.content)

            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func avatarView(icon: String, color: Color) -> some View {
        Image(systemName: icon)
            .font(.caption)
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .clipShape(Circle())
    }
}

#Preview {
    MessageBubbleView(message: .init(role: .assistant, content: "Some content"))
}
