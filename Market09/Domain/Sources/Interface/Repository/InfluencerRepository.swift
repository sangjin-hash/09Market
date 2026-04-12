//
//  InfluencerRepository.swift
//  Domain
//
//  Created by Sangjin Lee
//

public protocol InfluencerRepository {
    /// 인플루언서 등록
    /// - Parameters:
    ///   - username: 인플루언서 ID
    /// - Throws: `AppError.network(.conflict)` 이미 등록된 경우
    func registerInfluencer(_ username: String) async throws

    /// username 포함 검색 (최대 3개)
    /// - Parameters:
    ///   - username: 검색할 username
    /// - Returns: 매칭된 인플루언서 목록
    func searchInfluencers(_ username: String) async throws -> [Influencer]
}
