//
//  HomeCreatePostReactor.swift
//  Home
//
//  Created by Sangjin Lee
//

import Foundation

import AppCore
import Domain
import Shared_DI
import Shared_ReactiveX

final class HomeCreatePostReactor: Reactor, FactoryModule {
    
    struct Dependency {
        let searchInfluencersUseCase: SearchInfluencersUseCase
        let uploadImageUseCase: UploadImageUseCase
        let createPostUseCase: CreatePostUseCase
    }
    
    enum Action {
        // 인플루언서 검색 및 설정
        case searchInfluencerKeyword(String)
        case selectInfluencer(Influencer)
        
        // 이미지 업로드
        case tapImagePicker
        case didSelectImage(Data, MimeType)
        
        // 필수 입력들(품목, 가격, 카테고리, 날짜)
        case inputProductName(String)
        case inputPrice(Int)
        case selectCategory(GroupBuyingCategory)
        case selectStartDate(Date)
        case selectEndDate(Date)
        
        // 화면 닫힘 & 생성 요청
        case tapClose
        case tapSubmit
    }
    
    enum Mutation {
        // 화면 기본 상태(Loading, Error)
        case setLoading(Bool)
        case setError(AppError?)
        
        // 인플루언서 검색 및 설정
        case setInfluencerKeyword(String)
        case setInfluencerResult([Influencer])
        case setInfluencer(Influencer?)
        
        // 이미지 업로드
        case setOpenImagePicker
        case setImageUploadURL(String?)
        case setImageUploading(Bool)
        
        // 필수 입력들
        case setProductName(String)
        case setPrice(Int)
        case setCategory(GroupBuyingCategory?)
        case setStartDate(Date?)
        case setEndDate(Date?)
        
        // 화면 닫힘 & 생성 요청
        case setDismiss
        case setSubmitSuccess(Post)
    }
    
    struct State {
        // 화면 기본 상태
        var isLoading: Bool = false
        @Pulse var error: AppError?
        @Pulse var dismiss: Bool = false
        @Pulse var submitSuccess: Post?
        
        // 인플루언서 검색 및 설정
        var influencerKeyword: String = ""
        var influencerResult: [Influencer] = []
        var selectedInfluencer: Influencer?
        
        // 이미지 업로드
        var imageUploadURL: String?
        var isImageUploading: Bool = false
        @Pulse var openImagePicker: Bool = false
        
        // 필수 입력들
        var productName: String = ""
        var price: Int = 0
        var selectedCategory: GroupBuyingCategory?
        var startDate: Date?
        var endDate: Date?
        var isSubmitEnabled: Bool = false
    }
    
    let initialState: State = State()
    private let dependency: Dependency
    private let searchKeywordSubject = BehaviorSubject<String>(value: "")
    
    required init(dependency: Dependency, payload: Void) {
        self.dependency = dependency
    }
}


// MARK: - Mutate & Reduce

extension HomeCreatePostReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {

        // 인플루언서 검색
        case .searchInfluencerKeyword(let keyword):
            let stripped = keyword.hasPrefix("@") ? String(keyword.dropFirst()) : keyword
            self.searchKeywordSubject.onNext(stripped)
            return .concat([
                .just(.setInfluencer(nil)),
                .just(.setInfluencerKeyword(stripped)),
                stripped.isEmpty ? .just(.setInfluencerResult([])) : .empty()
            ])

        case .selectInfluencer(let influencer):
            return .concat([
                .just(.setInfluencer(influencer)),
                .just(.setInfluencerKeyword("@\(influencer.username)")),
                .just(.setInfluencerResult([]))
            ])


        // 이미지 업로드
        case .tapImagePicker:
            return .just(.setOpenImagePicker)

        case .didSelectImage(let data, let mimeType):
            let tenMB = 10 * 1024 * 1024
            guard data.count <= tenMB else {
                return .just(.setError(AppError.client(.imageSizeLimitExceeded)))
            }
            return .concat([
                .just(.setImageUploading(true)),
                Observable.task {
                    try await self.dependency.uploadImageUseCase.execute(data, mimeType)
                }
                .map { Mutation.setImageUploadURL($0) }
                .catch { error in
                    let appError = (error as? AppError) ?? AppError.unknown(message: error.localizedDescription)
                    return Observable.concat([
                        .just(.setImageUploadURL(nil)),
                        .just(.setError(appError))
                    ])
                },
                .just(.setImageUploading(false))
            ])


        // 필수 입력
        case .inputProductName(let name):
            return .just(.setProductName(name))

        case .inputPrice(let price):
            return .just(.setPrice(price))

        case .selectCategory(let category):
            return .just(.setCategory(category))

        case .selectStartDate(let date):
            let shouldClearEndDate: Bool
            if let endDate = self.currentState.endDate {
                let minEndDate = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
                shouldClearEndDate = endDate < minEndDate
            } else {
                shouldClearEndDate = false
            }

            if shouldClearEndDate {
                return .concat([
                    .just(.setStartDate(date)),
                    .just(.setEndDate(nil))
                ])
            }
            return .just(.setStartDate(date))

        case .selectEndDate(let date):
            return .just(.setEndDate(date))


        // 등록 요청
        case .tapSubmit:
            guard !self.currentState.isLoading,
                  let influencer = self.currentState.selectedInfluencer,
                  let category = self.currentState.selectedCategory,
                  let startDate = self.currentState.startDate,
                  let endDate = self.currentState.endDate else {
                return .empty()
            }
            
            let post = Post(
                productName: self.currentState.productName,
                price: self.currentState.price,
                category: category,
                displayUrl: self.currentState.imageUploadURL,
                groupBuyingStart: startDate,
                groupBuyingEnd: endDate,
                influencer: influencer
            )

            return .concat([
                .just(.setLoading(true)),
                Observable.task {
                    try await self.dependency.createPostUseCase.execute(post)
                }
                .map { Mutation.setSubmitSuccess($0) }
                .catch { .just(.setError($0 as? AppError)) },
                .just(.setLoading(false))
            ])


        // 닫기
        case .tapClose:
            return .just(.setDismiss)
        }
    }

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let searchMutation = self.searchKeywordSubject
            .skip(1)
            .filter { !$0.isEmpty }
            .flatMapLatest { keyword -> Observable<Mutation> in
                Observable.task {
                    try await self.dependency.searchInfluencersUseCase.execute(keyword)
                }
                .map { Mutation.setInfluencerResult($0) }
                .catch { .just(.setError($0 as? AppError)) }
            }

        return Observable.merge(mutation, searchMutation)
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .setError(let error):
            newState.error = error

        case .setInfluencerKeyword(let keyword):
            newState.influencerKeyword = keyword

        case .setInfluencerResult(let result):
            newState.influencerResult = result

        case .setInfluencer(let influencer):
            newState.selectedInfluencer = influencer

        case .setOpenImagePicker:
            newState.openImagePicker = true

        case .setImageUploadURL(let url):
            newState.imageUploadURL = url

        case .setImageUploading(let isUploading):
            newState.isImageUploading = isUploading

        case .setProductName(let name):
            newState.productName = name

        case .setPrice(let price):
            newState.price = price

        case .setCategory(let category):
            newState.selectedCategory = category

        case .setStartDate(let date):
            newState.startDate = date

        case .setEndDate(let date):
            newState.endDate = date

        case .setSubmitSuccess(let post):
            newState.submitSuccess = post

        case .setDismiss:
            newState.dismiss = true
        }

        newState.isSubmitEnabled =
            newState.selectedInfluencer != nil &&
            !newState.productName.isEmpty &&
            newState.price > 0 &&
            newState.selectedCategory != nil &&
            newState.startDate != nil &&
            newState.endDate != nil &&
            !newState.isImageUploading &&
            !newState.isLoading

        return newState
    }
}
