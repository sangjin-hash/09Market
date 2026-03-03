//
//  ProfileViewController.swift
//  ProfileImpl
//
//  Created by Sangjin Lee
//

import Core
import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class ProfileViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
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
        view.backgroundColor = .systemBackground
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.viewDidAppear)
    }
}

extension ProfileViewController: View {
    
    // MARK: - Bind

    func bind(reactor: ProfileReactor) {
        
        // MARK: - Action
        
        loginButton.rx.tap
            .map { Reactor.Action.loginButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        logoutButton.rx.tap
            .map { Reactor.Action.logoutButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        deleteAccountButton.rx.tap
            .map { Reactor.Action.deleteAccountTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        
        // MARK: - State
        
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
            .disposed(by: disposeBag)

        reactor.state.map(\.user)
            .distinctUntilChanged { $0?.id == $1?.id }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.nicknameLabel.text = user?.nickname ?? "사용자"
                self?.providerLabel.text = user?.provider
            })
            .disposed(by: disposeBag)

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
            .disposed(by: disposeBag)
    }
}

extension ProfileViewController {
    
    // MARK: - Layout

    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            nicknameLabel, providerLabel, loginButton, logoutButton, deleteAccountButton
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
