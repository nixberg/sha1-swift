import Foundation

public struct SHA1 {
    public static let byteCount = 20
    
    private var state: (UInt32, UInt32, UInt32, UInt32, UInt32)
    
    private var buffer: SIMD64<UInt8> = .zero
    private var digestedBytes: Int = 0
    
    private var expanded = [UInt32](repeating: 0, count: 80)
    
    private var done = false
    
    public init() {
        state = (0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0)
    }
    
    public mutating func update<Input>(with input: Input) where Input: DataProtocol {
        var index = digestedBytes % 64
        digestedBytes += input.count
        
        for byte in input {
            buffer[index] = byte
            index += 1
            
            if index == 64 {
                self.compress()
                index = 0
            }
        }
    }
    
    public mutating func finalize<Output>(to output: inout Output) where Output: MutableDataProtocol {
        precondition(!done)
        done = true
        
        let index = digestedBytes % 64
        
        buffer[index] = 0x80
        for i in (index + 1)..<64 {
            buffer[i] = 0
        }
        
        if index >= 56 {
            self.compress()
            for i in 0..<56 {
                buffer[i] = 0
            }
        }
        
        let digestedBits = 8 * UInt64(digestedBytes)
        buffer[56] = UInt8(truncatingIfNeeded: digestedBits &>> 56)
        buffer[57] = UInt8(truncatingIfNeeded: digestedBits &>> 48)
        buffer[58] = UInt8(truncatingIfNeeded: digestedBits &>> 40)
        buffer[59] = UInt8(truncatingIfNeeded: digestedBits &>> 32)
        buffer[60] = UInt8(truncatingIfNeeded: digestedBits &>> 24)
        buffer[61] = UInt8(truncatingIfNeeded: digestedBits &>> 16)
        buffer[62] = UInt8(truncatingIfNeeded: digestedBits &>>  8)
        buffer[63] = UInt8(truncatingIfNeeded: digestedBits &>>  0)
        
        self.compress()
        
        output.append(bigEndianBytesOf: state.0)
        output.append(bigEndianBytesOf: state.1)
        output.append(bigEndianBytesOf: state.2)
        output.append(bigEndianBytesOf: state.3)
        output.append(bigEndianBytesOf: state.4)
    }
    
    public mutating func finalize() -> [UInt8] {
        var output = [UInt8]()
        output.reserveCapacity(Self.byteCount)
        self.finalize(to: &output)
        return output
    }
    
    private mutating func compress() {
        var state = self.state
        
        expanded.removeAll(keepingCapacity: true)
        
        var indices = buffer.indices
        for _ in 0..<16 {
            expanded.append(indices.prefix(4).reduce(0) { ($0 &<< 8) | UInt32(buffer[$1]) })
            indices = indices.dropFirst(4)
        }
        
        for i in 16..<80 {
            expanded.append((expanded[i -  3] ^
                             expanded[i -  8] ^
                             expanded[i - 14] ^
                             expanded[i - 16]).rotated(left: 1))
        }
        
        @inline(__always)
        func round(_ i: Int, _ f: UInt32, _ k: UInt32) {
            let t = state.0.rotated(left: 5) &+ f &+ state.4 &+ k &+ expanded[i]
            state.4 = state.3
            state.3 = state.2
            state.2 = state.1.rotated(left: 30)
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
}

public extension SHA1 {
    static func hash<Input, Output>(_ input: Input, into output: inout Output) where Input: DataProtocol, Output: MutableDataProtocol {
        var hashFunction = Self()
        hashFunction.update(with: input)
        hashFunction.finalize(to: &output)
    }
    
    static func hash<Input>(_ input: Input) -> [UInt8] where Input: DataProtocol {
        var hashFunction = Self()
        hashFunction.update(with: input)
        return hashFunction.finalize()
    }
}

fileprivate extension FixedWidthInteger where Self: UnsignedInteger {
    @inline(__always)
    func rotated(left count: Int) -> Self {
        (self &<< count) | (self &>> (Self.bitWidth - count))
    }
}

fileprivate extension MutableDataProtocol {
    @inline(__always)
    mutating func append(bigEndianBytesOf word: UInt32) {
        self.append(UInt8(truncatingIfNeeded: word &>> 24))
        self.append(UInt8(truncatingIfNeeded: word &>> 16))
        self.append(UInt8(truncatingIfNeeded: word &>>  8))
        self.append(UInt8(truncatingIfNeeded: word &>>  0))
    }
}
