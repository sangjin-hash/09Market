//
//  ScheduleViewController.swift
//  ScheduleImpl
//
//  Created by 23ji
//

import UIKit

import Shared_DI
import Shared_ReactiveX

final class ScheduleViewController: UIViewController, FactoryModule, View {

    // MARK: - Module

    struct Dependency {
    }

    struct Payload {
        let reactor: ScheduleViewReactor
    }


    // MARK: - Properties

    let dependency: Dependency
    let payload: Payload
    var disposeBag: DisposeBag = DisposeBag()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // MARK: - Init

    init(dependency: Dependency, payload: Payload) {
        defer { self.reactor = payload.reactor }
        self.dependency = dependency
        self.payload = payload
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Bind

    func bind(reactor: ScheduleViewReactor) {
    }
}
