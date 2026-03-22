//
//  ChatMessage.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 21.03.2026.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    var content: String
    let timestamp: Date = .now

    enum Role {
        case user
        case assistant
    }
}
