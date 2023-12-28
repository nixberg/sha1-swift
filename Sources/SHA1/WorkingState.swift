struct WorkingState: ~Copyable {
    private var a: UInt32
    private var b: UInt32
    private var c: UInt32
    private var d: UInt32
    private var e: UInt32
    
    static func &+= (lhs: inout State, rhs: borrowing Self) {
        lhs.a &+= rhs.a
        lhs.b &+= rhs.b
        lhs.c &+= rhs.c
        lhs.d &+= rhs.d
        lhs.e &+= rhs.e
    }
    
    init(_ state: borrowing State) {
        a = state.a
        b = state.b
        c = state.c
        d = state.d
        e = state.e
    }
    
    mutating func round(with function: (borrowing Self) -> UInt32, constant: UInt32, word: UInt32) {
        let temp = a.rotated(left: 5) &+ function(self) &+ e &+ constant &+ word
        e = d
        d = c
        c = b.rotated(left: 30)
        b = a
        a = temp
    }
    
    var choice: UInt32 {
        d ^ (b & (c ^ d))
    }
    
    var parity: UInt32 {
        b ^ c ^ d
    }
    
    var majority: UInt32 {
        (b & c) | (d & (b | c))
    }
}
