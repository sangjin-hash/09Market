//
//  LoginViewController.swift
//  LoginImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import DesignSystem
import Shared_DI
import Shared_ReactiveX

import GoogleSignIn
import AuthenticationServices

final class LoginViewController: UIViewController, FactoryModule {
    
    struct Dependency {
        let reactor: LoginReactor
    }
    
    var disposeBag = DisposeBag()
    
    required init(dependency: Dependency, payload: Void) {
        super.init(nibName: nil, bundle: nil)
        defer { self.reactor = dependency.reactor }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        self.view.backgroundColor = .systemBackground
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension LoginViewController: View {
    func bind(reactor: LoginReactor) {

        // MARK: - Action

        self.googleLoginButton.rx.tap
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
            .disposed(by: self.disposeBag)

        self.appleLoginButton.rx.tap
            .map { Reactor.Action.appleLoginTapped }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

      // MARK: - State

      reactor.pulse(\.$appleLoginHashedNonce)
            .compactMap{ $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] hashedNonce in
                guard let self else { return }

                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
                request.nonce = hashedNonce

                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.delegate = self
                authorizationController.presentationContextProvider = self
                authorizationController.performRequests()
            })
            .disposed(by: self.disposeBag)


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
            .disposed(by: self.disposeBag)

        reactor.pulse(\.$error)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                ErrorDialog.show(on: self, error: error)
            })
            .disposed(by: self.disposeBag)
    }
}

extension LoginViewController {

    // MARK: - Layout

    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            self.googleLoginButton, self.appleLoginButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let idToken = String(data: identityToken, encoding: .utf8) else {
            return
        }

      guard let nonce = self.reactor?.currentState.appleLoginNonce else { return }
        self.reactor?.action.onNext(.appleLoginCompleted(idToken: idToken, nonce: nonce))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Login Error: \(error.localizedDescription)")
    }
}
