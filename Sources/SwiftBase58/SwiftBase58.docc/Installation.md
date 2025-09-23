# Installation

How to add SwiftBase58 to your Swift project.

## Swift Package Manager

### Xcode Integration

1. In Xcode, go to **File** → **Add Package Dependencies...**
2. Enter the package URL: `https://github.com/KINGH242/swift-base58.git`
3. Choose the version rule (recommended: "Up to Next Minor Version")
4. Click **Add Package**
5. Select the **SwiftBase58** library and add it to your target

### Package.swift

Add SwiftBase58 as a dependency in your `Package.swift` file:

```swift
// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "YourPackage",
    dependencies: [
        .package(url: "https://github.com/KINGH242/swift-base58.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: [
                .product(name: "SwiftBase58", package: "swift-base58")
            ]
        )
    ]
)
```

## Platform Requirements

SwiftBase58 supports the following platforms:

- **macOS**: 10.15+
- **iOS**: 13.0+
- **tvOS**: 13.0+
- **watchOS**: 6.0+
- **Linux**: Swift 5.7+

## Import in Your Code

Once installed, import SwiftBase58 in your Swift files:

```swift
import SwiftBase58

// Now you can use Base58 encoding/decoding
let encoded = Base58.base58Encode([1, 2, 3])
```

## Verifying Installation

Create a simple test to verify the installation:

```swift
import SwiftBase58

func testInstallation() {
    let testData: [UInt8] = [72, 101, 108, 108, 111] // "Hello" in UTF-8
    let encoded = Base58.base58Encode(testData)
    let decoded = Base58.base58Decode(encoded)
    
    print("Original: \(testData)")
    print("Encoded: \(encoded)")
    print("Decoded: \(decoded ?? [])")
    print("Round-trip successful: \(testData == decoded)")
}
```

If everything is working correctly, this should print:
```
Original: [72, 101, 108, 108, 111]
Encoded: 9Ajdvzr
Decoded: [72, 101, 108, 108, 111]
Round-trip successful: true
```