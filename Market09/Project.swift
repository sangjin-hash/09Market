import ProjectDescription

let project = Project(
    name: "Market09",
    targets: [
        .target(
            name: "Market09",
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
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                                ],
                            ],
                        ],
                    ],
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Market09/Sources",
                "Market09/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "Market09Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.ios.market09Tests",
            infoPlist: .default,
            buildableFolders: [
                "Market09/Tests",
            ],
            dependencies: [.target(name: "Market09")]
        ),
    ]
)
