//
//  AppDIContainer.swift
//  App
//
//  Created by Sangjin Lee
//

enum AppDIContainer {
    static func configure() {
        let assemblies: [Assemblable] = [
            DataAssembly(),
            DomainAssembly(),
            PresentationAssembly(),
        ]

        assemblies.forEach { $0.assemble(container: .shared) }
    }
}
