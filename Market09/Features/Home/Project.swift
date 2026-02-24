//
//  Project.swift
//  Home
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Home",
    targets: Project.interfaceTargets(
        name: "Home",
        dependencies: [
            .module(.core),
        ]
    ) + Project.implementTargets(
        name: "Home",
        dependencies: [
            .module(.core),
            .module(.domain),
            .external(name: "Swinject"),
        ]
    )
)
