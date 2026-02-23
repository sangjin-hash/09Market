//
//  HomeCoordinator.swift
//  App
//
//  Created by Sangjin Lee
//

import UIKit

final class HomeCoordinator: Coordinator {

    // MARK: - Coordinator Protocol

    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController

    // MARK: - Properties

    private let diContainer: AppDIContainer
    var onFinished: (() -> Void)?

    // MARK: - Init

    init(navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    // MARK: - Start

    // @Injected var viewModel: HomeViewModel

    func start() {
        // TODO: DIContainer에서 의존성 주입

        // -- UIKit 방식 --
        // let vc = HomeViewController(viewModel: viewModel)
        // vc.onItemTapped = { [weak self] item in
        //     self?.navigate(to: .detail(itemId: item.id))
        // }
        // navigationController.setViewControllers([vc], animated: false)

        // -- SwiftUI 방식 --
        // let homeView = HomeView(
        //     viewModel: viewModel,
        //     onItemTapped: { [weak self] item in
        //         self?.navigate(to: .detail(itemId: item.id))
        //     }
        // )
        // let hostingVC = UIHostingController(rootView: homeView)
        // navigationController.setViewControllers([hostingVC], animated: false)
    }
}

// MARK: - Route

extension HomeCoordinator {

    enum Route {
        case detail(itemId: String)
        case filter
        case safari(URL)
    }

    func navigate(to route: Route) {
        switch route {
        case .detail(let itemId):
            showDetail(itemId: itemId)
        case .filter:
            showFilter()
        case .safari(let url):
            openSafari(url: url)
        }
    }
}

// MARK: - Flow

private extension HomeCoordinator {

    func showDetail(itemId: String) {
        // TODO: DetailCoordinator 연결
    }

    func showFilter() {
        // TODO: Filter 화면 present
    }

    func openSafari(url: URL) {
        // TODO: SFSafariViewController present
    }
}
