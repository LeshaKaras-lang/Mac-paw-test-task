//
//  LoadingView.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 22.03.2026.
//

import SwiftUI

struct LoadingView: View {
    
    let loadingProgress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView(value: loadingProgress)
                .progressViewStyle(.linear)
                .frame(maxWidth: 300)
            Text("Loading Llama 3.2… \(Int(loadingProgress * 100))%")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("The model is downloaded on first launch (~800 MB)")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoadingView(loadingProgress: 0.5)
}
