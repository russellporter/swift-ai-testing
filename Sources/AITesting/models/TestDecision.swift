//
//  TestDecision.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

struct TestDecision: Decodable {
    enum CodingKeys: String, CodingKey {
        case actions, result, comment
    }

    let result: TestResult?
    let actions: [TestAction]?
    let comment: String
}
