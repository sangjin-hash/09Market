//
//  DataAssembly.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation

import Domain
import Shared_DI

public final class DataAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {

        // MARK: - KeychainClient

        container.register(KeychainClient.self) { _ in
            KeychainClientImpl()
        }.inObjectScope(.container)
        

        // MARK: - Auth

        container.register(AuthRemoteDataSource.self) { _ in
            guard let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
                  let url = URL(string: urlString),
                  let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String else {
                fatalError("Supabase 설정이 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
            }
            return AuthRemoteDataSourceImpl(supabaseURL: url, supabaseKey: key)
        }.inObjectScope(.container)

        container.register(AuthLocalDataSource.self) { r in
            AuthLocalDataSourceImpl(keychainClient: r.resolve())
        }.inObjectScope(.container)

        container.register(AuthRepository.self) { r in
            AuthRepositoryImpl(
                remoteDataSource: r.resolve(),
                localDataSource: r.resolve()
            )
        }.inObjectScope(.container)
        

        // MARK: - APIClient

        container.register(Interceptor.self) { r in
            guard let apiKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String else {
                fatalError("SUPABASE_ANON_KEY가 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
            }
            return Interceptor(
                localDataSource: r.resolve(),
                remoteDataSource: r.resolve(),
                apiKey: apiKey
            )
        }.inObjectScope(.container)

        container.register(APIClient.self) { r in
            guard let baseURL = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String else {
                fatalError("SUPABASE_URL이 Info.plist에 없습니다. Secrets.xcconfig을 확인하세요.")
            }
            return APIClientImpl(
                baseURL: baseURL,
                interceptor: r.resolve()
            )
        }.inObjectScope(.container)

        
        // MARK: - User

        container.register(UserRemoteDataSource.self) { r in
            UserRemoteDataSourceImpl(apiClient: r.resolve())
        }.inObjectScope(.container)

        container.register(UserRepository.self) { r in
            UserRepositoryImpl(remoteDataSource: r.resolve())
        }.inObjectScope(.container)
        
        
        // MARK: - Post
        
        container.register(PostRemoteDataSource.self) { r in
            PostRemoteDataSourceImpl(apiClient: r.resolve())
        }.inObjectScope(.container)
        
        container.register(PostRepository.self) { r in
            PostRepositoryImpl(remoteDataSource: r.resolve())
        }.inObjectScope(.container)
    }
}
