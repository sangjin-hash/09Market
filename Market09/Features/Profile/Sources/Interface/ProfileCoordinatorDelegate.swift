//
//  ProfileCoordinatorDelegate.swift
//  Profile
//
//  Created by Sangjin Lee
//

public protocol ProfileCoordinatorDelegate: AnyObject {
    func profileDidRequestLogin()
    func profileDidRequestLogout()
    func profileDidRequestDeleteAccount()
}
