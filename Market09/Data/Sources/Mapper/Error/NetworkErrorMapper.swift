//
//  NetworkErrorMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation
import Core

enum NetworkErrorMapper {

    static func map(_ error: URLError) -> AppError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .network(.notConnected)
        case .timedOut:
            return .network(.timeout)
        case .cannotDecodeRawData, .cannotDecodeContentData, .cannotParseResponse:
            return .network(.invalidResponse)
        default:
            return .unknown(message: error.localizedDescription)
        }
    }
}
