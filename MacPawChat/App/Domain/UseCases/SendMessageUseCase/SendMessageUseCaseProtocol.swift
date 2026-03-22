//
//  SendMessageUseCaseProtocol.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 22.03.2026.
//

import Foundation

protocol SendMessageUseCaseProtocol {
    func load(onProgress: @Sendable @escaping (Double) -> Void) async throws
    func execute(history: [ChatMessage]) async -> AsyncThrowingStream<String, Error>
}
