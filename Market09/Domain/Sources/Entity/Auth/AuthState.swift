//
//  AuthState.swift
//  Domain
//
//  Created by Sangjin Lee
//

public enum AuthState {
    case anonymous
    case authenticated(User)
    case unauthenticated
}
