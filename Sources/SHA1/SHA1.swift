public struct SHA1: ~Copyable {
    private var state = State()
    
    private var buffer: Buffer = []
    private var digestedBitsCount: UInt64 = 0
    
    public init() {
        buffer.reserveCapacity(320)
    }
    
    public mutating func append(_ newElement: UInt8) {
        buffer.append(newElement)
        digestedBitsCount += 8
        
        if buffer.count == 64 {
            state.compress(&buffer)
            buffer.removeAll(keepingCapacity: true)
        }
    }
    
    public mutating func append(contentsOf newElements: some Sequence<UInt8>) {
        for newElement in newElements {
            self.append(newElement)
        }
    }
    
    public consuming func finalized() -> Digest {
        self.finalize()
        return Digest(state: (consume self).state)
    }
    
    // Workaround for "Overlapping accesses to 'self'"
    private mutating func finalize() {
        buffer.append(0x80)
        
        if buffer.count > 56 {
            buffer.fill(with: 0, toCount: 64)
            state.compress(&buffer)
            buffer.removeAll(keepingCapacity: true)
        }
        
        buffer.fill(with: 0, toCount: 56)
        withUnsafeBytes(of: digestedBitsCount.bigEndian) {
            buffer.append(contentsOf: $0)
        }
        
        state.compress(&buffer)
    }
}

extension SHA1 {
    public static func hash(contentsOf elements: some Sequence<UInt8>) -> Digest {
        var hashFunction = Self()
        hashFunction.append(contentsOf: elements)
        return hashFunction.finalized()
    }
}
