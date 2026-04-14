//
//  HomeViewController.swift
//  HomeImpl
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

import Kingfisher

final class HomeViewController: UIViewController, FactoryModule {

    // MARK: - Init

    struct Dependency {
        let reactor: HomeReactor
    }

    var disposeBag = DisposeBag()

    required init(dependency: Dependency, payload: Void) {
        super.init(nibName: nil, bundle: nil)
        defer { self.reactor = dependency.reactor }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - CellType

    static let categoryCell = ReusableCell<HomeCategoryChipCell>()
    static let bannerCell = ReusableCell<HomeTop10BannerCell>()
    static let postCell = ReusableCell<HomePostCardCell>()
    static let skeletonCell = ReusableCell<HomePostSkeletonCell>()


    // MARK: - UI

    private let searchBar = UISearchBar().then {
        $0.placeholder = Strings.Home.searchPlaceholder
        $0.searchBarStyle = .minimal
    }

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: HomeCollectionViewLayout.create()
        )
        cv.backgroundColor = .systemBackground
        cv.register(Self.categoryCell)
        cv.register(Self.bannerCell)
        cv.register(Self.postCell)
        cv.register(Self.skeletonCell)
        return cv
    }()

    private let dimOverlay = UIControl().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        $0.isHidden = true
        $0.alpha = 0
    }

    private let fabButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = Colors.primary
        $0.layer.cornerRadius = 28
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 8
    }

    private let fabMenuContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.12
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 8
        $0.clipsToBounds = false
        $0.isHidden = true
        $0.alpha = 0
    }

    private let createPostMenuButton = UIButton(type: .custom).then {
        $0.setTitle(Strings.CreatePost.title, for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }

    private let registerInfluencerMenuButton = UIButton(type: .custom).then {
        $0.setTitle(Strings.RegisterInfluencer.title, for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }

    private let fabMenuDivider = UIView().then {
        $0.backgroundColor = .systemGray5
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.reactor?.action.onNext(.refreshFABVisibility)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.searchBar.pin
            .top(self.view.pin.safeArea.top + 4)
            .horizontally(8)
            .sizeToFit(.width)

        self.collectionView.pin
            .below(of: self.searchBar)
            .horizontally()
            .bottom()

        self.dimOverlay.pin.all()

        self.fabButton.pin
            .bottom(self.view.pin.safeArea.bottom + 24)
            .right(24)
            .size(56)

        let postSize = self.createPostMenuButton.intrinsicContentSize
        let influencerSize = self.registerInfluencerMenuButton.intrinsicContentSize
        let menuWidth = max(postSize.width, influencerSize.width)
        let rowHeight = max(postSize.height, influencerSize.height)

        self.createPostMenuButton.pin
            .top(0).left(0)
            .size(CGSize(width: menuWidth, height: rowHeight))
        self.fabMenuDivider.pin
            .below(of: self.createPostMenuButton)
            .left(0).right(0).height(1)
        self.registerInfluencerMenuButton.pin
            .below(of: self.fabMenuDivider)
            .size(CGSize(width: menuWidth, height: rowHeight))

        self.fabMenuContainer.pin
            .size(CGSize(width: menuWidth, height: rowHeight * 2 + 1))
            .bottom(self.view.pin.safeArea.bottom + 24 + 56 + 8)
            .right(24)

        self.fabMenuContainer.layer.borderColor = UIColor.systemGray4.cgColor
    }

    private func setupLayout() {
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.dimOverlay)
        self.view.addSubview(self.fabMenuContainer)
        self.view.addSubview(self.fabButton)

        self.fabMenuContainer.addSubview(self.createPostMenuButton)
        self.fabMenuContainer.addSubview(self.fabMenuDivider)
        self.fabMenuContainer.addSubview(self.registerInfluencerMenuButton)
    }
}

extension HomeViewController: View {
    func bind(reactor: HomeReactor) {

        // MARK: - DataSource

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<HomeSectionModel>(
            animationConfiguration: .init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none),
            configureCell: { [weak reactor] _, collectionView, indexPath, item in
                switch item {
                case .category(let category, let isSelected):
                    let cell = collectionView.dequeue(HomeViewController.categoryCell, for: indexPath)
                    cell.configure(
                        dependency: .init(),
                        payload: .init(
                            category: category,
                            isSelected: isSelected
                        )
                    )
                    return cell

                case .top10Banner:
                    let cell = collectionView.dequeue(HomeViewController.bannerCell, for: indexPath)
                    cell.configure(dependency: .init(), payload: .init())
                    return cell

                case .post(let post):
                    let cell = collectionView.dequeue(HomeViewController.postCell, for: indexPath)
                    cell.configure(dependency: .init(), payload: .init(post: post))

                    cell.likeButton.rx.tap
                        .map { HomeReactor.Action.toggleLike(post.id, post.isLiked) }
                        .bind(to: reactor!.action)
                        .disposed(by: cell.disposeBag)

                    return cell

                case .skeleton(_):
                    let cell = collectionView.dequeue(HomeViewController.skeletonCell, for: indexPath)
                    return cell
                }
            }
        )


        // MARK: - Action

        Observable.just(Reactor.Action.fetchPostList)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        let searchText = self.searchBar.rx.text.orEmpty.asObservable()

        let clearText = self.searchBar.rx.delegate
            .sentMessage(#selector(UISearchBarDelegate.searchBar(_:textDidChange:)))
            .map { $0[1] as? String ?? "" }

        Observable.merge(searchText, clearText)
            .skip(1)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { Reactor.Action.searchKeyword($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.collectionView.rx.itemSelected
            .filter { $0.section == 0 }
            .withLatestFrom(reactor.state.map(\.sections)) { indexPath, sections in
                guard case .category(let category, _) = sections[0].items[indexPath.item] else {
                    return nil as GroupBuyingCategory?
                }
                return category
            }
            .bind(to: reactor.action.mapObserver { .selectCategory($0) })
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.itemSelected
            .filter { $0.section == 1 }
            .map { _ in Reactor.Action.tapTop10Banner }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.collectionView.rx.willDisplayCell
            .filter { $0.at.section == 2 }
            .withLatestFrom(reactor.state) { event, state in
                return event.at.item >= state.posts.count - 3
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.dimOverlay.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.dismissFABMenu }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.fabButton.rx.tap
            .map { Reactor.Action.tapFAB }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.createPostMenuButton.rx.tap
            .map { Reactor.Action.tapCreatePost }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.registerInfluencerMenuButton.rx.tap
            .map { Reactor.Action.tapRegisterInfluencer }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        // MARK: - State

        reactor.state.map(\.sections)
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isFABVisible)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] visible in
                guard let self else { return }
                self.fabButton.isHidden = !visible
            })
            .disposed(by: self.disposeBag)

        reactor.state.map(\.isFABMenuOpen)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isOpen in
                guard let self else { return }
                if isOpen {
                    self.fabMenuContainer.isHidden = false
                    self.dimOverlay.isHidden = false
                }
                UIView.animate(withDuration: 0.2, animations: {
                    self.fabMenuContainer.alpha = isOpen ? 1 : 0
                    self.dimOverlay.alpha = isOpen ? 1 : 0
                }, completion: { _ in
                    if !isOpen {
                        self.fabMenuContainer.isHidden = true
                        self.dimOverlay.isHidden = true
                    }
                })
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

        reactor.pulse(\.$needsLogin)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                ConfirmDialog.show(
                    on: self,
                    message: Strings.Home.loginRequired,
                    confirmAction: { reactor.action.onNext(.confirmLogin) }
                )
            })
            .disposed(by: self.disposeBag)
    }
}
