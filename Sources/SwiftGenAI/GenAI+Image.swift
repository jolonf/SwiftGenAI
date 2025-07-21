//
//  GenAI+Image.swift
//  SwiftGenAI
//
//  Created by Jolon on 20/7/2025.
//

import Foundation
//
//  GenAI+Text.swift
//  swift-genai
//
//  Created by Jolon on 13/7/2025.
//

public let DEFAULT_IMAGE_MODEL = "imagen-4.0-generate-preview-06-06"

public extension GenAI {

    /// Generates images from a text prompt using the specified model and configuration.
    ///
    /// - Parameters:
    ///   - model: The name of the image generation model to use. Defaults to `imagen-4.0-generate-preview-06-06`.
    ///   - prompt: The text description for the image to generate.
    ///   - config: Optional configuration for image generation.
    /// - Returns: The response containing generated image data and metadata.
    /// - Throws: An error if image generation fails or is unsupported by the API client.
    ///
    /// Example:
    /// ```swift
    /// let response = try await genAI.generateImages(
    ///     model: "imagen-4.0-generate-preview-06-06",
    ///     prompt: "Robot holding a red skateboard",
    ///     config: GenerateImagesConfig(
    ///         numberOfImages: 1,
    ///         includeRaiReason: true
    ///     )
    /// )
    /// if let imageData = response.generatedImages?.first?.image?.imageBytes {
    ///     print(imageData)
    /// }
    /// ```
    func generateImages(model: String = DEFAULT_IMAGE_MODEL, prompt: String, config: GenerateImagesConfig? = nil) async throws -> GenerateImagesResponse {
        let body: GenerateImagesParameters
        let path: String

        if await apiClient.vertexai {
            throw GenAIError.vertexNotSupported
        } else {
            (path, body) = await generateImagesParametersToMldev(apiClient: apiClient, model: model, prompt: prompt, config: config)
        }

        // Serialize generated params to JSON with JSONEncoder
        let jsonData = try JSONEncoder().encode(body)

        let request = HttpRequest(
            path: "\(path):predict",
            httpMethod: .POST,
            body: jsonData
        )

        let response = try await apiClient.request(request: request)

        guard let responseData = response.body else {
            throw NSError(domain: "GenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response body"])
        }
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: responseData) {
            let truncatedJSONObject = truncateLongStringsInJSONObject(jsonObject)
            if let prettyData = try? JSONSerialization.data(withJSONObject: truncatedJSONObject, options: .prettyPrinted),
               let jsonString = String(data: prettyData, encoding: .utf8) {
                print(jsonString)
            }
        }

        let decoded = try JSONDecoder().decode(GenerateImagesResponse.self, from: responseData)

        return decoded
    }

    private func truncateLongStringsInJSONObject(_ object: Any, maxLength: Int = 100) -> Any {
        switch object {
        case let dict as [String: Any]:
            return dict.mapValues { truncateLongStringsInJSONObject($0, maxLength: maxLength) }
        case let array as [Any]:
            return array.map { truncateLongStringsInJSONObject($0, maxLength: maxLength) }
        case let string as String where string.count > maxLength:
            let prefix = string.prefix(maxLength)
            return "\(prefix)... [\(string.count) chars truncated]"
        default:
            return object
        }
    }

}
