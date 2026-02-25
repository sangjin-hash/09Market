//
//  Project.swift
//  Shared
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Shared",
    targets: [
        .target(
            name: "Shared",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.shared",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "RxSwift"),
            ]
        ),
    ]
)
