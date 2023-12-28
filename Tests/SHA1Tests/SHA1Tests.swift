import Blobby
import SHA1
import XCTest

final class SHA1Tests: XCTestCase {
    let testVectors = try! PackageResources.sha1_blb.blobs().couples()
    
    func test() {
        XCTAssert(SHA1.hash(contentsOf: []).elementsEqual([
            0xda, 0x39, 0xa3, 0xee, 0x5e, 0x6b, 0x4b, 0x0d,
            0x32, 0x55, 0xbf, 0xef, 0x95, 0x60, 0x18, 0x90,
            0xaf, 0xd8, 0x07, 0x09,
        ]))
    }
    
    func testBlob() {
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
