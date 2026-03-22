//
//  LLMChatMessage.swift
//  LLMKit
//
//  Created by Oleksii Karas on 21.03.2026.
//

import Foundation

public struct LLMChatMessage: Sendable {
    public enum Role: Sendable {
        case system
        case user
        case assistant
    }

    public let role: Role
    public let content: String

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}
