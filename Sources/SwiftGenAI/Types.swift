// Types.swift
// Common parameter and config types for GenAI
//
// This file is very large and was created by mostly converting the JS equivalents one by one using ChatGPT.
// The order in the file could be improved and perhaps split into smaller files. Additionally some of the
// structs lack inits, which should be added.


import Foundation

public struct Content: Codable, Sendable {
    public var parts: [Part]
    public var role: String? = nil

    public init(parts: [Part], role: String? = nil) {
        self.parts = parts
        self.role = role
    }
}

public enum Part: Codable, Sendable {
    case videoMetadata(VideoMetadata)
    case thought(Bool)
    case inlineData(Blob)
    case fileData(FileData)
    case thoughtSignature(String)
    case codeExecutionResult(CodeExecutionResult)
    case executableCode(ExecutableCode)
    case functionCall(FunctionCall)
    case functionResponse(FunctionResponse)
    case text(String)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .videoMetadata(let value):
            try container.encode(value, forKey: .videoMetadata)
        case .thought(let value):
            try container.encode(value, forKey: .thought)
        case .inlineData(let value):
            try container.encode(value, forKey: .inlineData)
        case .fileData(let value):
            try container.encode(value, forKey: .fileData)
        case .thoughtSignature(let value):
            try container.encode(value, forKey: .thoughtSignature)
        case .codeExecutionResult(let value):
            try container.encode(value, forKey: .codeExecutionResult)
        case .executableCode(let value):
            try container.encode(value, forKey: .executableCode)
        case .functionCall(let value):
            try container.encode(value, forKey: .functionCall)
        case .functionResponse(let value):
            try container.encode(value, forKey: .functionResponse)
        case .text(let value):
            try container.encode(value, forKey: .text)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(String.self, forKey: .text) {
            self = .text(value)
            return
        } else if let value = try container.decodeIfPresent(VideoMetadata.self, forKey: .videoMetadata) {
            self = .videoMetadata(value)
            return
        } else if let value = try container.decodeIfPresent(Bool.self, forKey: .thought) {
            self = .thought(value)
            return
        } else if let value = try container.decodeIfPresent(Blob.self, forKey: .inlineData) {
            self = .inlineData(value)
            return
        } else if let value = try container.decodeIfPresent(FileData.self, forKey: .fileData) {
            self = .fileData(value)
            return
        } else if let value = try container.decodeIfPresent(String.self, forKey: .thoughtSignature) {
            self = .thoughtSignature(value)
            return
        } else if let value = try container.decodeIfPresent(CodeExecutionResult.self, forKey: .codeExecutionResult) {
            self = .codeExecutionResult(value)
            return
        } else if let value = try container.decodeIfPresent(ExecutableCode.self, forKey: .executableCode) {
            self = .executableCode(value)
            return
        } else if let value = try container.decodeIfPresent(FunctionCall.self, forKey: .functionCall) {
            self = .functionCall(value)
            return
        } else if let value = try container.decodeIfPresent(FunctionResponse.self, forKey: .functionResponse) {
            self = .functionResponse(value)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Could not decode Part from known cases"))
    }

    private enum CodingKeys: String, CodingKey {
        case videoMetadata
        case thought
        case inlineData
        case fileData
        case thoughtSignature
        case codeExecutionResult
        case executableCode
        case functionCall
        case functionResponse
        case text
    }
}

/// This object will be sent in the Http Request
public struct GenerateContentParameters: Encodable, Sendable {
    let contents: [Content]
    
    // Optional
    let generationConfig: GenerateContentConfig?
    
    // Pulled up from GenerateContentConfig
    let systemInstruction: Content?
    let safetySettings: [SafetySetting]?
    let tools: [Tool]?
    let toolConfig: ToolConfig?
    let cachedContent: String?
}


/// Optional model configuration parameters for content generation.
public struct GenerateContentConfig: Encodable, Sendable {
    public let httpOptions: HttpOptions?
    public let temperature: Double?
    public let topP: Double?
    public let topK: Int?
    public let candidateCount: Int?
    public let maxOutputTokens: Int?
    public let stopSequences: [String]?
    public let responseLogprobs: Bool?
    public let logprobs: Int?
    public let presencePenalty: Double?
    public let frequencyPenalty: Double?
    public let seed: Int?
    public let responseMimeType: String?
    public let responseSchema: Schema?
    public let responseJsonSchema: Data? // Change type if you define more
    public let routingConfig: GenerationConfigRoutingConfig?
    public let modelSelectionConfig: ModelSelectionConfig?
    public let labels: [String: String]?
    public let responseModalities: [Modality]?
    public let mediaResolution: MediaResolution?
    public let speechConfig: SpeechConfig?
    public let audioTimestamp: Bool?
    public let automaticFunctionCalling: AutomaticFunctionCallingConfig?
    public let thinkingConfig: ThinkingConfig?

    // These members won't be encoded in this object, but stored in the parent
    public let systemInstruction: Content?
    public let safetySettings: [SafetySetting]?
    public let tools: [Tool]?
    public let toolConfig: ToolConfig?
    public let cachedContent: String?
    
    private enum CodingKeys: String, CodingKey {
        case httpOptions
        case temperature
        case topP
        case topK
        case candidateCount
        case maxOutputTokens
        case stopSequences
        case responseLogprobs
        case logprobs
        case presencePenalty
        case frequencyPenalty
        case seed
        case responseMimeType
        case responseSchema
        case responseJsonSchema
        case responseModalities
        case mediaResolution
        case speechConfig
        case automaticFunctionCalling
        case thinkingConfig
    }

    public init(
      httpOptions: HttpOptions? = nil,
      temperature: Double? = nil,
      topP: Double? = nil,
      topK: Int? = nil,
      candidateCount: Int? = nil,
      maxOutputTokens: Int? = nil,
      stopSequences: [String]? = nil,
      responseLogprobs: Bool? = nil,
      logprobs: Int? = nil,
      presencePenalty: Double? = nil,
      frequencyPenalty: Double? = nil,
      seed: Int? = nil,
      responseMimeType: String? = nil,
      responseSchema: Schema? = nil,
      responseJsonSchema: Data? = nil,
      routingConfig: GenerationConfigRoutingConfig? = nil,
      modelSelectionConfig: ModelSelectionConfig? = nil,
      labels: [String: String]? = nil,
      responseModalities: [Modality]? = nil,
      mediaResolution: MediaResolution? = nil,
      speechConfig: SpeechConfig? = nil,
      audioTimestamp: Bool? = nil,
      automaticFunctionCalling: AutomaticFunctionCallingConfig? = nil,
      thinkingConfig: ThinkingConfig? = nil,
      systemInstruction: Content? = nil,
      safetySettings: [SafetySetting]? = nil,
      tools: [Tool]? = nil,
      toolConfig: ToolConfig? = nil,
      cachedContent: String? = nil
    ) {
      self.httpOptions = httpOptions
      self.temperature = temperature
      self.topP = topP
      self.topK = topK
      self.candidateCount = candidateCount
      self.maxOutputTokens = maxOutputTokens
      self.stopSequences = stopSequences
      self.responseLogprobs = responseLogprobs
      self.logprobs = logprobs
      self.presencePenalty = presencePenalty
      self.frequencyPenalty = frequencyPenalty
      self.seed = seed
      self.responseMimeType = responseMimeType
      self.responseSchema = responseSchema
      self.responseJsonSchema = responseJsonSchema
      self.routingConfig = routingConfig
      self.modelSelectionConfig = modelSelectionConfig
      self.labels = labels
      self.responseModalities = responseModalities
      self.mediaResolution = mediaResolution
      self.speechConfig = speechConfig
      self.audioTimestamp = audioTimestamp
      self.automaticFunctionCalling = automaticFunctionCalling
      self.thinkingConfig = thinkingConfig
      self.systemInstruction = systemInstruction
      self.safetySettings = safetySettings
      self.tools = tools
      self.toolConfig = toolConfig
      self.cachedContent = cachedContent
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let httpOptions = httpOptions { try container.encode(httpOptions, forKey: .httpOptions) }
        if let temperature = temperature { try container.encode(temperature, forKey: .temperature) }
        if let topP = topP { try container.encode(topP, forKey: .topP) }
        if let topK = topK { try container.encode(topK, forKey: .topK) }
        if let candidateCount = candidateCount { try container.encode(candidateCount, forKey: .candidateCount) }
        if let maxOutputTokens = maxOutputTokens { try container.encode(maxOutputTokens, forKey: .maxOutputTokens) }
        if let stopSequences = stopSequences { try container.encode(stopSequences, forKey: .stopSequences) }
        if let responseLogprobs = responseLogprobs { try container.encode(responseLogprobs, forKey: .responseLogprobs) }
        if let logprobs = logprobs { try container.encode(logprobs, forKey: .logprobs) }
        if let presencePenalty = presencePenalty { try container.encode(presencePenalty, forKey: .presencePenalty) }
        if let frequencyPenalty = frequencyPenalty { try container.encode(frequencyPenalty, forKey: .frequencyPenalty) }
        if let seed = seed { try container.encode(seed, forKey: .seed) }
        if let responseMimeType = responseMimeType { try container.encode(responseMimeType, forKey: .responseMimeType) }
        if let responseSchema = responseSchema { try container.encode(responseSchema, forKey: .responseSchema) }
        if let responseJsonSchema = responseJsonSchema { try container.encode(responseJsonSchema, forKey: .responseJsonSchema) }
        if let responseModalities = responseModalities { try container.encode(responseModalities, forKey: .responseModalities) }
        if let mediaResolution = mediaResolution { try container.encode(mediaResolution, forKey: .mediaResolution) }
        if let speechConfig = speechConfig { try container.encode(speechConfig, forKey: .speechConfig) }
        if let automaticFunctionCalling = automaticFunctionCalling { try container.encode(automaticFunctionCalling, forKey: .automaticFunctionCalling) }
        if let thinkingConfig = thinkingConfig { try container.encode(thinkingConfig, forKey: .thinkingConfig) }
    }
    
    /// Checks if encoding this `GenerateContentConfig` instance results in any encoded data.
    ///
    /// This method attempts to encode the instance into JSON and decodes it back into a dictionary.
    /// It then returns true if the resulting dictionary contains any key-value pairs, indicating
    /// that there is at least some data encoded. Returns false if encoding or decoding fails or
    /// if the encoded dictionary is empty.
    public func encodesAnyValue() -> Bool {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let dict = jsonObject as? [String: Any], !dict.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}



indirect public enum SchemaNode: Codable, Sendable {
    case schema(Schema)
}

/// Schema is used to define the format of input/output data.
/// Represents a select subset of an OpenAPI 3.0 schema object.
public struct Schema: Codable, Sendable {
    /// The value should be validated against any (one or more) of the subschemas in the list.
    public let anyOf: [SchemaNode]?
    /// Default value of the data.
    public let defaultValue: AnyCodable?
    /// The description of the data.
    public let description: String?
    /// Possible values for primitive types with enum format.
    public let enumValues: [String]?
    /// Example of the object. Only populated when the object is the root.
    public let example: AnyCodable?
    /// The format of the data (e.g., "float", "email").
    public let format: String?
    /// For arrays, the schema of the item elements.
    public let items: SchemaNode?
    /// Maximum number of elements for arrays.
    public let maxItems: String?
    /// Maximum length for strings.
    public let maxLength: String?
    /// Maximum number of properties for objects.
    public let maxProperties: String?
    /// Maximum value for integer/number types.
    public let maximum: Double?
    /// Minimum number of elements for arrays.
    public let minItems: String?
    /// Minimum length for strings.
    public let minLength: String?
    /// Minimum number of properties for objects.
    public let minProperties: String?
    /// Minimum value for integer/number types.
    public let minimum: Double?
    /// Indicates if the value may be null.
    public let nullable: Bool?
    /// Pattern for strings (regexp).
    public let pattern: String?
    /// Properties of object types.
    public let properties: [String: SchemaNode]?
    /// Order of the properties (non-standard).
    public let propertyOrdering: [String]?
    /// Required properties of object types.
    public let required: [String]?
    /// The title of the schema.
    public let title: String?
    /// The type of the data (see the `Type` enum below / to be defined).
    public let type: SchemaType?

    public enum CodingKeys: String, CodingKey {
        case anyOf, defaultValue = "default", description, enumValues = "enum", example, format, items, maxItems, maxLength, maxProperties, maximum, minItems, minLength, minProperties, minimum, nullable, pattern, properties, propertyOrdering, required, title, type
    }
}

// /** Optional. The type of the data. */
public enum SchemaType: String, Codable, Sendable {
    /** Not specified, should not be used. */
    case unspecified = "TYPE_UNSPECIFIED"
    /** OpenAPI string type */
    case string = "STRING"
    /** OpenAPI number type */
    case number = "NUMBER"
    /** OpenAPI integer type */
    case integer = "INTEGER"
    /** OpenAPI boolean type */
    case boolean = "BOOLEAN"
    /** OpenAPI array type */
    case array = "ARRAY"
    /** OpenAPI object type */
    case object = "OBJECT"
    /** Null type */
    case null = "NULL"
}

public struct VideoMetadata: Codable, Sendable {
    let fps: Double?
    let endOffset: String?
    let startOffset: String?

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let fps = fps {
            try container.encode(fps, forKey: .fps)
        }
        if let endOffset = endOffset {
            try container.encode(endOffset, forKey: .endOffset)
        }
        if let startOffset = startOffset {
            try container.encode(startOffset, forKey: .startOffset)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case fps
        case endOffset
        case startOffset
    }
}

public struct Blob: Codable, Sendable {
    public let displayName: String?
    public let data: Data?
    public let mimeType: String?

    public init(displayName: String? = nil, data: Data? = nil, mimeType: String? = nil) {
        self.displayName = displayName
        self.data = data
        self.mimeType = mimeType
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let data = data {
            try container.encode(data, forKey: .data)
        }
        if let mimeType = mimeType {
            try container.encode(mimeType, forKey: .mimeType)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.displayName = nil
        self.data = try container.decodeIfPresent(Data.self, forKey: .data)
        self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
    }

    private enum CodingKeys: String, CodingKey {
        case data
        case mimeType
    }
}

public struct FileData: Codable, Sendable {
    let displayName: String?
    let fileUri: String?
    let mimeType: String?

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let fileUri = fileUri {
            try container.encode(fileUri, forKey: .fileUri)
        }
        if let mimeType = mimeType {
            try container.encode(mimeType, forKey: .mimeType)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.displayName = nil
        self.fileUri = try container.decodeIfPresent(String.self, forKey: .fileUri)
        self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
    }

    private enum CodingKeys: String, CodingKey {
        case fileUri
        case mimeType
    }
}

public struct CodeExecutionResult: Codable, Sendable {
    let outcome: Outcome?
    let output: String?
}

public enum Outcome: String, Codable, Sendable {
    /// Unspecified status. This value should not be used.
    case unspecified = "OUTCOME_UNSPECIFIED"
    /// Code execution completed successfully.
    case ok = "OUTCOME_OK"
    /// Code execution finished but with a failure. `stderr` should contain the reason.
    case failed = "OUTCOME_FAILED"
    /// Code execution ran for too long, and was cancelled. There may or may not be a partial output present.
    case deadlineExceeded = "OUTCOME_DEADLINE_EXCEEDED"
}

// Language is now available for use in ExecutableCode and related types.
public struct ExecutableCode: Codable, Sendable {
    let code: String?
    let language: Language?
}

public enum Language: String, Codable, Sendable {
    /// Unspecified language. This value should not be used.
    case unspecified = "LANGUAGE_UNSPECIFIED"
    /// Python >= 3.10, with numpy and simpy available.
    case python = "PYTHON"
}

public struct FunctionCall: Codable, Sendable {
    /// The unique id of the function call.
    public let id: String?
    /// The function parameters and values in JSON object format.
    public let args: [String: AnyCodable]?
    /// The name of the function to call.
    public let name: String?
}

/// Type of auth scheme.
public enum AuthType: String, Codable, Sendable {
    /// The auth type is unspecified.
    case unspecified = "AUTH_TYPE_UNSPECIFIED"
    /// No Auth.
    case noAuth = "NO_AUTH"
    /// API Key Auth.
    case apiKeyAuth = "API_KEY_AUTH"
    /// HTTP Basic Auth.
    case httpBasicAuth = "HTTP_BASIC_AUTH"
    /// Google Service Account Auth.
    case googleServiceAccountAuth = "GOOGLE_SERVICE_ACCOUNT_AUTH"
    /// OAuth auth.
    case oauth = "OAUTH"
    /// OpenID Connect (OIDC) Auth.
    case oidcAuth = "OIDC_AUTH"
}


/// A function response, converted from the provided TypeScript definition.

public struct FunctionResponse: Codable, Sendable {
    /// Signals that function call continues, and more responses will be returned.
    public let willContinue: Bool?
    /// Specifies how the response should be scheduled in the conversation.
    public let scheduling: FunctionResponseScheduling?
    /// Optional. The id of the function call this response is for.
    public let id: String?
    /// Required. The name of the function to call.
    public let name: String?
    /// Required. The function response in JSON object format.
    public let response: [String: AnyCodable]?
    
    public init(willContinue: Bool? = nil, scheduling: FunctionResponseScheduling? = nil, id: String? = nil, name: String? = nil, response: [String: AnyCodable]? = nil) {
        self.willContinue = willContinue
        self.scheduling = scheduling
        self.id = id
        self.name = name
        self.response = response
    }
}

/// Specifies how the response should be scheduled in the conversation.
public enum FunctionResponseScheduling: String, Codable, Sendable {
    /**
     * This value is unused.
     */
    case schedulingUnspecified = "SCHEDULING_UNSPECIFIED"
    /**
     * Only add the result to the conversation context, do not interrupt or trigger generation.
     */
    case silent = "SILENT"
    /**
     * Add the result to the conversation context, and prompt to generate output without interrupting ongoing generation.
     */
    case whenIdle = "WHEN_IDLE"
    /**
     * Add the result to the conversation context, interrupt ongoing generation and prompt to generate output.
     */
    case interrupt = "INTERRUPT"
}


// MARK: - AnyCodable implementation

/// Fully type-safe, enum-based AnyCodable, for a restrictive, Sendable-safe value container.
public enum AnyCodable: Codable, Sendable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case array([AnyCodable])
    case dictionary([String: AnyCodable])
    case null

    // Initializers for each case
    public init(_ value: Int) { self = .int(value) }
    public init(_ value: Double) { self = .double(value) }
    public init(_ value: Bool) { self = .bool(value) }
    public init(_ value: String) { self = .string(value) }
    public init(_ value: [AnyCodable]) { self = .array(value) }
    public init(_ value: [String: AnyCodable]) { self = .dictionary(value) }
    public init(_ value: Void) { self = .null }
    
    // Decoding logic: matches cases by type
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self = .array(array)
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self = .dictionary(dict)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    // Encoding logic: encodes the raw value
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
    
    // Convenience property for extracting value
    public var value: Any {
        switch self {
        case .int(let v): return v
        case .double(let v): return v
        case .bool(let v): return v
        case .string(let v): return v
        case .array(let v): return v
        case .dictionary(let v): return v
        case .null: return ()
        }
    }
}

/// Optional. Specify if the threshold is used for probability or severity score. If not specified, the threshold is used for probability score.
public enum HarmBlockMethod: String, Codable, Sendable {
    case unspecified = "HARM_BLOCK_METHOD_UNSPECIFIED"
    case severity = "SEVERITY"
    case probability = "PROBABILITY"
}

/// Required. Harm category.
public enum HarmCategory: String, Codable, Sendable {
    case unspecified = "HARM_CATEGORY_UNSPECIFIED"
    case hateSpeech = "HARM_CATEGORY_HATE_SPEECH"
    case dangerousContent = "HARM_CATEGORY_DANGEROUS_CONTENT"
    case harassment = "HARM_CATEGORY_HARASSMENT"
    case sexuallyExplicit = "HARM_CATEGORY_SEXUALLY_EXPLICIT"
    case civicIntegrity = "HARM_CATEGORY_CIVIC_INTEGRITY"
    case imageHate = "HARM_CATEGORY_IMAGE_HATE"
    case imageDangerousContent = "HARM_CATEGORY_IMAGE_DANGEROUS_CONTENT"
    case imageHarassment = "HARM_CATEGORY_IMAGE_HARASSMENT"
    case imageSexuallyExplicit = "HARM_CATEGORY_IMAGE_SEXUALLY_EXPLICIT"
}

/// Required. The harm block threshold.
public enum HarmBlockThreshold: String, Codable, Sendable {
    case unspecified = "HARM_BLOCK_THRESHOLD_UNSPECIFIED"
    case blockLowAndAbove = "BLOCK_LOW_AND_ABOVE"
    case blockMediumAndAbove = "BLOCK_MEDIUM_AND_ABOVE"
    case blockOnlyHigh = "BLOCK_ONLY_HIGH"
    case blockNone = "BLOCK_NONE"
    case off = "OFF"
}

/// Safety settings.
public struct SafetySetting: Codable, Sendable {
    /// Determines if the harm block method uses probability or probability and severity scores.
    public let method: HarmBlockMethod?
    /// Required. Harm category.
    public let category: HarmCategory?
    /// Required. The harm block threshold.
    public let threshold: HarmBlockThreshold?
}



/// The media resolution to use.
public enum MediaResolution: String, Codable, Sendable {
    /// Media resolution has not been set
    case unspecified = "MEDIA_RESOLUTION_UNSPECIFIED"
    /// Media resolution set to low (64 tokens).
    case low = "MEDIA_RESOLUTION_LOW"
    /// Media resolution set to medium (256 tokens).
    case medium = "MEDIA_RESOLUTION_MEDIUM"
    /// Media resolution set to high (zoomed reframing with 256 tokens).
    case high = "MEDIA_RESOLUTION_HIGH"
}

/// Tool details of a tool that the model may use to generate a response.
public struct Tool: Codable, Sendable {
    /// List of function declarations that the tool supports.
    public let functionDeclarations: [FunctionDeclaration]?
    /// Optional. Retrieval tool type.
    public let retrieval: Retrieval?
    /// Optional. Google Search tool type.
    public let googleSearch: GoogleSearch?
    /// Optional. GoogleSearchRetrieval tool type.
    public let googleSearchRetrieval: GoogleSearchRetrieval?
    /// Optional. Enterprise web search tool type.
    public let enterpriseWebSearch: EnterpriseWebSearch?
    /// Optional. Google Maps tool type.
    public let googleMaps: GoogleMaps?
    /// Optional. Tool to support URL context retrieval.
    public let urlContext: UrlContext?
    /// Optional. CodeExecution tool type.
    public let codeExecution: ToolCodeExecution?
    /// Optional. Tool to support the model interacting directly with the computer.
    public let computerUse: ToolComputerUse?
    
    public init(
        functionDeclarations: [FunctionDeclaration]? = nil,
        retrieval: Retrieval? = nil,
        googleSearch: GoogleSearch? = nil,
        googleSearchRetrieval: GoogleSearchRetrieval? = nil,
        enterpriseWebSearch: EnterpriseWebSearch? = nil,
        googleMaps: GoogleMaps? = nil,
        urlContext: UrlContext? = nil,
        codeExecution: ToolCodeExecution? = nil,
        computerUse: ToolComputerUse? = nil
    ) {
        self.functionDeclarations = functionDeclarations
        self.retrieval = retrieval
        self.googleSearch = googleSearch
        self.googleSearchRetrieval = googleSearchRetrieval
        self.enterpriseWebSearch = enterpriseWebSearch
        self.googleMaps = googleMaps
        self.urlContext = urlContext
        self.codeExecution = codeExecution
        self.computerUse = computerUse
    }
}

/// Tool that executes code generated by the model, and automatically returns the result to the model.
public struct ToolCodeExecution: Codable, Sendable {}

/// Required. The environment being operated.
public enum Environment: String, Codable, Sendable {
    /// Defaults to browser.
    case unspecified = "ENVIRONMENT_UNSPECIFIED"
    /// Operates in a web browser.
    case browser = "ENVIRONMENT_BROWSER"
}

/// Tool to support computer use.
public struct ToolComputerUse: Codable, Sendable {
    /// Required. The environment being operated.
    public let environment: Environment?
}

/// Tool to support Google Maps in Model.
public struct GoogleMaps: Codable, Sendable {
    /// Optional. Auth config for the Google Maps tool.
    public let authConfig: AuthConfig?
}

/// Tool to support URL context retrieval.
public struct UrlContext: Codable, Sendable {}

/// Represents a time interval, encoded as a start time (inclusive) and an end time (exclusive).
public struct Interval: Codable, Sendable {
    /// The start time of the interval.
    public let startTime: String?
    /// The end time of the interval.
    public let endTime: String?
}

/// Tool to support Google Search in Model. Powered by Google.
public struct GoogleSearch: Codable, Sendable {
    /// Optional. Filter search results to a specific time range.
    public let timeRangeFilter: Interval?
    
    public init(timeRangeFilter: Interval? = nil) {
        self.timeRangeFilter = timeRangeFilter
    }

}

/// Routing preference for auto routing mode.
public enum ModelRoutingPreference: String, Codable, Sendable {
    case unknown = "UNKNOWN"
    case prioritizeQuality = "PRIORITIZE_QUALITY"
    case balanced = "BALANCED"
    case prioritizeCost = "PRIORITIZE_COST"
}

/// When automated routing is specified, the routing will be determined by the pretrained routing model and customer provided model routing preference.
public struct GenerationConfigRoutingConfigAutoRoutingMode: Codable, Sendable {
    /// The model routing preference.
    public let modelRoutingPreference: ModelRoutingPreference?
}

/// When manual routing is set, the routing will be determined by the pretrained routing model and customer provided model routing preference.
public struct GenerationConfigRoutingConfigManualRoutingMode: Codable, Sendable {
    /// The model name to use. Only the public LLM models are accepted.
    public let modelName: String?
}

/// The configuration for routing the request to a specific model.
public struct GenerationConfigRoutingConfig: Codable, Sendable {
    /// Automated routing.
    public let autoMode: GenerationConfigRoutingConfigAutoRoutingMode?
    /// Manual routing.
    public let manualMode: GenerationConfigRoutingConfigManualRoutingMode?
}

/// Options for feature selection preference.
public enum FeatureSelectionPreference: String, Codable, Sendable {
    case unspecified = "FEATURE_SELECTION_PREFERENCE_UNSPECIFIED"
    case prioritizeQuality = "PRIORITIZE_QUALITY"
    case balanced = "BALANCED"
    case prioritizeCost = "PRIORITIZE_COST"
}

/// Config for model selection.
public struct ModelSelectionConfig: Codable, Sendable {
    /// Options for feature selection preference.
    public let featureSelectionPreference: FeatureSelectionPreference?
}

/// Supported HTTP methods for requests
public enum HTTPMethod: String {
    case GET, POST, PATCH, DELETE
}

/// HTTP options for configuring requests
/// Safe for Sendable because all properties are value types or immutable.
public struct HttpOptions: Codable, Sendable {
    /// API version to use for the request
    public var apiVersion: String?
    /// Base URL for the request
    public var baseUrl: String?
    /// Headers to include in the request
    public var headers: [String: String]?
    /// Timeout interval for the request (in seconds)
    public var timeout: TimeInterval?
    /// Extra JSON body content to merge or add to the request body
    public var extraBody: [String: AnyCodable]?
}

/// Represents an HTTP request for the API client
public struct HttpRequest {
    public let path: String
    public let httpMethod: HTTPMethod
    public let body: Data?
    public let queryParams: [String: String]?
    public let httpOptions: HttpOptions?

    public init(path: String, httpMethod: HTTPMethod, body: Data? = nil, queryParams: [String: String]? = nil, httpOptions: HttpOptions? = nil) {
        self.path = path
        self.httpMethod = httpMethod
        self.body = body
        self.queryParams = queryParams
        self.httpOptions = httpOptions
    }
}

/// Represents an HTTP response for the API client
public struct HttpResponse: Sendable {
    public let statusCode: Int
    public let headers: [String: String]
    public let body: Data?
}


/// Defines the function behavior. Defaults to BLOCKING.
public enum Behavior: String, Codable, Sendable {
    /// This value is unused.
    case unspecified = "UNSPECIFIED"
    /// System waits for function response before continuing.
    case blocking = "BLOCKING"
    /// System does not wait for function response, handles responses as available.
    case nonBlocking = "NON_BLOCKING"
}

/// Defines a function that the model can generate JSON inputs for.
public struct FunctionDeclaration: Codable, Sendable {
    /// Defines the function behavior.
    public let behavior: Behavior?
    /// Optional. Description and purpose of the function.
    public let description: String?
    /// Required. The name of the function to call.
    public let name: String?
    /// Optional. Describes the parameters to this function in JSON Schema Object format.
    public let parameters: Schema?
    /// Optional. Describes the parameters to the function in JSON Schema format. Mutually exclusive with `parameters`.
    public let parametersJsonSchema: AnyCodable?
    /// Optional. Describes the output from this function in JSON Schema format (Schema type).
    public let response: Schema?
    /// Optional. Describes the output from this function in JSON Schema format. Mutually exclusive with `response`.
    public let responseJsonSchema: AnyCodable?
}


/// The API secret.
public struct ApiAuthApiKeyConfig: Codable, Sendable {
    /// Required. The SecretManager secret version resource name storing API key.
    public let apiKeySecretVersion: String?
    /// The API key string. Either this or `api_key_secret_version` must be set.
    public let apiKeyString: String?
}

/// The generic reusable api auth config. Deprecated.
public struct ApiAuth: Codable, Sendable {
    /// The API secret.
    public let apiKeyConfig: ApiAuthApiKeyConfig?
}

/// Config for authentication with API key.
public struct ApiKeyConfig: Codable, Sendable {
    /// The API key to be used in the request directly.
    public let apiKeyString: String?
}

/// Config for Google Service Account Authentication.
public struct AuthConfigGoogleServiceAccountConfig: Codable, Sendable {
    /// The service account that the extension execution service runs as.
    public let serviceAccount: String?
}

/// Config for HTTP Basic Authentication.
public struct AuthConfigHttpBasicAuthConfig: Codable, Sendable {
    /// The name of the SecretManager secret version resource storing the base64 encoded credentials.
    public let credentialSecret: String?
}

/// Config for user oauth.
public struct AuthConfigOauthConfig: Codable, Sendable {
    /// Access token for extension endpoint.
    public let accessToken: String?
    /// The service account used to generate access tokens for executing the Extension.
    public let serviceAccount: String?
}

/// Config for user OIDC auth.
public struct AuthConfigOidcConfig: Codable, Sendable {
    /// OpenID Connect formatted ID token for extension endpoint.
    public let idToken: String?
    /// The service account used to generate an OpenID Connect (OIDC)-compatible JWT token.
    public let serviceAccount: String?
}

/// Auth configuration to run the extension.
public struct AuthConfig: Codable, Sendable {
    /// Config for API key auth.
    public let apiKeyConfig: ApiKeyConfig?
    /// Type of auth scheme.
    public let authType: AuthType?
    /// Config for Google Service Account auth.
    public let googleServiceAccountConfig: AuthConfigGoogleServiceAccountConfig?
    /// Config for HTTP Basic auth.
    public let httpBasicAuthConfig: AuthConfigHttpBasicAuthConfig?
    /// Config for user oauth.
    public let oauthConfig: AuthConfigOauthConfig?
    /// Config for user OIDC auth.
    public let oidcConfig: AuthConfigOidcConfig?
}

/// The API spec that the external API implements.
public enum ApiSpec: String, Codable, Sendable {
    /// Unspecified API spec. This value should not be used.
    case unspecified = "API_SPEC_UNSPECIFIED"
    /// Simple search API spec.
    case simpleSearch = "SIMPLE_SEARCH"
    /// Elastic search API spec.
    case elasticSearch = "ELASTIC_SEARCH"
}

/// The search parameters to use for the ELASTIC_SEARCH spec.
public struct ExternalApiElasticSearchParams: Codable, Sendable {
    /// The ElasticSearch index to use.
    public let index: String?
    /// Optional. Number of hits (chunks) to request.
    public let numHits: Int?
    /// The ElasticSearch search template to use.
    public let searchTemplate: String?
}

/// The search parameters to use for SIMPLE_SEARCH spec.
public struct ExternalApiSimpleSearchParams: Codable, Sendable {}

/// Retrieve from data source powered by external API for grounding.
public struct ExternalApi: Codable, Sendable {
    /// The authentication config to access the API. Deprecated.
    public let apiAuth: ApiAuth?
    /// The API spec that the external API implements.
    public let apiSpec: ApiSpec?
    /// The authentication config to access the API.
    public let authConfig: AuthConfig?
    /// Parameters for the elastic search API.
    public let elasticSearchParams: ExternalApiElasticSearchParams?
    /// The endpoint of the external API.
    public let endpoint: String?
    /// Parameters for the simple search API.
    public let simpleSearchParams: ExternalApiSimpleSearchParams?
}

/// Data store spec for Vertex AI Search.
public struct VertexAISearchDataStoreSpec: Codable, Sendable {
    /// Full resource name of DataStore.
    public let dataStore: String?
    /// Optional. Filter specification.
    public let filter: String?
}

/// Retrieve from Vertex AI Search datastore or engine for grounding.
public struct VertexAISearch: Codable, Sendable {
    /// Specs defining DataStores to be searched.
    public let dataStoreSpecs: [VertexAISearchDataStoreSpec]?
    /// Fully-qualified Vertex AI Search data store resource ID.
    public let datastore: String?
    /// Fully-qualified Vertex AI Search engine resource ID.
    public let engine: String?
    /// Filter strings for the search API.
    public let filter: String?
    /// Number of search results to return per query.
    public let maxResults: Int?
}

/// The definition of the Rag resource.
public struct VertexRagStoreRagResource: Codable, Sendable {
    /// Optional. RagCorpora resource name.
    public let ragCorpus: String?
    /// Optional. rag_file_id.
    public let ragFileIds: [String]?
}

/// Config for filters.
public struct RagRetrievalConfigFilter: Codable, Sendable {
    /// String for metadata filtering.
    public let metadataFilter: String?
    /// Only returns contexts with vector distance smaller than the threshold.
    public let vectorDistanceThreshold: Double?
    /// Only returns contexts with vector similarity larger than the threshold.
    public let vectorSimilarityThreshold: Double?
}

/// Config for Hybrid Search.
public struct RagRetrievalConfigHybridSearch: Codable, Sendable {
    /// Alpha value controls the weight between dense and sparse vector search results.
    public let alpha: Double?
}

/// Config for LlmRanker.
public struct RagRetrievalConfigRankingLlmRanker: Codable, Sendable {
    /// The model name used for ranking.
    public let modelName: String?
}

/// Config for Rank Service.
public struct RagRetrievalConfigRankingRankService: Codable, Sendable {
    /// The model name of the rank service.
    public let modelName: String?
}

/// Config for ranking and reranking.
public struct RagRetrievalConfigRanking: Codable, Sendable {
    /// Config for LlmRanker.
    public let llmRanker: RagRetrievalConfigRankingLlmRanker?
    /// Config for Rank Service.
    public let rankService: RagRetrievalConfigRankingRankService?
}

/// Specifies the context retrieval config.
public struct RagRetrievalConfig: Codable, Sendable {
    /// Config for filters.
    public let filter: RagRetrievalConfigFilter?
    /// Config for Hybrid Search.
    public let hybridSearch: RagRetrievalConfigHybridSearch?
    /// Config for ranking and reranking.
    public let ranking: RagRetrievalConfigRanking?
    /// The number of contexts to retrieve.
    public let topK: Int?
}

/// Retrieve from Vertex RAG Store for grounding.
public struct VertexRagStore: Codable, Sendable {
    /// Deprecated. Please use rag_resources instead.
    public let ragCorpora: [String]?
    /// Representation of the rag source. Supports one corpus or multiple files from one corpus.
    public let ragResources: [VertexRagStoreRagResource]?
    /// The retrieval config for the Rag query.
    public let ragRetrievalConfig: RagRetrievalConfig?
    /// Number of top k results to return from the selected corpora.
    public let similarityTopK: Int?
    /// Only supported for Gemini Multimodal Live API.
    public let storeContext: Bool?
    /// Only return results with vector distance smaller than the threshold.
    public let vectorDistanceThreshold: Double?
}

/// Defines a retrieval tool that model can call to access external knowledge.
public struct Retrieval: Codable, Sendable {
    /// Deprecated. This option is no longer supported.
    public let disableAttribution: Bool?
    /// Use data source powered by external API for grounding.
    public let externalApi: ExternalApi?
    /// Set to use data source powered by Vertex AI Search.
    public let vertexAiSearch: VertexAISearch?
    /// Set to use data source powered by Vertex RAG store.
    public let vertexRagStore: VertexRagStore?
}

/// Describes the options to customize dynamic retrieval.

/// Config for the dynamic retrieval config mode.
public enum DynamicRetrievalConfigMode: String, Codable, Sendable {
    /// Always trigger retrieval.
    case unspecified = "MODE_UNSPECIFIED"
    /// Run retrieval only when system decides it is necessary.
    case dynamic = "MODE_DYNAMIC"
}

public struct DynamicRetrievalConfig: Codable, Sendable {
    /// The mode of the predictor to be used in dynamic retrieval.
    public let mode: DynamicRetrievalConfigMode?
    /// Optional. The threshold to be used in dynamic retrieval. If not set, a system default value is used.
    public let dynamicThreshold: Double?
}

/// Tool to retrieve public web data for grounding, powered by Google.
public struct GoogleSearchRetrieval: Codable, Sendable {
    /// Specifies the dynamic retrieval configuration for the given source.
    public let dynamicRetrievalConfig: DynamicRetrievalConfig?
}

/// Tool to search public web data, powered by Vertex AI Search and Sec4 compliance.
public struct EnterpriseWebSearch: Codable, Sendable {}


/// Config for the function calling config mode.
public enum FunctionCallingConfigMode: String, Codable, Sendable {
    /// The function calling config mode is unspecified. Should not be used.
    case unspecified = "MODE_UNSPECIFIED"
    /// Default model behavior, model decides to predict either function calls or natural language response.
    case auto = "AUTO"
    /// Model is constrained to always predicting function calls only.
    case any = "ANY"
    /// Model will not predict any function calls.
    case none = "NONE"
}

/// Function calling config.
public struct FunctionCallingConfig: Codable, Sendable {
    /// Optional. Function calling mode.
    public let mode: FunctionCallingConfigMode?
    /// Optional. Function names to call. Only set when the Mode is ANY.
    public let allowedFunctionNames: [String]?
}

/// An object that represents a latitude/longitude pair.
public struct LatLng: Codable, Sendable {
    /// The latitude in degrees.
    public let latitude: Double?
    /// The longitude in degrees.
    public let longitude: Double?
}

/// Retrieval config.
public struct RetrievalConfig: Codable, Sendable {
    /// Optional. The location of the user.
    public let latLng: LatLng?
    /// The language code of the user.
    public let languageCode: String?
}

/// Tool config.
public struct ToolConfig: Codable, Sendable {
    /// Optional. Function calling config.
    public let functionCallingConfig: FunctionCallingConfig?
    /// Optional. Retrieval config.
    public let retrievalConfig: RetrievalConfig?
}


/// The configuration for the prebuilt speaker to use.
public struct PrebuiltVoiceConfig: Codable, Sendable {
    /// The name of the prebuilt voice to use.
    public let voiceName: String?
}

/// The configuration for the voice to use.
public struct VoiceConfig: Codable, Sendable {
    /// The configuration for the speaker to use.
    public let prebuiltVoiceConfig: PrebuiltVoiceConfig?
}

/// The configuration for the speaker to use.
public struct SpeakerVoiceConfig: Codable, Sendable {
    /// The name of the speaker to use. Should be the same as in the prompt.
    public let speaker: String?
    /// The configuration for the voice to use.
    public let voiceConfig: VoiceConfig?
}

/// The configuration for the multi-speaker setup.
public struct MultiSpeakerVoiceConfig: Codable, Sendable {
    /// The configuration for the speaker to use.
    public let speakerVoiceConfigs: [SpeakerVoiceConfig]?
}

/// The speech generation configuration.
public struct SpeechConfig: Codable, Sendable {
    /// The configuration for the speaker to use.
    public let voiceConfig: VoiceConfig?
    /// The configuration for the multi-speaker setup. Mutually exclusive with the voice_config field.
    public let multiSpeakerVoiceConfig: MultiSpeakerVoiceConfig?
    /// Language code (ISO 639. e.g. en-US) for the speech synthesization.
    public let languageCode: String?
}

/// The configuration for automatic function calling.
public struct AutomaticFunctionCallingConfig: Codable, Sendable {
    /// Whether to disable automatic function calling. If not set or set to false, will enable automatic function calling. If set to true, disables automatic function calling.
    public let disable: Bool?
    /// If automatic function calling is enabled, maximum number of remote calls for automatic function calling. Default is 10.
    public let maximumRemoteCalls: Int?
    /// If automatic function calling is enabled, whether to ignore call history to the response. Default is false.
    public let ignoreCallHistory: Bool?
}

/// The thinking features configuration.
public struct ThinkingConfig: Encodable, Sendable {
    /// Indicates whether to include thoughts in the response. If true, thoughts are returned only if the model supports thought and thoughts are available.
    public let includeThoughts: Bool?
    /// Indicates the thinking budget in tokens. 0 is DISABLED. -1 is AUTOMATIC. The default values and allowed ranges are model dependent.
    public let thinkingBudget: Int?
    
    public init(includeThoughts: Bool? = nil, thinkingBudget: Int? = nil) {
        self.includeThoughts = includeThoughts
        self.thinkingBudget = thinkingBudget
    }
}


// MARK: - Content Filtering & Response Types

/// Output only. Blocked reason.
public enum BlockedReason: String, Codable, Sendable {
    /** Unspecified blocked reason. */
    case unspecified = "BLOCKED_REASON_UNSPECIFIED"
    /** Candidates blocked due to safety. */
    case safety = "SAFETY"
    /** Candidates blocked due to other reason. */
    case other = "OTHER"
    /** Candidates blocked due to the terms which are included from the terminology blocklist. */
    case blocklist = "BLOCKLIST"
    /** Candidates blocked due to prohibited content. */
    case prohibitedContent = "PROHIBITED_CONTENT"
    /** Candidates blocked due to unsafe image generation content. */
    case imageSafety = "IMAGE_SAFETY"
}

/// Represents a safety rating (placeholder for actual fields).
public struct SafetyRating: Codable, Sendable {
    /// Output only. Indicates whether the content was filtered out because of this rating.
    public let blocked: Bool?
    /// Output only. Harm category.
    public let category: HarmCategory?
    /// Output only. The overwritten threshold for the safety category.
    public let overwrittenThreshold: HarmBlockThreshold?
    /// Output only. Harm probability levels in the content.
    public let probability: HarmProbability?
    /// Output only. Harm probability score.
    public let probabilityScore: Double?
    /// Output only. Harm severity levels in the content.
    public let severity: HarmSeverity?
    /// Output only. Harm severity score.
    public let severityScore: Double?
}

/// The modality associated with a token count.
public enum MediaModality: String, Codable, Sendable {
    /** The modality is unspecified. */
    case unspecified = "MODALITY_UNSPECIFIED"
    /** Plain text. */
    case text = "TEXT"
    /** Images. */
    case image = "IMAGE"
    /** Video. */
    case video = "VIDEO"
    /** Audio. */
    case audio = "AUDIO"
    /** Document, e.g. PDF. */
    case document = "DOCUMENT"
}

/// Server content modalities.
public enum Modality: String, Codable, Sendable {
    /// The modality is unspecified.
    case unspecified = "MODALITY_UNSPECIFIED"
    /// Indicates the model should return text
    case text = "TEXT"
    /// Indicates the model should return images.
    case image = "IMAGE"
    /// Indicates the model should return audio.
    case audio = "AUDIO"
}

/// Represents token counting info for a single modality.
public struct ModalityTokenCount: Codable, Sendable {
    /// The modality associated with this token count.
    public let modality: MediaModality?
    /// Number of tokens.
    public let tokenCount: Int?
}

/// Output only. Traffic type.
public enum TrafficType: String, Codable, Sendable {
    /** Unspecified request traffic type. */
    case unspecified = "TRAFFIC_TYPE_UNSPECIFIED"
    /** Type for Pay-As-You-Go traffic. */
    case onDemand = "ON_DEMAND"
    /** Type for Provisioned Throughput traffic. */
    case provisionedThroughput = "PROVISIONED_THROUGHPUT"
}

/// Usage metadata about response(s).
public struct GenerateContentResponseUsageMetadata: Codable, Sendable {
    /// Output only. List of modalities of the cached content in the request input.
    public let cacheTokensDetails: [ModalityTokenCount]?
    /// Output only. Number of tokens in the cached part in the input.
    public let cachedContentTokenCount: Int?
    /// Number of tokens in the response(s).
    public let candidatesTokenCount: Int?
    /// Output only. List of modalities that were returned in the response.
    public let candidatesTokensDetails: [ModalityTokenCount]?
    /// Number of tokens in the request input (including cached content).
    public let promptTokenCount: Int?
    /// Output only. List of modalities that were processed in the request input.
    public let promptTokensDetails: [ModalityTokenCount]?
    /// Output only. Number of tokens present in thoughts output.
    public let thoughtsTokenCount: Int?
    /// Output only. Number of tokens present in tool-use prompt(s).
    public let toolUsePromptTokenCount: Int?
    /// Output only. List of modalities processed for tool-use request inputs.
    public let toolUsePromptTokensDetails: [ModalityTokenCount]?
    /// Total token count for prompt, response candidates, and tool-use prompts (if present).
    public let totalTokenCount: Int?
    /// Output only. Traffic type (e.g., PAYG or Provisioned).
    public let trafficType: TrafficType?
}

/// A response candidate generated from the model.
public struct Candidate: Codable, Sendable {
    /// Contains the multi-part content of the response.
    public let content: Content?
    /// Source attribution of the generated content.
    public let citationMetadata: CitationMetadata?
    /// Describes the reason the model stopped generating tokens.
    public let finishMessage: String?
    /// Number of tokens for this candidate.
    public let tokenCount: Int?
    /// The reason why the model stopped generating tokens. If empty, the model has not stopped generating the tokens.
    public let finishReason: FinishReason?
    /// Metadata related to url context retrieval tool.
    public let urlContextMetadata: UrlContextMetadata?
    /// Output only. Average log probability score of the candidate.
    public let avgLogprobs: Double?
    /// Output only. Metadata specifies sources used to ground generated content.
    public let groundingMetadata: GroundingMetadata?
    /// Output only. Index of the candidate.
    public let index: Int?
    /// Output only. Log-likelihood scores for the response tokens and top tokens.
    public let logprobsResult: LogprobsResult?
    /// Output only. List of ratings for the safety of a response candidate. There is at most one rating per category.
    public let safetyRatings: [SafetyRating]?
}

// Replaced definition of CitationMetadata
public struct CitationMetadata: Codable, Sendable {
    /// Contains citation information when the model directly quotes another source.
    public let citations: [Citation]?
}

// Additional types related to CitationMetadata
public struct Citation: Codable, Sendable {
    /// Output only. End index into the content.
    public let endIndex: Int?
    /// Output only. License of the attribution.
    public let license: String?
    /// Output only. Publication date of the attribution.
    public let publicationDate: GoogleTypeDate?
    /// Output only. Start index into the content.
    public let startIndex: Int?
    /// Output only. Title of the attribution.
    public let title: String?
    /// Output only. Url reference of the attribution.
    public let uri: String?
}

public struct GoogleTypeDate: Codable, Sendable {
    /// Day of a month. 1-31, or 0.
    public let day: Int?
    /// Month of a year. 1-12, or 0.
    public let month: Int?
    /// Year of the date. 1-9999, or 0.
    public let year: Int?
}

// Replaced definition of UrlContextMetadata
public struct UrlContextMetadata: Codable, Sendable {
    /// List of url context.
    public let urlMetadata: [UrlMetadata]?
}

// Supporting types for UrlContextMetadata
public struct UrlMetadata: Codable, Sendable {
    /// The URL retrieved by the tool.
    public let retrievedUrl: String?
    /// Status of the url retrieval.
    public let urlRetrievalStatus: UrlRetrievalStatus?
}

public enum UrlRetrievalStatus: String, Codable, Sendable {
    /** Default value. This value is unused */
    case unspecified = "URL_RETRIEVAL_STATUS_UNSPECIFIED"
    /** Url retrieval is successful. */
    case success = "URL_RETRIEVAL_STATUS_SUCCESS"
    /** Url retrieval is failed due to error. */
    case error = "URL_RETRIEVAL_STATUS_ERROR"
}

/// FinishReason replaces the placeholder enum.
public enum FinishReason: String, Codable, Sendable {
    /** The finish reason is unspecified. */
    case unspecified = "FINISH_REASON_UNSPECIFIED"
    /** Token generation reached a natural stopping point or a configured stop sequence. */
    case stop = "STOP"
    /** Token generation reached the configured maximum output tokens. */
    case maxTokens = "MAX_TOKENS"
    /** Token generation stopped because the content potentially contains safety violations. */
    case safety = "SAFETY"
    /** The token generation stopped because of potential recitation. */
    case recitation = "RECITATION"
    /** The token generation stopped because of using an unsupported language. */
    case language = "LANGUAGE"
    /** All other reasons that stopped the token generation. */
    case other = "OTHER"
    /** Token generation stopped because the content contains forbidden terms. */
    case blocklist = "BLOCKLIST"
    /** Token generation stopped for potentially containing prohibited content. */
    case prohibitedContent = "PROHIBITED_CONTENT"
    /** Token generation stopped because the content potentially contains Sensitive Personally Identifiable Information (SPII). */
    case spii = "SPII"
    /** The function call generated by the model is invalid. */
    case malformedFunctionCall = "MALFORMED_FUNCTION_CALL"
    /** Token generation stopped because generated images have safety violations. */
    case imageSafety = "IMAGE_SAFETY"
    /** The tool call generated by the model is invalid. */
    case unexpectedToolCall = "UNEXPECTED_TOOL_CALL"
}

/// GroundingMetadata replaces the placeholder struct.
public struct GroundingMetadata: Codable, Sendable {
    /// List of supporting references retrieved from specified grounding source.
    public let groundingChunks: [GroundingChunk]?
    /// Optional. List of grounding support.
    public let groundingSupports: [GroundingSupport]?
    /// Optional. Output only. Retrieval metadata.
    public let retrievalMetadata: RetrievalMetadata?
    /// Optional. Queries executed by the retrieval tools.
    public let retrievalQueries: [String]?
    /// Optional. Google search entry for following-up web searches.
    public let searchEntryPoint: SearchEntryPoint?
    /// Optional. Web search queries for following-up web search.
    public let webSearchQueries: [String]?
}

// New types added above GroundingChunk

public struct RagChunkPageSpan: Codable, Sendable {
    /// Page where chunk starts in the document. Inclusive. 1-indexed.
    public let firstPage: Int?
    /// Page where chunk ends in the document. Inclusive. 1-indexed.
    public let lastPage: Int?
}

public struct RagChunk: Codable, Sendable {
    /// If populated, represents where the chunk starts and ends in the document.
    public let pageSpan: RagChunkPageSpan?
    /// The content of the chunk.
    public let text: String?
}

public struct GroundingChunkRetrievedContext: Codable, Sendable {
    /// Additional context for the RAG retrieval result.
    public let ragChunk: RagChunk?
    /// Text of the attribution.
    public let text: String?
    /// Title of the attribution.
    public let title: String?
    /// URI reference of the attribution.
    public let uri: String?
}

public struct GroundingChunkWeb: Codable, Sendable {
    /// Domain of the (original) URI.
    public let domain: String?
    /// Title of the chunk.
    public let title: String?
    /// URI reference of the chunk.
    public let uri: String?
}

// Replaced definition of GroundingChunk
public struct GroundingChunk: Codable, Sendable {
    /// Grounding chunk from context retrieved by the retrieval tools.
    public let retrievedContext: GroundingChunkRetrievedContext?
    /// Grounding chunk from the web.
    public let web: GroundingChunkWeb?
}

// Replaced definition of Segment
public struct Segment: Codable, Sendable {
    /// Output only. End index in the given Part, measured in bytes. Offset from the start of the Part, exclusive, starting at zero.
    public let endIndex: Int?
    /// Output only. The index of a Part object within its parent Content object.
    public let partIndex: Int?
    /// Output only. Start index in the given Part, measured in bytes. Offset from the start of the Part, inclusive, starting at zero.
    public let startIndex: Int?
    /// Output only. The text corresponding to the segment from the response.
    public let text: String?
}

public struct GroundingSupport: Codable, Sendable {
    /// Confidence score of the support references. Ranges from 0 to 1.
    public let confidenceScores: [Double]?
    /// A list of indices specifying the citations associated with the claim.
    public let groundingChunkIndices: [Int]?
    /// Segment of the content this support belongs to.
    public let segment: Segment?
}

public struct RetrievalMetadata: Codable, Sendable {
    /// Optional. Score indicating how likely information from Google Search could help answer the prompt.
    public let googleSearchDynamicRetrievalScore: Double?
}

public struct SearchEntryPoint: Codable, Sendable {
    /// Optional. Web content snippet.
    public let renderedContent: String?
    /// Optional. Base64 encoded JSON representing array of tuple.
    public let sdkBlob: String?
}

public struct LogprobsResultCandidate: Codable, Sendable {
    /// The candidate's log probability.
    public let logProbability: Double?
    /// The candidate's token string value.
    public let token: String?
    /// The candidate's token id value.
    public let tokenId: Int?
}

public struct LogprobsResultTopCandidates: Codable, Sendable {
    /// Sorted by log probability in descending order.
    public let candidates: [LogprobsResultCandidate]?
}

// LogprobsResult replaces the placeholder struct.
public struct LogprobsResult: Codable, Sendable {
    /// Length = total number of decoding steps. The chosen candidates may or may not be in topCandidates.
    public let chosenCandidates: [LogprobsResultCandidate]?
    /// Length = total number of decoding steps.
    public let topCandidates: [LogprobsResultTopCandidates]?
}

/// Additional enums for SafetyRating

public enum HarmProbability: String, Codable, Sendable {
    case unspecified = "HARM_PROBABILITY_UNSPECIFIED"
    case negligible = "NEGLIGIBLE"
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
}

public enum HarmSeverity: String, Codable, Sendable {
    case unspecified = "HARM_SEVERITY_UNSPECIFIED"
    case negligible = "NEGLIGIBLE"
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
}

/// Content filter results for a prompt sent in the request.
public struct GenerateContentResponsePromptFeedback: Codable, Sendable {
    /// Output only. Blocked reason.
    public let blockReason: BlockedReason?
    /// Output only. A readable block reason message.
    public let blockReasonMessage: String?
    /// Output only. Safety ratings.
    public let safetyRatings: [SafetyRating]?
}

/// Response message for PredictionService.GenerateContent.
public struct GenerateContentResponse: Codable, Sendable {
    /// Response variations returned by the model.
    public let candidates: [Candidate]?
    /// Timestamp when the request is made to the server.
    public let createTime: String?
    /// Identifier for each response.
    public let responseId: String?
    /// The history of automatic function calling.
    public let automaticFunctionCallingHistory: [Content]?
    /// Output only. The model version used to generate the response.
    public let modelVersion: String?
    /// Output only. Content filter results for a prompt sent in the request.
    public let promptFeedback: GenerateContentResponsePromptFeedback?
    /// Usage metadata about the response(s).
    public let usageMetadata: GenerateContentResponseUsageMetadata?
}

