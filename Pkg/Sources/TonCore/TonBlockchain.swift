
import Foundation
import SwiftyTON


public actor TonBlockchain: ObservableObject {
    
    var isInitialized = false
    
    private var deliveredBalance = false
    private var deliveredTransavtions = false
    
    
    public init() { }
    
    public nonisolated func balanceForAddress(_ address: TonAddress) -> AsyncStream<Toncoin?> {
        return AsyncStream(unfolding: { [self] in
            do {
                if await deliveredBalance {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } else {
                    await setDeliveredBalance(true)
                }
                let c = try await Contract(address: address.toSwiftyAddress())
                return Toncoin(nano: Int(c.info.balance.value))
            } catch {
                return nil
            }
            
        }, onCancel: { Task { await self.setDeliveredBalance(false) } })
    }
    
    private func setDeliveredBalance(_ v: Bool) {
        deliveredBalance = v
    }
    
    private func setDeliveredTransactions(_ v: Bool) {
        deliveredTransavtions = v
    }
    
    public nonisolated func transactionsForAddress(_ address: TonAddress) -> AsyncStream<[TonTransaction]> {
        return AsyncStream { [self] in
            do {
                if await deliveredTransavtions {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } else {
                    await setDeliveredTransactions(true)
                }
                let c = try await Contract(address: address.toSwiftyAddress())
                let ts = try await c.transactions(after: nil)
                var transactions: [TonTransaction] = []
                for t in ts {
                    print(t)
                    if let inMessage = t.in, let fromRaw = inMessage.sourceAccountAddress {
                        let from = TonAddress.fromSwiftyAddress(fromRaw.address)
                        let value = Toncoin(nano: Int(inMessage.value.value))
                        var message: String? = nil
                        if case .text(let m) = inMessage.body {
                            message = m
                        }
                        transactions.append(TonTransaction(id: t.id, direction: .incoming, from: from, to: address, value: value, date: t.date, message: message))
                    } else if let outMessage = t.out.first, let toRaw = outMessage.destinationAccountAddress {
                        let to = TonAddress.fromSwiftyAddress(toRaw.address)
                        let value = Toncoin(nano: Int(outMessage.value.value))
                        var message: String? = nil
                        if case .text(let m) = outMessage.body {
                            message = m
                        }
                        transactions.append(TonTransaction(id: t.id, direction: .outgoing, from: address, to: to, value: value, date: t.date, message: message))
                    } else {
                        transactions.append(TonTransaction(id: t.id, direction: .outgoing, from: address, to: address, value: Toncoin(nano: 0), date: t.date, message: nil))
                    }
                }
                return transactions
            } catch {
                print(error)
                return []
            }
        }
    }
    
    
    public nonisolated func sendTransaction(usingWallet wallet: TonWallet, to destinationAddress: TonAddress, amount: Toncoin, comment: String?) async throws {
        do {
            let myAddress = wallet.address.toSwiftyAddress()
            var myContract = try await Contract(address: myAddress)
            
            let selectedContractInfo = myContract.info
            print(myContract)
            print(myContract.info)
            print(myContract.info.balance)
            
            print(try! await myContract.transactions(after: nil))
            
            switch myContract.kind {
            case .none:
                fatalError()
            case .uninitialized: // for uninited state we should pass initial data
                myContract = Contract(
                    address: myAddress,
                    info: selectedContractInfo,
                    kind: .walletV4R2,
                    data: .zero // will be created automatically
                )
            default:
                break
            }
            
            guard let myAnyWallet = AnyWallet(contract: myContract) else {
                fatalError()
            }
            
            let key = try await Key.import(password: Data(), words: wallet.keyPair.seedPhrase.words)
            
            
            let message = try await myAnyWallet.subsequentTransferMessage(
                to: ConcreteAddress(address: destinationAddress.toSwiftyAddress()),
                amount: Currency(value: Int64(amount.nano)),
                message: (comment?.data(using: .utf8), nil),
                key: key,
                passcode: Data()
            )
            
            let fees = try await message.fees() // get estimated fees
            print("Estimated fees - \(fees)")
            
            try await message.send() // send transaction
        } catch {
            throw error
        }
    }
}

