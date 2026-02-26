//
//  AuthRepository.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol AuthRepository {

    // MARK: - SignIn

    /// 익명 로그인으로 임시 세션을 생성하고 토큰을 Keychain에 저장
    /// - Returns: 발급된 인증 토큰
    func signInAnonymously() async throws -> AuthToken

    /// 소셜 로그인(Google 등)의 IdToken을 사용하여 인증하고 토큰을 Keychain에 저장
    /// - Parameters:
    ///   - provider: OIDC 제공자 식별자 (예: "google", "apple")
    ///   - idToken: 소셜 로그인 제공자로부터 발급받은 ID 토큰
    ///   - nonce: CSRF 방지를 위한 임의 문자열 (Apple 로그인 시 필수)
    /// - Returns: 발급된 인증 토큰
    func signInWithIdToken(provider: String, idToken: String, nonce: String?) async throws -> AuthToken
    
    // MARK: - Token

    /// Keychain에 저장된 refreshToken으로 세션을 갱신하고 새 토큰을 저장
    /// - Returns: 갱신된 인증 토큰
    func refreshToken() async throws -> AuthToken
    
    /// 토큰 유무, 만료 여부, 익명 여부를 통합 조회하여 현재 인증 상태를 반환
    /// - Returns: noToken / valid / expired 중 하나
    func currentTokenStatus() -> TokenStatus

    /// Keychain에 저장된 모든 인증 데이터를 삭제
    func clearToken() throws
    
    // MARK: - SignOut & Delete Account

    /// 현재 세션을 종료하고 Keychain의 토큰을 삭제
    func signOut() async throws

    /// 계정을 삭제하고 Keychain의 토큰을 삭제
    func deleteAccount() async throws
}
