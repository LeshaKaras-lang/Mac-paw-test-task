//
//  SendMessageUseCase.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 22.03.2026.
//

import Foundation
import LLMKit

final class SendMessageUseCase: SendMessageUseCaseProtocol {
    private let engine: LLMChatEngineProtocol
    
    init(engine: LLMChatEngineProtocol) {
        self.engine = engine
    }
    
    public func load(
        onProgress: @Sendable @escaping (Double) -> Void = { _ in }
    ) async throws {
        try await engine.loadModel(onProgress: onProgress)
    }

    func execute(history: [ChatMessage]) async -> AsyncThrowingStream<String, Error> {
        let llmMessages = history.map { LLMChatMessage(role: $0.role == .user ? .user : .assistant, content: $0.content) }
        return await engine.generate(messages: llmMessages)
    }
}
