//
//  ConfirmDialog.swift
//  DesignSystem
//
//  Created by Sangjin Lee
//

import UIKit

import Util

public enum ConfirmDialog {
    public static func show(
        on viewController: UIViewController,
        message: String,
        confirmTitle: String = Strings.Common.confirm,
        cancelTitle: String = Strings.Common.cancel,
        confirmAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
            confirmAction()
        })
        viewController.present(alert, animated: true)
    }
}
