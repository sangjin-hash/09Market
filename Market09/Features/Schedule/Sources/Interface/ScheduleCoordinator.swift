//
//  ScheduleCoordinator.swift
//  Schedule
//

import AppCore

public protocol ScheduleCoordinator: Coordinator {
    var delegate: ScheduleCoordinatorDelegate? { get set }
}
