//
//  RemoteDataSource.swift
//  AppCore
//
//  Created by Sangjin Lee
//

public protocol RemoteDataSource {}

public extension RemoteDataSource {
    @discardableResult
    func performRequest<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch let error as AppError {
            throw error
        } catch is DecodingError {
            throw AppError.network(.invalidResponse)
        } catch {
            throw AppError.unknown(message: error.localizedDescription)
        }
    }
}
