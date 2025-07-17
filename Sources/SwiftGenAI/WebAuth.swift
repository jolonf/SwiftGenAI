//
//  WebAuth.swift
//  swift-genai
//
//  Created by Jolon on 13/7/2025.
//

import Foundation

let GOOGLE_API_KEY_HEADER = "x-goog-api-key"

public struct WebAuth: Auth, Sendable {
    private let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func addAuthHeaders(headers: inout [String: String]) async throws {
        if headers[GOOGLE_API_KEY_HEADER] != nil {
            return
        }
        if apiKey.hasPrefix("auth_tokens/") {
            throw NSError(domain: "WebAuth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ephemeral tokens are only supported by the live API."])
        }
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw NSError(domain: "WebAuth", code: 2, userInfo: [NSLocalizedDescriptionKey: "API key is missing. Please provide a valid API key."])
        }
        headers[GOOGLE_API_KEY_HEADER] = apiKey
    }
}
