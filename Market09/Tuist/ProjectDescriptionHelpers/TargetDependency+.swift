//
//  TargetDependency+.swift
//  ProjectDescriptionHelpers
//
//  Created by Sangjin Lee
//

import ProjectDescription

// MARK: - Feature

public enum Feature: String {
    case home = "Home"
    case auth = "Authenticate"
    case profile = "Profile"
    case login = "Login"
}

public enum FeatureType {
    case interface
    case implement
}

extension TargetDependency {

    public static func feature(_ feature: Feature, type: FeatureType) -> TargetDependency {
        switch type {
        case .interface:
            return .project(
                target: feature.rawValue,
                path: .relativeToRoot("Features/\(feature.rawValue)")
            )
        case .implement:
            return .project(
                target: "\(feature.rawValue)Impl",
                path: .relativeToRoot("Features/\(feature.rawValue)")
            )
        }
    }
}

// MARK: - Module

public enum Module: String {
    case domain = "Domain"
    case domainImpl = "DomainImpl"
    case core = "Core"
    case data = "Data"
    case sharedReactiveX = "Shared_ReactiveX"
    case sharedDI = "Shared_DI"
    case util = "Util"
    case designSystem = "DesignSystem"

    var projectPath: String {
        switch self {
        case .domainImpl: return "Domain"
        case .sharedReactiveX, .sharedDI: return "Shared/\(rawValue)"
        default: return rawValue
        }
    }
}

extension TargetDependency {

    public static func module(_ module: Module) -> TargetDependency {
        .project(
            target: module.rawValue,
            path: .relativeToRoot(module.projectPath)
        )
    }
}
