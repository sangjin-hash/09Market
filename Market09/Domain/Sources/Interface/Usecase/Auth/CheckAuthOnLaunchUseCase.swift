//
//  CheckAuthOnLaunchUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Core

public protocol CheckAuthOnLaunchUseCase {
    func execute() async throws -> AuthState
}
