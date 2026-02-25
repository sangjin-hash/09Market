//
//  AuthRepository.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol AuthRepository {
    
    /// 익명 로그인으로 임시 세션을 생성
    func signInAnonymously() async throws -> AuthToken
    
    /// 소셜 로그인(Google 등)의 IdToken을 사용하여 인증
    /// - Parameters:
    ///   - provider: OIDC 제공자 식별자 (예: "google", "apple")
    ///   - idToken: 소셜 로그인 제공자로부터 발급받은 ID 토큰
    ///   - nonce: CSRF 방지를 위한 임의 문자열 (Apple 로그인 시 필수)
    func signInWithIdToken(provider: String, idToken: String, nonce: String?) async throws -> AuthToken
    
    /// refreshToken으로 만료된 세션을 갱신
    /// - Parameter refreshToken: 세션 갱신에 사용할 리프레시 토큰
    func refreshToken(_ refreshToken: String) async throws -> AuthToken
    
    /// 현재 세션을 종료하고 로그아웃
    func signOut() async throws
    
    /// 계정을 삭제하고 로그아웃 처리
    func deleteAccount() async throws
}
