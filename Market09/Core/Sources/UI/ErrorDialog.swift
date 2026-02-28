//
//  ErrorDialog.swift
//  Core
//
//  Created by Sangjin Lee
//

import UIKit

public enum ErrorDialog {

    /// AppError의 handleStrategy에 따라 적절한 다이얼로그를 표시
    public static func show(
        on viewController: UIViewController,
        error: AppError,
        retryAction: (() -> Void)? = nil
    ) {
        switch error.handleStrategy {
        case .retryable(let message):
            if let retryAction {
                showRetryAlert(on: viewController, message: message, retryAction: retryAction)
            } else {
                showConfirmAlert(on: viewController, message: message)
            }

        case .userGuide(let message):
            showConfirmAlert(on: viewController, message: message)

        case .developerError:
            assertionFailure("[Developer Error] \(error)")

        case .silent:
            print("[AppError] \(error.message)")
        }
    }
}

// MARK: - Private

private extension ErrorDialog {

    static func showRetryAlert(
        on viewController: UIViewController,
        message: String,
        retryAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        alert.addAction(UIAlertAction(title: "재시도", style: .default) { _ in retryAction() })
        viewController.present(alert, animated: true)
    }

    static func showConfirmAlert(
        on viewController: UIViewController,
        message: String
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        viewController.present(alert, animated: true)
    }
}
