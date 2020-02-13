import Foundation

public struct SHA1 {
    public static let byteCount = 20
    
    private var state: (UInt32, UInt32, UInt32, UInt32, UInt32)
    
    private var buffer = [UInt8](repeating: 0, count: 64)
    private var length: Int = 0
    
    private var expanded = [UInt32](repeating: 0, count: 80)
    
    public init() {
        state = (0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0)
    }
    
    private mutating func compress() {
        var state = self.state
        
        var buffer = self.buffer[...]
        for i in 0..<16 {
            expanded[i] = UInt32(bigEndianBytes: buffer.prefix(4))
            buffer = buffer.dropFirst(4)
        }
        
        for i in 16..<80 {
            expanded[i] = (
                expanded[i -  3] ^
                expanded[i -  8] ^
                expanded[i - 14] ^
                expanded[i - 16]
            ).rotatedLeft(by: 1)
        }
        
        @inline(__always)
        func round(_ i: Int, _ f: UInt32, _ k: UInt32) {
            let t = state.0.rotatedLeft(by: 5) &+ f &+ state.4 &+ k &+ expanded[i]
            state.4 = state.3
            state.3 = state.2
            state.2 = state.1.rotatedLeft(by: 30)
            state.1 = state.0
            state.0 = t
        }
        
        @inline(__always)
        func choice(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            z ^ (x & (y ^ z))
        }
        
        @inline(__always)
        func parity(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            x ^ y ^ z
        }
        
        @inline(__always)
        func majority(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            (x & y) | (z & (x | y))
        }
        
        for i in 0..<20 {
            round(i, choice(state.1, state.2, state.3), 0x5a827999)
        }
        for i in 20..<40 {
            round(i, parity(state.1, state.2, state.3), 0x6ed9eba1)
        }
        for i in 40..<60 {
            round(i, majority(state.1, state.2, state.3), 0x8f1bbcdc)
        }
        for i in 60..<80 {
            round(i, parity(state.1, state.2, state.3), 0xca62c1d6)
        }
        
        self.state.0 &+= state.0
        self.state.1 &+= state.1
        self.state.2 &+= state.2
        self.state.3 &+= state.3
        self.state.4 &+= state.4
    }
    
    public mutating func update<D>(with input: D) where D: DataProtocol {
        var index = length % 64
        length += input.count
        
        for byte in input {
            buffer[index] = byte
            index += 1
            
            if index == 64 {
                self.compress()
                index = 0
            }
        }
    }
    
    public mutating func finalize<M>(into output: inout M) where M: MutableDataProtocol {
        let index = length % 64
        
        buffer[index] = 0x80
        buffer.resetBytes(in: (index + 1)..<64)
        
        if index >= 56 {
            self.compress()
            buffer.resetBytes(in: 0..<64)
        }
        
        for (i, byte) in (8 * length).bigEndianBytes.enumerated() {
            buffer[56 + i] = byte
        }
        self.compress()
        
        output.append(contentsOf: state)
    }
    
    public mutating func finalize() -> [UInt8] {
        var output = [UInt8]()
        output.reserveCapacity(Self.byteCount)
        self.finalize(into: &output)
        return output
    }
}

public extension SHA1 {
    static func hash<D, M>(_ input: D, into output: inout M) where D: DataProtocol, M: MutableDataProtocol {
        var sha1 = SHA1()
        sha1.update(with: input)
        sha1.finalize(into: &output)
    }
    
    static func hash<D>(_ input: D) -> [UInt8] where D: DataProtocol {
        var sha1 = SHA1()
        sha1.update(with: input)
        return sha1.finalize()
    }
}

fileprivate extension UInt32 {
    init<D>(bigEndianBytes bytes: D) where D: DataProtocol {
        assert(bytes.count == 4)
        self = bytes.reduce(0, { $0 &<< 8 | Self($1) })
    }
    
    var bigEndianBytes: [UInt8] {
        (0..<4).reversed().map { UInt8(truncatingIfNeeded: self &>> ($0 * 8)) }
    }
    
    @inline(__always)
    func rotatedLeft(by n: Int) -> Self {
        (self &<< n) | (self &>> (32 - n))
    }
}

fileprivate extension Int {
    var bigEndianBytes: [UInt8] {
        let bitPattern = UInt64(bitPattern: Int64(self))
        return (0..<8).reversed().map { UInt8(truncatingIfNeeded: bitPattern &>> ($0 * 8)) }
    }
}

fileprivate extension MutableDataProtocol {
    mutating func append(contentsOf state: (UInt32, UInt32, UInt32, UInt32, UInt32)) {
        self.append(contentsOf: state.0.bigEndianBytes)
        self.append(contentsOf: state.1.bigEndianBytes)
        self.append(contentsOf: state.2.bigEndianBytes)
        self.append(contentsOf: state.3.bigEndianBytes)
        self.append(contentsOf: state.4.bigEndianBytes)
    }
}
