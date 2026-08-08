// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FinglishKeyboardEngine",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "FinglishKeyboardEngine", targets: ["FinglishKeyboardEngine"]),
    ],
    targets: [
        .target(
            name: "FinglishKeyboardEngine",
            path: "KeyboardExtension",
            exclude: [
                "Assets.xcassets",
                "Info.plist",
                "KeyboardView.swift",
                "KeyboardViewController.swift",
                "PrivacyInfo.xcprivacy",
                "Views",
            ],
            sources: [
                "FinglishConverter.swift",
                "FinglishDictionary.swift",
            ]
        ),
        .testTarget(
            name: "FinglishKeyboardEngineTests",
            dependencies: ["FinglishKeyboardEngine"],
            path: "Tests/FinglishKeyboardEngineTests"
        ),
    ]
)
