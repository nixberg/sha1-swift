import XCTest
import SHA1
import CryptoKit

final class SHA1Tests: XCTestCase {
    func testZero() {
        XCTAssertEqual(SHA1.hash([]).hex(), "da39a3ee5e6b4b0d3255bfef95601890afd80709")
    }
    
    func testQuickBrownFox() {
        let input = ArraySlice("The quick brown fox jumps over the lazy dog".utf8)
        XCTAssertEqual(SHA1.hash(input).hex(), "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12")
    }
    
    func testRandomInputs() {
        (1..<512).forEach {
            let input = [UInt8].random(count: $0)
            XCTAssert(Insecure.SHA1.hash(data: input).elementsEqual(SHA1.hash(input)))
        }
    }
    
    func testMultipleInputs() {
        (2..<32).forEach {
            let inputs = (0..<$0).map { _ in
                [UInt8].random(count: .random(in: 0..<128))
            }
            let joinedInputs = ArraySlice(inputs.joined())
            
            var sha1 = SHA1()
            inputs.forEach {
                sha1.update(with: $0)
            }
            let digest = sha1.finalize()
            
            XCTAssertEqual(digest, SHA1.hash(joinedInputs))
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

fileprivate extension DataProtocol {
    func hex() -> String {
        self.map { String(format: "%02hhx", $0) }.joined()
    }
}
