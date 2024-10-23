//
//  String.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import Foundation

extension String {
    func applySubstitutions(_ substitutions: [String: String]) -> String {
        var result = self
        for (key, value) in substitutions {
            result = result.replacingOccurrences(of: "<\(key)>", with: value)
        }
        return result
    }
}
