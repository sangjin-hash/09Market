//
//  TokenStatus.swift
//  Domain
//
//  Created by Sangjin Lee
//

public enum TokenStatus {
    case noToken
    case valid(isAnonymous: Bool)
    case expired(isAnonymous: Bool)

    /// 토큰과 익명 여부를 조합하여 현재 토큰 상태를 판정
    /// - Parameters:
    ///   - token: Keychain에서 로드한 토큰 (없으면 nil)
    ///   - isAnonymous: 익명 로그인 여부
    /// - Returns: 판정된 토큰 상태
    public static func evaluate(token: AuthToken?, isAnonymous: Bool) -> TokenStatus {
        guard let token = token else { return .noToken }
        if token.isExpired { return .expired(isAnonymous: isAnonymous) }
        return .valid(isAnonymous: isAnonymous)
    }
}
