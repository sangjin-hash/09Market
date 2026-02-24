//
//  Project.swift
//  Data
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Data",
    targets: [
        .target(
            name: "Data",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.data",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .module(.domain),
                .module(.core),
                .external(name: "Alamofire"),
                .external(name: "Kingfisher"),
                .external(name: "Swinject"),
            ]
        ),
        .target(
            name: "DataTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.ios.market09.dataTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Tests/**"],
            dependencies: [.target(name: "Data")]
        ),
    ]
)
