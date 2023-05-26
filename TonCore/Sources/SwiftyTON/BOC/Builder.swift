
import Foundation


@resultBuilder public struct Builder {
    
    public let bits: [Bit]
    public let refs: [Cell]
    
    public init(bits: [Bit] = [], refs: [Cell] = []) {
        precondition(bits.count <= MAX_BITS, "Builder cannot store more than 1023 bits")
        precondition(refs.count <= MAX_REFS, "Builder cannot store more than 4 refs")
        self.bits = bits
        self.refs = refs
    }
    
    static func buildExpression(_ expression: Bit) -> Builder {
        Builder(bits: [expression])
    }
    
    static func buildExpression(_ expression: [Bit]) -> Builder {
        Builder(bits: expression)
    }
    
    static func buildExpression<I: FixedWidthInteger>(_ expression: I) -> Builder {
        Builder(bits: expression.bits)
    }
    
    static func buildExpression<B: BitsConvertible>(_ expression: B) -> Builder {
        Builder(bits: expression.bits)
    }
    
    static func buildBlock(_ components: Builder...) -> Builder {
        Builder(
            bits: components.flatMap(\.bits),
            refs: components.flatMap(\.refs)
        )
    }
    
    static func buildFinalResult(_ component: Builder) -> Cell {
        Cell(bits: component.bits, refs: component.refs)
    }
}
