import Foundation
//
//  GenAI+Text.swift
//  swift-genai
//
//  Created by Jolon on 13/7/2025.
//

public let DEFAULT_CONTENT_MODEL = "gemini-2.5-flash"

public extension GenAI {

    func generateContent(model: String = DEFAULT_CONTENT_MODEL, content: String, config: GenerateContentConfig? = nil) async throws -> GenerateContentResponse {
        return try await generateContent(model: model, contents: [Content(parts: [.text(content)])], config: config)
    }

    func generateContent(model: String = DEFAULT_CONTENT_MODEL, content: Content, config: GenerateContentConfig? = nil) async throws -> GenerateContentResponse {
        return try await generateContent(model: model, contents: [content], config: config)
    }

    func generateContent(model: String = DEFAULT_CONTENT_MODEL, part: Part, config: GenerateContentConfig? = nil) async throws -> GenerateContentResponse {
        return try await generateContent(model: model, contents: [Content(parts: [part])], config: config)
    }

    func generateContent(model: String = DEFAULT_CONTENT_MODEL, parts: [Part], config: GenerateContentConfig? = nil) async throws -> GenerateContentResponse {
        return try await generateContent(model: model, contents: [Content(parts: parts)], config: config)
    }

    /**
     Makes an API request to generate content using the specified model.

     The `model` parameter supports the following formats for different APIs:

     - For Vertex AI API (note Vertex is currently not supported):
       - Gemini model ID (e.g., "gemini-2.0-flash")
       - Full resource name, starting with "projects/" (e.g., "projects/my-project-id/locations/us-central1/publishers/google/models/gemini-2.0-flash")
       - Partial resource name with "publishers/" (e.g., "publishers/google/models/gemini-2.0-flash" or "publishers/meta/models/llama-3.1-405b-instruct-maas")
       - Publisher and model name separated by "/" (e.g., "google/gemini-2.0-flash" or "meta/llama-3.1-405b-instruct-maas")

     - For Gemini API:
       - Gemini model ID (e.g., "gemini-2.0-flash")
       - Model name starting with "models/" (e.g., "models/gemini-2.0-flash")
       - Tuned model name starting with "tunedModels/" (e.g., "tunedModels/1234567890123456789")

     Some models support multimodal input and output.

     - Parameters:
        - model: The model identifier or resource string.
        - contents: The list of content parts for the request.
        - config: Optional configuration for content generation.
     - Returns: The content generation response.

     */
    func generateContent(model: String = DEFAULT_CONTENT_MODEL, contents: [Content], config: GenerateContentConfig? = nil) async throws -> GenerateContentResponse {
        let body: GenerateContentParameters
        let path: String

        if await apiClient.vertexai {
            throw GenAIError.vertexNotSupported
        } else {
            (path, body) = await generateContentParametersToMldev(apiClient: apiClient, model: model, contents: contents, config: config)
        }

        // Serialize generated params to JSON with JSONEncoder
        let jsonData = try JSONEncoder().encode(body)

        let request = HttpRequest(
            path: "\(path):generateContent",
            httpMethod: .POST,
            body: jsonData
        )

        let response = try await apiClient.request(request: request)

        guard let responseData = response.body else {
            throw NSError(domain: "GenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response body"])
        }
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: responseData),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: prettyData, encoding: .utf8) {
            print(jsonString)
        }

        let decoded = try JSONDecoder().decode(GenerateContentResponse.self, from: responseData)

        return decoded
    }

    // MARK: Stream versions
    
    func generateContentStream(model: String = DEFAULT_CONTENT_MODEL, content: String, config: GenerateContentConfig? = nil) -> AsyncThrowingStream<GenerateContentResponse, Error>{
        return generateContentStream(model: model, contents: [Content(parts: [.text(content)])], config: config)
    }
    
    /// Generates content using a streaming API, yielding each chunk as a `GenerateContentResponse`.
    func generateContentStream(model: String = DEFAULT_CONTENT_MODEL, contents: [Content], config: GenerateContentConfig? = nil) -> AsyncThrowingStream<GenerateContentResponse, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                let (path, body) = await generateContentParametersToMldev(apiClient: apiClient, model: model, contents: contents, config: config)
                // Serialize parameters to JSON
                guard let jsonData = try? JSONEncoder().encode(body) else {
                    continuation.finish(throwing: NSError(domain: "GenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode parameters for streaming"]))
                    return
                }

                let request = HttpRequest(
                    path: "\(path):streamGenerateContent",
                    httpMethod: .POST,
                    body: jsonData
                )

                let stream = await apiClient.requestStream(request: request)
                for try await chunk in stream {
                    guard let data = chunk.body else { continue }
                    do {
                        let decoded = try JSONDecoder().decode(GenerateContentResponse.self, from: data)
                        continuation.yield(decoded)
                    } catch {
                        continuation.finish(throwing: error)
                        return
                    }
                }
                continuation.finish()
            }
        }
    }
}
