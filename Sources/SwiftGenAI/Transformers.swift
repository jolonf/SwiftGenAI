//
//  Transformers.swift
//  swift-genai
//
//  Created by Jolon on 15/7/2025.
//

import Foundation

/// Returns the fully-qualified model name for the given API client and model string.
public func tModel(apiClient: ApiClient, model: String) async -> String {
    if await apiClient.vertexai {
        if model.hasPrefix("publishers/") || model.hasPrefix("projects/") || model.hasPrefix("models/") {
            return model
        } else if let slashIndex = model.firstIndex(of: "/"), slashIndex != model.startIndex {
            let parts = model.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)
            if parts.count == 2 {
                return "publishers/\(parts[0])/models/\(parts[1])"
            }
        }
        return "publishers/google/models/\(model)"
    } else {
        if model.hasPrefix("models/") || model.hasPrefix("tunedModels/") {
            return model
        } else {
            return "models/\(model)"
        }
    }
}
