//
//  XCUIElementSnapshot.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import XCTest

extension XCUIElementSnapshot {
    var detailedDescription: String {
        detailedDescription(rootSnapshot: self)
    }

    private func detailedDescription(
        rootSnapshot: any XCUIElementSnapshot,
        indent: String = ""
    ) -> String {
        var result = ""

        // Only include elements with meaningful identifiers, labels, or specific types
        let relevantTypes: Set<String> = ["button", "staticText", "textField", "tabBar", "navigationBar", "scrollView"]
        let elementType = elementType.stringValue
        var additionalIndent = ""
        if relevantTypes.contains(elementType) ||
            !identifier.isEmpty ||
            !label.isEmpty {

            additionalIndent = "  "

            // Start with element type
            result += "\(indent)[\(elementType)]"

            // Add identifier if present
            if !identifier.isEmpty {
                result += " id='\(identifier)'"
            }

            // Add label if present and different from identifier
            if !label.isEmpty && label != identifier {
                result += " label='\(label)'"
            }

            // Add selection/focus state only if true
            if isSelected {
                result += " [selected]"
            }
            if hasFocus {
                result += " [focused]"
            }
            if !isEnabled {
                result += " [disabled]"
            }

            // Include information if the element is off screen
            let screenFrame = rootSnapshot.frame
            let elementFrame = frame
            if elementFrame.midY < screenFrame.minY {
                result += " [off-screen, scroll up]"
            } else if elementFrame.midY > screenFrame.maxY {
                result += " [off-screen, scroll down]"
            }

            // Add frame info only for layout-critical elements
            result += " frame=\(frame)"

            result += "\n"
        }

        // Process children recursively
        for child in children {
            result += child.detailedDescription(rootSnapshot: rootSnapshot, indent: indent + additionalIndent)
        }

        return result
    }
}
