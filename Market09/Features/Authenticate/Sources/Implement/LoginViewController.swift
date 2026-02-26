//
//  LoginViewController.swift
//  AuthenticateImpl
//
//  Created by Sangjin Lee
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import Core

final class LoginViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI
    
    private let googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.Auth.googleLogin, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return button
    }()

    private let appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.Auth.appleLogin, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }
}

extension LoginViewController: View {
    
    // MARK: - Bind

    func bind(reactor: LoginReactor) {
        // Action
        googleLoginButton.rx.tap
            .map { Reactor.Action.googleLoginTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        appleLoginButton.rx.tap
            .map { Reactor.Action.appleLoginTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State
        reactor.state.map(\.isLoginCompleted)
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                // TODO: Coordinator에서 dismiss 처리
                // TODO: Step 11에서 delegate 연결
            })
            .disposed(by: disposeBag)
    }
}

extension LoginViewController {
    
    // MARK: - Layout
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            googleLoginButton, appleLoginButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
