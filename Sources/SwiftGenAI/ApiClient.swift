//
//  ApiClient.swift
//  swift-genai
//
//  Created by Jolon on 13/7/2025.
//

import Foundation


/// Default API versions
private let VERTEX_AI_API_DEFAULT_VERSION = "v1beta1"
private let GOOGLE_AI_API_DEFAULT_VERSION = "v1beta"

private let LIBRARY_LABEL = "swift-genai/0.1.0"
private let USER_AGENT_HEADER = "User-Agent"
private let GOOGLE_API_CLIENT_HEADER = "x-goog-api-client"
private let CONTENT_TYPE_HEADER = "Content-Type"
private let SERVER_TIMEOUT_HEADER = "X-Server-Timeout"

/// ApiClient for Gemini and Vertex AI endpoints
public actor ApiClient {
    public private(set) var auth: Auth
    public private(set) var project: String?
    public private(set) var location: String?
    public private(set) var apiKey: String?
    public private(set) var vertexai: Bool
    public private(set) var apiVersion: String?
    public private(set) var httpOptions: HttpOptions?
    public private(set) var userAgentExtra: String?

    private static func baseUrlFromProjectLocation(location: String?) -> String {
        if let location = location, !location.isEmpty, location.lowercased() != "global" {
            return "https://\(location)-aiplatform.googleapis.com/"
        } else {
            return "https://aiplatform.googleapis.com/"
        }
    }

    private static func getDefaultHeaders(userAgentExtra: String?) -> [String: String] {
        let versionHeaderValue = LIBRARY_LABEL + (userAgentExtra.map { " " + $0 } ?? "")
        return [
            USER_AGENT_HEADER: versionHeaderValue,
            GOOGLE_API_CLIENT_HEADER: versionHeaderValue,
            CONTENT_TYPE_HEADER: "application/json"
        ]
    }

    private static func patchHttpOptions(base: HttpOptions, patch: HttpOptions) -> HttpOptions {
        var result = base
        if let apiVersion = patch.apiVersion { result.apiVersion = apiVersion }
        if let baseUrl = patch.baseUrl { result.baseUrl = baseUrl }
        if let headers = patch.headers {
            if result.headers == nil { result.headers = headers }
            else { result.headers?.merge(headers) { _, new in new } }
        }
        if let timeout = patch.timeout { result.timeout = timeout }
        if let extraBody = patch.extraBody { result.extraBody = extraBody }
        return result
    }

    public init(
        auth: Auth,
        project: String? = nil,
        location: String? = nil,
        apiKey: String? = nil,
        vertexai: Bool = false,
        apiVersion: String? = nil,
        httpOptions: HttpOptions? = nil,
        userAgentExtra: String? = nil
    ) {
        self.auth = auth
        self.project = project
        self.location = location
        self.apiKey = apiKey
        self.vertexai = vertexai
        self.userAgentExtra = userAgentExtra

        var initHttpOptions = HttpOptions()

        if vertexai {
            self.apiVersion = apiVersion ?? VERTEX_AI_API_DEFAULT_VERSION
            initHttpOptions.apiVersion = self.apiVersion
            initHttpOptions.baseUrl = Self.baseUrlFromProjectLocation(location: location)
            // Inline normalizeAuthParameters logic
            if let projectUn = project, !projectUn.isEmpty,
               let locationUn = location, !locationUn.isEmpty {
                self.apiKey = nil
            } else {
                self.project = nil
                self.location = nil
            }
        } else {
            self.apiVersion = apiVersion ?? GOOGLE_AI_API_DEFAULT_VERSION
            initHttpOptions.apiVersion = self.apiVersion
            initHttpOptions.baseUrl = "https://generativelanguage.googleapis.com/"
        }

        initHttpOptions.headers = Self.getDefaultHeaders(userAgentExtra: userAgentExtra)

        if let patch = httpOptions {
            self.httpOptions = Self.patchHttpOptions(base: initHttpOptions, patch: patch)
        } else {
            self.httpOptions = initHttpOptions
        }
    }

    /// Makes an HTTP request based on the request object, similar to the JS client
    public func request(request: HttpRequest) async throws -> HttpResponse {
        // Patch HTTP options if needed
        var patchedHttpOptions = self.httpOptions ?? HttpOptions()
        if let reqOptions = request.httpOptions {
            patchedHttpOptions = Self.patchHttpOptions(base: patchedHttpOptions, patch: reqOptions)
        }
        let prependProjectLocation = self.shouldPrependVertexProjectPath(request: request)
        var url = self.constructUrl(path: request.path, options: patchedHttpOptions, prependProjectLocation: prependProjectLocation)
        if let queryParams = request.queryParams, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            let existingItems = urlComponents.queryItems ?? []
            let additionalItems = queryParams.map { URLQueryItem(name: $0.key, value: String($0.value)) }
            urlComponents.queryItems = existingItems + additionalItems
            if let newUrl = urlComponents.url {
                url = newUrl
            }
        }
        var requestInit = URLRequest(url: url)
        requestInit.httpMethod = request.httpMethod.rawValue

        if request.httpMethod == .GET {
            if let body = request.body, !body.isEmpty {
                throw NSError(domain: "ApiClient", code: 400, userInfo: [NSLocalizedDescriptionKey: "Request body should be empty for GET request, but got non empty request body"])
            }
        } else {
            requestInit.httpBody = request.body
        }

        requestInit = try await self.includeExtraHttpOptionsToRequestInit(requestInit, patchedHttpOptions)
        return try await self.unaryApiCall(url: url, request: requestInit, httpMethod: request.httpMethod.rawValue)
    }
    
    /// Makes a streaming HTTP request that can throw errors via the stream.
    public func requestStream(request: HttpRequest) -> AsyncThrowingStream<HttpResponse, Error> {
        return AsyncThrowingStream<HttpResponse, Error>(HttpResponse.self) { continuation in
            Task {
                do {
                    var patchedHttpOptions = self.httpOptions ?? HttpOptions()
                    if let reqOptions = request.httpOptions {
                        patchedHttpOptions = Self.patchHttpOptions(base: patchedHttpOptions, patch: reqOptions)
                    }
                    let prependProjectLocation = self.shouldPrependVertexProjectPath(request: request)
                    var url = self.constructUrl(path: request.path, options: patchedHttpOptions, prependProjectLocation: prependProjectLocation)
                    // Ensure alt=sse
                    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                        var items = urlComponents.queryItems ?? []
                        if !items.contains(where: { $0.name == "alt" && $0.value == "sse" }) {
                            items.append(URLQueryItem(name: "alt", value: "sse"))
                        }
                        urlComponents.queryItems = items
                        if let newUrl = urlComponents.url {
                            url = newUrl
                        }
                    }
                    var requestInit = URLRequest(url: url)
                    requestInit.httpMethod = request.httpMethod.rawValue
                    if request.httpMethod == .GET {
                        if let body = request.body, !body.isEmpty {
                            throw NSError(domain: "ApiClient", code: 400, userInfo: [NSLocalizedDescriptionKey: "Request body should be empty for GET request, but got non empty request body"])
                        }
                    } else {
                        requestInit.httpBody = request.body
                    }
                    requestInit = try await self.includeExtraHttpOptionsToRequestInit(requestInit, patchedHttpOptions)
                    // Streaming HTTP response using URLSession
                    let (bytes, response) = try await URLSession.shared.bytes(for: requestInit)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw NSError(domain: "ApiClient", code: -3, userInfo: [NSLocalizedDescriptionKey: "Did not receive HTTP response"])
                    }
                    if !(200...299).contains(httpResponse.statusCode) {
                        throw NSError(domain: "ApiClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error \(httpResponse.statusCode)"])
                    }
                    let headers: [(String, String)] = httpResponse.allHeaderFields.compactMap { key, value in
                        guard let k = key as? String, let v = value as? String else { return nil }
                        return (k, v)
                    }
                    var buffer = ""
                    let decoder = String.Encoding.utf8
                    for try await line in self.lineSequence(from: bytes) {
                        buffer += line
                        let trimmed = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty { continue }
                        // Remove SSE 'data: ' prefix for each line before decoding as JSON
                        var jsonLine = trimmed
                        if jsonLine.hasPrefix("data: ") {
                            jsonLine = String(jsonLine.dropFirst(6))
                        }
                        do {
                            if let data = jsonLine.data(using: decoder) {
                                if let chunkJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let errorJson = chunkJson["error"] as? [String: Any], let code = errorJson["code"] as? Int, let status = errorJson["status"] as? String, code >= 400 && code < 600 {
                                    let errorMessage = "got status: \(status). \(chunkJson)"
                                    throw NSError(domain: "ApiClient", code: code, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                                }
                            }
                            let responseObj = HttpResponse(statusCode: httpResponse.statusCode, headers: Dictionary(uniqueKeysWithValues: headers), body: jsonLine.data(using: decoder) ?? Data())
                            continuation.yield(responseObj)
                            buffer = ""
                        } catch {
                            continuation.finish(throwing: error)
                            return
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // Helper to read the byte stream as lines (splitting on \n)
    private func lineSequence(from bytes: URLSession.AsyncBytes) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                var buffer = Data()
                for try await chunk in bytes {
                    buffer.append(chunk)
                    while let range = buffer.range(of: Data([0x0A])) { // 0x0A == \n
                        let lineData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
                        if let line = String(data: lineData, encoding: .utf8) {
                            continuation.yield(line)
                        }
                        buffer.removeSubrange(buffer.startIndex...range.lowerBound)
                    }
                }
                if !buffer.isEmpty, let line = String(data: buffer, encoding: .utf8) {
                    continuation.yield(line)
                }
                continuation.finish()
            }
        }
    }

    // Updated implementation as requested
    private func shouldPrependVertexProjectPath(request: HttpRequest) -> Bool {
        if self.apiKey != nil {
            return false
        }
        if !self.vertexai {
            return false
        }
        if request.path.hasPrefix("projects/") {
            return false
        }
        if request.httpMethod == .GET && request.path.hasPrefix("publishers/google/models") {
            return false
        }
        return true
    }

    private func constructUrl(path: String, options: HttpOptions, prependProjectLocation: Bool) -> URL {
        var segments: [String] = []
        segments.append(getRequestUrlInternal(options).trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        if prependProjectLocation {
            let basePath = getBaseResourcePath().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if !basePath.isEmpty {
                segments.append(basePath)
            }
        }
        if !path.isEmpty {
            segments.append(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        }
        let fullUrlString = segments.joined(separator: "/")
        return URL(string: fullUrlString)!
    }
    
    /// Returns the base URL to use for requests.
    /// This will crash if HttpOptions is not correctly set, matching the TypeScript error-throwing behavior.
    private func getRequestUrlInternal(_ options: HttpOptions) -> String {
        guard let baseUrlRaw = options.baseUrl else {
            fatalError("HttpOptions.baseUrl is required")
        }
        guard let apiVersionRaw = options.apiVersion else {
            fatalError("HttpOptions.apiVersion is required")
        }

        // Remove trailing slash from baseUrl if present
        let baseUrl: String
        if baseUrlRaw.hasSuffix("/") {
            baseUrl = String(baseUrlRaw.dropLast())
        } else {
            baseUrl = baseUrlRaw
        }

        var urlElement = [baseUrl]
        if !apiVersionRaw.isEmpty {
            urlElement.append(apiVersionRaw)
        }
        return urlElement.joined(separator: "/")
    }
    
    private func getBaseResourcePath() -> String {
        if let project = project, !project.isEmpty,
           let location = location, !location.isEmpty {
            return "projects/\(project)/locations/\(location)"
        }
        return ""
    }

    private func includeExtraHttpOptionsToRequestInit(_ request: URLRequest, _ options: HttpOptions) async throws -> URLRequest {
        var mutableRequest = request

        // If timeout is specified, set it on the request
        if let timeoutInterval = options.timeout {
            mutableRequest.timeoutInterval = timeoutInterval
        }

        // Handle merging or setting of JSON body with extraBody if present
        if let extraBody = options.extraBody {
            // Attempt to merge extraBody into existing httpBody if possible
            if let existingBody = mutableRequest.httpBody {
                // Decode existing body JSON to NSDictionary
                if let existingJson = try? JSONSerialization.jsonObject(with: existingBody, options: []) as? NSDictionary {
                    // Convert extraBody dictionary to NSDictionary for merging
                    let extraBodyDict = extraBody as NSDictionary
                    // Merge extraBodyDict into existingJson (extraBody keys override)
                    let mergedJson = NSMutableDictionary(dictionary: existingJson)
                    mergedJson.addEntries(from: extraBodyDict as! [AnyHashable: Any])
                    // Encode merged JSON back to Data
                    let mergedData = try JSONSerialization.data(withJSONObject: mergedJson, options: [])
                    mutableRequest.httpBody = mergedData
                }
                // If existing body is not valid JSON, do not merge, keep original body
            } else {
                // No existing body, so encode extraBody as JSON and set as httpBody
                let jsonData = try JSONSerialization.data(withJSONObject: extraBody, options: [])
                mutableRequest.httpBody = jsonData
            }
        }
        
        // Overwrite headers with merged and auth headers from getHeadersInternal
        let finalHeaders = try await self.getHeadersInternal(httpOptions: options)
        for (key, value) in finalHeaders {
            mutableRequest.setValue(value, forHTTPHeaderField: key)
        }

        return mutableRequest
    }
    
    private func unaryApiCall(url: URL, request: URLRequest, httpMethod: String) async throws -> HttpResponse {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "ApiClient", code: -3, userInfo: [NSLocalizedDescriptionKey: "Did not receive HTTP response"]) 
        }
        if !(200...299).contains(httpResponse.statusCode) {
            // Mirror throwErrorIfNotOK from TS: throw if not OK
            let bodyString = String(data: data, encoding: .utf8) ?? "<empty>"
            throw NSError(domain: "ApiClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error \(httpResponse.statusCode): \(bodyString)"])
        }
        let headers: [(String, String)] = httpResponse.allHeaderFields.compactMap { key, value in
            guard let k = key as? String, let v = value as? String else { return nil }
            return (k, v)
        }
        return HttpResponse(statusCode: httpResponse.statusCode, headers: Dictionary(uniqueKeysWithValues: headers), body: data)
    }

    /// Returns headers for a request, merging options and adding auth headers
    public func getHeadersInternal(httpOptions: HttpOptions?) async throws -> [String: String] {
        var headers: [String: String] = [:]
        
        // Copy over headers from options
        if let optionsHeaders = httpOptions?.headers {
            for (key, value) in optionsHeaders {
                headers[key] = value
            }
        }
        // If a timeout is present, add the timeout header (convert seconds to whole seconds string)
        if let timeout = httpOptions?.timeout, timeout > 0 {
            headers[SERVER_TIMEOUT_HEADER] = String(Int(ceil(timeout)))
        }
        // Call the auth object's addAuthHeaders function, passing headers inout
        try await self.auth.addAuthHeaders(headers: &headers)
        return headers
    }
}

