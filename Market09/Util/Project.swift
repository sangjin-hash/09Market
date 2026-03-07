//
//  Project.swift
//  Util
//
//  Created by Sangjin Lee
//

import ProjectDescription

let project = Project(
    name: "Util",
    targets: [
        .target(
            name: "Util",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.util",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: []
        ),
    ]
)
