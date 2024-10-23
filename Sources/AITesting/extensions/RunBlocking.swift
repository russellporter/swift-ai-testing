//
//  RunBlocking.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import Foundation
import XCTest

struct TimeoutError: Error {}

public func runBlocking<T: Sendable>(_ block: @Sendable @escaping @isolated(any) () async throws -> T) throws -> T {
    var result: Result<T, Error>!
    let expectation = XCTestExpectation(description: "")
    Task {
        do {
            result = .success(try await block())
        } catch {
            result = .failure(error)
        }
        expectation.fulfill()
    }

    let waitResult = XCTWaiter().wait(for: [expectation], timeout: 1000)
    guard waitResult == .completed else {
        throw TimeoutError()
    }

    guard let result else {
        fatalError("Result should be set at this point")
    }

    return try result.get()
}
