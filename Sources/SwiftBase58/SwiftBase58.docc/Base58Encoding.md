# Base58 Encoding

Learn about standard Base58 encoding and decoding operations.

## Overview

Base58 is a binary-to-text encoding scheme that represents data using a 58-character alphabet. It's designed to be more user-friendly than Base64 by excluding characters that can be easily confused (0, O, I, l) and characters that can affect word wrapping (+, /).

The Base58 alphabet used by SwiftBase58 is: `123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`

## Basic Encoding

Convert byte arrays to Base58 strings:

```swift
import SwiftBase58

// Encoding simple data
let data: [UInt8] = [255, 254, 253, 252]
let encoded = Base58.base58Encode(data)
print(encoded) // "7YXVWT"

// Encoding text
let text = "Hello, World!"
let textBytes = [UInt8](text.utf8)
let encodedText = Base58.base58Encode(textBytes)
print(encodedText) // "72k1xXWG59fYdzuwFxosp"
```

## Basic Decoding

Convert Base58 strings back to byte arrays:

```swift
import SwiftBase58

let encodedString = "7YXVWT"
if let decoded = Base58.base58Decode(encodedString) {
    print(decoded) // [255, 254, 253, 252]
} else {
    print("Invalid Base58 string")
}

// Converting decoded bytes back to text
let encodedText = "72k1xXWG59fYdzuwFxosp"
if let decodedBytes = Base58.base58Decode(encodedText),
   let originalText = String(bytes: decodedBytes, encoding: .utf8) {
    print(originalText) // "Hello, World!"
}
```

## Handling Leading Zeros

Base58 preserves leading zeros as leading '1' characters:

```swift
import SwiftBase58

// Data with leading zeros
let dataWithZeros: [UInt8] = [0, 0, 1, 2, 3]
let encoded = Base58.base58Encode(dataWithZeros)
print(encoded) // "11Ldp" - Notice the leading "11" for two zero bytes

// Decoding preserves the leading zeros
if let decoded = Base58.base58Decode(encoded) {
    print(decoded) // [0, 0, 1, 2, 3]
}
```

## Working with Different Data Types

### Converting from Data

```swift
import Foundation
import SwiftBase58

let data = Data([1, 2, 3, 4, 5])
let encoded = Base58.base58Encode([UInt8](data))
print(encoded)
```

### Converting from Strings

```swift
import SwiftBase58

let message = "Hello"
let bytes = [UInt8](message.utf8)
let encoded = Base58.base58Encode(bytes)

// Decode back to string
if let decoded = Base58.base58Decode(encoded),
   let original = String(bytes: decoded, encoding: .utf8) {
    print(original) // "Hello"
}
```

### Working with Integers

```swift
import SwiftBase58

// Convert integer to bytes (big-endian)
let number: UInt64 = 12345
let bytes = withUnsafeBytes(of: number.bigEndian) { [UInt8]($0) }
let encoded = Base58.base58Encode(bytes)

// Decode back to integer
if let decoded = Base58.base58Decode(encoded),
   decoded.count == 8 {
    let restoredNumber = decoded.withUnsafeBytes {
        UInt64(bigEndian: $0.load(as: UInt64.self))
    }
    print(restoredNumber) // 12345
}
```

## Error Handling

Base58 decoding can fail if the input contains invalid characters:

```swift
import SwiftBase58

let validString = "123456789"
let invalidString = "0OIl" // Contains invalid characters

// This succeeds
if let result1 = Base58.base58Decode(validString) {
    print("Valid: \(result1)")
}

// This fails and returns nil
if let result2 = Base58.base58Decode(invalidString) {
    print("This won't print")
} else {
    print("Invalid Base58 string - contains forbidden characters")
}
```

## Performance Considerations

- Encoding and decoding use arbitrary-precision arithmetic (BigInt)
- Performance scales with the size of the input data
- For very large data sets, consider processing in chunks if memory is a concern

```swift
import SwiftBase58

// Efficient for typical use cases
let largeData = [UInt8](repeating: 42, count: 1000)
let encoded = Base58.base58Encode(largeData)
let decoded = Base58.base58Decode(encoded)
```

## Next Steps

- Learn about <doc:Base58CheckEncoding> for error detection
- Explore <doc:CrossPlatformSupport> for platform-specific information