//
//  SignInWithIdTokenUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Core

public protocol SignInWithIdTokenUseCase {
    func execute(provider: AuthProvider, idToken: String, nonce: String?) async throws -> AuthToken
}
