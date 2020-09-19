// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "UIImageHEIC",
    products: [
        .library(name: "UIImageHEIC", targets: ["UIImageHEIC"])
    ],
    targets: [
        .target(
            name: "UIImageHEIC",
            path: "Source"
        )
    ]
)
