// Copyright Keefer Taylor, 2019.

import Testing
import SwiftBase58

@Suite("Base58 Tests")
struct Base58Tests {
    /// Tuples of arbitrary strings that are mapped to valid Base58 encodings.
    private let validStringDecodedToEncodedTuples: [(String, String)] = [
        ("", ""),
        (" ", "Z"),
        ("-", "n"),
        ("0", "q"),
        ("1", "r"),
        ("-1", "4SU"),
        ("11", "4k8"),
        ("abc", "ZiCa"),
        ("1234598760", "3mJr7AoUXx2Wqd"),
        ("abcdefghijklmnopqrstuvwxyz", "3yxU3u1igY8WkgtjK92fbJQCd4BZiiT1v25f"),
        ("00000000000000000000000000000000000000000000000000000000000000",
         "3sN2THZeE9Eh9eYrwkvZqNstbHGvrxSAM7gXUXvyFQP8XvQLUqNCS27icwUeDT7ckHm4FUHM2mTVh1vbLmk7y")
    ]
    
    /// Tuples of invalid strings.
    private let invalidStrings: [String] = [
        "0",
        "O",
        "I",
        "l",
        "3mJr0",
        "O3yxU",
        "3sNI",
        "4kl8",
        "0OIl",
        "!@#$%^&*()-_=+~`"
    ]
    
    @Test
    func base58EncodingForValidStrings() {
        for (decoded, encoded) in validStringDecodedToEncodedTuples {
            let bytes = [UInt8](decoded.utf8)
            let result = Base58.base58Encode(bytes)
            #expect(result == encoded)
        }
    }
    
    @Test
    func base58DecodingForValidStrings() throws {
        for (decoded, encoded) in validStringDecodedToEncodedTuples {
            let bytes = try #require(Base58.base58Decode(encoded))
            let result = try #require(String(bytes: bytes, encoding: .utf8))
            #expect(result == decoded)
        }
    }
    
    @Test
    func base58DecodingForInvalidStrings() {
        for invalidString in invalidStrings {
            let result = Base58.base58Decode(invalidString)
            #expect(result == nil)
        }
    }
    
    @Test
    func base58CheckEncoding() {
        let inputData: [UInt8] = [
            6, 161, 159, 136, 34, 110, 33, 238, 14, 79, 14, 218, 133, 13, 109, 40, 194, 236, 153, 44, 61, 157, 254
        ]
        let expectedOutput = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"
        let actualOutput = Base58.base58CheckEncode(inputData)
        #expect(actualOutput == expectedOutput)
    }
    
    @Test
    func base58CheckDecoding() throws {
        let inputString = "tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtRw"
        let expectedOutputData: [UInt8] = [
            6, 161, 159, 136, 34, 110, 33, 238, 14, 79, 14, 218, 133, 13, 109, 40, 194, 236, 153, 44, 61, 157, 254
        ]
        
        let actualOutput = try #require(Base58.base58CheckDecode(inputString))
        #expect(actualOutput == expectedOutputData)
    }
    
    @Test
    func base58CheckDecodingLeadingOne() throws {
        let inputString = "1CdPoF9cvw3YEiuRCHxdsGpvb5tSUYBBo"
        let expectedOutputData: [UInt8] = [
            0, 2, 50, 244, 121, 42, 5, 10, 13, 224, 245, 201, 20, 55, 55, 148, 92, 255, 84, 36, 4
        ]
        let actualOutput = try #require(Base58.base58CheckDecode(inputString))
        #expect(actualOutput == expectedOutputData)
        
    }
    
    @Test
    func decodeLeadingOnes() throws {
        let inputString = "11111111111111111111111111111111"
        let expectedOutputData: [UInt8] = [
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ]
        
        let actualOutput = try #require(Base58.base58Decode(inputString))
        #expect(actualOutput == expectedOutputData)
    }
    
    @Test
    func base58CheckDecodingWithInvalidCharacters() {
        #expect(Base58.base58CheckDecode("0oO1lL") == nil)
    }
    
    @Test
    func base58CheckDecodingWithInvalidChecksum() {
        #expect(Base58.base58CheckDecode("tz1Y3qqTg9HdrzZGbEjiCPmwuZ7fWVxpPtrW") == nil)
    }
}
