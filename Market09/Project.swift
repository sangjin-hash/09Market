//
//  Project.swift
//  Manifest
//
//  Created by Sangjin Lee
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Market09",
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "./Secrets.xcconfig"),
            .release(name: "Release", xcconfig: "./Secrets.xcconfig"),
        ]
    ),
    targets: [
        // MARK: - App
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "com.ios.market09",
            infoPlist: .extendingDefault(
                with: [
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName":
                                        "$(PRODUCT_MODULE_NAME).SceneDelegate",
                                ]
                            ]
                        ],
                    ],
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "SUPABASE_URL": "$(SUPABASE_URL)",
                    "SUPABASE_ANON_KEY": "$(SUPABASE_ANON_KEY)",
                ]
            ),
            buildableFolders: [
                "App/Sources",
                "App/Resources",
            ],
            dependencies: [
                .module(.domain),
                .module(.core),
                .module(.data),
                .feature(.home, type: .interface),
                .feature(.home, type: .implement),
                .feature(.auth, type: .interface),
                .feature(.auth, type: .implement),
                .feature(.profile, type: .interface),
                .feature(.profile, type: .implement),
                .external(name: "Swinject"),
            ],
        ),

        // MARK: - Tests
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.ios.market09.appTests",
            buildableFolders: [
                "App/Tests"
            ],
            dependencies: [.target(name: "App")]
        ),
    ]
)
