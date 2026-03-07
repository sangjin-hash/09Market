//
//  Project.swift
//  DesignSystem
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "DesignSystem",
    targets: [
        .target(
            name: "DesignSystem",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.designsystem",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .module(.util),
            ]
        ),
    ]
)
