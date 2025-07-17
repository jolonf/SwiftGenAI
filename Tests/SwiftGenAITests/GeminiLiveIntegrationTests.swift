// GeminiLiveIntegrationTests.swift
// Live test for end-to-end Gemini API integration (skipped unless GEMINI_API_KEY is set)

import Foundation
import Testing
import SwiftGenAI

private func geminiApiKey() -> String {
    return ""
}

private func hasGeminiApiKey() -> Bool {
    geminiApiKey().isEmpty == false
}

@Suite("Gemini LIVE API integration")
struct GeminiLiveIntegrationTests {
    @Test("generateContent works with real Gemini API if GEMINI_API_KEY is set", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_generateContent() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)

        // Use instance method to call the real Gemini API
        let response = try await genAI.generateContent(model: "gemini-2.5-flash", content: "How does AI work?")

        // Assert that at least one candidate exists in the response
        let candidateCount = response.candidates?.count ?? 0
        #expect(candidateCount > 0, "Expected at least one candidate in live generateContent response")

        // Print a snippet of the first candidate for manual inspection
        if let firstCandidate = response.candidates?.first {
            print("Live test response snippet: \(firstCandidate)")
        }
    }
}
