//
//  GenerateImagesJSONTests.swift
//  SwiftGenAI
//
//  Created by Jolon on 20/7/2025.
//

import Foundation
import Testing
import SwiftGenAI

@Suite("Imagen JSON parameter generation")
struct GenerateImagesJSONTests {
  @Test("matches imagen rest example")
  func matchesImagenRestExample() async throws {
    let apiClient = ApiClient(auth: WebAuth(apiKey: "dummy-key"))
      let (_, params) = await generateImagesParametersToMldev(
      apiClient: apiClient,
      model: "imagen-4.0-generate-preview-06-06",
      prompt: "Robot holding a red skateboard",
      config: GenerateImagesConfig(numberOfImages: 4)
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(params)

    let generatedJson = try JSONSerialization.jsonObject(with: data) as? NSDictionary

    let expectedJSONString = """
    {
      "instances": [
        {
          "prompt": "Robot holding a red skateboard"
        }
      ],
      "parameters": {
        "numberOfImages": 4
      }
    }
    """
    let expectedData = expectedJSONString.data(using: .utf8)!
    let expectedJson = try JSONSerialization.jsonObject(with: expectedData) as? NSDictionary

    #expect(generatedJson == expectedJson, "Generated JSON should match expected JSON")
  }
}
