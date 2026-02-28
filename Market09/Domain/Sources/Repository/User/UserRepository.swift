//
//  UserRepository.swift
//  Domain
//
//  Created by Sangjin Lee
//


public protocol UserRepository {
    /// GET /me — 유저  조회
    /// - Returns: 소셜 유저면 User, 익명 로그인이면 nil
    func getMe() async throws -> User?
}
