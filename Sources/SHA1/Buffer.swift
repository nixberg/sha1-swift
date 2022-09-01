struct Buffer {
    typealias Element = UInt8
    
    typealias Storage = Array64<Element>
    
    private var storage = Storage()
    
    var endIndex = 0
    
    @inline(__always)
    var isFull: Bool {
        endIndex == storage.endIndex
    }
    
    mutating func append(_ byte: UInt8) {
        storage[endIndex] = byte
        endIndex += 1
    }
    
    mutating func append(contentsOf bytes: some Sequence<UInt8>) {
        for byte in bytes {
            self.append(byte)
        }
    }
    
    mutating func removeAll() {
        endIndex = 0
    }
    
    mutating func padWithZeros(toCount paddedCount: Int = Storage.count) {
        assert((storage.startIndex...storage.endIndex).contains(endIndex))
        let padElementCount = paddedCount - count
        guard padElementCount > 0 else {
            return
        }
        self.append(contentsOf: repeatElement(0, count: padElementCount))
    }
}

extension Buffer: RandomAccessCollection {
    typealias Index = Int
    
    @inline(__always)
    var startIndex: Index {
        0
    }
    
    @inline(__always)
    subscript(position: Index) -> Element {
        storage[unchecked: position]
    }
}

extension Buffer: ExpressibleByArrayLiteral {
    init(arrayLiteral: Element...) {
        self.init()
        self.append(contentsOf: arrayLiteral)
    }
}
