//
//  Project.swift
//  Domain
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Domain",
    targets: [
        .target(
            name: "Domain",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.domain",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "Swinject"),
            ]
        ),
        .target(
            name: "DomainTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.ios.market09.domainTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Tests/**"],
            dependencies: [.target(name: "Domain")]
        ),
    ]
)
