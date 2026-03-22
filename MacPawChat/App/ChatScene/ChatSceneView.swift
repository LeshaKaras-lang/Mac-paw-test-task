//
//  ChatSceneView.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 21.03.2026.
//

import SwiftUI

struct ChatSceneView<ViewModel: ChatVMP>: View {
    @StateObject private var viewModel: ViewModel

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            mainContentView
        }
        .frame(minWidth: 620, idealWidth: 720, minHeight: 500, idealHeight: 700)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var mainContentView: some View {
        switch viewModel.modelState {
        case let .loading(progress):
            LoadingView(loadingProgress: progress)
        case .ready:
            chatView
        case let .failed(error):
            ErrorView(error: error)
        }
    }

    private var headerView: some View {
        HeaderView(
            hasMessages: !viewModel.messages.isEmpty,
            isModelLoading: viewModel.modelState.isLoading,
            clearChat: viewModel.clearChat
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var chatView: some View {
        ChatView(
            text: $viewModel.inputText,
            isGenerating: viewModel.isGenerating,
            messages: viewModel.messages,
            canSend: viewModel.canSend,
            onSend: viewModel.sendMessage,
            onStop: viewModel.stopGeneration
        )
    }
}

#Preview {
    ChatSceneView(viewModel: ChatViewModel())
}
