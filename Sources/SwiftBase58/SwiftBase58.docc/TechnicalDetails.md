# Technical Details

Deep dive into the implementation details and algorithms used in SwiftBase58.

## Overview

This document provides technical implementation details for developers who need to understand the inner workings of SwiftBase58, contribute to the project, or implement compatible libraries.

## Base58 Algorithm Implementation

### Alphabet and Radix

SwiftBase58 uses the standard Bitcoin Base58 alphabet:

```swift
private static let alphabet = [UInt8]("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".utf8)
private static var radix: BigUInt { BigUInt(alphabet.count) } // 58
```

**Excluded characters**: `0` (zero), `O` (uppercase O), `I` (uppercase i), `l` (lowercase L)

### Encoding Algorithm

The encoding process converts binary data to Base58 representation:

1. **Convert to BigUInt**: Input bytes are interpreted as a big-endian unsigned integer
2. **Repeated division**: Divide by 58 repeatedly, collecting remainders
3. **Map remainders**: Each remainder maps to a character in the Base58 alphabet
4. **Handle leading zeros**: Leading zero bytes become leading '1' characters

```swift
public static func base58Encode(_ bytes: [UInt8]) -> String {
    var answer: [UInt8] = []
    var integerBytes = BigUInt(Data(bytes))
    
    // Convert to base58 representation
    while integerBytes > 0 {
        let (quotient, remainder) = integerBytes.quotientAndRemainder(dividingBy: radix)
        answer.insert(alphabet[Int(remainder)], at: 0)
        integerBytes = quotient
    }
    
    // Handle leading zeros
    let prefix = Array(bytes.prefix { $0 == 0 }).map { _ in alphabet[0] }
    answer.insert(contentsOf: prefix, at: 0)
    
    return String(bytes: answer, encoding: String.Encoding.utf8)!
}
```

### Decoding Algorithm

The decoding process reverses the encoding:

1. **Validate characters**: Ensure all characters exist in the Base58 alphabet
2. **Convert from base58**: Multiply each character's value by appropriate power of 58
3. **Handle leading '1's**: Leading '1' characters become leading zero bytes
4. **Convert to bytes**: Extract bytes from the resulting BigUInt

```swift
public static func base58Decode(_ input: String) -> [UInt8]? {
    var answer = zero
    var i = BigUInt(1)
    let byteString = [UInt8](input.utf8)
    
    // Process characters in reverse order
    for char in byteString.reversed() {
        guard let alphabetIndex = alphabet.firstIndex(of: char) else {
            return nil // Invalid character
        }
        answer += (i * BigUInt(alphabetIndex))
        i *= radix
    }
    
    let bytes = answer.serialize()
    
    // Handle leading '1' characters
    let leadingOnes = byteString.prefix(while: { $0 == alphabet[0] })
    let leadingZeros: [UInt8] = Array(repeating: 0, count: leadingOnes.count)
    
    return leadingZeros + bytes
}
```

## Base58Check Implementation

### Checksum Calculation

Base58Check uses SHA256 double-hashing for checksum generation:

```swift
private static func calculateChecksum(_ input: [UInt8]) -> [UInt8] {
    let hashedData = sha256(input)           // First SHA256
    let doubleHashedData = sha256(hashedData) // Second SHA256
    let doubleHashedArray = Array(doubleHashedData)
    return Array(doubleHashedArray.prefix(checksumLength)) // First 4 bytes
}
```

### SHA256 Implementation Strategy

The library uses conditional compilation for cross-platform SHA256:

```swift
private static func sha256(_ data: [UInt8]) -> [UInt8] {
    #if canImport(CommonCrypto) || canImport(UncommonCrypto)
    // Hardware-optimized implementation on Apple platforms
    // Compatible implementation on Linux
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes { rawBuffer in
        _ = CC_SHA256(rawBuffer.baseAddress, CC_LONG(rawBuffer.count), &hash)
    }
    return hash
    
    #elseif canImport(CryptoKit)
    // Modern Swift platforms
    let digest = SHA256.hash(data: Data(data))
    return Array(digest)
    
    #else
    fatalError("No SHA256 implementation available on this platform.")
    #endif
}
```

## BigInt Dependency

### Why BigInt is Required

Base58 encoding requires arbitrary-precision arithmetic because:

1. **Large numbers**: Converting binary data to base58 can produce very large intermediate values
2. **Precision**: Standard integer types (UInt64, etc.) would overflow for large inputs
3. **Accuracy**: Mathematical operations must be exact, not approximate

### BigInt Usage Patterns

```swift
// Creating BigUInt from byte array
var integerBytes = BigUInt(Data(bytes))

// Division with remainder
let (quotient, remainder) = integerBytes.quotientAndRemainder(dividingBy: radix)

// Multiplication and addition
answer += (i * BigUInt(alphabetIndex))

// Serialization back to bytes
let bytes = answer.serialize()
```

## Memory Management and Performance

### Memory Efficiency

- **Stack allocation**: Small arrays and primitive types use stack allocation
- **Copy-on-write**: Swift's array semantics minimize unnecessary copies
- **BigInt optimization**: BigInt library provides optimized memory management

### Performance Characteristics

| Operation | Time Complexity | Notes |
|-----------|----------------|-------|
| Encoding | O(n × log₅₈(2^(8n))) | Where n is input byte length |
| Decoding | O(m × log₂(58^m)) | Where m is input string length |
| Checksum | O(n) | Linear in data size for SHA256 |

### Optimization Strategies

```swift
// Efficient: Process data once
let encoded = Base58.base58CheckEncode(data)

// Less efficient: Multiple operations
let regularEncoded = Base58.base58Encode(data)
// ... additional processing
```

## Error Handling Design

### Encoding Errors

Encoding operations are designed to be infallible for valid inputs:
- All byte arrays can be encoded
- Encoding always produces valid Base58 strings

### Decoding Errors

Decoding operations return optionals to handle invalid inputs:

```swift
public static func base58Decode(_ input: String) -> [UInt8]? {
    // Fail if invalid characters found
    guard let alphabetIndex = alphabet.firstIndex(of: char) else {
        return nil
    }
    // ... rest of implementation
}
```

### Checksum Validation

```swift
public static func base58CheckDecode(_ input: String) -> [UInt8]? {
    guard let decodedChecksummedBytes = base58Decode(input) else {
        return nil // Invalid Base58
    }
    
    // Extract and verify checksum
    guard decodedChecksum.elementsEqual(calculatedChecksum, by: { $0 == $1 }) else {
        return nil // Checksum mismatch
    }
    
    return Array(decodedBytes)
}
```

## Thread Safety

### Stateless Design

SwiftBase58 is inherently thread-safe because:
- All methods are static
- No shared mutable state
- No global variables (beyond constants)

### Concurrent Usage

```swift
// Safe to call from multiple threads simultaneously
DispatchQueue.concurrentPerform(iterations: 1000) { index in
    let data = [UInt8](repeating: UInt8(index % 256), count: 32)
    let encoded = Base58.base58CheckEncode(data)
    let decoded = Base58.base58CheckDecode(encoded)
    assert(decoded == data)
}
```

## Testing Strategy

### Test Vector Sources

The library includes comprehensive test vectors covering:

- **Bitcoin test vectors**: Standard cryptocurrency use cases
- **Edge cases**: Empty strings, leading zeros, maximum values
- **Invalid inputs**: Malformed strings, invalid characters
- **Round-trip testing**: Encoding → Decoding verification

### Property-Based Testing

```swift
// Example property: encode(decode(x)) == x for valid x
@Test
func roundTripProperty() {
    let randomData = generateRandomBytes()
    let encoded = Base58.base58Encode(randomData)
    let decoded = Base58.base58Decode(encoded)
    #expect(decoded == randomData)
}
```

## Compatibility Notes

### Bitcoin Compatibility

SwiftBase58 is fully compatible with Bitcoin's Base58Check implementation:
- Same alphabet
- Same checksum algorithm (SHA256 double-hash)
- Same leading zero handling

### Other Base58 Variants

Some cryptocurrencies use different alphabets:
- **Ripple**: Uses a different character set
- **Monero**: Uses a completely different algorithm

SwiftBase58 implements the Bitcoin standard exclusively.

## Contributing Guidelines

### Code Style

- Follow Swift API Design Guidelines
- Use explicit types where clarity helps
- Prefer immutable data structures
- Include comprehensive documentation

### Testing Requirements

- All new features must include tests
- Maintain 100% test coverage for core algorithms
- Include both positive and negative test cases
- Test cross-platform compatibility

### Performance Considerations

- Profile changes with large datasets
- Avoid unnecessary memory allocations
- Consider both time and space complexity
- Test on resource-constrained devices

## Next Steps

- Explore <doc:CrossPlatformSupport> for platform details
- Review <doc:Base58CheckEncoding> for practical usage
- Check <doc:GettingStarted> for integration guidance