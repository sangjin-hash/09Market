//
//  Project.swift
//  Schedule
//
//  Created by 23ji
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Schedule",
    targets: Project.interfaceTargets(
        name: "Schedule",
        dependencies: [
            .module(.core),
        ]
    ) + Project.implementTargets(
        name: "Schedule",
        dependencies: [
          .module(.core),
          .module(.domain),
          .module(.sharedDI),
          .module(.sharedReactiveX),
          .external(name: "Kingfisher")
        ]
    )
)
