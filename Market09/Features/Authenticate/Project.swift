//
//  Project.swift
//  Authenticate
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Authenticate",
    targets: Project.interfaceTargets(
        name: "Authenticate",
        dependencies: [
            .module(.core),
            .module(.domain),
        ]
    ) + Project.implementTargets(
        name: "Authenticate",
        dependencies: [
            .module(.core),
            .module(.domain),
            .module(.shared),
            .external(name: "Swinject"),
            .external(name: "ReactorKit"),
            .external(name: "RxSwift"),
            .external(name: "RxCocoa"),
            .external(name: "GoogleSignIn"),
        ]
    )
)
