//
//  UIView+Flex.swift
//  Shared_UI
//
//  Created by Sangjin Lee
//

import UIKit

import FlexLayout
import PinLayout

extension UIView {
    /// FlexLayout의 rootContainer로 사용할 뷰를 생성하고 addSubview까지 수행
    public func makeFlexContainer(
        direction: Flex.Direction = .column
    ) -> UIView {
        let container = UIView()
        addSubview(container)
        container.flex.direction(direction)
        return container
    }

    /// PinLayout + FlexLayout 조합으로 레이아웃 수행
    /// viewDidLayoutSubviews() 에서 호출
    public func flexLayout(pinToSuperView: Bool = true) {
        if pinToSuperView {
            self.pin.all()
        }
        self.flex.layout()
    }

    /// flex.layout() 단축 호출
    public func flexLayout(mode: Flex.LayoutMode = .fitContainer) {
        self.flex.layout(mode: mode)
    }
}
