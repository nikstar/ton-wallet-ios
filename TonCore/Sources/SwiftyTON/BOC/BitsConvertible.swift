
import Algorithms
import CryptoSwift
import Foundation


public protocol BitsConvertible {
    var bits: [Bit] { get }
}


public extension BitsConvertible {
    var bytes: [UInt8] {
        bits.bytes
    }
}


extension FixedWidthInteger {
    
    var bits: [Bit] {
        let n = bitWidth
        var bits = [Bit](repeating: 0, count: n)
        var v = self
        for i in (0..<n).reversed() {
            bits[i] = Bit(v & 1)
            v >>= 1
        }
        return bits
    }
}


extension VarUInt: BitsConvertible {
    
    public var bits: [Bit] {
        var bits = [Bit](repeating: 0, count: size)
        var v = value
        for i in (0..<size).reversed() {
            bits[i] = Bit(v & 1)
            v >>= 1
        }
        return bits
    }
}


extension VarInt: BitsConvertible {
    
    public var bits: [Bit] {
        
        var bits = [Bit](repeating: 0, count: size)
        var v = value
        for i in (0..<size).reversed() {
            bits[i] = Bit(v & 1)
            v >>= 1
        }
        return bits
    }
}


extension IntN: BitsConvertible {
    
    public var bits: [Bit] {
        var bits = [Bit](repeating: 0, count: nBits)
        var v = value
        for i in (0..<nBits).reversed() {
            bits[i] = Bit(v & 1)
            v >>= 1
        }
        return bits
    }
}


extension Array: BitsConvertible where Element: BitsConvertible {
    
    public var bits: [Bit] {
        self.flatMap(\.bits)
    }
}


extension Data: BitsConvertible {
    
    public var bits: [Bit] {
        bytes.flatMap(\.bits)
    }
}
