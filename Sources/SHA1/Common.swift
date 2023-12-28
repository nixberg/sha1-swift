typealias Buffer = ContiguousArray<UInt8>

extension Buffer {
    mutating func fill(with element: Element, toCount wantedCount: Int) {
        let missingCount = wantedCount - count
        assert(missingCount > 0)
        self.append(contentsOf: repeatElement(element, count: missingCount))
    }
}

extension UInt32 {
    func rotated(left count: Int) -> Self {
        self &<< count | self &>> (Self.bitWidth - count)
    }
}
