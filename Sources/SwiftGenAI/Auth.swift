//
//  Auth.swift
//  swift-genai
//
//  Created by Jolon on 13/7/2025.
//


/// The Auth protocol is used to authenticate with the API service.
public protocol Auth: Sendable {
    /// Sets the headers needed to authenticate with the API service.
    /// - Parameter headers: The dictionary to update with the authentication headers.
    func addAuthHeaders(headers: inout [String: String]) async throws
}

