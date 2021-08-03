// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "AsyncStore",
	products: [
		.library(
			name: "AsyncStore",
			targets: ["AsyncStore"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "AsyncStore",
			dependencies: []
		),
		.testTarget(
			name: "AsyncStoreTests",
			dependencies: ["AsyncStore"]
		),
	]
)
