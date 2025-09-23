# Getting Started

Learn how to use SwiftBase58 for encoding and decoding data in your Swift applications.

## Overview

SwiftBase58 makes it easy to encode and decode data using the Base58 and Base58Check algorithms. This guide will walk you through the basic usage patterns and common scenarios.

## Quick Start

### Basic Base58 Encoding

Start by importing the SwiftBase58 module and using the static methods on the `Base58` enum:

```swift
import SwiftBase58

let data: [UInt8] = [255, 254, 253, 252]
let encoded = Base58.base58Encode(data)
print(encoded) // "7YXVWT"
```

### Basic Base58 Decoding

Decode Base58 strings back to their original byte representation:

```swift
import SwiftBase58

let encodedString = "7YXVWT"
if let decoded = Base58.base58Decode(encodedString) {
    print(decoded) // [255, 254, 253, 252]
}
```

### Base58Check with Checksums

For applications that need error detection, use Base58Check encoding which includes a checksum:

```swift
import SwiftBase58

let data: [UInt8] = [255, 254, 253, 252]

// Encode with checksum
let encodedWithChecksum = Base58.base58CheckEncode(data)
print(encodedWithChecksum) // "jpUz5f99p1R"

// Decode and verify checksum
if let decoded = Base58.base58CheckDecode(encodedWithChecksum) {
    print(decoded) // [255, 254, 253, 252]
} else {
    print("Invalid checksum!")
}
```

## Error Handling

Base58 decoding methods return optional values. Always check for `nil` return values:

```swift
let invalidString = "0OIl" // Contains invalid characters
if let result = Base58.base58Decode(invalidString) {
    print("Decoded: \(result)")
} else {
    print("Failed to decode - invalid Base58 string")
}
```

## Common Use Cases

### Cryptocurrency Addresses

Base58Check is commonly used for cryptocurrency addresses:

```swift
let addressBytes: [UInt8] = [/* address bytes */]
let address = Base58.base58CheckEncode(addressBytes)
// Use address string...
```

### Data Integrity

Use Base58Check when you need to ensure data hasn't been corrupted:

```swift
let importantData: [UInt8] = [/* your data */]
let encodedData = Base58.base58CheckEncode(importantData)

// Later, when receiving the data:
if let verifiedData = Base58.base58CheckDecode(encodedData) {
    // Data is valid and matches original
    processData(verifiedData)
} else {
    // Data was corrupted or invalid
    handleError()
}
```

## Next Steps

- Learn about <doc:Base58Encoding> for detailed encoding information
- Explore <doc:Base58CheckEncoding> for checksum functionality
- Read <doc:CrossPlatformSupport> for platform-specific considerations