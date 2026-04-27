//
//  Project.swift
//  Schedule
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Schedule",
    targets: Project.interfaceTargets(
        name: "Schedule",
        dependencies: [
            .module(.core)
        ]
    ) + Project.implementTargets(
        name: "Schedule",
        dependencies: [
            .module(.core),
            .module(.domain),
            .module(.util),
            .module(.designSystem),
            .module(.sharedReactiveX),
            .module(.sharedDI),
            .module(.sharedUI)
        ]
    )
)
