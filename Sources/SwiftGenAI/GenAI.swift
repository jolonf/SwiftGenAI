//
//  GenAI.swift
//  swift-genai
//
//  Created by Jolon on 13/7/2025.
//

import Foundation

enum GenAIError: Error, LocalizedError {
    case vertexNotSupported

    var errorDescription: String? {
        switch self {
        case .vertexNotSupported:
            return "Vertex not supported"
        }
    }
}


/// Provides access to GenAI features.
///
/// Initialise the SDK for using the Gemini API:
/// ```
/// import swift-genai
///
/// let ai = GenAI(apiKey: "GEMINI_API_KEY")
/// let response = await ai.generateContent()
/// ```
///
public actor GenAI {
    
    let apiKey: String
    let vertexai: Bool
    let project: String?
    let location: String?
    let apiVersion: String?
    let httpOptions: HttpOptions?
    
    let apiClient: ApiClient
    
    public init (apiKey: String,
                 vertexai: Bool = false,
                 project: String? = nil,
                 location: String? = nil,
                 apiVersion: String? = nil,
                 httpOptions: HttpOptions? = nil) {
        self.apiKey = apiKey
        self.vertexai = vertexai
        self.project = project
        self.location = location
        self.apiVersion = apiVersion
        self.httpOptions = httpOptions
        
        let auth = WebAuth(apiKey: apiKey)
        self.apiClient = ApiClient(auth: auth,
                                   project: project,
                                   location: location,
                                   apiKey: apiKey,
                                   vertexai: vertexai,
                                   apiVersion: apiVersion,
                                   httpOptions: httpOptions,
                                   userAgentExtra: "swift/cross")
    }
    
    
}
