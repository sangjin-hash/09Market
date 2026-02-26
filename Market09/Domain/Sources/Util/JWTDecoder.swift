//
//  JWTDecoder.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Foundation

public enum JWTDecoder {

    /// JWT accessToken의 exp claim을 추출하여 만료 여부 반환
    /// - Parameter token: JWT 문자열
    /// - Returns: 만료되었거나 디코딩 실패 시 true
    public static func isExpired(_ token: String) -> Bool {
        guard let payload = decodePayload(token),
              let exp = payload["exp"] as? TimeInterval else {
            return true
        }
        return Date().timeIntervalSince1970 >= exp
    }

    // MARK: - Private

    private static func decodePayload(_ token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }

        let payloadSegment = String(segments[1])
        guard let data = base64URLDecode(payloadSegment) else { return nil }

        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    /// JWT는 Base64URL 인코딩 사용 (+ → -, / → _, 패딩 없음)
    private static func base64URLDecode(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        return Data(base64Encoded: base64)
    }
}
