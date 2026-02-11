import ProjectDescription

let project = Project(
    name: "Market09",
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
                "App/Sources",
                "App/Resources",
            ],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Core"),
                .target(name: "Data"),
            ]
        ),

        // MARK: - Domain
        .target(
            name: "Domain",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.ios.market09.domain",
            buildableFolders: [
                "Domain/Sources",
            ],
            dependencies: []
        ),

        // MARK: - Core
        .target(
            name: "Core",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.ios.market09.core",
            buildableFolders: [
                "Core/Sources",
            ],
            dependencies: []
        ),

        // MARK: - Data
        .target(
            name: "Data",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.ios.market09.data",
            buildableFolders: [
                "Data/Sources",
            ],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Core"),
                .external(name: "Alamofire"),
                .external(name: "Kingfisher"),
            ]
        ),

        // MARK: - Tests
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.ios.market09.appTests",
            buildableFolders: [
                "App/Tests",
            ],
            dependencies: [.target(name: "App")]
        ),
        .target(
            name: "DomainTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.ios.market09.domainTests",
            buildableFolders: [
                "Domain/Tests",
            ],
            dependencies: [.target(name: "Domain")]
        ),
        .target(
            name: "DataTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.ios.market09.dataTests",
            buildableFolders: [
                "Data/Tests",
            ],
            dependencies: [.target(name: "Data")]
        ),
        .target(
            name: "CoreTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.ios.market09.coreTests",
            buildableFolders: [
                "Core/Tests",
            ],
            dependencies: [.target(name: "Core")]
        ),
    ]
)
