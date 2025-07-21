# SwiftGenAI

SwiftGenAI is a Swift port of Gemini's GenAI 2.0 SDK based on the JS SDK.

## Installation

### Swift Package Manager
1. In Xcode, open your project settings.
2. Select the "Package Dependencies" tab.
3. Click the + button and enter the repository URL for SwiftGenAI.
4. Add the package to your target.

## Usage

### Basic prompt

```swift
import SwiftGenAI

let ai = GenAI(apiKey: "GEMINI_API_KEY")
let response = try await ai.generateContent(content: "Prompt")

if let candidates = response.candidates {
    for candidate in candidates {
        if let parts = candidate.content?.parts {
            for part in parts {
                switch part {
                    case .text(text):
                        print(text)
                    default:
                        print("Part type not supported")
                }
            }
        }
    }
}
```

### Enable Google Search

```swift
import SwiftGenAI

let ai = GenAI(apiKey: "GEMINI_API_KEY")
let config = GenerateContentConfig(tools: [
    Tool(googleSearch: GoogleSearch())
])
let response = try await ai.generateContent(content: "Prompt", config: config)
...
```

### Multi-turn chat

```swift
let genAI = GenAI(apiKey: apiKey)
let contents = [
    Content(parts: [.text("Hello")], role: "user"),
    Content(parts: [.text("Great to meet you. What would you like to know?")], role: "model"),
    Content(parts: [.text("I have two dogs in my house. How many paws are in my house?")], role: "user")
]
let response = try await genAI.generateContent(model: "gemini-2.5-flash", contents: contents)
...
```

### Streaming response

```swift
var candidates: [Candidate] = []
let stream = try await genAI.generateContentStream(model: "gemini-2.5-flash", content: "How does AI work?")

for try await event in stream {
    if let eventCandidates = event.candidates, !eventCandidates.isEmpty {
        candidates.append(contentsOf: eventCandidates)
    }
}
```

### ImageGen

```swift

let response = try await genAI.generateImages(prompt: "Rabbit on a hat", GenerateImagesConfig(numberOfImages: 4))

if let predictions = response.predictions {
    for prediction in predictions {
        let imageData = prediction.bytesBase64Encoded
    }
}

```
