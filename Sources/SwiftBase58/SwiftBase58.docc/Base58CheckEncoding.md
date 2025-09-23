# Base58Check Encoding

Learn about Base58Check encoding which adds error detection through checksums.

## Overview

Base58Check extends Base58 encoding by appending a 4-byte checksum to the original data. This checksum is computed by taking the first 4 bytes of the SHA256 double-hash of the data, providing protection against transcription errors and data corruption.

Base58Check is widely used in cryptocurrency applications, particularly for wallet addresses, private keys, and other critical data where data integrity is essential.

## How Base58Check Works

1. Start with original data
2. Compute SHA256 hash of the data
3. Compute SHA256 hash of the previous hash (double-hash)
4. Take the first 4 bytes of the double-hash as the checksum
5. Append checksum to original data
6. Apply Base58 encoding to the combined data

## Basic Base58Check Encoding

```swift
import SwiftBase58

// Encode with automatic checksum
let data: [UInt8] = [255, 254, 253, 252]
let encodedWithChecksum = Base58.base58CheckEncode(data)
print(encodedWithChecksum) // "jpUz5f99p1R"

// Compare with regular Base58 (no checksum)
let regularBase58 = Base58.base58Encode(data)
print(regularBase58) // "7YXVWT"
```

## Basic Base58Check Decoding

```swift
import SwiftBase58

let encodedString = "jpUz5f99p1R"
if let decoded = Base58.base58CheckDecode(encodedString) {
    print(decoded) // [255, 254, 253, 252]
    print("Checksum verification successful!")
} else {
    print("Invalid checksum - data may be corrupted")
}
```

## Error Detection in Action

Base58Check automatically detects corruption in the encoded string:

```swift
import SwiftBase58

let validString = "jpUz5f99p1R"
let corruptedString = "jpUz5f99p1X" // Last character changed

// Valid string decodes successfully
if let result1 = Base58.base58CheckDecode(validString) {
    print("Valid data: \(result1)")
}

// Corrupted string fails checksum verification
if let result2 = Base58.base58CheckDecode(corruptedString) {
    print("This won't print")
} else {
    print("Checksum failed - detected data corruption")
}
```

## Real-World Examples

### Cryptocurrency Address Encoding

```swift
import SwiftBase58

// Example: Encoding a Bitcoin-style address payload
let addressPayload: [UInt8] = [
    0x00, // Version byte for Bitcoin mainnet
    0x89, 0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45, 0x67,
    0x89, 0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45, 0x67,
    0x89, 0xAB, 0xCD, 0xEF
] // 20-byte hash160

let address = Base58.base58CheckEncode(addressPayload)
print("Address: \(address)")

// Verify the address
if let verifiedPayload = Base58.base58CheckDecode(address) {
    print("Address verification successful")
    print("Version: 0x\(String(verifiedPayload[0], radix: 16))")
} else {
    print("Invalid address")
}
```

### Private Key Encoding

```swift
import SwiftBase58

// Example: Encoding a private key with version byte
let privateKeyBytes: [UInt8] = [
    0x80, // Version byte for private key
    /* 32 bytes of private key data */
    0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0,
    0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0,
    0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0,
    0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0
]

let encodedPrivateKey = Base58.base58CheckEncode(privateKeyBytes)
print("Encoded private key: \(encodedPrivateKey)")
```

## Working with Structured Data

### Encoding Multi-Part Data

```swift
import SwiftBase58

struct AddressData {
    let version: UInt8
    let hash: [UInt8]
    
    var bytes: [UInt8] {
        [version] + hash
    }
}

let address = AddressData(
    version: 0x00,
    hash: [UInt8](repeating: 0xFF, count: 20)
)

let encoded = Base58.base58CheckEncode(address.bytes)

if let decoded = Base58.base58CheckDecode(encoded) {
    let decodedAddress = AddressData(
        version: decoded[0],
        hash: Array(decoded[1...])
    )
    print("Version: \(decodedAddress.version)")
    print("Hash: \(decodedAddress.hash)")
}
```

## Validation and Error Handling

### Comprehensive Validation

```swift
import SwiftBase58

func validateBase58CheckString(_ input: String) -> Bool {
    // Check for invalid characters first
    let validChars = Set("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
    guard input.allSatisfy({ validChars.contains($0) }) else {
        print("Invalid characters in Base58 string")
        return false
    }
    
    // Check minimum length (data + 4-byte checksum)
    guard input.count >= 5 else {
        print("String too short for Base58Check")
        return false
    }
    
    // Verify checksum
    guard Base58.base58CheckDecode(input) != nil else {
        print("Checksum verification failed")
        return false
    }
    
    return true
}

// Usage
let testString = "jpUz5f99p1R"
if validateBase58CheckString(testString) {
    print("Valid Base58Check string")
}
```

### Batch Processing

```swift
import SwiftBase58

func processMultipleAddresses(_ addresses: [String]) -> [(String, [UInt8]?)] {
    return addresses.map { address in
        (address, Base58.base58CheckDecode(address))
    }
}

let addresses = [
    "jpUz5f99p1R",
    "invalidAddress123",
    "anotherValidAddress"
]

let results = processMultipleAddresses(addresses)
for (address, decoded) in results {
    if let data = decoded {
        print("\(address): Valid (\(data.count) bytes)")
    } else {
        print("\(address): Invalid")
    }
}
```

## Performance and Security Notes

- **Checksum Strength**: The 4-byte checksum provides protection against common transcription errors
- **Performance**: Base58Check operations are slightly slower than regular Base58 due to hashing
- **Security**: While the checksum detects errors, it doesn't provide cryptographic integrity guarantees

## Next Steps

- Read about <doc:CrossPlatformSupport> for platform considerations
- Explore <doc:TechnicalDetails> for implementation specifics
- Check out <doc:GettingStarted> for basic usage patterns