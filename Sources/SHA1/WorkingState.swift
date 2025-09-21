import CryptoExtras

// TODO: FB13498502: Noncopyable struct + key path compiler bug

struct WorkingState {
    var a: UInt32
    var b: UInt32
    var c: UInt32
    var d: UInt32
    var e: UInt32

    private init(a: UInt32, b: UInt32, c: UInt32, d: UInt32, e: UInt32) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
    }

    init(_ state: borrowing State) {
        a = state[0]
        b = state[1]
        c = state[2]
        d = state[3]
        e = state[4]
    }

    mutating func round0(with word: UInt32) {
        self.round(with: \.choice, constant: 0x5a82_7999, word: word)
    }

    mutating func round1(with word: UInt32) {
        self.round(with: \.parity, constant: 0x6ed9_eba1, word: word)
    }

    mutating func round2(with word: UInt32) {
        self.round(with: \.majority, constant: 0x8f1b_bcdc, word: word)
    }

    mutating func round3(with word: UInt32) {
        self.round(with: \.parity, constant: 0xca62_c1d6, word: word)
    }

    private mutating func round(
        with function: (borrowing Self) -> UInt32,
        constant: UInt32,
        word: UInt32
    ) {
        self = Self(
            a: a.rotated(left: 05) &+ function(self) &+ e &+ constant &+ word,
            b: a,
            c: b.rotated(left: 30),
            d: c,
            e: d,
        )
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
}
