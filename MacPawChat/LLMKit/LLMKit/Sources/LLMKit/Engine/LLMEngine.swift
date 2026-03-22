//
//  LLMEngine.swift
//  LLMKit
//
//  Created by Oleksii Karas on 21.03.2026.
//

import Foundation
import MLXLLM
import MLXLMCommon

/// Primary inference actor. Handles model loading and token streaming.
/// Declared as `actor` to guarantee thread-safe access to the model container.
public actor LLMEngine: LLMEngineProtocol {
    
    private var modelContainer: ModelContainer?

    public init() {}

    // MARK: - Model Loading

    /// Downloads (on first run) and loads a quantized LLM from HuggingFace Hub.
    /// Subsequent runs load from local cache (~/.cache/huggingface/).
    /// - Parameters:
    ///   - modelId: HuggingFace repo ID. Defaults to Llama 3.2 1B 4-bit (~800 MB).
    ///   - onProgress: Progress callback with values from 0.0 to 1.0.
    public func loadModel(
        modelId: String,
        onProgress: @Sendable @escaping (Double) -> Void = { _ in }
    ) async throws {
        // ModelConfiguration lives in MLXLMCommon, LLMModelFactory — in MLXLLM
        let configuration = MLXLMCommon.ModelConfiguration(id: modelId)
        modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: configuration
        ) { progress in
            onProgress(progress.fractionCompleted)
        }
    }

    // MARK: - Streaming Generation

    /// Generates a response using the new AsyncStream-based API.
    ///
    /// Example:
    /// ```swift
    /// for try await token in engine.generate(messages: history) {
    ///     responseText += token
    /// }
    /// ```
    public func generate(
        messages: [LLMChatMessage],
        parameters: GenerateParameters = GenerateParameters(temperature: 0.7, topP: 0.9)
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                guard let container = self.modelContainer else {
                    continuation.finish(throwing: LLMError.modelNotLoaded)
                    return
                }

                do {
                    _ = try await container.perform { context in
                        let prompt = Self.buildPrompt(from: messages)
                        let input = try await context.processor.prepare(
                            input: .init(prompt: prompt)
                        )
                        for await generation in try MLXLMCommon.generate(
                            input: input,
                            parameters: parameters,
                            context: context
                        ) {
                            guard !Task.isCancelled else { break }

                            if let text = generation.chunk, !text.isEmpty {
                                continuation.yield(text)
                            }
                        }
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish(throwing: LLMError.generationCancelled)
                } catch {
                    continuation.finish(throwing: LLMError.generationFailed(error.localizedDescription))
                }
            }
        }
    }

    // MARK: - Prompt Formatting (Llama 3 Chat Template)

    /// Formats the conversation history into the Llama 3 Instruct chat template.
    private static func buildPrompt(from messages: [LLMChatMessage]) -> String {
        var prompt = "<|begin_of_text|>"

        // Prepend a default system message if none is provided
        if messages.first?.role != .system {
            prompt += "<|start_header_id|>system<|end_header_id|>\n\n"
            prompt += "You are a helpful assistant."
            prompt += "<|eot_id|>"
        }

        for message in messages {
            let role: String
            switch message.role {
            case .system: role = "system"
            case .user: role = "user"
            case .assistant: role = "assistant"
            }
            prompt += "<|start_header_id|>\(role)<|end_header_id|>\n\n"
            prompt += message.content
            prompt += "<|eot_id|>"
        }

        // Begin the assistant turn
        prompt += "<|start_header_id|>assistant<|end_header_id|>\n\n"

        return prompt
    }
}
