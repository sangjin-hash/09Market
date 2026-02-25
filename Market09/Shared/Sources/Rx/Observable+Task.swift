//
//  Observable+Task.swift
//  Shared
//
//  Created by Sangjin Lee
//

import RxSwift

extension Observable {

    /// async throws 함수를 Observable로 변환
    /// - Parameter work: async throws 클로저
    /// - Returns: 성공 시 onNext, 실패 시 onError를 방출하는 Observable
    static func task(_ work: @escaping () async throws -> Element) -> Observable<Element> {
        Observable.create { observer in
            let task = Task {
                do {
                    let result = try await work()
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }
    }
}
