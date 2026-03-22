//
//  MacPawChatApp.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 21.03.2026.
//

import SwiftUI

@main
struct MacPawChatApp: App {
    var body: some Scene {
        WindowGroup {
            ChatSceneView(viewModel: ChatViewModel())
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
