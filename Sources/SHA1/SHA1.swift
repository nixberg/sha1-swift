import Algorithms
import Duplex
import EndianBytes

public struct SHA1: Duplex {
    
    public typealias Output = [UInt8]
    
    public static var defaultOutputByteCount = 20
    
    private var state = State()
    
    private var buffer: Buffer = []
    private var digestedBits: UInt64 = 0
    
    private var done = false
    
    public init() {}
    
    public mutating func absorb(contentsOf bytes: some Sequence<UInt8>) {
        precondition(!done)
        for byte in bytes {
            buffer.append(byte)
            digestedBits += 8
            if buffer.isFull {
                self.compress()
            }
        }
    }
    
    public mutating func squeeze(
        to output: inout some RangeReplaceableCollection<UInt8>,
        outputByteCount: Int
    ) {
        precondition(
            outputByteCount == Self.defaultOutputByteCount,
            "SHA-1 does not support arbitrary-length outputs"
        )
        precondition(!done)
        
        buffer.append(0x80)
        if buffer.count > 56 {
            buffer.padWithZeros()
            self.compress()
        }
        buffer.padWithZeros(toCount: 56)
        buffer.append(contentsOf: digestedBits.bigEndianBytes())
        
        self.compress()
        
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
    
    private mutating func compress() {
        assert(buffer.isFull)
        
        var expandedBuffer: Array80<UInt32> = .init(repeating: 0)
        
        for (i, chunk) in zip(expandedBuffer.indices.prefix(16), buffer.chunks(ofCount: 4)) {
            expandedBuffer[i] = UInt32(bigEndianBytes: chunk)
        }
        
        for i in expandedBuffer.indices.dropFirst(16) {
            expandedBuffer[i] = (
                expandedBuffer[i -  3] ^
                expandedBuffer[i -  8] ^
                expandedBuffer[i - 14] ^
                expandedBuffer[i - 16]
            ).rotated(left: 1)
        }
        
        var state = self.state
        
        for word in expandedBuffer.dropFirst(00).prefix(20) {
            state.performRound(with: word, state.choice, 0x5a827999)
        }
        for word in expandedBuffer.dropFirst(20).prefix(20) {
            state.performRound(with: word, state.parity, 0x6ed9eba1)
        }
        for word in expandedBuffer.dropFirst(40).prefix(20) {
            state.performRound(with: word, state.majority, 0x8f1bbcdc)
        }
        for word in expandedBuffer.dropFirst(60).prefix(20) {
            state.performRound(with: word, state.parity, 0xca62c1d6)
        }
        
        self.state &+= state
        
        buffer.removeAll()
    }
}

// TODO: Remove when available in Numerics.
extension FixedWidthInteger where Self: UnsignedInteger {
    @inline(__always)
    func rotated(left count: Int) -> Self {
        (self &<< count) | (self &>> (Self.bitWidth - count))
    }
}
