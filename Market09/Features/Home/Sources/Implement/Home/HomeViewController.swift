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


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupLayout() {
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.collectionView)

        self.searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(4)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
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

        // MARK: - State

        reactor.state.map(\.sections)
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
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
