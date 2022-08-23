struct State {
    var a: UInt32 = 0x67452301
    var b: UInt32 = 0xefcdab89
    var c: UInt32 = 0x98badcfe
    var d: UInt32 = 0x10325476
    var e: UInt32 = 0xc3d2e1f0
    
    @inline(__always)
    mutating func performRound(with word: UInt32, _ f: UInt32, _ k: UInt32) {
        let temporary = a.rotated(left: 5) &+ f &+ e &+ k &+ word
        e = d
        d = c
        c = b.rotated(left: 30)
        b = a
        a = temporary
    }
    
    @inline(__always)
    var choice: UInt32 {
        d ^ (b & (c ^ d))
    }
    
    @inline(__always)
    var parity: UInt32 {
        b ^ c ^ d
    }
    
    @inline(__always)
    var majority: UInt32 {
        (b & c) | (d & (b | c))
    }
    
    @inline(__always)
    static func &+= (lhs: inout Self, rhs: Self) {
        lhs.a &+= rhs.a
        lhs.b &+= rhs.b
        lhs.c &+= rhs.c
        lhs.d &+= rhs.d
        lhs.e &+= rhs.e
    }
}
