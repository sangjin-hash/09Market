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
    /// 소셜 로그인 성공
    func authDidLogin()
    /// 로그인 화면 닫기
    func authDidCancelLogin()
}
