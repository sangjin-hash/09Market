//
//  HomeCoordinatorImpl.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Domain
import Home
import Shared_DI
import Shared_ReactiveX

final class HomeCoordinatorImpl: HomeCoordinator {

    // MARK: - Coordinator Protocol

    public var childCoordinators: [Coordinator] = []
    public let navigationController: UINavigationController


    // MARK: - Delegate

    public weak var delegate: HomeCoordinatorDelegate?


    // MARK: - Properties

    private let homeViewController: HomeViewController
    private let resolver: Resolver
    private let disposeBag = DisposeBag()


    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        homeViewController: HomeViewController,
        resolver: Resolver
    ) {
        self.navigationController = navigationController
        self.homeViewController = homeViewController
        self.resolver = resolver
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

    private func showTop10() {
        let coordinator = self.resolver.resolve(
            HomeTop10Coordinator.self,
            argument: self.navigationController
        )!
        self.addChild(coordinator)
        coordinator.start()
    }


    // MARK: - CreatePost

    private func showCreatePost() {
        let coordinator = self.resolver.resolve(
            HomeCreatePostCoordinator.self,
            argument: self.navigationController
        )!
        coordinator.delegate = self
        self.addChild(coordinator)
        coordinator.start()
    }
}


// MARK: - HomeCreatePostCoordinatorDelegate

extension HomeCoordinatorImpl: HomeCreatePostCoordinatorDelegate {
    func createPostDidComplete(post: Post) {}

    func createPostCoordinatorDidFinish() {
        guard let coordinator = self.childCoordinators.first(where: { $0 is HomeCreatePostCoordinator }) else { return }
        self.removeChild(coordinator)
    }
}
