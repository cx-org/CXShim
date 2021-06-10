// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CXShim",
    products: [
        .library(name: "CXShim", targets: ["CXShim"]),
    ],
    targets: [
        .target(name: "CXShim"),
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
        // TODO: move CXCompatible into this repo
        // FIXME: branch
        case .combineX, .combine: return [.package(url: "https://github.com/cx-org/CombineX", .branch("strip-cxshim"))]
        case .openCombine: return  [.package(url: "https://github.com/broadwaylamb/OpenCombine", .upToNextMinor(from: "0.11.0"))]
        // default: return []
        }
    }
    
    var shimTargetDependencies: [Target.Dependency] {
        switch self {
        case .combine:      return [.product(name: "CXCompatible", package: "CombineX")]
        case .combineX:     return ["CombineX"]
        case .openCombine:  return ["OpenCombine", "OpenCombineDispatch"]
        }
    }
}

// MARK: - Helpers

import Foundation

extension ProcessInfo {
    
    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
    
    var isCI: Bool {
        return (environment["CX_CONTINUOUS_INTEGRATION"] as NSString?)?.boolValue ?? false
    }
}

extension Optional where Wrapped: RangeReplaceableCollection {
    
    mutating func append(contentsOf newElements: [Wrapped.Element]) {
        if newElements.isEmpty { return }
        
        if let wrapped = self {
            self = wrapped + newElements
        } else {
            self = .init(newElements)
        }
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