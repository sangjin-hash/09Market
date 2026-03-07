//
//  SignOutUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Core

public protocol SignOutUseCase {
    func execute(provider: AuthProvider) async throws
}
