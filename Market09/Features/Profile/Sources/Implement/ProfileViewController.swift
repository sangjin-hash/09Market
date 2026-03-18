//
//  ProfileViewController.swift
//  ProfileImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import DesignSystem
import Shared_DI
import Shared_ReactiveX

final class ProfileViewController: UIViewController, FactoryModule {

    struct Dependency {
        let reactor: ProfileReactor
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

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.Profile.login, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return button
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let providerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.Profile.logout, for: .normal)
        button.isHidden = true
        return button
    }()

    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.Profile.deleteAccount, for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.isHidden = true
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reactor?.action.onNext(.viewDidAppear)
    }
}

extension ProfileViewController: View {

    // MARK: - Bind

    func bind(reactor: ProfileReactor) {
        
        // MARK: - Action
        
        self.loginButton.rx.tap
            .map { Reactor.Action.loginButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                ConfirmDialog.show(
                    on: self,
                    message: Strings.Profile.logoutConfirm,
                    confirmAction: { [weak self] in
                        self?.reactor?.action.onNext(.logoutButtonTapped)
                    }
                )
            })
            .disposed(by: self.disposeBag)

        self.deleteAccountButton.rx.tap
            .map { Reactor.Action.deleteAccountTapped }
            .bind(to: reactor.action)
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

        reactor.state.map(\.isLoggedIn)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoggedIn in
                self?.loginButton.isHidden = isLoggedIn
                self?.nicknameLabel.isHidden = !isLoggedIn
                self?.providerLabel.isHidden = !isLoggedIn
                self?.logoutButton.isHidden = !isLoggedIn
                self?.deleteAccountButton.isHidden = !isLoggedIn
            })
            .disposed(by: self.disposeBag)

        reactor.state.map(\.user)
            .distinctUntilChanged { $0?.id == $1?.id }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.nicknameLabel.text = user?.nickname ?? "사용자"
                self?.providerLabel.text = user?.provider.rawValue
            })
            .disposed(by: self.disposeBag)

        reactor.pulse(\.$error)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                ErrorDialog.show(
                    on: self,
                    error: error,
                    loginAction: { [weak self] in
                        self?.reactor?.action.onNext(.loginRequired)
                    }
                )
            })
            .disposed(by: self.disposeBag)
    }
}

extension ProfileViewController {

    // MARK: - Layout

    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            self.nicknameLabel, self.providerLabel, self.loginButton, self.logoutButton, self.deleteAccountButton
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
