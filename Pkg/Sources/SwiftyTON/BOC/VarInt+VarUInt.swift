
import Foundation


public struct VarInt {
    
    public var value: Int64
    public let size: Int
    
    /// Arbitrary size signed integer
    /// - Parameters:
    ///   - value: Underlying `Int64` value
    ///   - size: Size in bits (1...64)
    public init(_ value: Int64, size: Int) {
        precondition(size > 0 && size <= 64, "VarInt size must be greater than 0 and not greater than 64")
        self.value = value
        self.size = size
    }
}


public struct VarUInt {
    
    public var value: UInt64
    public let size: Int
    
    /// Arbitrary size unsigned integer
    /// - Parameters:
    ///   - value: Underlying `UInt64` value
    ///   - size: Size in bits (1...64)
    public init(_ value: UInt64, size: Int) {
        precondition(size > 0 && size <= 64, "VarUInt size must be greater than 0 and not greater than 64")
        self.value = value
        self.size = size
    }
}

