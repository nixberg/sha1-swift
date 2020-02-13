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
    
    @available(OSX 10.15, *)
    func testShortInputs() {
        (0..<64).forEach {
            let input = [UInt8].random(count: $0)
            XCTAssert(Insecure.SHA1.hash(data: input).elementsEqual(SHA1.hash(input)))
        }
    }
    
    @available(OSX 10.15, *)
    func testLongInputs() {
        (64..<512).forEach {
            let input = [UInt8].random(count: $0)
            XCTAssert(Insecure.SHA1.hash(data: input).elementsEqual(SHA1.hash(input)))
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
