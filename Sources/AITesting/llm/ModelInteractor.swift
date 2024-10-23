//
//  ModelInteractor.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import UIKit

public protocol ModelInteractor: Sendable {
    func perform<PromptResponse: Decodable & Sendable>(
        prompt: String,
        image: UIImage?,
        promptResponseType: PromptResponse.Type
    ) async throws -> PromptResponse
}
