
import SwiftUI
import SharedUI
import TonCore
import SwiftUIBackports
import AppState


public struct SendView: View {
    
    @StateObject private var model: Model = Model()
    
    @EnvironmentObject var appState: AppState
    @Environment(\.backportDismiss) var dismiss
    
    @State var sendAddressString: String = ""
    @State var sendAll = false
    
    @State var addressText: String = ""
    @State var addressIsFocused: Bool = false
    
    // initial parameters
    var destinationAddress: TonAddress?
    var amount: Toncoin?
    var comment: String?
    var currentBalance: () -> Toncoin? = { nil }
    var resolveAddress: (String) async throws -> TonAddress = { _ in throw NSError() }
    var authorizeTransaction: (OutgoingTransaction) async throws -> () = { _ in }
    var sendTransaction: (OutgoingTransaction) async throws -> () = {_ in }
        
    
    @State var commentText = ""

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
        
        print("init", self)
    }
    
    public var body: some View {
        Group {
            if #available(iOS 16, *) {
                NavigationStack {
                    rootView
                }
            } else {
                NavigationView {
                    rootView
                }
            }
        }
        .onAppear {
            
            self.model.destinationAddress = appState.requestedTonURL?.address
            self.model.amount = appState.requestedTonURL?.amount
            self.model.comment = appState.requestedTonURL?.text
            self.model.currentBalance = currentBalance
            self.model.resolveAddress = resolveAddress
            self.model.authorizeTransaction = authorizeTransaction
            self.model.sendTransaction = sendTransaction
        }
        .onChange(of: appState.requestedTonURL) { requestedTonURL in
            guard let requestedTonURL else { return }
            self.model.destinationAddress = requestedTonURL.address
            self.model.amount = requestedTonURL.amount
            self.model.comment = requestedTonURL.text
        }
    }
    
    var rootView: some View {
        EnterAddressView(
        next: {
            amountView
        })
    }
    
    var amountView: some View {
        AmountView()
    }
    
    var commentView: some View {
        EmptyView()
    }
}

