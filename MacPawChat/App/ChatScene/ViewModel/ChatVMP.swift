//
//  ChatVMP.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 22.03.2026.
//

import Foundation

enum ModelState: Equatable {
    case loading(progress: Double)
    case ready
    case failed(String)
    
    var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }
}

@MainActor
protocol ChatVMP: ObservableObject {
    var messages: [ChatMessage] { get }
    var inputText: String { get set }
    var isGenerating: Bool { get }
    var modelState: ModelState { get }
    var canSend: Bool { get }

    func sendMessage()
    func stopGeneration()
    func clearChat()
}
