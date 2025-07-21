//
//  ModelsConverters.swift
//  swift-genai
//
//  Created by Jolon on 15/7/2025.
//

// The versions of functions here are much simpler than their JS counterparts which allow for any object to be passed in for the parameters
// and then maps the properties to the object sent in the HttpRequest. Swift is stricter so there is less to be done.
// Because we don't support Vertex as yet the call to tModel is almost unnecessary and is the only reason these functions are async.


import Foundation

/// Generates parameters for Mldev API requests, including model, contents, and optional config.
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

/// Generates parameters for Mldev API requests, including model, contents, and optional config.
public func generateImagesParametersToMldev(apiClient: ApiClient, model: String, prompt: String, config: GenerateImagesConfig? = nil) async -> (String, GenerateImagesParameters) {
    let generateImagesParameters = GenerateImagesParameters(
        instances: [ImageInstance(prompt: prompt)],
        parameters: config
    )
    
    let path = await tModel(apiClient: apiClient, model: model)
    
    return (path, generateImagesParameters)
}

