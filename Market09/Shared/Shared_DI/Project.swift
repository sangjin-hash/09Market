//
//  Project.swift
//  Shared_DI
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Shared_DI",
    targets: [
        .target(
            name: "Shared_DI",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.shared-di",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "Swinject"),
                .external(name: "Pure")
            ]
        ),
    ]
)
