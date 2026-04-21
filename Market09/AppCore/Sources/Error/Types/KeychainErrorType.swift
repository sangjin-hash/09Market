//
//  KeychainErrorType.swift
//  AppCore
//
//  Created by Sangjin Lee
//

public enum KeychainErrorType: Equatable {
    case saveFailed
    case loadFailed
    case deleteFailed
    case notFound

    public var message: String {
        switch self {
        case .saveFailed:
            return ErrorString.Keychain.saveFailed
        case .loadFailed:
            return ""
        case .deleteFailed:
            return ""
        case .notFound:
            return ErrorString.Keychain.notFound
        }
    }
}
