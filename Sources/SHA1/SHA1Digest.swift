import HexString

extension SHA1 {
    public struct Digest {
        var bytes = Array20<UInt8>()
    }
}

extension SHA1.Digest: CustomStringConvertible {
    public var description: String {
        "\("SHA-1") digest: \(bytes.hexString())"
    }
}

extension SHA1.Digest: RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Int
    
    @inline(__always)
    public var startIndex: Index {
        bytes.startIndex
    }
    
    @inline(__always)
    public var endIndex: Index {
        bytes.endIndex
    }
    
    @inline(__always)
    public subscript(position: Index) -> Element {
        bytes[position]
    }
}

#if canImport(Subtle)
import Subtle

extension SHA1.Digest: ConstantTimeEquatable {}

extension SHA1.Digest: Zeroizable {
    public mutating func zeroize() {
        bytes.zeroize()
    }
}
#endif
