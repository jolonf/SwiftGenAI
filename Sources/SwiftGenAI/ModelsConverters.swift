//
//  ModelsConverters.swift
//  swift-genai
//
//  Created by Jolon on 15/7/2025.
//

import Foundation


// MARK: This file uses the encodesAnyValue pattern for optional config encoding.

// Generates parameters for Mldev API requests, including model, contents, and optional config.
public func generateContentParametersToMldev(apiClient: ApiClient, model: String, contents: [Content], config: GenerateContentConfig?) async -> (String, GenerateContentParameters) {
    
    // Use filteredConfig to avoid sending empty configs for generationConfig,
    // but lift other fields directly from the original config to preserve any intentional nils or values.
    let filteredConfig: GenerateContentConfig? = (config == nil || config?.encodesAnyValue() == false) ? nil : config

    let generateContentParameters = GenerateContentParameters(
        contents: contents,
        generationConfig: filteredConfig,
        systemInstruction: config?.systemInstruction,
        safetySettings: config?.safetySettings,
        tools: config?.tools,
        toolConfig: config?.toolConfig,
        cachedContent: config?.cachedContent
    )

    let path = await tModel(apiClient: apiClient, model: model)
    
    return (path, generateContentParameters)
}

