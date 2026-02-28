//
//  SupabaseErrorMapper.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation
import Auth
import Core

enum SupabaseErrorMapper {

    static func map(_ error: AuthError) -> AppError {
        switch error {
        case .sessionMissing:
            return .auth(.sessionExpired)

        case .jwtVerificationFailed:
            return .auth(.sessionExpired)

        case .pkceGrantCodeExchange, .implicitGrantRedirect:
            return .auth(.providerFailed)

        case .api(let message, let errorCode, _, let response):
            return mapAPIError(
                message: message,
                errorCode: errorCode,
                statusCode: response.statusCode
            )

        default:
            return .unknown(message: error.localizedDescription)
        }
    }

    private static func mapAPIError(
        message: String,
        errorCode: ErrorCode,
        statusCode: Int
    ) -> AppError {
        switch errorCode {
        case .invalidCredentials:
            return .auth(.invalidCredentials)
        case .sessionNotFound, .sessionExpired,
             .refreshTokenNotFound, .refreshTokenAlreadyUsed:
            return .auth(.sessionExpired)
        case .signupDisabled, .anonymousProviderDisabled:
            return .auth(.providerFailed)
        case .overRequestRateLimit, .overEmailSendRateLimit, .overSMSSendRateLimit:
            return .auth(.rateLimited)
        default:
            break
        }

        switch statusCode {
        case 401:    return .auth(.invalidCredentials)
        case 403:    return .auth(.providerFailed)
        case 404:    return .network(.notFound)
        case 429:    return .auth(.rateLimited)
        case 500...: return .network(.serverError(statusCode: statusCode))
        default:     return .unknown(message: message)
        }
    }
}
