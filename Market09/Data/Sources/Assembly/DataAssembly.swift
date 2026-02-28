//
//  DataAssembly.swift
//  Data
//
//  Created by Sangjin Lee
//

import Foundation
import Swinject
import Domain

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
        
        container.register(AuthLocalDataSource.self) { resolver in
            AuthLocalDataSourceImpl(
                keychainClient: resolver.resolve(KeychainClient.self)!
            )
        }.inObjectScope(.container)

        container.register(AuthRepository.self) { resolver in
            AuthRepositoryImpl(
                remoteDataSource: resolver.resolve(AuthRemoteDataSource.self)!,
                localDataSource: resolver.resolve(AuthLocalDataSource.self)!
            )
        }.inObjectScope(.container)
        
        // MARK: - APIClient
        
        container.register(Interceptor.self) { resolver in
            Interceptor(
                localDataSource: resolver.resolve(AuthLocalDataSource.self)!,
                remoteDataSource: resolver.resolve(AuthRemoteDataSource.self)!,
                apiKey: Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as! String
            )
        }.inObjectScope(.container)
        
        container.register(APIClient.self) { resolver in
            APIClientImpl(
                baseURL: Bundle.main.infoDictionary?["SUPABASE_URL"] as! String,
                interceptor: resolver.resolve(Interceptor.self)!
            )
        }.inObjectScope(.container)

        // MARK: - User

        container.register(UserRemoteDataSource.self) { resolver in
            UserRemoteDataSourceImpl(
                apiClient: resolver.resolve(APIClient.self)!
            )
        }.inObjectScope(.container)

        container.register(UserRepository.self) { resolver in
            UserRepositoryImpl(
                remoteDataSource: resolver.resolve(UserRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
    }
}
