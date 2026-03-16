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


    // MARK: - UI

    private let searchBar = UISearchBar().then {
        $0.placeholder = "브랜드, 상품 검색"
        $0.searchBarStyle = .minimal
    }

    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<HomeSectionModel>(
        animationConfiguration: .init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none),
        configureCell: { _, collectionView, indexPath, item in
            switch item {
            case .category(let category, let isSelected):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "CategoryCell", for: indexPath
                ) as? HomeCategoryChipCell else { return UICollectionViewCell() }

                cell.configure(
                    dependency: .init(),
                    payload: .init(
                        category: category,
                        isSelected: isSelected
                    )
                )

                return cell

            case .top10Banner:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "BannerCell", for: indexPath
                ) as? HomeTop10BannerCell else { return UICollectionViewCell() }

                cell.configure(dependency: .init(), payload: .init())
                return cell

            case .post(let post):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PostCell", for: indexPath
                ) as? HomePostCardCell else { return UICollectionViewCell() }

                cell.configure(dependency: .init(), payload: .init(post: post))
                return cell
                
            case .skeleton(_):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "SkeletonCell", for: indexPath
                ) as? HomePostSkeletonCell else { return UICollectionViewCell() }
                
                return cell
            }
        }
    )

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: HomeCollectionViewLayout.create()
        )
        cv.backgroundColor = .systemBackground
        cv.register(HomeCategoryChipCell.self, forCellWithReuseIdentifier: "CategoryCell")
        cv.register(HomeTop10BannerCell.self, forCellWithReuseIdentifier: "BannerCell")
        cv.register(HomePostCardCell.self, forCellWithReuseIdentifier: "PostCell")
        cv.register(HomePostSkeletonCell.self, forCellWithReuseIdentifier: "SkeletonCell")
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
            .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
}
