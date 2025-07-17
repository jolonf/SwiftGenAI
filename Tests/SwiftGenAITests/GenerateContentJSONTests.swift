// GenerateContentJSONTests.swift
// Tests JSON parameter generation for Gemini API against documented REST examples.

import Foundation
import Testing
import SwiftGenAI

@Suite("Gemini JSON parameter generation")
struct GenerateContentJSONTests {

    @Test("Matches Gemini text generation minimal example")
    func matchesMinimalTextGenerationExample() async throws {
        // Arrange: Create ApiClient with dummy WebAuth and API key
        let auth = WebAuth(apiKey: "dummy-key")
        let apiClient = ApiClient(auth: auth)

        // Prepare the test input ("How does AI work?")
        let part = Part.text("How does AI work?")
        let content = Content(parts: [part])
        let contents = [content]
        
        // Act: Generate parameters
        let (_, params) = await generateContentParametersToMldev(apiClient: apiClient, model: "gemini-2.5-flash", contents: contents, config: nil)
        
        // Serialize generated params to JSON with JSONEncoder
        let generatedJsonData = try JSONEncoder().encode(params)
        
        // Assert: Use the REST docs JSON as expected
        let expectedJsonString = """
        {
          "contents": [
            {
              "parts": [
                {
                  "text": "How does AI work?"
                }
              ]
            }
          ]
        }
        """
        let expectedJsonData = expectedJsonString.data(using: .utf8)!
        let expectedJsonObject = try JSONSerialization.jsonObject(with: expectedJsonData) as! NSDictionary
        let generatedJsonObject = try JSONSerialization.jsonObject(with: generatedJsonData) as! NSDictionary

        #expect(generatedJsonObject == expectedJsonObject, "JSON does not match Gemini docs example")
    }

    @Test("Matches Gemini 'thinking' config example")
    func matchesThinkingConfigExample() async throws {
        let auth = WebAuth(apiKey: "dummy-key")
        let apiClient = ApiClient(auth: auth)
        let part = Part.text("How does AI work?")
        let content = Content(parts: [part])
        let contents = [content]
        let config = GenerateContentConfig(
            thinkingConfig: ThinkingConfig(thinkingBudget: 0)
        )

        let (_, params) = await generateContentParametersToMldev(apiClient: apiClient, model: "gemini-2.5-flash", contents: contents, config: config)
        let generatedJsonData = try JSONEncoder().encode(params)
        let expectedJsonString = """
        {
          "contents": [
            {
              "parts": [
                {
                  "text": "How does AI work?"
                }
              ]
            }
          ],
          "generationConfig": {
            "thinkingConfig": {
              "thinkingBudget": 0
            }
          }
        }
        """
        let expectedJsonData = expectedJsonString.data(using: .utf8)!
        let expectedJsonObject = try JSONSerialization.jsonObject(with: expectedJsonData) as! NSDictionary
        let generatedJsonObject = try JSONSerialization.jsonObject(with: generatedJsonData) as! NSDictionary
        #expect(generatedJsonObject == expectedJsonObject, "JSON does not match Gemini 'thinking' config example")
    }

    @Test("Matches Gemini system instruction example")
    func matchesSystemInstructionExample() async throws {
        let auth = WebAuth(apiKey: "dummy-key")
        let apiClient = ApiClient(auth: auth)
        let systemInstruction = Content(parts: [Part.text("You are a cat. Your name is Neko.")])
        let userContent = Content(parts: [Part.text("Hello there")])
        let contents = [userContent]
        let config = GenerateContentConfig(
            systemInstruction: systemInstruction
        )
        let (_, params) = await generateContentParametersToMldev(apiClient: apiClient, model: "gemini-2.5-flash", contents: contents, config: config)
        let generatedJsonData = try JSONEncoder().encode(params)
        let expectedJsonString = """
        {
          "systemInstruction": {
            "parts": [
              {
                "text": "You are a cat. Your name is Neko."
              }
            ]
          },
          "contents": [
            {
              "parts": [
                {
                  "text": "Hello there"
                }
              ]
            }
          ]
        }
        """
        let expectedJsonData = expectedJsonString.data(using: .utf8)!
        let expectedJsonObject = try JSONSerialization.jsonObject(with: expectedJsonData) as! NSDictionary
        let generatedJsonObject = try JSONSerialization.jsonObject(with: generatedJsonData) as! NSDictionary
        #expect(generatedJsonObject == expectedJsonObject, "JSON does not match Gemini system instruction example")
    }

    @Test("Matches Gemini stopSequences and temperature config example")
    func matchesStopSequencesConfigExample() async throws {
        let auth = WebAuth(apiKey: "dummy-key")
        let apiClient = ApiClient(auth: auth)
        let part = Part.text("Explain how AI works")
        let content = Content(parts: [part])
        let contents = [content]
        let config = GenerateContentConfig(
            temperature: 1.0,
            topP: 0.8,
            topK: 10,
            stopSequences: ["Title"],
        )
        let (_, params) = await generateContentParametersToMldev(apiClient: apiClient, model: "gemini-2.5-flash", contents: contents, config: config)
        let generatedJsonData = try JSONEncoder().encode(params)
        let expectedJsonString = """
        {
          "contents": [
            {
              "parts": [
                {
                  "text": "Explain how AI works"
                }
              ]
            }
          ],
          "generationConfig": {
            "stopSequences": [
              "Title"
            ],
            "temperature": 1.0,
            "topP": 0.8,
            "topK": 10
          }
        }
        """
        let expectedJsonData = expectedJsonString.data(using: .utf8)!
        let expectedJsonObject = try JSONSerialization.jsonObject(with: expectedJsonData) as! NSDictionary
        let generatedJsonObject = try JSONSerialization.jsonObject(with: generatedJsonData) as! NSDictionary
        #expect(generatedJsonObject == expectedJsonObject, "JSON does not match Gemini stopSequences config example")
    }

    @Test("Matches Gemini multi-turn conversation (chat) example")
    func matchesMultiTurnChatExample() async throws {
        let auth = WebAuth(apiKey: "dummy-key")
        let apiClient = ApiClient(auth: auth)
        let contents = [
            Content(parts: [Part.text("Hello")], role: "user"),
            Content(parts: [Part.text("Great to meet you. What would you like to know?")], role: "model"),
            Content(parts: [Part.text("I have two dogs in my house. How many paws are in my house?")], role: "user")
        ]
        let (_, params) = await generateContentParametersToMldev(apiClient: apiClient, model: "gemini-2.5-flash", contents: contents, config: nil)
        let generatedJsonData = try JSONEncoder().encode(params)
        let expectedJsonString = """
        {
          "contents": [
            {
              "role": "user",
              "parts": [
                { "text": "Hello" }
              ]
            },
            {
              "role": "model",
              "parts": [
                { "text": "Great to meet you. What would you like to know?" }
              ]
            },
            {
              "role": "user",
              "parts": [
                { "text": "I have two dogs in my house. How many paws are in my house?" }
              ]
            }
          ]
        }
        """
        let expectedJsonData = expectedJsonString.data(using: .utf8)!
        let expectedJsonObject = try JSONSerialization.jsonObject(with: expectedJsonData) as! NSDictionary
        let generatedJsonObject = try JSONSerialization.jsonObject(with: generatedJsonData) as! NSDictionary
        #expect(generatedJsonObject == expectedJsonObject, "JSON does not match Gemini multi-turn chat example")
    }
}
