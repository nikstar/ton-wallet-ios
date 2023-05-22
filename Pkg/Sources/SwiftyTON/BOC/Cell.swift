
import Foundation
import Algorithms


public let MAX_BITS = 1023
public let MAX_REFS = 4


public struct Cell: Hashable {
    
    public let bits: [Bit]
    public let refs: [Cell]
    
    public init(bits: [Bit] = [], refs: [Cell] = []) {
        precondition(bits.count <= MAX_BITS, "Cell cannot store more than 1023 bits")
        precondition(refs.count <= MAX_REFS, "Cell cannot store more than 4 refs")
        self.bits = bits
        self.refs = refs
    }
    
    public init(@Builder builder: () -> Cell) {
        self = builder()
    }
}


extension Cell: CustomStringConvertible {

    public var description: String {
        var s = ""
        for chunk in bits.chunks(ofCount: 4) {
            s += _4Bits(Array(chunk))
        }
        if s.count % 2 == 1 {
            s += "_"
        }
        s = "\(bits.count)[" + s + "]"
        return s
    }
    
    private func _4Bits(_ bits: [Bit]) -> String {
        var bits = bits
        if bits.count < 4 {
            bits = bits + [Bit](repeating: 0, count: 4 - bits.count)
        }
        var v = 0
        for bit in bits {
            v *= 2
            v += bit.value
        }
        return String(v, radix: 16)
    }
}



