//
//  Types+Images.swift
//  SwiftGenAI
//
//  Created by Jolon on 20/7/2025.
//

import Foundation

/// Safety attributes of a GeneratedImage or the user-provided prompt.
public struct SafetyAttributes: Codable, Sendable {
    /// List of RAI categories.
    public let categories: [String]?
    /// List of scores for each category.
    public let scores: [Double]?
    /// Internal use only.
    public let contentType: String?
    
    public init(categories: [String]? = nil, scores: [Double]? = nil, contentType: String? = nil) {
        self.categories = categories
        self.scores = scores
        self.contentType = contentType
    }
}

/// An output image. This is very different to GeneratedImage in the JS GenAI SDK as the actual API returns a different object.
public struct GeneratedImage: Codable, Sendable {
    
    public let mimeType: String?
    public let bytesBase64Encoded: Data?
    
    public init(mimeType: String? = nil, bytesBase64Encoded: Data? = nil) {
        self.mimeType = mimeType
        self.bytesBase64Encoded = bytesBase64Encoded
    }
}

/// The output images response.
public struct GenerateImagesResponse: Codable, Sendable {
    /// List of generated images - the API docs and JS SDK call this generatedImages, but the API returns predictions
    public let predictions: [GeneratedImage]?
    /// Safety attributes of the positive prompt. Only populated if `includeSafetyAttributes` is set to true.
    public let positivePromptSafetyAttributes: SafetyAttributes?
    
    public init(predictions: [GeneratedImage]? = nil, positivePromptSafetyAttributes: SafetyAttributes? = nil) {
        self.predictions = predictions
        self.positivePromptSafetyAttributes = positivePromptSafetyAttributes
    }
}


/// This object will be sent in the Http Request
public struct GenerateImagesParameters: Encodable, Sendable {
    // Contains prompt
    let instances: [ImageInstance]
    // Optional config
    let parameters: GenerateImagesConfig?
}

/// Prompt for GenerateImagesParameters
public struct ImageInstance: Encodable, Sendable {
    let prompt: String
}

/// The config for generating images.
public struct GenerateImagesConfig: Codable, Sendable {
    /// Used to override HTTP request options.
    public var httpOptions: HttpOptions?
    /// Cloud Storage URI used to store the generated images.
    public var outputGcsUri: String?
    /// Description of what to discourage in the generated images.
    public var negativePrompt: String?
    /// Number of images to generate.
    public var numberOfImages: Int?
    /// Aspect ratio of the generated images. Supported values: "1:1", "3:4", "4:3", "9:16", and "16:9".
    public var aspectRatio: String?
    /// Controls how much the model adheres to the text prompt. Larger values increase prompt alignment but may affect quality.
    public var guidanceScale: Double?
    /// Random seed for image generation. Not available when addWatermark is true.
    public var seed: Int?
    /// Filter level for safety filtering.
    public var safetyFilterLevel: SafetyFilterLevel?
    /// Allows generation of people by the model.
    public var personGeneration: PersonGeneration?
    /// Whether to report the safety scores of each generated image and the positive prompt in the response.
    public var includeSafetyAttributes: Bool?
    /// Whether to include the Responsible AI filter reason if the image is filtered from the response.
    public var includeRaiReason: Bool?
    /// Language of the text in the prompt.
    public var language: ImagePromptLanguage?
    /// MIME type of the generated image.
    public var outputMimeType: String?
    /// Compression quality of the generated image (for image/jpeg only).
    public var outputCompressionQuality: Int?
    /// Whether to add a watermark to the generated images.
    public var addWatermark: Bool?
    /// Whether to use the prompt rewriting logic.
    public var enhancePrompt: Bool?
    
    public init(
        httpOptions: HttpOptions? = nil,
        outputGcsUri: String? = nil,
        negativePrompt: String? = nil,
        numberOfImages: Int? = nil,
        aspectRatio: String? = nil,
        guidanceScale: Double? = nil,
        seed: Int? = nil,
        safetyFilterLevel: SafetyFilterLevel? = nil,
        personGeneration: PersonGeneration? = nil,
        includeSafetyAttributes: Bool? = nil,
        includeRaiReason: Bool? = nil,
        language: ImagePromptLanguage? = nil,
        outputMimeType: String? = nil,
        outputCompressionQuality: Int? = nil,
        addWatermark: Bool? = nil,
        enhancePrompt: Bool? = nil
    ) {
        self.httpOptions = httpOptions
        self.outputGcsUri = outputGcsUri
        self.negativePrompt = negativePrompt
        self.numberOfImages = numberOfImages
        self.aspectRatio = aspectRatio
        self.guidanceScale = guidanceScale
        self.seed = seed
        self.safetyFilterLevel = safetyFilterLevel
        self.personGeneration = personGeneration
        self.includeSafetyAttributes = includeSafetyAttributes
        self.includeRaiReason = includeRaiReason
        self.language = language
        self.outputMimeType = outputMimeType
        self.outputCompressionQuality = outputCompressionQuality
        self.addWatermark = addWatermark
        self.enhancePrompt = enhancePrompt
    }
}

// Placeholder enums for fields present in the config.
public enum SafetyFilterLevel: String, Codable, Sendable {
    /// Block low-severity and above objectionable content.
    case blockLowAndAbove = "BLOCK_LOW_AND_ABOVE"
    /// Block medium-severity and above objectionable content.
    case blockMediumAndAbove = "BLOCK_MEDIUM_AND_ABOVE"
    /// Block only high-severity objectionable content.
    case blockOnlyHigh = "BLOCK_ONLY_HIGH"
    /// Do not block objectionable content.
    case blockNone = "BLOCK_NONE"
}

public enum PersonGeneration: String, Codable, Sendable {
    /// Block generation of images of people.
    case dontAllow = "DONT_ALLOW"
    /// Generate images of adults, but not children.
    case allowAdult = "ALLOW_ADULT"
    /// Generate images that include adults and children.
    case allowAll = "ALLOW_ALL"
}

public enum ImagePromptLanguage: String, Codable, Sendable {
    /// Auto-detect the language.
    case auto = "auto"
    /// English
    case en = "en"
    /// Japanese
    case ja = "ja"
    /// Korean
    case ko = "ko"
    /// Hindi
    case hi = "hi"
    /// Chinese
    case zh = "zh"
    /// Portuguese
    case pt = "pt"
    /// Spanish
    case es = "es"
}

