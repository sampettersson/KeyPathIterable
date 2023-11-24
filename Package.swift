// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "KeyPathIterable",
  platforms: [.macOS(.v12), .iOS(.v15)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "KeyPathIterable",
      targets: ["KeyPathIterable"]
    ),
    .library(
      name: "KeyPathIterableAccessor",
      targets: ["KeyPathIterableAccessor"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.2")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "KeyPathIterable",
      dependencies: [
        "KeyPathIterableMacrosPlugin"
      ]
    ),
    .target(
      name: "KeyPathIterableAccessor",
      dependencies: [
        "KeyPathIterable"
      ]
    ),
    .macro(
      name: "KeyPathIterableMacrosPlugin",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "KeyPathIterableTests",
      dependencies: [
        "KeyPathIterable",
        "KeyPathIterableAccessor",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
