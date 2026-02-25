//
//  AuthRemoteDataSource.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation
import Auth
import Supabase
import Core

public protocol AuthRemoteDataSource {
    func signInAnonymously() async throws -> AuthTokenResponse
    func signInWithIdToken(provider: String, idToken: String, nonce: String?) async throws -> AuthTokenResponse
    func refreshToken(_ refreshToken: String) async throws -> AuthTokenResponse
    func signOut() async throws
    func deleteAccount() async throws
}

public final class AuthRemoteDataSourceImpl: AuthRemoteDataSource {
    
    private let client: SupabaseClient
    
    public init(supabaseURL: URL, supabaseKey: String) {
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    /// 익명 로그인으로 임시 세션을 생성
    public func signInAnonymously() async throws -> AuthTokenResponse {
        let session = try await performAuth {
            try await self.client.auth.signInAnonymously()
        }
        
        return AuthTokenResponse(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
    }
    
    /// 소셜 로그인(Google 등)의 IdToken을 사용하여 인증
    /// - Parameters:
    ///   - provider: OIDC 제공자 식별자 (예: "google", "apple")
    ///   - idToken: 소셜 로그인 제공자로부터 발급받은 ID 토큰
    ///   - nonce: CSRF 방지를 위한 임의 문자열 (Apple 로그인 시 필수)
    public func signInWithIdToken(
        provider: String,
        idToken: String,
        nonce: String?
    ) async throws -> AuthTokenResponse {
        guard let oidcProvider = OpenIDConnectCredentials.Provider(rawValue: provider) else {
            throw AppError.auth(.providerFailed)
        }

        let session = try await performAuth {
            try await self.client.auth.signInWithIdToken(
                credentials: .init(
                    provider: oidcProvider,
                    idToken: idToken,
                    nonce: nonce
                )
            )
        }
        
        return AuthTokenResponse(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
    }

    /// refreshToken으로 만료된 세션을 갱신
    /// - Parameter refreshToken: 세션 갱신에 사용할 리프레시 토큰
    public func refreshToken(_ refreshToken: String) async throws -> AuthTokenResponse {
        let session = try await performAuth {
            try await self.client.auth.setSession(
                accessToken: "",
                refreshToken: refreshToken
            )
        }
        
        return AuthTokenResponse(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
    }

    /// 현재 세션을 종료하고 로그아웃
    public func signOut() async throws {
        try await performAuth {
            try await self.client.auth.signOut()
        }
    }

    /// 계정을 삭제하고 로그아웃 처리
    public func deleteAccount() async throws {
        // TODO: Supabase Edge Function 또는 자체 API로 계정 삭제 구현
//        try await performAuth {
//            try await self.client.auth.signOut()
//        }
    }

    // MARK: - Private

    @discardableResult
    private func performAuth<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch let error as AuthError {
            // 1) Supabase Auth 에러
            throw SupabaseErrorMapper.map(error)
        } catch let error as URLError {
            // 2) Network 에러
            throw NetworkErrorMapper.map(error)
        } catch {
            // 3) 알 수 없는 에러
            throw AppError.unknown(message: error.localizedDescription)
        }
    }
}
