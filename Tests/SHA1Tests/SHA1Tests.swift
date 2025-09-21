import Blobby
import SHA1
import Testing

@Test
func `Empty message`() {
    let input: [0 of UInt8] = []
    let expected: [UInt8] = [
        0xda, 0x39, 0xa3, 0xee, 0x5e, 0x6b, 0x4b, 0x0d,
        0x32, 0x55, 0xbf, 0xef, 0x95, 0x60, 0x18, 0x90,
        0xaf, 0xd8, 0x07, 0x09,
    ]
    #expect(SHA1.hash(input.span.bytes).elementsEqual(expected))
}

@Test(arguments: `sha1.blb`)
func `md4.blb`(testVector: TestVector) {
    #expect(SHA1.hash(testVector.message.span.bytes).elementsEqual(testVector.expected))
}

@Test(arguments: `sha1.blb`)
func `md4.blb split messages`(testVector: TestVector) {
    let count = Int.random(in: 0...testVector.message.count)
    let prefix = testVector.message.prefix(count)
    let suffix = testVector.message.dropFirst(count)

    var hasher = SHA1()
    hasher.update(with: prefix.span.bytes)
    hasher.update(with: suffix.span.bytes)
    #expect(hasher.finalized().elementsEqual(testVector.expected))
}
