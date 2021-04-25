// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PCloudSDKSwift",
	platforms: [
		// Only support the iOS platform. As of this writing (April 2021), I couldn't find a way to exclude the .xib file in the "macOS" directory
		// from the iOS version of the library but still keep it for the macOS version. You can exclude resources on a per-target basis, but each
		// target must support all platforms declared here. Until SPM makes this possible, we are only going to support one of the platforms.
		.iOS(.v9)
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "PCloudSDKSwift", targets: ["PCloudSDKSwift"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(name: "PCloudSDKSwift", dependencies: [], path: "PCloudSDKSwift/Source", exclude: ["macOS"]),
		.testTarget(name: "PCloudSDKSwiftTests", dependencies: ["PCloudSDKSwift"], path: "PCloudSDKSwift/Tests"),
    ]
)
