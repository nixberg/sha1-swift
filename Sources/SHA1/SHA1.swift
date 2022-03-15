import Algorithms
import Duplex
import EndianBytes

public struct SHA1: Duplex {
    public typealias Output = [UInt8]
    
    public static var defaultOutputByteCount = 20
    
    private var state: State = .init()
    private var digestedBytes = 0
    
    private var buffer: [UInt8] = []
    
    private var done = false
    
    public init() {}
    
    public mutating func absorb<Bytes>(contentsOf bytes: Bytes)
    where Bytes: Sequence, Bytes.Element == UInt8 {
        assert((0..<64).contains(buffer.count))
        precondition(!done)
        
        for byte in bytes {
            buffer.append(byte)
            digestedBytes += 1
            if buffer.count == 64 {
                self.compress()
            }
        }
    }
    
    public mutating func squeeze<Output>(to output: inout Output, outputByteCount: Int)
    where Output: RangeReplaceableCollection, Output.Element == UInt8 {
        precondition(outputByteCount == Self.defaultOutputByteCount)
        
        assert((0..<64).contains(buffer.count))
        precondition(!done)
        
        buffer.append(0x80)
        if buffer.count - 1 >= 56 {
            buffer.padEnd(with: 0, toCount: 64)
            self.compress()
        }
        buffer.padEnd(with: 0, toCount: 56)
        buffer.append(contentsOf: (8 * UInt64(digestedBytes)).bigEndianBytes())
        
        self.compress(keepingBufferCapacity: false)
        
        output.append(contentsOf: state.a.bigEndianBytes())
        output.append(contentsOf: state.b.bigEndianBytes())
        output.append(contentsOf: state.c.bigEndianBytes())
        output.append(contentsOf: state.d.bigEndianBytes())
        output.append(contentsOf: state.e.bigEndianBytes())
        
        done = true
    }
    
    public mutating func squeeze(outputByteCount: Int) -> Output {        
        var output: [UInt8] = []
        output.reserveCapacity(Self.defaultOutputByteCount)
        self.squeeze(to: &output, outputByteCount: outputByteCount)
        return output
    }
    
    private mutating func compress(keepingBufferCapacity: Bool = true) {
        assert(buffer.count == 64)
        
        withUnsafeTemporaryAllocation(of: UInt32.self, capacity: 80) { expandedBuffer in
            for (i, chunk) in zip(0..<16, buffer.chunks(ofCount: 4)) {
                expandedBuffer
                    .baseAddress!
                    .advanced(by: i)
                    .initialize(to: .init(bigEndianBytes: chunk))
            }
            
            for i in 16..<80 {
                expandedBuffer
                    .baseAddress!
                    .advanced(by: i)
                    .initialize(to: (expandedBuffer[i -  3] ^
                                     expandedBuffer[i -  8] ^
                                     expandedBuffer[i - 14] ^
                                     expandedBuffer[i - 16]).rotated(left: 1))
            }

            var state = self.state
        
            for i in 00..<20 {
                state.round(expandedBuffer[i], state.choice, 0x5a827999)
            }
            for i in 20..<40 {
                state.round(expandedBuffer[i], state.parity, 0x6ed9eba1)
            }
            for i in 40..<60 {
                state.round(expandedBuffer[i], state.majority, 0x8f1bbcdc)
            }
            for i in 60..<80 {
                state.round(expandedBuffer[i], state.parity, 0xca62c1d6)
            }
        
            self.state &+= state
        }
        
        buffer.removeAll(keepingCapacity: keepingBufferCapacity)
    }
}

fileprivate struct State {
    var a: UInt32 = 0x67452301
    var b: UInt32 = 0xefcdab89
    var c: UInt32 = 0x98badcfe
    var d: UInt32 = 0x10325476
    var e: UInt32 = 0xc3d2e1f0
    
    mutating func round(_ word: UInt32, _ f: UInt32, _ k: UInt32) {
        let temporary = a.rotated(left: 5) &+ f &+ e &+ k &+ word
        e = d
        d = c
        c = b.rotated(left: 30)
        b = a
        a = temporary
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
    
    static func &+= (lhs: inout Self, rhs: Self) {
        lhs.a &+= rhs.a
        lhs.b &+= rhs.b
        lhs.c &+= rhs.c
        lhs.d &+= rhs.d
        lhs.e &+= rhs.e
    }
}

// TODO: Remove when available in Algorithms.
fileprivate extension RangeReplaceableCollection {
    mutating func padEnd(with element: Element, toCount paddedCount: Int) {
        let padElementCount = paddedCount - count
        guard padElementCount > 0 else {
            return
        }
        self.append(contentsOf: repeatElement(element, count: padElementCount))
    }
}

fileprivate extension FixedWidthInteger where Self: UnsignedInteger {
    @inline(__always)
    func rotated(left count: Int) -> Self {
        (self &<< count) | (self &>> (Self.bitWidth - count))
    }
}
