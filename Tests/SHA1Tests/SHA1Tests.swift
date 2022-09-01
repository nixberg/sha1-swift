import Crypto
import HexString
import SHA1
import XCTest

final class SHA1Tests: XCTestCase {
    func testZero() {
        let digest = SHA1.hash(contentsOf: EmptyCollection())
        let expectedHexString = "da39a3ee5e6b4b0d3255bfef95601890afd80709"
        XCTAssert(digest.elementsEqual(Array(hexString: expectedHexString)!))
        XCTAssertEqual(String(describing: digest), "SHA-1 digest: \(expectedHexString)")
    }
    
    func testQuickBrownFox() {
        let digest = SHA1.hash(contentsOf: "The quick brown fox jumps over the lazy dog".utf8)
        let expectedHexString = "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"
        XCTAssert(digest.elementsEqual(Array(hexString: expectedHexString)!))
        XCTAssertEqual(String(describing: digest), "SHA-1 digest: \(expectedHexString)")
    }
    
    func testRandomInputs() {
        (1..<512).forEach {
            let bytes: [UInt8] = .random(count: $0)
            let digest = SHA1.hash(contentsOf: bytes)
            let expectedDigest = Insecure.SHA1.hash(data: bytes)
            XCTAssert(digest.elementsEqual(expectedDigest))
            XCTAssertEqual(
                String(describing: digest).suffix(40),
                String(describing: expectedDigest).suffix(40)
            )
        }
    }
    
    func testMultipleInputs() {
        for count in 2..<32 {
            let inputs = (0..<count).map { _ in
                [UInt8].random(count: .random(in: 0..<128))
            }
            let joinedInputs = Array(inputs.joined())
            
            var sha1 = SHA1()
            inputs.forEach {
                sha1.absorb(contentsOf: $0)
            }
            var digest = [UInt8](repeating: 0, count: SHA1.defaultOutputByteCount)
            sha1.squeeze(into: &digest)
            
            XCTAssert(digest.elementsEqual(SHA1.hash(contentsOf: joinedInputs)))
            XCTAssert(Insecure.SHA1.hash(data: joinedInputs).elementsEqual(digest))
        }
    }
}

fileprivate extension Array<UInt8> {
    static func random(count: Int) -> Self {
        var rng = SystemRandomNumberGenerator()
        return (0..<count).map({ _ in rng.next() })
    }
}
