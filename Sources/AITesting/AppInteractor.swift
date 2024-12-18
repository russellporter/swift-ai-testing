//
//  AppInteractor.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import XCTest

@MainActor
public protocol AppInteractor: Sendable {
    func tap(at position: CGPoint) throws
    func type(text: String, at position: CGPoint) throws
    func scroll(from point: CGPoint, offset: CGVector)
    func wait(duration: TimeInterval)
}

@MainActor
open class StandardAppInteractor: AppInteractor {
    private let app: XCUIApplication

    public init(app: XCUIApplication) {
        self.app = app
    }

    open func tap(at position: CGPoint) throws {
        app.coordinate(withAbsolutePosition: position).tap()
    }

    open func type(text: String, at position: CGPoint) throws {
        try tap(at: position)
        app.typeText(text)
    }

    open func scroll(from point: CGPoint, offset: CGVector) {
        app.coordinate(withAbsolutePosition: point)
            .press(
                forDuration: 0.01,
                thenDragTo: app.coordinate(withAbsolutePosition: CGPoint(x: point.x - offset.dx, y: point.y - offset.dy))
            )
    }

    open func wait(duration: TimeInterval) {
        Thread.sleep(forTimeInterval: duration)
    }
}
