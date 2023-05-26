
import Foundation
import SwiftyTON


public struct Toncoin: Hashable, Codable {
    public var nano: Int
    
    public init(nano: Int) {
        self.nano = nano
    }
}

extension Toncoin: CustomStringConvertible {
    
    public var description: String {
        let v = Double(nano) / 1_000_000_000
        var s: String
        if abs(v) < 0.001 {
            s = String(format: "%.9f Toncoin", v)
        } else {
            s = String(format: "%.3f Toncoin", v)
        }
        return s
    }
}
