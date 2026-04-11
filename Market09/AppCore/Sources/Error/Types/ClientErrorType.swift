//
//  ClientErrorType.swift
//  Core
//
//  Created by Sangjin Lee
//

public enum ClientErrorType: Equatable {
    case imageSizeLimitExceeded

    public var message: String {
        switch self {
        case .imageSizeLimitExceeded:
            return ErrorString.Client.imageSizeLimitExceeded
        }
    }
}
