//
//  KeychainErrorMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import AppCore

enum KeychainErrorMapper {
    static func map(_ error: KeychainError) -> AppError {
        switch error {
        case .saveFailed:
            return .keychain(.saveFailed)
        case .deleteFailed:
            return .keychain(.deleteFailed)
        }
    }
}
