# SwiftBase58

This is a fork of the [Base58Swift](https://github.com/keefertaylor/Base58Swift) project that adds Linux compatibility.

Base58Swift is a Swift library that implements Base58 / Base58Check encodings for cryptocurrencies. It is based off of [go-base-58](https://github.com/jbenet/go-base58) with some added functions.

## Installation

### Swift Package Manager

Add the following to the `dependencies` section of your `Package.swift` file:

```swift
.package(url: "https://github.com/KINGH242/swift-base58.git", from: "0.1.0")
```

## Usage

Base58Swift provides a static utility class, `Base58`, which provides encoding and decoding functions.

To encode / decode in Base58:
```swift
let bytes: [UInt8] = [255, 254, 253, 252]

let encodedString = Base58.encode(bytes)!
let decodedBytes = Base58.decode(encodedString)!

print(encodedString) // 7YXVWT
print(decodedBytes)  // [255, 254, 253, 252]
```

To encode / decode in Base58Check:
```swift
let bytes: [UInt8] = [255, 254, 253, 252]

let encodedString = Base58.base58CheckEncode(bytes)!
let decodedBytes = Base58.base58CheckDecode(encodedString)!

print(encodedString) // jpUz5f99p1R
print(decodedBytes)  // [255, 254, 253, 252]
```

## License

MIT

