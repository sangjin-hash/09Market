//
//  ScheduleCoordinator.swift
//  Schedule
//
//  Created by 23ji
//

import AppCore

public protocol ScheduleCoordinator: Coordinator {
    var delegate: ScheduleCoordinatorDelegate? { get set }
}
