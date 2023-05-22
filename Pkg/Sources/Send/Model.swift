
import SwiftUI
import TonCore


/// Model class for sending transactions workflow
public final class Model: ObservableObject {
    /// The destination address of the transaction.
    @Published public var destinationAddress: TonAddress?
    /// The amount of Toncoin to send.
    @Published public var amount: Toncoin?
    /// The optional comment for the transaction.
    @Published public var comment: String?
    
    /// A closure that returns the current balance of the sender's account.
    public var currentBalance: () -> Toncoin? = { nil }
    /// A closure that takes a string and returns a resolved TonAddress object asynchronously, throwing an error if the resolution fails.
    public var resolveAddress: (String) async throws -> TonAddress = { _ in throw NSError() }
    /// A closure that takes an OutgoingTransaction object and authorizes it asynchronously, throwing an error if the authorization fails.
    public var authorizeTransaction: (OutgoingTransaction) async throws -> () = { _ in }
    /// A closure that takes an OutgoingTransaction object and sends it asynchronously, throwing an error if the sending fails.
    public var sendTransaction: (OutgoingTransaction) async throws -> () = {_ in }
    
    public init() {}
    
    /// Initializes a new model class for sending transactions workflow.
    /// - Parameters:
    ///   - destinationAddress: The destination address of the transaction. Defaults to nil.
    ///   - amount: The amount of Toncoin to send. Defaults to nil.
    ///   - comment: The optional comment for the transaction. Defaults to nil.
    ///   - currentBalance: A closure that returns the current balance of the sender's account.
    ///   - resolveAddress: A closure that takes a string and returns a resolved TonAddress object asynchronously, throwing an error if the resolution fails.
    ///   - authorizeTransaction: A closure that takes an OutgoingTransaction object and authorizes it asynchronously, throwing an error if the authorization fails.
    ///   - sendTransaction: A closure that takes an OutgoingTransaction object and sends it asynchronously, throwing an error if the sending fails.
    public init(destinationAddress: TonAddress? = nil, amount: Toncoin? = nil, comment: String? = nil, currentBalance: @escaping () -> Toncoin?, resolveAddress: @escaping (String) async throws -> TonAddress, authorizeTransaction: @escaping (OutgoingTransaction) async throws -> (), sendTransaction: @escaping (OutgoingTransaction) async throws -> ()) {
        self.destinationAddress = destinationAddress
        self.amount = amount
        self.comment = comment
        self.currentBalance = currentBalance
        self.resolveAddress = resolveAddress
        self.authorizeTransaction = authorizeTransaction
        self.sendTransaction = sendTransaction
    }
}

extension Model {
    
    /// A static method that returns a mock model with the given parameters and dummy closures.
    /// - Parameters:
    ///   - destinationAddress: The destination address of the transaction. Defaults to nil.
    ///   - amount: The amount of Toncoin to send. Defaults to nil.
    ///   - comment: The optional comment for the transaction. Defaults to nil.
    /// - Returns: A mock model object with the given parameters and dummy closures.
    public static func mock(destinationAddress: TonAddress? = nil, amount: Toncoin? = nil, comment: String? = nil) -> Model {
        return Model(
            destinationAddress: destinationAddress,
            amount: amount,
            comment: comment,
            currentBalance: { Toncoin(nano: 123456) },
            resolveAddress: { _ in throw NSError() },
            authorizeTransaction: { _ in },
            sendTransaction: { _ in }
        )
    }
}

public struct OutgoingTransaction {
    public var destinationAddress: TonAddress
    public var amount: Toncoin
    public var comment: String?
}
