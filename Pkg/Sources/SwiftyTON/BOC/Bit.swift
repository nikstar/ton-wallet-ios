
import Foundation

public struct Bit: ExpressibleByIntegerLiteral, Hashable {
    
    let value: Int
    
    public init<I: BinaryInteger>(_ value: I) {
        precondition(value == 0 || value == 1, "Bit must be 1 or 0")
        self.value = (value & 1 == 1) ? 1 : 0
    }

    public init(_ value: Bool) {
        self.value = value ? 1 : 0
    }

    public init(integerLiteral value: Int) {
        precondition(value == 0 || value == 1, "Bit must be 1 or 0")
        self.value = value & 1
    }
    
}

