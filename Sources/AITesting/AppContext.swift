//
//  AppContext.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import Foundation
import XCTest

public struct AppContext: Sendable {
    let instructions: String
    let viewHierarchy: String
    let screenshot: XCUIScreenshot
    let textSubstitutions: [String: String]

    @MainActor
    public static func capture(instructions: String, textSubstitutions: [String: String] = [:], app: XCUIApplication, in screen: XCUIScreen = .main) throws -> Self {
        // This should be first as getting the snapshot might wait for the app to idle.
        let hierarchySnapshot = try app.snapshot()
        let screenshot = screen.screenshot()

        let viewHierarchy = hierarchySnapshot.detailedDescription

        return AppContext(instructions: instructions, viewHierarchy: viewHierarchy, screenshot: screenshot, textSubstitutions: textSubstitutions)
    }
}
