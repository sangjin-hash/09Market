//
//  HomeReactor.swift
//  HomeImpl
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore
import Domain
import Shared_DI
import Shared_ReactiveX

final class HomeReactor: Reactor, FactoryModule {

    struct Dependency {
        let fetchPostsListUseCase: FetchPostsListUseCase
        let likePostUseCase: LikePostUseCase
        let cancelLikePostUseCase: CancelLikePostUseCase
        let userStore: UserStore
    }

    enum Action {
        case fetchPostList
        case loadNextPage
        case selectCategory(GroupBuyingCategory?)
        case searchKeyword(String)
        case toggleLike(String, Bool)
        case confirmLogin
        case tapTop10Banner
    }

    enum Mutation {
        case setLoading(Bool)
        case setFetchCompleted(Page<Post>)
        case setSelectedCategory(GroupBuyingCategory?)
        case setKeyword(String)
        case setError(AppError?)
        case setLikeStatus(String, Bool)
        case setNeedsLogin
        case setLoginConfirmed
        case setShowTop10
    }

    struct State {
        var sections: [HomeSectionModel] = []
        var posts: [Post] = []
        var selectedCategory: GroupBuyingCategory?
        var searchKeyword: String?
        var currentPage: Int = 1
        var hasNextPage: Bool = true
        var isLoading: Bool = false
        @Pulse var error: AppError?
        @Pulse var needsLogin: Bool = false
        @Pulse var loginConfirmed: Bool = false
        @Pulse var showTop10: Bool = false
    }

    let initialState: State = State()
    private let dependency: Dependency
    private let pageSize = 30
    private let searchKeyword = BehaviorSubject<String>(value: "")
    private var likingPostIds: Set<String> = []

    required init(dependency: Dependency, payload: Void) {
        self.dependency = dependency
    }
}


// MARK: - Mutate & Reduce

extension HomeReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchPostList:
            return fetchPosts(page: self.currentState.currentPage)

        case .loadNextPage:
            guard !self.currentState.isLoading else {
                return .empty()
            }
            
            guard self.currentState.hasNextPage else {
                return .empty()
            }

            return fetchPosts(page: self.currentState.currentPage + 1)
            
        case .selectCategory(let category):
            guard category != self.currentState.selectedCategory else {
                return .empty()
            }
            
            return .concat([
                .just(.setSelectedCategory(category)),
                fetchPosts(page: 1)
            ])
            
        case .searchKeyword(let keyword):
            self.searchKeyword.onNext(keyword)
            return .just(.setKeyword(keyword))
            
        // isLiked -> 좋아요 버튼을 누른 시점의 좋아요 상태(좋아요 요청 호출 전)
        case .toggleLike(let postId, let isLiked):
            guard self.dependency.userStore.isLoggedIn else {
                return .just(.setNeedsLogin)
            }
            
            guard !self.likingPostIds.contains(postId) else {
                return .empty()
            }
            
            self.likingPostIds.insert(postId)
            
            return .concat([
                // UI 즉시 변경 + 좋아요 요청 호출 후 예상 결과 => !isLiked(toggle)
                .just(.setLikeStatus(postId, !isLiked)),
                Observable.task {
                    if isLiked {
                        try await self.dependency.cancelLikePostUseCase.execute(postId: postId)
                    } else {
                        try await self.dependency.likePostUseCase.execute(postId: postId)
                    }
                }
                .flatMap { Observable<Mutation>.empty() }
                .catch { .concat([
                    .just(.setError($0 as? AppError)),
                    .just(.setLikeStatus(postId, isLiked))
                ])}
                .do(onDispose: { self.likingPostIds.remove(postId) })
            ])
            
        case .confirmLogin:
            return .just(.setLoginConfirmed)
            
        case .tapTop10Banner:
            return .just(.setShowTop10)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            newState.sections = self.buildSections(
                selectedCategory: newState.selectedCategory,
                posts: newState.posts,
                isLoading: newState.isLoading
            )

        case .setFetchCompleted(let page):
            if page.page == 1 {
                newState.posts = page.data
            } else {
                newState.posts += page.data
            }
            
            newState.currentPage = page.page
            newState.hasNextPage = newState.posts.count < page.total
            newState.sections = self.buildSections(
                selectedCategory: newState.selectedCategory,
                posts: newState.posts,
                isLoading: newState.isLoading
            )
        
        case .setSelectedCategory(let category):
            newState.selectedCategory = category
            newState.posts = []
            newState.sections = self.buildSections(
                selectedCategory: newState.selectedCategory,
                posts: newState.posts,
                isLoading: newState.isLoading
            )
            
        case .setKeyword(let keyword):
            newState.searchKeyword = keyword
            
        case .setLikeStatus(let postId, let isLiked):
            newState.posts = state.posts.map { post in
                guard post.id == postId else { return post }
                var updated = post
                updated.isLiked = isLiked
                updated.likesCount += isLiked ? 1 : -1
                return updated
            }
            
            newState.sections = self.buildSections(
                selectedCategory: newState.selectedCategory,
                posts: newState.posts,
                isLoading: newState.isLoading
            )
            
        case .setNeedsLogin:
            newState.needsLogin = true
            
        case .setLoginConfirmed:
            newState.loginConfirmed = true
            
        case .setShowTop10:
            newState.showTop10 = true

        case .setError(let error):
            newState.error = error
        }
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let searchMutation = self.searchKeyword
            .skip(1)
            .flatMapLatest { keyword in
                self.fetchPosts(page: 1, keyword: keyword)
            }

        return Observable.merge(mutation, searchMutation)
    }

    private func fetchPosts(page: Int, keyword: String? = nil) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            Observable.task {
                try await self.dependency.fetchPostsListUseCase.execute(
                    page: page,
                    limit: self.pageSize,
                    search: keyword ?? self.currentState.searchKeyword,
                    category: self.currentState.selectedCategory,
                    dateFrom: nil,
                    dateTo: nil
                )
            }
            .map { Mutation.setFetchCompleted($0) }
            .catch { .just(.setError($0 as? AppError)) },
            .just(.setLoading(false))
        ])
    }
}


// MARK: - Build Sections

extension HomeReactor {
    private func buildSections(
        selectedCategory: GroupBuyingCategory?,
        posts: [Post],
        isLoading: Bool
    ) -> [HomeSectionModel] {
        var categories: [HomeSectionItem] = [
            .category(nil, selectedCategory == nil),
        ]
        categories += GroupBuyingCategory.allCases.map { category in
            .category(category, category == selectedCategory)
        }

        let postItems: [HomeSectionItem]
        if isLoading && posts.isEmpty {
            postItems = (0..<5).map { .skeleton($0) }
        } else {
            postItems = posts.map { .post($0) }
        }

        return [
            .category(items: categories),
            .top10Banner(items: [.top10Banner]),
            .postList(items: postItems),
        ]
    }
}
