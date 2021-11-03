import Crypto
import HexString
import SHA1
import XCTest

final class SHA1Tests: XCTestCase {
    func testZero() {
        XCTAssertEqual(
            SHA1.hash(contentsOf: EmptyCollection()),
            "da39a3ee5e6b4b0d3255bfef95601890afd80709")
    }
    
    func testQuickBrownFox() {
        XCTAssertEqual(
            SHA1.hash(contentsOf: "The quick brown fox jumps over the lazy dog".utf8),
            "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12")
    }
    
    func testRandomInputs() {
        (1..<512).forEach {
            let bytes: [UInt8] = .random(count: $0)
            XCTAssert(Insecure.SHA1.hash(data: bytes).elementsEqual(SHA1.hash(contentsOf: bytes)))
        }
    }
    
    func testMultipleInputs() {
        (2..<32).forEach {
            let inputs = (0..<$0).map { _ in
                [UInt8].random(count: .random(in: 0..<128))
            }
            let joinedInputs = Array(inputs.joined())
            
            var sha1: SHA1 = .init()
            inputs.forEach {
                sha1.absorb(contentsOf: $0)
            }
            let digest = sha1.squeeze()
            
            XCTAssertEqual(digest, SHA1.hash(contentsOf: joinedInputs))
            XCTAssert(Insecure.SHA1.hash(data: joinedInputs).elementsEqual(digest))
        }
    }
}

fileprivate extension Array where Element == UInt8 {
    static func random(count: Int) -> Self {
        var rng = SystemRandomNumberGenerator()
        return (0..<count).map { _ in rng.next() }
    }
}
