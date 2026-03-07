//
//  LoadingIndicator.swift
//  DesignSystem
//
//  Created by Sangjin Lee
//

import UIKit

public enum LoadingIndicator {

    private static let overlayTag = 999_001
    private static let indicatorTag = 999_002

    /// 화면 중앙에 로딩 인디케이터를 표시
    /// - Parameters:
    ///   - view: 인디케이터를 표시할 뷰
    ///   - blockInteraction: true이면 회색 반투명 오버레이 + 사용자 입력 차단
    public static func show(on view: UIView, blockInteraction: Bool = false) {
        guard view.viewWithTag(indicatorTag) == nil else { return }

        if blockInteraction {
            let overlay = UIView()
            overlay.tag = overlayTag
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            overlay.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(overlay)
            NSLayoutConstraint.activate([
                overlay.topAnchor.constraint(equalTo: view.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.tag = indicatorTag
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true

        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        indicator.startAnimating()
    }

    /// 로딩 인디케이터 및 오버레이 제거
    public static func hide(from view: UIView) {
        view.viewWithTag(overlayTag)?.removeFromSuperview()

        guard let indicator = view.viewWithTag(indicatorTag) as? UIActivityIndicatorView else { return }
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
}
