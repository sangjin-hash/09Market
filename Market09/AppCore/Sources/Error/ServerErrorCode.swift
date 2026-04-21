//
//  ServerErrorCode.swift
//  AppCore
//
//  Created by Sangjin Lee
//

import Foundation

/// 서버-클라이언트가 Feature.reason 형태로 공유하는 에러 코드
/// 새로운 에러 코드 추가 시 이 타입과 ErrorString.Server에만 추가
public enum ServerErrorCode: String, Equatable {
    case influencerConflict = "influencer.conflict"
    case unknown

    public init(code: String) {
        self = ServerErrorCode(rawValue: code) ?? .unknown
    }

    public var message: String {
        switch self {
        case .influencerConflict:
            return ErrorString.Server.influencerConflict
        case .unknown:
            return ErrorString.Server.unknown
        }
    }
}
