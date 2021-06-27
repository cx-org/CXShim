// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CXShim",
    products: [
        .library(name: "CXShim", targets: ["CXShim"]),
    ],
    targets: [
        .target(name: "CXCompatible"),
        .target(name: "CXShim"),
        
        // Just make sure it compiles. We run functionality tests in CombineX repo.
        .testTarget(name: "CXShimSmokeTests", dependencies: ["CXShim"])
    ]
)

// MARK: - Combine Implementations

enum CombineImplementation {
    
    case combine
    case combineX
    case openCombine
    
    static var `default`: CombineImplementation {
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
    
    init?(_ description: String) {
        let desc = description.lowercased().filter { $0.isLetter }
        switch desc {
        case "combine":     self = .combine
        case "combinex":    self = .combineX
        case "opencombine": self = .openCombine
        default:            return nil
        }
    }
    
    var swiftSettings: [SwiftSetting] {
        switch self {
        case .combine:      return [.define("USE_COMBINE")]
        case .combineX:     return [.define("USE_COMBINEX")]
        case .openCombine:  return [.define("USE_OPEN_COMBINE")]
        }
    }
    
    var packageDependencies: [Package.Dependency] {
        switch self {
        case .combine: return []
        case .combineX: return [.package(url: "https://github.com/cx-org/CombineX", .branch("master"))]
        case .openCombine: return  [.package(url: "https://github.com/broadwaylamb/OpenCombine", .upToNextMinor(from: "0.12.0"))]
        }
    }
    
    var shimTargetDependencies: [Target.Dependency] {
        switch self {
        case .combine:      return ["CXCompatible"]
        case .combineX:     return ["CombineX"]
        case .openCombine:  return [
            "OpenCombine",
            .product(name: "OpenCombineDispatch", package: "OpenCombine"),
            .product(name: "OpenCombineFoundation", package: "OpenCombine"),
        ]
        }
    }
}

// MARK: - Helpers

import Foundation

extension ProcessInfo {
    
    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
}

// MARK: - Config Package

var combineImp = ProcessInfo.processInfo.combineImplementation

package.dependencies = combineImp.packageDependencies
let shimTarget = package.targets.first(where: { $0.name == "CXShim" })!
shimTarget.dependencies = combineImp.shimTargetDependencies
shimTarget.swiftSettings = combineImp.swiftSettings

if combineImp == .combine {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
}
