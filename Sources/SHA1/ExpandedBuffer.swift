typealias ExpandedBuffer = InlineArray<80, UInt32>

extension ExpandedBuffer {
    init(parsingBigEndian input: borrowing RawSpan) {
        var input = copy input
        self.init(initializingWith: {
            for _ in 00..<16 {
                $0.append(UInt32(parsingBigEndian: &input))
            }
            for index in 16..<80 {
                var word: UInt32 = 0
                word ^= $0[index &- 03]
                word ^= $0[index &- 08]
                word ^= $0[index &- 14]
                word ^= $0[index &- 16]
                $0.append(word.rotated(left: 1))
            }
        })
    }
}

extension UInt32 {
    fileprivate init(parsingBigEndian input: inout RawSpan) {
        self = Self(bigEndian: unsafe input.unsafeLoadUnaligned(as: Self.self))
        input = input.extracting(MemoryLayout<Self>.stride...)
    }
}
