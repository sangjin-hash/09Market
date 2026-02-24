//
//  FeatureTarget.swift
//  ProjectDescriptionHelpers
//
//  Created by Sangjin Lee
//

import ProjectDescription

extension Project {

    public static func interfaceTargets(
        name: String,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList? = nil,
        dependencies: [TargetDependency] = []
    ) -> [Target] {
        let target = Target.target(
            name: name,
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.feature.\(name.lowercased())",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources ?? ["Sources/Interface/**"],
            resources: nil,
            dependencies: dependencies,
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]
                ]
            )
        )
        return [target]
    }

    public static func implementTargets(
        name: String,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList? = nil,
        dependencies: [TargetDependency] = []
    ) -> [Target] {
        let target = Target.target(
            name: "\(name)Impl",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.feature.\(name.lowercased()).impl",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources ?? ["Sources/Implement/**"],
            resources: nil,
            dependencies: [.target(name: name)] + dependencies,
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]
                ]
            )
        )
        return [target]
    }
}
