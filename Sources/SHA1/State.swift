struct State {
    var a: UInt32 = 0x6745_2301
    var b: UInt32 = 0xefcd_ab89
    var c: UInt32 = 0x98ba_dcfe
    var d: UInt32 = 0x1032_5476
    var e: UInt32 = 0xc3d2_e1f0
    
    var bigEndian: Self {
        Self(
            a: a.bigEndian,
            b: b.bigEndian,
            c: c.bigEndian,
            d: d.bigEndian,
            e: e.bigEndian
        )
    }
    
    mutating func compress(_ buffer: [UInt8]) {
        assert(buffer.count == 64)
        
        withUnsafeTemporaryAllocation(of: UInt32.self, capacity: 80) { expandedBuffer in
            buffer.withUnsafeBytes {
                $0.withMemoryRebound(to: UInt32.self) { buffer in
                    for (index, word) in zip(expandedBuffer.indices, buffer) {
                        expandedBuffer.initializeElement(at: index, to: UInt32(bigEndian: word))
                    }
                }
            }
            
            for index in expandedBuffer.indices.dropFirst(16) {
                expandedBuffer.initializeElement(at: index, to: (
                    expandedBuffer[index - 03] ^
                    expandedBuffer[index - 08] ^
                    expandedBuffer[index - 14] ^
                    expandedBuffer[index - 16]
                ).rotated(left: 1))
            }
            
            var state = self
            
            for word in expandedBuffer.dropFirst(00).prefix(20) {
                state.round(with: word, state.choice, 0x5a82_7999)
            }
            for word in expandedBuffer.dropFirst(20).prefix(20) {
                state.round(with: word, state.parity, 0x6ed9_eba1)
            }
            for word in expandedBuffer.dropFirst(40).prefix(20) {
                state.round(with: word, state.majority, 0x8f1b_bcdc)
            }
            for word in expandedBuffer.dropFirst(60).prefix(20) {
                state.round(with: word, state.parity, 0xca62_c1d6)
            }
            
            self &+= state
        }
    }
    
    private mutating func round(with word: UInt32, _ f: UInt32, _ k: UInt32) {
        let temp = a.rotated(left: 5) &+ f &+ e &+ k &+ word
        e = d
        d = c
        c = b.rotated(left: 30)
        b = a
        a = temp
    }
    
    private var choice: UInt32 {
        d ^ (b & (c ^ d))
    }
    
    private var parity: UInt32 {
        b ^ c ^ d
    }
    
    private var majority: UInt32 {
        (b & c) | (d & (b | c))
    }
    
    static func &+= (lhs: inout Self, rhs: Self) {
        lhs.a &+= rhs.a
        lhs.b &+= rhs.b
        lhs.c &+= rhs.c
        lhs.d &+= rhs.d
        lhs.e &+= rhs.e
    }
}

extension UInt32 {
    fileprivate func rotated(left count: Int) -> Self {
        self << count | self >> (Self.bitWidth - count)
    }
}
