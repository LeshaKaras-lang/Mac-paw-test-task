//
//  LLMEngineProtocol.swift
//  LLMKit
//
//  Created by Oleksii Karas on 22.03.2026.
//

import Foundation
import MLXLLM
import MLXLMCommon

/// Defines the public interface for the LLM inference engine.
/// Conform to this protocol to enable dependency injection and testability.
public protocol LLMEngineProtocol: Actor {

    /// Loads the model into memory. Call once at app startup.
    /// - Parameters:
    ///   - modelId: HuggingFace repository identifier.
    ///   - onProgress: Called periodically with load progress (0.0 – 1.0).
    func loadModel(
        modelId: String,
        onProgress: @Sendable @escaping (Double) -> Void
    ) async throws

    /// Streams a generated response for the given conversation history.
    /// - Parameters:
    ///   - messages: Full conversation history including the latest user message.
    ///   - parameters: Sampling parameters (temperature, topP, etc.)
    /// - Returns: An `AsyncThrowingStream` that yields new text pieces as tokens are generated.
    func generate(
        messages: [LLMChatMessage],
        parameters: GenerateParameters
    ) -> AsyncThrowingStream<String, Error>
}
