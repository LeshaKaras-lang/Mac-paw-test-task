//
//  LLMChatEngineProtocol.swift
//  LLMKit
//
//  Created by Oleksii Karas on 22.03.2026.
//

import Foundation
import MLXLLM
import MLXLMCommon

/// High-level inference protocol with a pre-configured model.
/// Concrete engines implement this to hide model selection from the call site.
public protocol LLMChatEngineProtocol: AnyObject {

    /// Loads the engine's pre-configured model into memory.
    func loadModel(
        onProgress: @Sendable @escaping (Double) -> Void
    ) async throws

    /// Streams a generated response for the given conversation history.
    func generate(
        messages: [LLMChatMessage]
    ) async -> AsyncThrowingStream<String, Error>
}
