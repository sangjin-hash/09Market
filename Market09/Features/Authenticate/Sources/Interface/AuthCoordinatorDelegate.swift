//
//  AuthCoordinatorDelegate.swift
//  Authenticate
//
//  Created by Sangjin Lee
//

import Domain

public protocol AuthCoordinatorDelegate: AnyObject {
    /// Splash 인증 확인 완료
    func authDidCheckOnLaunch(state: AuthState)
}
