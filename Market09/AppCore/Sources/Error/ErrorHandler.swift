//
//  ErrorHandler.swift
//  AppCore
//
//  Created by Sangjin Lee
//

import UIKit

import Shared_ReactiveX

public enum ErrorHandler {

    // MARK: - Global Stream

    /// requireLogin 에러 발생 시 전역으로 이벤트를 발행한다.
    /// AppCoordinator에서 구독하여 로그인 화면으로 이동 처리.
    public static let loginRequiredStream = PublishSubject<Void>()


    // MARK: - Handle

    /// 모든 화면에서 에러 처리 시 이 메서드를 통해 처리한다.
    /// handleStrategy에 따라 Dialog 표시 / assertionFailure / print 분기.
    ///
    /// - Parameters:
    ///   - error: 처리할 AppError
    ///   - viewController: Dialog를 표시할 기준 ViewController
    ///   - action: 재시도 or 확인 버튼 이후 fallback
    public static func handle(
        error: AppError,
        on viewController: UIViewController,
        action: (() -> Void)? = nil
    ) {
        switch error.handleStrategy {
        case .retryable(let message):
            if let action {
                ErrorDialog.showRetryAlert(
                    on: viewController,
                    message: message,
                    retryAction: action
                )
            } else {
                ErrorDialog.showConfirmAlert(
                    on: viewController,
                    message: message
                )
            }

        case .userGuide(let message):
            ErrorDialog.showConfirmAlert(on: viewController, message: message)

        case .requireLogin(let message):
            ErrorDialog.showConfirmAlert(on: viewController, message: message) {
                Self.loginRequiredStream.onNext(())
            }

        case .developerError:
            assertionFailure("[Developer Error] \(error)")

        case .silent:
            print("[AppError] \(error.message)")
        }
    }
}
