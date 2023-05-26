// swift-tools-version: 5.7
import PackageDescription

func Core(_ dependency: String) -> Target.Dependency {
    .product(name: dependency, package: "Core")
}
func TonCore(_ dependency: String) -> Target.Dependency {
    .product(name: dependency, package: "TonCore")
}

let package = Package(
    name: "Features",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "NewWallet", targets: ["NewWallet"]),
        .library(name: "Send", targets: ["Send"]),
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
        .package(name: "TonCore", path: "../TonCore"),
    ],
    targets: [
        
        .target(
            name: "Send",
            dependencies: [
                TonCore("TonCore"),
                Core("SharedUI"),
                Core("AppState"),
            ]
        ),
        
        .target(
            name: "NewWallet",
            dependencies: [
                TonCore("TonCore"),
                Core("SharedUI"),
            ]
        ),
    ]
)
