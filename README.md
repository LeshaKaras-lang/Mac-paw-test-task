# MacPaw Chat

A macOS chat application powered by a local LLM via Apple's MLX framework.

---

## Requirements

| | |
|---|---|
| **OS** | macOS 14.0 (Sonoma) or later |
| **Hardware** | Apple Silicon (M1 / M2 / M3) — required for MLX |
| **Xcode** | 15.0 or later |
| **Disk space** | ~1 GB for the Llama 3.2 1B model cache |

---

## Build & Run

1. Clone the repository:
```bash
git clone https://github.com/yourusername/MacPawChat.git
cd MacPawChat
```

2. Open the project in Xcode:
```bash
open MacPawChat.xcodeproj
```

3. Select the `MacPawChat` scheme and your Mac as the target device.

4. Build and run with `⌘R`.

> **First launch:** The app will automatically download the Llama 3.2 1B 4-bit model (~800 MB) from HuggingFace. This happens once — subsequent launches load the model from local cache at `~/.cache/huggingface/`.

---

## Switching Models

Two models are available out of the box. To switch, update the engine passed into `ChatViewModel` in `App.swift`:

```swift
// Llama 3.2 1B — fast, low memory (~800 MB)
ChatSceneView(viewModel: ChatViewModel(engine: LLMLamaLightEngine()))

// Llama 3.1 8B — higher quality (~4.5 GB, requires 16 GB RAM)
ChatSceneView(viewModel: ChatViewModel(engine: LLMLamaProEngine()))
```

---

## Project Structure

The project is split into two components as required:

```
MacPawChat/                        ← Main SwiftUI application
├── App/
│   └── ChatScene/
│       ├── ViewModel/
│       │   ├── ChatViewModel.swift    ← State management, orchestration
│       │   └── ChatVMP.swift          ← ViewModel protocol
│       └── Views/
│           ├── ChatSceneView.swift    ← Root scene view
│           ├── ChatView.swift         ← Message list + input bar
│           ├── MessageBubbleView.swift
│           ├── InputBarView.swift
│           ├── HeaderView.swift
│           ├── LoadingView.swift
│           └── ErrorView.swift
└── Domain/
    ├── Entities/
    │   └── ChatMessage.swift          ← UI-layer message model
    └── UseCases/
        └── SendMessageUseCase/
            ├── SendMessageUseCaseProtocol.swift
            └── SendMessageUseCase.swift   ← Maps domain → LLM types

LLMKit/                            ← Local Swift Package (LLM module)
└── Sources/LLMKit/
    ├── Engine/
    │   ├── LLMEngineProtocol.swift    ← Low-level protocol (modelId-based)
    │   └── LLMEngine.swift            ← Core MLX inference actor
    ├── ChatEngine/
    │   ├── LLMChatEngineProtocol.swift ← High-level protocol (pre-configured)
    │   └── LamaChatEngines/
    │       ├── LLMLamaLightEngine.swift ← Llama 3.2 1B 4-bit
    │       └── LLMLamaProEngine.swift   ← Llama 3.1 8B 4-bit
    └── Entities/
        ├── LLMChatMessage.swift
        └── LLMError.swift
```

---

## Architecture

### Dependency flow
```
Views → ChatViewModel → SendMessageUseCase → LLMChatEngineProtocol
                                                      ↓
                                              LLMEngine (MLX)
```

### Key design decisions

**LLMKit as a local Swift Package** encapsulates all LLM-related logic. The main app has zero knowledge of MLX internals — it only depends on `LLMChatEngineProtocol` and `SendMessageUseCaseProtocol`.

**Two-level engine protocol design:**
- `LLMEngineProtocol` — low-level, accepts `modelId: String`. Flexible, reusable for any HuggingFace model.
- `LLMChatEngineProtocol` — high-level, model is pre-configured. `LLMLamaLightEngine` and `LLMLamaProEngine` implement this, hiding model selection from the call site.

**SendMessageUseCase** sits between the ViewModel and the engine. It owns the mapping from the domain model (`ChatMessage`) to the LLM input type (`LLMChatMessage`), keeping the ViewModel free of LLMKit-specific types.

**`LLMEngine` as an `actor`** guarantees thread-safe access to the model container. All MLX inference runs on its isolated context, while UI updates are dispatched back to `@MainActor` via the streaming mechanism.

### Token streaming

Streaming is implemented with Swift's `AsyncThrowingStream`. The `LLMEngine.generate()` method wraps the new `MLXLMCommon.generate(input:parameters:context:)` async sequence API, yielding text pieces as each `Generation.chunk` arrives. The ViewModel appends each token to the assistant message in real time, triggering SwiftUI to re-render the bubble incrementally.

```
MLX token → Generation.chunk → AsyncThrowingStream.yield →
messages[idx].content += token → SwiftUI re-renders bubble
```

---

## Features

- [x] SwiftUI macOS chat interface
- [x] Local LLM inference via Apple MLX (no internet required after first download)
- [x] Real-time token streaming
- [x] Stop generation mid-response
- [x] Full conversation context passed to the model on each turn
- [x] Model loading progress indicator
- [x] Two pre-configured model tiers (Light / Pro)
- [x] Clean Architecture: Use Cases, protocol-driven engine, SPM separation

---

## Dependencies

| Package | Purpose |
|---|---|
| [mlx-swift-lm](https://github.com/ml-explore/mlx-swift-lm) | MLX LLM inference (MLXLLM, MLXLMCommon) |

All other code is written from scratch with no additional third-party dependencies.
