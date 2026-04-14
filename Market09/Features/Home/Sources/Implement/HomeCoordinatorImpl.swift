//
//  HomeCoordinatorImpl.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Home
import Shared_DI
import Shared_ReactiveX

final class HomeCoordinatorImpl: HomeCoordinator {

    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController


    // MARK: - Delegate

    public weak var delegate: HomeCoordinatorDelegate?
    
    
    // MARK: - Reactor
    
    private let homeViewController: HomeViewController
    private let homeTop10ViewController: HomeTop10ViewController
    private let homeCreatePostController: HomeCreatePostViewController
    private let disposeBag = DisposeBag()


    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        homeViewController: HomeViewController,
        homeTop10ViewController: HomeTop10ViewController,
        homeCreatePostController: HomeCreatePostViewController
    ) {
        self.navigationController = navigationController
        self.homeViewController = homeViewController
        self.homeTop10ViewController = homeTop10ViewController
        self.homeCreatePostController = homeCreatePostController
    }


    // MARK: - Start

    public func start() {
        guard let reactor = self.homeViewController.reactor else { return }

        reactor.pulse(\.$loginConfirmed)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.delegate?.homeDidRequestLogin()
            })
            .disposed(by: self.disposeBag)

        reactor.pulse(\.$showTop10)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.showTop10()
            })
            .disposed(by: self.disposeBag)

        reactor.pulse(\.$openCreatePost)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.showCreatePost()
            })
            .disposed(by: self.disposeBag)

        self.navigationController.pushViewController(self.homeViewController, animated: true)
    }
    
    
    // MARK: - Top10
    
    func showTop10() {
        self.navigationController.pushViewController(self.homeTop10ViewController, animated: true)
    }
    
    
    // MARK: - CreatePost
    
    func showCreatePost() {
        self.navigationController.present(self.homeCreatePostController, animated: true)
    }
}
