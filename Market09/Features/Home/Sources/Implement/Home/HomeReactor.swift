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
        // 공구 게시글 조회(필터링 포함) 및 페이지네이션
        case fetchPostList
        case loadNextPage
        case selectCategory(GroupBuyingCategory?)
        case searchKeyword(String)
        
        // 게시글 좋아요
        case toggleLike(String, Bool)
        
        // 세션 만료 or 익명 로그인 상태에서 로그인이 필요한 서비스 이용할 때 -> 로그인 유도
        case confirmLogin
        
        // Top10 공구
        case tapTop10Banner
        
        // FAB
        case refreshFABVisibility
        case tapFAB
        case dismissFABMenu
        case tapCreatePost
        case tapRegisterInfluencer
        case postRegistrationCallback(Post)
        
    }

    enum Mutation {
        // 화면 기본 상태(Loading, Error)
        case setLoading(Bool)
        case setError(AppError?)
        
        // 공구 게시글 조회
        case setFetchCompleted(Page<Post>)
        case setSelectedCategory(GroupBuyingCategory?)
        case setKeyword(String)
        
        // 게시글 좋아요
        case setLikeStatus(String, Bool)
        
        // 로그인
        case setNeedsLogin // '로그인 필요' 다이얼로그 표시
        case setLoginConfirmed // 로그인 화면으로 이동
        
        // Top10 공구
        case setShowTop10
        
        // FAB
        case setFABVisible(Bool)
        case setFABMenuOpen(Bool)
        case setCreatePostOpen
        case setRegisterInfluencerOpen
        case setPostRegistrationCallback(Post)
    }

    struct State {
        // 화면 기본 상태(Loading, Error)
        var isLoading: Bool = false
        @Pulse var error: AppError?
        
        // 공구 게시글 조회
        var sections: [HomeSectionModel] = []
        var posts: [Post] = []
        var selectedCategory: GroupBuyingCategory?
        var searchKeyword: String?
        var currentPage: Int = 1
        var hasNextPage: Bool = true
        
        // 로그인
        @Pulse var needsLogin: Bool = false
        @Pulse var loginConfirmed: Bool = false
        
        // Top10 공구
        @Pulse var showTop10: Bool = false
        
        // FAB
        var isFABVisible: Bool = false
        var isFABMenuOpen: Bool = false
        @Pulse var openCreatePost: Bool = false
        @Pulse var openRegisterInfluencer: Bool = false
    }

    let initialState: State = State()
    private let dependency: Dependency
    private let pageSize = 30
    private let searchKeywordSubject = BehaviorSubject<String>(value: "")
    private var likingPostIds: Set<String> = []

    required init(dependency: Dependency, payload: Void) {
        self.dependency = dependency
    }
}


// MARK: - Mutate & Reduce

extension HomeReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        // 공구 게시글 조회
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
            self.searchKeywordSubject.onNext(keyword)
            return .just(.setKeyword(keyword))
            
            
        // 게시글 좋아요
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
            
            
        // 로그인
        case .confirmLogin:
            return .just(.setLoginConfirmed)
            
        case .tapTop10Banner:
            return .just(.setShowTop10)
            
            
        // FAB
        case .refreshFABVisibility:
            return .just(.setFABVisible(self.dependency.userStore.isLoggedIn))
            
        case .tapFAB:
            return .just(.setFABMenuOpen(true))
            
        case .dismissFABMenu:
            return .just(.setFABMenuOpen(false))
            
        case .tapCreatePost:
            return .concat([
                .just(.setFABMenuOpen(false)),
                .just(.setCreatePostOpen)
            ])
            
        case .tapRegisterInfluencer:
            return .concat([
                .just(.setFABMenuOpen(false)),
                .just(.setRegisterInfluencerOpen)
            ])
            
        case .postRegistrationCallback(let post):
            return .just(.setPostRegistrationCallback(post))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        // 화면 기본 상태(Loading, Error)
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            newState.sections = self.buildSections(
                selectedCategory: newState.selectedCategory,
                posts: newState.posts,
                isLoading: newState.isLoading
            )
            
        case .setError(let error):
            newState.error = error
            
        
        // 공구 게시글 조회
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
            
        
        // 게시글 좋아요
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
        
        
        // 로그인
        case .setNeedsLogin:
            newState.needsLogin = true
            
        case .setLoginConfirmed:
            newState.loginConfirmed = true
            
        
        // Top10 공구
        case .setShowTop10:
            newState.showTop10 = true
            
        
        // FAB
        case .setFABVisible(let isFABVisible):
            newState.isFABVisible = isFABVisible
            
        case .setFABMenuOpen(let isFABMenuOpen):
            newState.isFABMenuOpen = isFABMenuOpen
            
        case .setCreatePostOpen:
            newState.openCreatePost = true
            
        case .setRegisterInfluencerOpen:
            newState.openRegisterInfluencer = true
            
        case .setPostRegistrationCallback(let post):
            newState.posts.insert(post, at: 0)
            newState.sections = self.buildSections(
                selectedCategory: newState.selectedCategory,
                posts: newState.posts,
                isLoading: newState.isLoading
            )
        }
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let searchMutation = self.searchKeywordSubject
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
