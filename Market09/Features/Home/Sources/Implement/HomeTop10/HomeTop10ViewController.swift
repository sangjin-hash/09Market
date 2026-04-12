//
//  HomeTop10ViewController.swift
//  Home
//
//  Created by Sangjin Lee
//

import UIKit

import AppCore
import DesignSystem
import Domain
import Shared_DI
import Shared_ReactiveX
import Shared_UI

final class HomeTop10ViewController: UIViewController, FactoryModule {

    // MARK: - Init

    struct Dependency {
        let reactor: HomeTop10Reactor
    }

    var disposeBag = DisposeBag()

    required init(dependency: Dependency, payload: Void) {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        defer { self.reactor = dependency.reactor }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UI

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = Strings.Home.top10Banner
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.pin.all(self.view.pin.safeArea)
        self.contentView.pin.top().horizontally()

        var yOffset: CGFloat = 20
        for view in self.contentView.subviews {
            view.frame.origin = CGPoint(x: 0, y: yOffset)
            view.frame.size.width = self.contentView.bounds.width
            view.setNeedsLayout()
            view.layoutIfNeeded()
            yOffset = view.frame.maxY + 16
        }

        self.contentView.frame.size.height = yOffset + 20
        self.scrollView.contentSize = self.contentView.frame.size
    }

    private func setupLayout() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
    }
}


// MARK: - Bind

extension HomeTop10ViewController: View {
    func bind(reactor: HomeTop10Reactor) {

        // MARK: - Action

        Observable.just(Reactor.Action.fetchTop10Posts)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        // MARK: - State

        reactor.state.map(\.isLoading)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self else { return }
                self.contentView.subviews.forEach { $0.removeFromSuperview() }
                if isLoading {
                    (0..<10).forEach { _ in
                        self.contentView.addSubview(PostCardSkeletonView())
                    }
                }
                self.view.setNeedsLayout()
            })
            .disposed(by: self.disposeBag)

        reactor.state.map(\.posts)
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                guard let self else { return }
                self.contentView.subviews.forEach { $0.removeFromSuperview() }
                posts.enumerated().forEach { index, post in
                    let view = HomeTop10RankedView()
                    view.configure(payload: .init(post: post, rank: index + 1))
                    self.contentView.addSubview(view)
                }
                self.view.setNeedsLayout()
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
