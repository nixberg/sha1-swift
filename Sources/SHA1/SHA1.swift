import Algorithms
@_exported
import Duplex
import EndianBytes

public struct SHA1: Duplex {
    public static var defaultOutputByteCount = 20
    
    private var state = State()
    
    private var buffer: Buffer = []
    private var digestedBits: UInt64 = 0
    
    private var done = false
    
    public init() {}
    
    public mutating func absorb(contentsOf bytes: some ByteSequence) {
        precondition(!done, "SHA-1 used after finalization")
        for byte in bytes {
            buffer.append(byte)
            digestedBits += 8
            if buffer.isFull {
                self.compress()
            }
        }
    }
    
    public mutating func squeeze(to byteSink: inout some ByteSink, outputByteCount: Int) {
        precondition(
            outputByteCount == Self.defaultOutputByteCount,
            "SHA-1 does not support arbitrary-length outputs"
        )
        precondition(!done, "SHA-1 used after finalization")
        
        buffer.append(0x80)
        if buffer.count > 56 {
            buffer.padWithZeros()
            self.compress()
        }
        buffer.padWithZeros(toCount: 56)
        buffer.append(contentsOf: digestedBits.bigEndianBytes())
        
        self.compress()
        
        byteSink.write(contentsOf: state.a.bigEndianBytes())
        byteSink.write(contentsOf: state.b.bigEndianBytes())
        byteSink.write(contentsOf: state.c.bigEndianBytes())
        byteSink.write(contentsOf: state.d.bigEndianBytes())
        byteSink.write(contentsOf: state.e.bigEndianBytes())
        
        done = true
    }
    
    private mutating func compress() {
        assert(buffer.isFull)
        
        var expandedBuffer: Array80<UInt32> = .init(repeating: 0)
        
        for (index, chunk) in zip(expandedBuffer.indices.prefix(16), buffer.chunks(ofCount: 4)) {
            expandedBuffer[index] = UInt32(bigEndianBytes: chunk)
        }
        
        for index in expandedBuffer.indices.dropFirst(16) {
            expandedBuffer[index] = (
                expandedBuffer[index -  3] ^
                expandedBuffer[index -  8] ^
                expandedBuffer[index - 14] ^
                expandedBuffer[index - 16]
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

extension SHA1: FixedSizeOutputProtocol {
    public typealias FixedSizeOutput = SHA1.Digest
    
    public mutating func squeeze() -> FixedSizeOutput {
        var output = FixedSizeOutput()
        self.squeeze(into: &output.bytes)
        return output
    }
}

// TODO: Remove when available in Numerics.
extension FixedWidthInteger where Self: UnsignedInteger {
    @inline(__always)
    func rotated(left count: Int) -> Self {
        (self &<< count) | (self &>> (Self.bitWidth - count))
    }
}
