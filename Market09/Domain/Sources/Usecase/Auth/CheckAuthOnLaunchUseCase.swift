//
//  CheckAuthOnLaunchUseCase.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol CheckAuthOnLaunchUseCase {
    func execute() async throws -> AuthState
}

public final class CheckAuthOnLaunchUseCaseImpl: CheckAuthOnLaunchUseCase {

    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute() async throws -> AuthState {
        switch authRepository.currentTokenStatus() {
        case .noToken:
            _ = try await authRepository.signInAnonymously()
            return .anonymous

        case .valid(let isAnonymous):
            return isAnonymous ? .anonymous : .authenticated

        case .expired(let isAnonymous):
            do {
                _ = try await authRepository.refreshToken()
                return isAnonymous ? .anonymous : .authenticated
            } catch {
                if isAnonymous {
                    _ = try await authRepository.signInAnonymously()
                    return .anonymous
                } else {
                    try authRepository.clearToken()
                    return .unauthenticated
                }
            }
        }
    }
}
