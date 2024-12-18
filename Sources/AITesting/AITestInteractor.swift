//
//  AITestInteractor.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import Foundation
import XCTest
import OSLog

enum AITestError: Error {
    case failed(reason: String)
}

public actor AITestInteractor {
    enum Interaction {
        case decision(TestDecision)
        case failure(Error)

        var comment: String {
            switch self {
            case .decision(let decision):
                let actions = decision.actions ?? []
                return "\(decision.comment). Action: \(actions.map { String(describing: $0) }.joined(separator: ", "))"
            case .failure(let error):
                return "Interaction error: \(String(describing: error))"
            }
        }
    }

    private let promptGenerator = PromptGenerator()
    private let modelInteractor: ModelInteractor
    private let appInteractor: AppInteractor
    private let logger = Logger()
    private let includingImage: Bool

    public init(
        appInteractor: AppInteractor,
        modelInteractor: ModelInteractor,
        includingImage: Bool = true
    ) {
        self.appInteractor = appInteractor
        self.modelInteractor = modelInteractor
        self.includingImage = includingImage
    }

    private var interactionHistory = [Interaction]()

    @MainActor
    public func performTestBlocking(contextProvider: @MainActor @escaping () throws -> AppContext) throws {
        try runBlocking {
            try await self.performTest(contextProvider: contextProvider)
        }
    }

    public func performTest(contextProvider: @MainActor () throws -> AppContext) async throws {
        while true {
            let context = try await contextProvider()
            let result = try await performStep(context: context)
            if let result {
                if case .fail = result {
                    throw AITestError.failed(reason: interactionHistory.last!.comment)
                }
                break
            }
        }
    }

    func performStep(context: AppContext) async throws -> TestResult? {
        let prompt = await promptGenerator.generate(for: context, pastDecisions: interactionHistory.map { $0.comment })
        let image = await context.screenshot.image

        await XCTContext.runActivity(named: "Request decision") { activity in
            let promptAttachment = XCTAttachment(string: prompt)
            promptAttachment.name = "Prompt"
            activity.add(promptAttachment)

            let imageAttachment = XCTAttachment(image: image)
            imageAttachment.name = "Image"
            activity.add(imageAttachment)
        }
        // Downscale the image to non-retina resolution
        let downscaledImage = includingImage ? image.resized(scale: 1) : nil
        let decision = try await modelInteractor.perform(prompt: prompt, image: downscaledImage, promptResponseType: TestDecision.self)

        interactionHistory.append(.decision(decision))

        await XCTContext.runActivity(named: "Received decision") { activity in
            let promptAttachment = XCTAttachment(string: String(describing: decision))
            promptAttachment.name = "Decision"
            activity.add(promptAttachment)
        }

        if let result = decision.result {
            logger.info("Received result: \(String(describing: result)) \(decision.comment)")
            return result
        }

        logger.info("Received decision: \(decision.comment)")

        let actions = decision.actions ?? []
        do {
            for action in actions {
                try await performAction(action, context: context)
            }
        } catch {
            logger.error("Interaction failed: \(error)")
            interactionHistory.append(.failure(error))
        }

        return nil
    }

    func performAction(_ action: TestAction, context: AppContext) async throws {
        logger.info("Performing action: \(String(describing: action))")
        switch action {
        case .tap(let position):
            try await appInteractor.tap(at: position)
        case .type(let position, text: let text):
            try await appInteractor.type(text: text.applySubstitutions(context.textSubstitutions), at: position)
        case .scroll(let point, let offset):
            await appInteractor.scroll(from: point, offset: offset)
        case .wait(duration: let duration):
            await appInteractor.wait(duration: duration)
        }
    }
}
