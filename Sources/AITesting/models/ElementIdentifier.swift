//
//  ElementIdentifier.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

public struct ElementIdentifier: Decodable, Sendable {
    enum CodingKeys: String, CodingKey {
        case type, idOrLabel = "id_or_label"
    }

    public let type: String
    public let idOrLabel: String
}
