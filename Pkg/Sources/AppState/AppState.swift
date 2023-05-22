
import SwiftUI
import SwiftyTON
import TonCore
import Collections
import Combine
import SwiftUIBackports

// key
// (Key + wallet type) -> address
// Address -> balance, transactions

@MainActor
public final class AppState: ObservableObject {
    
    @Published private(set) public var setupComplete: Bool
    @Published private(set) public var wallet: TonWallet?
    @Published private(set) public var passcode: String
    @Published /*private(set) */ public var biometricsEnabled: Bool
    
    @Published private(set) public var currentBalance: Toncoin?
    @Published private(set) public var currentTransactions: [TonTransaction] = []
    @Published private(set) public var currentTransactionsGroupedByDate: OrderedDictionary<DateComponents, [TonTransaction]> = [:]
    @Published private(set) public var currentTransactionsLoadedAtLeastOnce = false
    
    @Published public var requestedTonURL: TonURL?
    
    private let storage = AppStorage()
    private let cache = AppCache()
    
    private var currentBalanceTask: Task<Void, Never>?
    private var currentTransactionsTask: Task<Void, Never>?
    private var storageObservables: Set<AnyCancellable> = []
    
    private var tonBlockchain = TonBlockchain()
    
    public init(setupComplete: Bool, wallet: TonWallet?, passcode: String, biometricsEnabled: Bool) {
        self.setupComplete = setupComplete
        self.wallet = wallet
        self.passcode = passcode
        self.biometricsEnabled = biometricsEnabled
    }
    
    // MARK: - Updating
    
    public func setWallet(_ newWallet: TonWallet) async {
        guard newWallet != self.wallet else { return }
        self.wallet = newWallet
        self.currentBalanceTask?.cancel()
        self.currentBalanceTask = Task { [weak self] in
            for await v in tonBlockchain.balanceForAddress(newWallet.address) {
                if Task.isCancelled {
                    return
                }
                guard let self else { return }
                self.currentBalance = v
            }
        }
        self.currentTransactionsTask?.cancel()
        self.currentTransactionsLoadedAtLeastOnce = false
        self.currentTransactionsTask = Task { [weak self] in
            for await txs in tonBlockchain.transactionsForAddress(newWallet.address) {
                guard !Task.isCancelled, let self else { return }
                if txs.isEmpty {
                    self.currentTransactionsLoadedAtLeastOnce = true
                    return
                }
                self.currentTransactions = txs
                self.currentTransactionsGroupedByDate = OrderedDictionary(grouping: txs) { tx in
                    Calendar.current.dateComponents([.year, .month, .day], from: tx.date)
                }
                self.currentTransactionsLoadedAtLeastOnce = true
            }
        }
    }
    
    public func setSetupComplete(_ value: Bool) {
        self.setupComplete = value
    }
    
    public func setPasscode(_ value: String) {
        self.passcode = value
    }
    
    // MARK: - Persistence
    
    public static func load() -> AppState {
        let storage = AppStorage()
        
        let setupComplete = storage.get("setupComplete", default: false)
        
        let a: AppState
        if !setupComplete {
            a = AppState(setupComplete: false, wallet: nil, passcode: "", biometricsEnabled: false)
        } else {
            struct DecodingError: Error {}
            
            do {
                let wallet = try storage.get("wallet", ofType: Optional<TonWallet>.self, orThrow: DecodingError())
                let passcode = try storage.get("passcode", ofType: String.self, orThrow: DecodingError())
                guard let wallet, !passcode.isEmpty else {
                    throw DecodingError()
                }
                let biometricsEnabled = storage.get("biometricsEnabled", default: false)
                
                a = AppState(setupComplete: true, wallet: wallet, passcode: passcode, biometricsEnabled: biometricsEnabled)
            } catch {
                // couldn't load wallet or passcode or biometrics for some reason
                a = AppState(setupComplete: false, wallet: nil, passcode: "", biometricsEnabled: false)
            }
        }
        
        // load cached values
        Task {
            await a.loadFromDisk()
        }
        Task {
            await a.observeChangesForStorage()
        }
        return a
    }
    
    private var loadFromDiskTask: Task<Void, Never>? = nil
    private func loadFromDisk() async {
        
        currentBalance = cache.get("currentBalance", ofType: type(of: currentBalance), default: nil)
        currentTransactions = cache.get("currentTransactions", ofType: type(of: currentTransactions), default: [])
        currentTransactionsGroupedByDate = cache.get("currentTransactionsGroupedByDate", ofType: type(of: currentTransactionsGroupedByDate), default: [:])
        currentTransactionsLoadedAtLeastOnce = cache.get("currentTransactionsLoadedAtLeastOnce", default: false)
    }
    
    private func observeChangesForStorage() async {
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        storageObservables = []
        
        let storeFunc: (String) -> (Codable) -> () = { [storage] key in
            return { value in
                print("store: \(key) \(value) \(type(of: value))")
                storage.set(value, forKey: key)
            }
        }
        let cacheFunc: (String) -> (Codable) -> () = { [cache] key in
            return { value in
                print("cache: \(key) \(value) \(type(of: value))")
                cache.set(value, forKey: key)
            }
        }
                
        $setupComplete.sink(receiveValue: storeFunc("setupComplete")).store(in: &storageObservables)
        $wallet.sink(receiveValue: storeFunc("wallet")).store(in: &storageObservables)
        $passcode.sink(receiveValue: storeFunc("passcode")).store(in: &storageObservables)
        $biometricsEnabled.sink(receiveValue: storeFunc("biometricsEnabled")).store(in: &storageObservables)
        
        $currentBalance.dropFirst(1).sink(receiveValue: cacheFunc("currentBalance")).store(in: &storageObservables)
        $currentTransactions.dropFirst(1).sink(receiveValue: cacheFunc("currentTransactions")).store(in: &storageObservables)
        $currentTransactionsGroupedByDate.dropFirst(1).sink(receiveValue: cacheFunc("currentTransactionsGroupedByDate")).store(in: &storageObservables)
        $currentTransactionsLoadedAtLeastOnce.dropFirst(1).sink(receiveValue: cacheFunc("currentTransactionsLoadedAtLeastOnce")).store(in: &storageObservables)
    }
    
    
    // MARK: - Debug
    
    public func debug_toggleSetupComplete() {
        setupComplete.toggle()
    }
    
    public func debug_loadTestWallet() {
        Task {
            let testWords = ["night", "﻿﻿﻿friend", "﻿﻿﻿volume", "﻿﻿﻿tilt", "﻿﻿﻿case", "﻿﻿﻿skate", "﻿﻿﻿rotate", "﻿﻿﻿away", "﻿﻿﻿physical", "﻿﻿﻿﻿smile", "﻿﻿﻿﻿unhappy", "﻿﻿﻿﻿hammer", "kitten", "﻿﻿﻿﻿energy", "﻿﻿﻿﻿worry", "﻿﻿﻿﻿ability", "﻿﻿﻿﻿burst", "﻿﻿﻿﻿label", "﻿﻿﻿﻿stereo", "﻿﻿﻿﻿jazz", "﻿﻿﻿﻿deputy", "﻿﻿﻿﻿keep", "﻿﻿﻿﻿critic", "﻿﻿﻿﻿joy",]
            let key = try! await TonKey.derive(from: TonSeedPhrase(testWords))
            await setWallet(try! await TonWallet(version: .v4r2, keyPair: key))
            setupComplete = true
            setPasscode("1111")
        }
    }
    
    public func debug_fullReset() {
        storage.removeAll()
        cache.removeAll()
        exit(0)
    }
}


