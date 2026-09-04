// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FinglishCore",
    products: [
        .library(name: "FinglishCore", targets: ["FinglishCore"]),
    ],
    targets: [
        .target(
            name: "FinglishCore",
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
            name: "FinglishCoreTests",
            dependencies: ["FinglishCore"],
            path: "Tests/FinglishCoreTests"
        ),
    ]
)
