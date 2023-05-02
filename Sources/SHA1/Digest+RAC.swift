extension SHA1.Digest: RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Int
    
    @inline(__always)
    public var startIndex: Index {
        0
    }
    
    @inline(__always)
    public var endIndex: Index {
        MemoryLayout<Self>.size
    }
    
    @inline(__always)
    public subscript(position: Index) -> Element {
        precondition(indices.contains(position), "Index out of range")
        return self.withUnsafeBufferPointer {
            $0[position]
        }
    }
    
    @inline(__always)
    public var first: Element {
        self[startIndex]
    }
    
    @inline(__always)
    public var last: Element {
        self[self.index(before: endIndex)]
    }
    
    @inline(__always)
    public func withContiguousStorageIfAvailable<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R? {
        try self.withUnsafeBufferPointer(body)
    }
}

extension SHA1.Digest {
    @inline(__always)
    public func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        try self.withUnsafeBytes {
            try $0.withMemoryRebound(to: UInt8.self, body)
        }
    }
    
    @inline(__always)
    public func withUnsafeBytes<R>(
        _ body: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        try Swift.withUnsafeBytes(of: self, body)
    }
}
