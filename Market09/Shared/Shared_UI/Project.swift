//
//  Project.swift
//  Shared_UI
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Shared_UI",
    targets: [
        .target(
            name: "Shared_UI",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.shared-ui",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "SnapKit"),
                .external(name: "FlexLayout"),
                .external(name: "PinLayout")
            ]
        ),
    ]
)
