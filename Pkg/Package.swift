// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "TonWalletPkg",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Features
        .library(name: "NewWallet", targets: ["NewWallet"]),
        .library(name: "Send", targets: ["Send"]),
        
        // Core
        .library(name: "AppState", targets: ["AppState"]),
        .library(name: "TonCore", targets: ["TonCore"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
        
        // Modified deps
        .library(name: "SwiftyTON", targets: ["SwiftyTON"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMajor(from: "5.3.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.4.3")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/shaps80/SwiftUIBackports.git", branch: "main"),
        .package(url: "https://github.com/twostraws/CodeScanner.git", branch: "main"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.2.0"),
        .package(url: "https://github.com/1024jp/GzipSwift.git", from: "5.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        
    ],
    targets: [
        .target(name: "Send", dependencies: ["TonCore", "SharedUI", "AppState"]),
        .target(name: "NewWallet", dependencies: ["TonCore", "SharedUI"]),
        .target(name: "AppState", dependencies: ["TonCore"]),
        .target(name: "SharedUI", dependencies: [
            "TonCore", "SwiftUIBackports",
            .product(name: "Lottie", package: "lottie-spm"),
            .product(name: "Gzip", package: "GzipSwift"),
            "CodeScanner",
        ]),
        .target(name: "TonCore", dependencies: ["SwiftyTON", .product(name: "Collections", package: "swift-collections")]),
        .target(
            name: "SwiftyTON",
            dependencies: [
                "GlossyTON",
                "CryptoSwift",
                "BigInt",
                "TON3",
                .product(name: "Algorithms", package: "swift-algorithms"),

            ],
            resources: [
                .copy("Resources/mainnet.json"),
                .copy("Resources/testnet.json"),
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "GlossyTON",
            dependencies: [
                "TON",
                "OpenSSL"
            ],
            publicHeadersPath: "Include",
            cSettings: [
                .define("DEBUG", to: "1", .when(configuration: .debug)),
            ],
            cxxSettings: [
                .define("DEBUG", to: "1", .when(configuration: .debug)),
            ],
            linkerSettings: [
                .linkedLibrary("z", .when(platforms: [.macOS, .macCatalyst]))
            ]
        ),
        .target(
            name: "TON3",
            dependencies: [
                "CryptoSwift",
                "SwiftyJS"
            ],
            resources: [
                .copy("Resources/ton3-core.bundle")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
            ]
        ),
        .target(
            name: "SwiftyJS",
            dependencies: [
                "CryptoSwift",
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("JS_DEBUG", .when(configuration: .debug)),
            ]
        ),
        .binaryTarget(
            name: "TON",
            url: "https://github.com/labraburn/tonlib-xcframework/releases/download/v0.1.1/TON.xcframework.zip",
            checksum: "0868908f4894855e383aa1ee28c158508553adc7190c73d987a7e0c15a38079c"
        ),
        .binaryTarget(
            name: "OpenSSL",
            url: "https://github.com/labraburn/tonlib-xcframework/releases/download/v0.1.1/OpenSSL.xcframework.zip",
            checksum: "e468db1155374b79f17edf449ded01681c2c9b5725011bdebb7542740460ddd1"
        ),
    ],
    cxxLanguageStandard: .gnucxx14
)
