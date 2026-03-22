// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LLMKit",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "LLMKit",
            targets: ["LLMKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ml-explore/mlx-swift-lm",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "LLMKit",
            dependencies: [
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
            ]
        ),
    ]
)
