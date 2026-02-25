//
//  StorageErrorType.swift
//  Core
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
        case .saveFailed:   return ErrorString.Storage.saveFailed
        case .loadFailed:   return ErrorString.Storage.loadFailed
        case .deleteFailed: return ErrorString.Storage.deleteFailed
        case .notFound:     return ErrorString.Storage.notFound
        }
    }
}
