import Blobby
import SHA1
import XCTest

final class SHA1Tests: XCTestCase {
    let testVectors = try! Data(
        contentsOf: Bundle.module.url(forResource: "sha1", withExtension: "blb")!
    ).blobs().couples()
    
    func test() {
        for (message, expectedOutput) in testVectors {
            XCTAssert(SHA1.hash(contentsOf: message).elementsEqual(expectedOutput))
        }
    }
    
    func testRandomlySplitMessages() {
        for (message, expectedOutput) in testVectors {
            var hashFunction = SHA1()
            let count = Int.random(in: 0...message.count)
            hashFunction.append(contentsOf: message.prefix(count))
            hashFunction.append(contentsOf: message.dropFirst(count))
            XCTAssert(hashFunction.finalize().elementsEqual(expectedOutput))
        }
    }
}
