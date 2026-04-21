//
//  ClientErrorType.swift
//  AppCore
//
//  Created by Sangjin Lee
//

public enum ClientErrorType: Equatable {
    case imageSizeLimitExceeded
    case photoLibraryAccessDenied
    case invalidImageFormat

    public var message: String {
        switch self {
        case .imageSizeLimitExceeded:
            return ErrorString.Client.imageSizeLimitExceeded
        case .photoLibraryAccessDenied:
            return ErrorString.Client.photoLibraryAccessDenied
        case .invalidImageFormat:
            return ErrorString.Client.invalidImageFormat
        }
    }
}
