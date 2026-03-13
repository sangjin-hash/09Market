//
//  UIView+FlexVisible.swift
//  Shared_UI
//
//  Created by Sangjin Lee
//

import UIKit

import FlexLayout

extension UIView {
    public var flexVisible: Bool {
        get { return !self.isHidden }
        set {
            self.isHidden = !newValue
            self.flex.isIncludedInLayout(newValue)
        }
    }
}
