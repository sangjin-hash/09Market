//
//  CalendarCoordinator.swift
//  Calendar
//
//  Created by 23ji
//

import AppCore

public protocol CalendarCoordinator: Coordinator {
    var delegate: CalendarCoordinatorDelegate? { get set }
}
