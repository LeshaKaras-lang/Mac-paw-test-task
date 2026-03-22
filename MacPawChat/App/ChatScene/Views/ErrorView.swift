//
//  ErrorView.swift
//  MacPawChat
//
//  Created by Oleksii Karas on 22.03.2026.
//

import SwiftUI

struct ErrorView: View {
    
    private enum Constants {
        static let errorIcon: String = "exclamationmark.triangle.fill"
    }
    
    let error: String

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: Constants.errorIcon)
                .font(.largeTitle)
                .foregroundStyle(.red)
            Text(error)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ErrorView(error: "Some error")
}
