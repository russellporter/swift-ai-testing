//
//  XCUIElement.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import XCTest

extension XCUIElement {
    func coordinate(withAbsolutePosition point: CGPoint) -> XCUICoordinate {
        let normalizedOffset = CGVector(dx: point.x / frame.width, dy: point.y / frame.height)
        return coordinate(withNormalizedOffset: normalizedOffset)
    }
}
