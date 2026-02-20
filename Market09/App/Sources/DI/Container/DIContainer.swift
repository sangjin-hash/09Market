//
//  DIContainer.swift
//  App
//
//  Created by Sangjin Lee
//

import Foundation

final class DIContainer {
    static let shared = DIContainer()
    
    private var factories: [String: () -> Any] = [:]
    private var singletons: [String: Any] = [:]
    private var scopes: [String: ObjectScope] = [:]
    
    private init() {}
    
    // MARK: - Register
    
    func register<T>(
        _ type: T.Type,
        scope: ObjectScope = .singleton,
        factory: @escaping () -> T
    ) {
        let key = String(describing: type)
        factories[key] = factory
        scopes[key] = scope
    }
    
    // MARK: - Resolve
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        if scopes[key] == .singleton, let cached = singletons[key] as? T {
            return cached
        }
        
        guard let factory = factories[key] else {
            fatalError("'\(key)' 타입이 등록되지 않았습니다. register()를 먼저 호출하세요.")
        }
        
        let instance = factory() as! T
        
        if scopes[key] == .singleton {
            singletons[key] = instance
        }
        
        return instance
    }
    
    func resolveOptional<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        
        if scopes[key] == .singleton, let cached = singletons[key] as? T {
            return cached
        }
        
        guard let factory = factories[key] else { return nil }
        let instance = factory() as! T
        
        if scopes[key] == .singleton {
            singletons[key] = instance
        }
        
        return instance
    }
}
