// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "AppState", targets: ["AppState"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
    ],
    dependencies: [
        .package(name: "TonCore", path: "../TonCore"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/shaps80/SwiftUIBackports.git", branch: "main"),
        .package(url: "https://github.com/twostraws/CodeScanner.git", branch: "main"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.2.0"),
        .package(url: "https://github.com/1024jp/GzipSwift.git", from: "5.2.0"),
    ],
    targets: [
        
        .target(
            name: "AppState",
            dependencies: [
                .product(name: "TonCore", package: "TonCore"),
            ]
        ),
        
        .target(
            name: "SharedUI",
            dependencies: [
                .product(name: "TonCore", package: "TonCore"),
                .product(name: "SwiftUIBackports", package: "SwiftUIBackports"),
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "Gzip", package: "GzipSwift"),
                .product(name: "CodeScanner", package: "CodeScanner"),
            ]
        ),
    ]
)
