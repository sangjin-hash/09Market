//
//  StorageErrorType.swift
//  AppCore
//
//  Created by Sangjin Lee
//

public enum StorageErrorType: Equatable {
    case saveFailed
    case loadFailed
    case deleteFailed
    case notFound

    public var message: String {
        switch self {
        case .saveFailed, .loadFailed, .deleteFailed, .notFound:
            return ErrorString.Storage.insufficientSpace
        }
    }
}
