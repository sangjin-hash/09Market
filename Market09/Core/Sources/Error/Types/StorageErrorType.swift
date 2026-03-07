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
        ErrorString.Storage.insufficientSpace
    }
}
