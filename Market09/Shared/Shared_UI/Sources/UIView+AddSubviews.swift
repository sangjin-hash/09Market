//
//  UIView+AddSubviews.swift
//  Shared_UI
//
//  Created by Sangjin Lee
//

import UIKit

extension UIView {
    /// 여러 서브뷰를 한 번에 추가
    public func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
