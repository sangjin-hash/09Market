//
//  UITextField+Padding.swift
//  DesignSystem
//
//  Created by Sangjin Lee
//

import UIKit

public extension UITextField {
    func addLeftPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 1))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
