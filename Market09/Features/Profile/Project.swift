//
//  Project.swift
//  Profile
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Profile",
    targets: Project.interfaceTargets(
        name: "Profile",
        dependencies: [
            .module(.core),
        ]
    ) + Project.implementTargets(
        name: "Profile",
        dependencies: [
            .module(.core),
            .module(.domain),
            .external(name: "Swinject"),
            .external(name: "ReactorKit"),
            .external(name: "RxSwift"),
            .external(name: "RxCocoa"),
        ]
    )
)
