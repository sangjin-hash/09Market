//
//  Project.swift
//  Shared_ReactiveX
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Shared_ReactiveX",
    targets: [
        .target(
            name: "Shared_ReactiveX",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.ios.market09.shared-reactivex",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "RxSwift"),
                .external(name: "RxCocoa"),
                .external(name: "RxRelay"),
                .external(name: "ReactorKit"),
                .external(name: "RxDataSources"),
            ]
        ),
    ]
)
