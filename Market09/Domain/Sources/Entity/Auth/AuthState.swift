//
//  AuthState.swift
//  Domain
//
//  Created by Sangjin Lee
//

import Core

public enum AuthState {
    case anonymous
    case authenticated(User)
    case unauthenticated
}
