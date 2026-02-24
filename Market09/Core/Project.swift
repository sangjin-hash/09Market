//
//  Project.swift
//  Core
//
//  Created by Sangjin Lee
//

import ProjectDescription

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
            dependencies: []
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
