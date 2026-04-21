//
//  NetworkErrorMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore

enum NetworkErrorMapper {
    static func map(_ error: URLError) -> AppError {
        switch error.code {
        case .notConnectedToInternet:
            return .network(.notConnected)
        case .networkConnectionLost:
            return .network(.connectionLost)
        case .timedOut:
            return .network(.timeout)
        case .cancelled:
            return .network(.cancelled)
        case .secureConnectionFailed, .serverCertificateHasBadDate,
             .serverCertificateUntrusted, .serverCertificateHasUnknownRoot,
             .serverCertificateNotYetValid, .clientCertificateRejected,
             .clientCertificateRequired:
            return .network(.sslError)
        case .cannotDecodeRawData, .cannotDecodeContentData, .cannotParseResponse:
            return .network(.invalidResponse)
        default:
            return .unknown(message: error.localizedDescription)
        }
    }
}
