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

    @Test("generateContent works with thinking config", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_thinkingConfig() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)
        let config = GenerateContentConfig(thinkingConfig: ThinkingConfig(thinkingBudget: 0))
        let response = try await genAI.generateContent(model: "gemini-2.5-flash", content: "How does AI work?", config: config)
        let candidateCount = response.candidates?.count ?? 0
        #expect(candidateCount > 0, "Expected at least one candidate in live thinking config response")
        if let firstCandidate = response.candidates?.first {
            print("Thinking config response snippet: \(firstCandidate)")
        }
    }

    @Test("generateContent works with system instruction", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_systemInstruction() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)
        let systemInstruction = Content(parts: [.text("You are a cat. Your name is Neko.")])
        let userContent = Content(parts: [.text("Hello there")])
        let config = GenerateContentConfig(systemInstruction: systemInstruction)
        let response = try await genAI.generateContent(model: "gemini-2.5-flash", contents: [userContent], config: config)
        let candidateCount = response.candidates?.count ?? 0
        #expect(candidateCount > 0, "Expected at least one candidate in live system instruction response")
        if let firstCandidate = response.candidates?.first {
            print("System instruction response snippet: \(firstCandidate)")
        }
    }

    @Test("generateContent works with stopSequences, temperature, topP, topK", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_stopSequencesAndConfig() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)
        let config = GenerateContentConfig(
            temperature: 1.0,
            topP: 0.8,
            topK: 10,
            stopSequences: ["Title"]
        )
        let response = try await genAI.generateContent(model: "gemini-2.5-flash", content: "Explain how AI works", config: config)
        let candidateCount = response.candidates?.count ?? 0
        #expect(candidateCount > 0, "Expected at least one candidate in live stopSequences config response")
        if let firstCandidate = response.candidates?.first {
            print("StopSequences config response snippet: \(firstCandidate)")
        }
    }

    @Test("generateContent works with multi-turn chat", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_multiTurnChat() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)
        let contents = [
            Content(parts: [.text("Hello")], role: "user"),
            Content(parts: [.text("Great to meet you. What would you like to know?")], role: "model"),
            Content(parts: [.text("I have two dogs in my house. How many paws are in my house?")], role: "user")
        ]
        let response = try await genAI.generateContent(model: "gemini-2.5-flash", contents: contents)
        let candidateCount = response.candidates?.count ?? 0
        #expect(candidateCount > 0, "Expected at least one candidate in live multi-turn chat response")
        if let firstCandidate = response.candidates?.first {
            print("Multi-turn chat response snippet: \(firstCandidate)")
        }
    }

    @Test("generateContentStream works with real Gemini API if GEMINI_API_KEY is set", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_generateContentStream() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)
        
        var candidates: [Candidate] = []
        let stream = await genAI.generateContentStream(model: "gemini-2.5-flash", content: "How does AI work?")
        
        for try await event in stream {
            if let eventCandidates = event.candidates, !eventCandidates.isEmpty {
                candidates.append(contentsOf: eventCandidates)
            }
        }
        let candidateCount = candidates.count
        #expect(candidateCount > 0, "Expected at least one candidate in live generateContentStream response")
        if let firstCandidate = candidates.first {
            print("candidates.count = \(candidates.count)")
            print("Live test stream response snippet: \(firstCandidate)")
        }
    }

    @Test("generateContentStream works with thinking config", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_generateContentStream_thinkingConfig() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)
        let config = GenerateContentConfig(thinkingConfig: ThinkingConfig(thinkingBudget: 0))
        var candidates: [Candidate] = []
        let stream = await genAI.generateContentStream(model: "gemini-2.5-flash", content: "How does AI work?", config: config)
        for try await event in stream {
            if let eventCandidates = event.candidates, !eventCandidates.isEmpty {
                candidates.append(contentsOf: eventCandidates)
            }
        }
        let candidateCount = candidates.count
        #expect(candidateCount > 0, "Expected at least one candidate in live stream thinking config response")
        if let firstCandidate = candidates.first {
            print("Thinking config (stream) response snippet: \(firstCandidate)")
        }
    }

    @Test("generateContentStream works with system instruction", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_generateContentStream_systemInstruction() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)
        let systemInstruction = Content(parts: [.text("You are a cat. Your name is Neko.")])
        let userContent = Content(parts: [.text("Hello there")])
        let config = GenerateContentConfig(systemInstruction: systemInstruction)
        var candidates: [Candidate] = []
        let stream = await genAI.generateContentStream(model: "gemini-2.5-flash", contents: [userContent], config: config)
        for try await event in stream {
            if let eventCandidates = event.candidates, !eventCandidates.isEmpty {
                candidates.append(contentsOf: eventCandidates)
            }
        }
        let candidateCount = candidates.count
        #expect(candidateCount > 0, "Expected at least one candidate in live stream system instruction response")
        if let firstCandidate = candidates.first {
            print("System instruction (stream) response snippet: \(firstCandidate)")
        }
    }

    @Test("generateContentStream works with stopSequences, temperature, topP, topK", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_generateContentStream_stopSequencesAndConfig() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)
        let config = GenerateContentConfig(
            temperature: 1.0,
            topP: 0.8,
            topK: 10,
            stopSequences: ["Title"]
        )
        var candidates: [Candidate] = []
        let stream = await genAI.generateContentStream(model: "gemini-2.5-flash", content: "Explain how AI works", config: config)
        for try await event in stream {
            if let eventCandidates = event.candidates, !eventCandidates.isEmpty {
                candidates.append(contentsOf: eventCandidates)
            }
        }
        let candidateCount = candidates.count
        #expect(candidateCount > 0, "Expected at least one candidate in live stream stopSequences config response")
        if let firstCandidate = candidates.first {
            print("StopSequences config (stream) response snippet: \(firstCandidate)")
        }
    }

    @Test("generateContentStream works with multi-turn chat", .enabled(if: hasGeminiApiKey()))
    func liveIntegrationTest_generateContentStream_multiTurnChat() async throws {
        let apiKey = geminiApiKey()
        let genAI = GenAI(apiKey: apiKey)
        let contents = [
            Content(parts: [.text("Hello")], role: "user"),
            Content(parts: [.text("Great to meet you. What would you like to know?")], role: "model"),
            Content(parts: [.text("I have two dogs in my house. How many paws are in my house?")], role: "user")
        ]
        var candidates: [Candidate] = []
        let stream = await genAI.generateContentStream(model: "gemini-2.5-flash", contents: contents)
        for try await event in stream {
            if let eventCandidates = event.candidates, !eventCandidates.isEmpty {
                candidates.append(contentsOf: eventCandidates)
            }
        }
        let candidateCount = candidates.count
        #expect(candidateCount > 0, "Expected at least one candidate in live stream multi-turn chat response")
        if let firstCandidate = candidates.first {
            print("Multi-turn chat (stream) response snippet: \(firstCandidate)")
        }
    }
}
