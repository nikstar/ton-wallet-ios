
import Foundation
import SwiftyTON

public struct TonTransaction: Hashable, Codable {
    
    public typealias ID = Transaction.ID
    
    public enum Direction: Codable {
        case incoming, outgoing
    }
    
    public let id: ID
    public let direction: Direction
    public let from: TonAddress
    public let to: TonAddress
    public let value: Toncoin
    public let date: Date
    public let message: String?
}

public extension TonTransaction {
    
    var counterparty: TonAddress {
        if direction == .incoming {
            return from
        } else {
            return to
        }
    }
}

extension TonTransaction: CustomStringConvertible {
    
    public var description: String {
        var s = "Transaction[\(from) -> \(to), \(value)"
        if let message {
            s += ", \"\(message)\"]"
        } else {
            s += "]"
        }
        return s
    }
}

