//
//  Resolver+Extension.swift
//  Shared_DI
//
//  Created by Sangjin Lee
//

import Swinject

extension Resolver {
    public func resolve<Service>() -> Service! {
        return self.resolve(Service.self)
    }

    public func resolve<Service, Arg>(argument: Arg) -> Service! {
        return self.resolve(Service.self, argument: argument)
    }
}
