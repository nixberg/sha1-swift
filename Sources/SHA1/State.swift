struct State: ~Copyable {
    var a: UInt32 = 0x67452301
    var b: UInt32 = 0xefcdab89
    var c: UInt32 = 0x98badcfe
    var d: UInt32 = 0x10325476
    var e: UInt32 = 0xc3d2e1f0
    
    mutating func compress(_ buffer: inout Buffer) {
        var state = WorkingState(self)
        
        buffer.expand()
        
        buffer.withUnsafeBytes {
            $0.withMemoryRebound(to: UInt32.self) {
                for index in 00..<20 {
                    state.round(with: { $0.choice   }, constant: 0x5a827999, word: $0[index])
                }
                for index in 20..<40 {
                    state.round(with: { $0.parity   }, constant: 0x6ed9eba1, word: $0[index])
                }
                for index in 40..<60 {
                    state.round(with: { $0.majority }, constant: 0x8f1bbcdc, word: $0[index])
                }
                for index in 60..<80 {
                    state.round(with: { $0.parity   }, constant: 0xca62c1d6, word: $0[index])
                }
            }
        }
        
        self &+= state
    }
}

extension Buffer {
    fileprivate mutating func expand() {
        self.fill(with: 0, toCount: 320)
        
        self.withUnsafeMutableBytes {
            $0.withMemoryRebound(to: UInt32.self) {
                for index in 0..<16 {
                    $0[index] = UInt32(bigEndian: $0[index])
                }
                for index in 16..<80 {
                    $0[index] = (
                        $0[index &- 03] ^
                        $0[index &- 08] ^
                        $0[index &- 14] ^
                        $0[index &- 16]
                    ).rotated(left: 1)
                }
            }
        }
    }
}
