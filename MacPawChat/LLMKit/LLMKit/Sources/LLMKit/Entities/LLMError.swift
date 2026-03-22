//
//  LLMError.swift
//  LLMKit
//
//  Created by Oleksii Karas on 21.03.2026.
//

import Foundation

public enum LLMError: LocalizedError {
    case modelNotLoaded
    case generationCancelled
    case generationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Model is not loaded. Call loadModel() before generating."
        case .generationCancelled:
            return "Generation was cancelled by the user."
        case .generationFailed(let reason):
            return "Generation failed: \(reason)"
        }
    }
}
