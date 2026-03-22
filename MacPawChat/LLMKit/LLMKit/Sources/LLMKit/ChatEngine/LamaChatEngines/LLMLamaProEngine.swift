//
//  LLMEngineProEngine.swift
//  LLMKit
//
//  Created by Oleksii Karas on 22.03.2026.
//

import Foundation
import MLXLLM
import MLXLMCommon

// MARK: - Llama 3.1 8B · Pro
/// Pro engine backed by Llama 3.1 8B 4-bit (~4.5 GB).
/// Higher quality responses at the cost of more memory and slower generation.
public actor LLMLamaProEngine: LLMChatEngineProtocol {

    private static let modelId = "mlx-community/Meta-Llama-3.1-8B-Instruct-4bit"
    private let engine = LLMEngine()

    public init() {}

    public func loadModel(
        onProgress: @Sendable @escaping (Double) -> Void = { _ in }
    ) async throws {
        try await engine.loadModel(
            modelId: Self.modelId,
            onProgress: onProgress
        )
    }

    public func generate(
        messages: [LLMChatMessage]
    ) async -> AsyncThrowingStream<String, Error> {
        let parameters: GenerateParameters = GenerateParameters(temperature: 0.7, topP: 0.9)
        return await engine.generate(messages: messages, parameters: parameters)
    }
}
