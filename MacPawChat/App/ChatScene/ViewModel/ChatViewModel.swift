//
//  ChatViewModel.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 21.03.2026.
//

import Combine
import Foundation
import LLMKit
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject, ChatVMP {

    // MARK: - Published

    @Published private(set) var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published private(set) var isGenerating: Bool = false
    @Published private(set) var modelState: ModelState = .loading(progress: 0)

    // MARK: - Computed

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isGenerating
            && modelState == .ready
    }

    // MARK: - Private

    private let sendMessageUseCase: SendMessageUseCaseProtocol
    private var generationTask: Task<Void, Never>?

    // MARK: - Init

    init(
        sendMessageUseCase: SendMessageUseCaseProtocol? = nil
    ) {
        self.sendMessageUseCase = sendMessageUseCase ?? SendMessageUseCase(engine: LLMLamaLightEngine())
        Task { await loadModel() }
    }

    // MARK: - Public Interface

    func sendMessage() {
        guard canSend else { return }

        let text = consumeInput()
        appendUserMessage(text)
        let assistantIndex = appendAssistantPlaceholder()
        startGeneration(assistantIndex: assistantIndex)
    }

    func stopGeneration() {
        generationTask?.cancel()
        generationTask = nil
        isGenerating = false
    }

    func clearChat() {
        stopGeneration()
        messages.removeAll()
    }

    // MARK: - Model Loading

    private func loadModel() async {
        modelState = .loading(progress: 0)
        do {
            try await sendMessageUseCase.load { [weak self] progress in
                Task {
                    await self?.updateLoadingProgress(progress)
                }
            }
            modelState = .ready
        } catch {
            modelState = .failed(error.localizedDescription)
        }
    }

    // MARK: - Message Helpers

    private func consumeInput() -> String {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""
        return text
    }

    private func appendUserMessage(_ text: String) {
        messages.append(ChatMessage(role: .user, content: text))
    }

    @discardableResult
    private func appendAssistantPlaceholder() -> Int {
        messages.append(ChatMessage(role: .assistant, content: ""))
        return messages.count - 1
    }

    /// Returns conversation history without the empty assistant placeholder.
    /// Mapping to LLMChatMessage is the responsibility of SendMessageUseCase.
    private func buildHistory() -> [ChatMessage] {
        Array(messages.dropLast())
    }

    // MARK: - Generation

    private func startGeneration(assistantIndex: Int) {
        isGenerating = true
        generationTask = Task { [weak self] in
            await self?.runGeneration(assistantIndex: assistantIndex)
        }
    }

    private func runGeneration(assistantIndex: Int) async {
        defer { isGenerating = false }

        let history = buildHistory()

        do {
            let stream = await sendMessageUseCase.execute(history: history)
            try await consumeStream(stream, appendingTo: assistantIndex)
        } catch LLMError.generationCancelled {
            return
        } catch {
            messages[assistantIndex].content = "⚠️ \(error.localizedDescription)"
        }
    }

    private func consumeStream(
        _ stream: AsyncThrowingStream<String, Error>,
        appendingTo index: Int
    ) async throws {
        for try await token in stream {
            guard !Task.isCancelled else { break }
            messages[index].content += token
        }
    }

    @MainActor
    private func updateLoadingProgress(_ progress: Double) async {
        modelState = .loading(progress: progress)
    }
}
