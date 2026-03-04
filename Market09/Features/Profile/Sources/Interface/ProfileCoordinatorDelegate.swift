//
//  ProfileCoordinatorDelegate.swift
//  Profile
//
//  Created by Sangjin Lee
//

public protocol ProfileCoordinatorDelegate: AnyObject {
    /// 익명 상태에서 로그인 버튼 탭 (back 버튼 O)
    func profileDidRequestLogin()
    
    /// 세션만료/인증실패로 강제 재인증 필요 (back 버튼 X)
    func profileDidRequireLogin()
}
