//
//  ErrorDialog.swift
//  AppCore
//
//  Created by Sangjin Lee
//

import UIKit

import DesignSystem

public enum ErrorDialog {
    static func showRetryAlert(
        on viewController: UIViewController,
        message: String,
        retryAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Strings.Common.retry, style: .default) { _ in retryAction() })
        viewController.present(alert, animated: true)
    }

    static func showConfirmAlert(
        on viewController: UIViewController,
        message: String,
        confirmAction: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.Common.confirm, style: .default) { _ in confirmAction?() })
        viewController.present(alert, animated: true)
    }
}
