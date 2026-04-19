//
//  HomeCreatePostCoordinatorImpl.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import Domain
import Shared_ReactiveX


// MARK: - Protocol

protocol HomeCreatePostCoordinator: Coordinator {
    var delegate: HomeCreatePostCoordinatorDelegate? { get set }
}


// MARK: - Delegate

protocol HomeCreatePostCoordinatorDelegate: AnyObject {
    func createPostDidComplete(post: Post)
    func createPostCoordinatorDidFinish()
}


// MARK: - Coordinator

final class HomeCreatePostCoordinatorImpl: NSObject, HomeCreatePostCoordinator {

    // MARK: - Coordinator Protocol

    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController


    // MARK: - Delegate

    weak var delegate: HomeCreatePostCoordinatorDelegate?


    // MARK: - Properties

    private let viewController: HomeCreatePostViewController
    private let disposeBag = DisposeBag()


    // MARK: - Init

    init(
        navigationController: UINavigationController,
        viewController: HomeCreatePostViewController
    ) {
        self.navigationController = navigationController
        self.viewController = viewController
    }


    // MARK: - Start

    func start() {
        guard let reactor = self.viewController.reactor else { return }

        reactor.pulse(\.$submitSuccess)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] post in
                guard let self else { return }
                self.viewController.dismiss(animated: true)
                self.delegate?.createPostDidComplete(post: post)
                self.delegate?.createPostCoordinatorDidFinish()
            })
            .disposed(by: self.disposeBag)

        self.navigationController.present(self.viewController, animated: true) { [weak self] in
            self?.viewController.presentationController?.delegate = self
        }
    }
}


// MARK: - UIAdaptivePresentationControllerDelegate

extension HomeCreatePostCoordinatorImpl: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.delegate?.createPostCoordinatorDidFinish()
    }
}
