//
//  TestAction.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import Foundation

enum TestAction: Decodable {
    case tap(ElementIdentifier)
    case type(ElementIdentifier, text: String)
    case scroll(CGPoint, offset: CGVector)
    case wait(duration: TimeInterval)

    // Custom coding keys
    private enum CodingKeys: String, CodingKey {
        case type
        case x
        case y
        case id
        case durationSecs = "duration_secs"
        case originX = "origin_x"
        case originY = "origin_y"
        case offsetX = "offset_x"
        case offsetY = "offset_y"
        case text
    }

    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "tap":
            self = .tap(try container.decode(ElementIdentifier.self, forKey: .id))
        case "type":
            let text = try container.decode(String.self, forKey: .text)
            self = .type(try container.decode(ElementIdentifier.self, forKey: .id), text: text)
        case "wait":
            let secs = try container.decode(TimeInterval.self, forKey: .durationSecs)
            self = .wait(duration: secs)
        case "scroll":
            let x = try container.decode(Double.self, forKey: .originX)
            let y = try container.decode(Double.self, forKey: .originY)
            let offsetX = try container.decode(Double.self, forKey: .offsetX)
            let offsetY = try container.decode(Double.self, forKey: .offsetY)
            self = .scroll(CGPoint(x: x, y: y), offset: CGVector(dx: offsetX, dy: offsetY))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Invalid type value: \(type)"
            )
        }
    }

}
