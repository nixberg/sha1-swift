extension SHA1.Digest: RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Int
    
    public var startIndex: Index {
        0
    }
    
    public var endIndex: Index {
        MemoryLayout<Self>.size
    }
    
    public subscript(position: Index) -> Element {
        precondition(indices.contains(position), "Index out of range")
        return self.withUnsafeBufferPointer {
            $0[position]
        }
    }
    
    public var first: Element {
        self[startIndex]
    }
    
    public var last: Element {
        self[self.index(before: endIndex)]
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
