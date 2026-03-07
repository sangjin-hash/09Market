//
//  Project.swift
//  Core
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Core",
    targets: [
        .target(
            name: "Core",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.core",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .module(.util),
                .project(
                    target: "Shared_ReactiveX",
                    path: .relativeToRoot("Shared_ReactiveX")
                ),
            ]
        ),
        .target(
            name: "CoreTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.ios.market09.coreTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Tests/**"],
            dependencies: [.target(name: "Core")]
        ),
    ]
)
