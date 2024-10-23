//
//  AppInteractor.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import XCTest

enum AppInteractionError: Error {
    case elementNotFound(ElementIdentifier)
    case elementNotHittable(ElementIdentifier)
}

@MainActor
public protocol AppInteractor: Sendable {
    func tap(_ id: ElementIdentifier) throws
    func type(text: String, _ id: ElementIdentifier) throws
    func scroll(from point: CGPoint, offset: CGVector)
    func wait(duration: TimeInterval)
}

@MainActor
open class StandardAppInteractor: AppInteractor {
    private let app: XCUIApplication

    public init(app: XCUIApplication) {
        self.app = app
    }

    open func tap(_ id: ElementIdentifier) throws {
        let element = app[id]
        guard element.exists else { throw AppInteractionError.elementNotFound(id) }
        guard element.isHittable else { throw AppInteractionError.elementNotHittable(id) }

        app[id].tap()
    }

    open func type(text: String, _ id: ElementIdentifier) throws {
        try tap(id)
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

extension XCUIApplication {
    subscript(id: ElementIdentifier) -> XCUIElement {
        self.descendants(matching: .any).matching(identifier: id.idOrLabel).firstMatch
    }
}
