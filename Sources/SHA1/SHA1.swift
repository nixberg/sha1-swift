import CryptoExtras

public typealias SHA1 = CoreWrapper<InlineByteBuffer<64>, SHA1Core>

public struct SHA1Core: ~Copyable, InitCore, FixedSizeOutputCore, UpdateCore {
    public static let blockByteCount = 64

    public static let outputByteCount = 20

    private var state = State()

    private var messageByteCount = 0

    public init() {}

    public mutating func update(withBlock block: borrowing RawSpan) {
        precondition(block.byteCount == Self.blockByteCount, "TODO")
        state.compress(block)
        messageByteCount += Self.blockByteCount
    }

    public mutating func finalize<Buffer>(
        withBuffer buffer: inout Buffer,
        into output: inout MutableRawSpan
    ) where Buffer: ~Copyable & ByteBufferProtocol {
        precondition(Buffer._capacity == Self.blockByteCount, "TODO")
        precondition(output.byteCount == Self.outputByteCount, "TODO")

        messageByteCount += buffer.count
        buffer.append(0x80)

        if buffer.count > 56 {
            buffer.pad()
            state.compress(buffer.bytes)
            buffer.removeAll()
        }

        buffer.pad(toCount: 56)
        buffer.append(contentsOf: UInt64(messageByteCount * 8).bigEndian.bytes)
        state.compress(buffer.bytes)

        state.storeBytes(into: &output)
    }
}

extension UInt64 {
    fileprivate var bytes: RawSpan {
        @_lifetime(borrow self)
        _read {
            let result: [1 of Self] = [self]
            yield result.span.bytes
        }
    }
}
