extension SHA1 {
    public struct Digest {
        private var a: UInt32
        private var b: UInt32
        private var c: UInt32
        private var d: UInt32
        private var e: UInt32
        
        init(state: consuming State) {
            a = state.a.bigEndian
            b = state.b.bigEndian
            c = state.c.bigEndian
            d = state.d.bigEndian
            e = state.e.bigEndian
        }
    }
}

extension SHA1.Digest: RandomAccessCollection {
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        20
    }
    
    public subscript(index: Int) -> UInt8 {
        precondition(indices.contains(index), "Index out of range")
        return self.withUnsafeBufferPointer {
            $0[index]
        }
    }
    
    public func withContiguousStorageIfAvailable<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R? {
        try self.withUnsafeBufferPointer(body)
    }
}

extension SHA1.Digest {
    public func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        try self.withUnsafeBytes {
            try $0.withMemoryRebound(to: UInt8.self, body)
        }
    }
    
    public func withUnsafeBytes<R>(
        _ body: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        try Swift.withUnsafeBytes(of: self, body)
    }
}
