//
//  AnthropicModelInteractor.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import UIKit
import OSLog

public actor AnthropicModelInteractor: ModelInteractor {
    struct MessageContent: Codable {
        enum CodingKeys: String, CodingKey {
            case type, source, text
        }
        let type: String
        var source: MessageImageSource?
        var text: String?
    }

    struct MessageImageSource: Codable {
        enum CodingKeys: String, CodingKey {
            case type, mediaType = "media_type", data
        }
        let type: String
        let mediaType: String
        let data: String

        init(image: UIImage) {
            self.type = "base64"
            self.mediaType = "image/png"
            self.data = image.pngData()!.base64EncodedString()
        }
    }

    struct Message: Codable {
        let role: String
        let content: [MessageContent]
    }

    struct AnthropicRequest: Codable {
        let model: String
        let maxTokens: Int
        let messages: [Message]
        let system: String

        enum CodingKeys: String, CodingKey {
            case model
            case maxTokens = "max_tokens"
            case messages
            case system
        }
    }

    struct AnthropicResponse: Codable {
        struct MessageContent: Codable {
            let type: String
            let text: String?
        }

        struct Usage: Codable {
            let inputTokens: Int
            let outputTokens: Int

            enum CodingKeys: String, CodingKey {
                case inputTokens = "input_tokens"
                case outputTokens = "output_tokens"
            }
        }


        let id: String
        let type: String
        let role: String
        let content: [MessageContent]
        let model: String
        let stopReason: String?
        let stopSequence: String?
        let usage: Usage

        enum CodingKeys: String, CodingKey {
            case id, type, role, content, model
            case stopReason = "stop_reason"
            case stopSequence = "stop_sequence"
            case usage
        }
    }

    struct AnthropicError: Error {
        let message: String
    }

    private let apiKey: String
    private let modelName: String
    private let logger = Logger()

    public init(apiKey: String, modelName: String = "claude-3-5-sonnet-20241022") {
        self.apiKey = apiKey
        self.modelName = modelName
    }

    public func perform<PromptResponse: Decodable & Sendable>(
        prompt: String,
        image: UIImage?,
        promptResponseType: PromptResponse.Type
    ) async throws -> PromptResponse {
        try await perform(prompt: prompt, image: image, promptResponseType: promptResponseType, tries: 2)
    }

    func perform<PromptResponse: Decodable>(
        prompt: String,
        image: UIImage?,
        promptResponseType: PromptResponse.Type,
        tries: Int
    ) async throws -> PromptResponse {
        if tries < 1 { throw AnthropicError(message: "No more retries remaining") }
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)

        // Set up the request
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        // Create the request body
        let messageData = AnthropicRequest(
            model: modelName,
            maxTokens: 1024,
            messages: [
                Message(
                    role: "user",
                    content: [
                        MessageContent(type: "text", text: prompt),
                        image.map { MessageContent(type: "image", source: MessageImageSource(image: $0)) }
                    ].compactMap { $0 }
                ),
                Message(
                    role: "assistant",
                    content: [MessageContent(type: "text", text: "Here is the JSON requested:\n<json>{")]
                )
            ],
            system: "You are an expert QA tester, testing out an app."
        )

        // Encode the request body
        let encoder = JSONEncoder()
        let requestData = try encoder.encode(messageData)
        request.httpBody = requestData

        // Make the request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check the response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnthropicError(message: "Invalid response")
        }

        if httpResponse.statusCode == 429 || httpResponse.statusCode == 529 {
            let retryAfter = httpResponse.allHeaderFields["retry-after"] as? String
            let seconds = retryAfter.flatMap { Int($0) } ?? 30
            logger.warning("Rate limited. Retrying in \(seconds) seconds. ☕️")
            try await Task.sleep(for: .seconds(seconds))
            return try await perform(prompt: prompt, image: image, promptResponseType: promptResponseType, tries: tries - 1)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            throw AnthropicError(message: "Error: HTTP \(httpResponse.statusCode). Body: \(body ?? "")")
        }

        let json: String
        do {
            let decoder = JSONDecoder()
            let anthropicResponse = try decoder.decode(AnthropicResponse.self, from: data)
            json = "{" + anthropicResponse.content.first!.text!.removeAll(startingFrom: "</json>")
        } catch {
            logger.error("Failed to decode anthropic response: \(String(data: data, encoding: .utf8)!) \(error)")
            throw error
        }

        do {
            let decoder = JSONDecoder()
            let promptResponse = try decoder.decode(PromptResponse.self, from: json.data(using: .utf8)!)
            return promptResponse
        } catch {
            logger.error("Failed to decode prompt response: \(json) \(error)")

            // TODO: remove once using a "tool" to specify output
            // Let the model try again to output a correct response.
            return try await perform(prompt: prompt, image: image, promptResponseType: promptResponseType, tries: tries - 1)
        }
    }
}

extension String {
    func removeAll(startingFrom substring: String) -> String {
        guard let range = self.range(of: substring) else { return self }
        return String(self[..<range.lowerBound])
    }
}
