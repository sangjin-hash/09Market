//
//  LoginViewController.swift
//  LoginImpl
//
//  Created by Sangjin Lee
//

import Core
import DesignSystem
import Shared_ReactiveX
import UIKit
import Util

import GoogleSignIn

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension LoginViewController: View {
    
    func bind(reactor: LoginReactor) {
        
        // MARK: - Action
        
        googleLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
                    guard let self, let reactor = self.reactor else { return }

                    if let error {
                        if (error as NSError).code == GIDSignInError.canceled.rawValue { return }
                        reactor.action.onNext(.googleLoginFailed)
                        return
                    }

                    guard let idToken = result?.user.idToken?.tokenString else {
                        reactor.action.onNext(.googleLoginFailed)
                        return
                    }

                    reactor.action.onNext(.googleLoginCompleted(idToken: idToken))
                }
            })
            .disposed(by: disposeBag)

        appleLoginButton.rx.tap
            .map { Reactor.Action.appleLoginTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        

        // MARK: - State

        reactor.state.map(\.isLoading)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    LoadingIndicator.show(on: self.view, blockInteraction: true)
                } else {
                    LoadingIndicator.hide(from: self.view)
                }
            })
            .disposed(by: disposeBag)

        reactor.pulse(\.$error)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                ErrorDialog.show(on: self, error: error)
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
