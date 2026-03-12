//
//  UIView+Then.swift
//  Shared_UI
//
//  Created by Sangjin Lee
//

import Foundation

/// 초기화 직후 클로저로 설정을 체이닝할 수 있는 프로토콜
/// ```swift
/// let label = UILabel().then {
///     $0.text = "Hello"
///     $0.textColor = .black
/// }
/// ```
public protocol Then {}

extension Then where Self: AnyObject {
    @discardableResult
    public func then(_ configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}

extension NSObject: Then {}
