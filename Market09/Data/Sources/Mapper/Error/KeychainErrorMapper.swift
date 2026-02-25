//
//  KeychainErrorMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Core

enum KeychainErrorMapper {

    static func map(_ error: KeychainError) -> AppError {
        switch error {
        case .saveFailed:
            return .storage(.saveFailed)
        case .deleteFailed:
            return .storage(.deleteFailed)
        }
    }
}
