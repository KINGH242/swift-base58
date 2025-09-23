# Cross-Platform Support

Understanding how SwiftBase58 works across different platforms and environments.

## Overview

SwiftBase58 is designed to work seamlessly across all Swift-supported platforms. The library uses conditional compilation to handle platform-specific differences, particularly for cryptographic operations required by Base58Check encoding.

## Supported Platforms

### Apple Platforms
- **macOS**: 10.15+ (Catalina and later)
- **iOS**: 13.0+
- **iPadOS**: 13.0+
- **tvOS**: 13.0+
- **watchOS**: 6.0+
- **visionOS**: 1.0+ (automatically supported)

### Other Platforms
- **Linux**: All distributions with Swift 5.7+
- **Windows**: With Swift for Windows (5.7+)

## Platform-Specific Implementation Details

### Cryptographic Libraries

SwiftBase58 uses different crypto libraries depending on the platform:

```swift
#if canImport(CommonCrypto)
import CommonCrypto        // Apple platforms
#elseif canImport(UncommonCrypto)
import UncommonCrypto     // Linux and other platforms
#elseif canImport(CryptoKit)
import CryptoKit          // Fallback for newer platforms
#endif
```

#### Apple Platforms (macOS, iOS, etc.)
- Uses **CommonCrypto** framework
- Provides hardware-accelerated SHA256 operations
- No additional dependencies required

#### Linux
- Uses **UncommonCrypto** package (automatically included)
- Provides CommonCrypto-compatible API
- Linked only on Linux platforms through Package.swift conditions

#### Modern Swift Platforms
- Falls back to **CryptoKit** when available
- Provides consistent API across platforms

### Platform-Specific Package Configuration

The Package.swift uses conditional compilation to include dependencies only when needed:

```swift
.target(
    name: "SwiftBase58",
    dependencies: [
        .product(name: "BigInt", package: "BigInt"),
        // Only link UncommonCrypto on Linux
        .product(
            name: "UncommonCrypto",
            package: "UncommonCrypto.swift",
            condition: .when(platforms: [.linux])
        )
    ]
)
```

## Next Steps

- Review <doc:TechnicalDetails> for implementation specifics
- Check <doc:GettingStarted> for basic usage
- Explore <doc:Base58Encoding> for API details
