//
//  Created by Anton Spivak
//

import Foundation
import GlossyTON

private let password = "PkVcWBQ22i7oNeBYQ5l2".data(using: .utf8)!

private(set) var _tonlibWrapper: TonlibWrapper? = nil
public var tonlibWrapper: TonlibWrapper {
    if _tonlibWrapper == nil {
        let keystoreDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("keystore", isDirectory: true)
        try! FileManager.default.createDirectory(at: keystoreDir, withIntermediateDirectories: true)
        print(keystoreDir.path)
        _tonlibWrapper = TonlibWrapper(configuration: Configuration(network: .main, logging: .info, keystoreURL: keystoreDir))
    }
    return _tonlibWrapper!
}

public final class TonlibWrapper: NSObject {
    
    private struct Flags: OptionSet {
        
        let rawValue: Int
        
        static let initialized = Flags(rawValue: 1 << 0)
    }
    
    private(set) var configuration: Configuration
    
    private let tonlib = GTTON()
    private var flags: Flags = []
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init()
        self.tonlib.delegate = self
    }
    
    struct RequestContext<T> {
        var callback: (T?, Error?) -> ()
        var requestID: GTRequestID
    }
    
    func request<T>(
        function: String = #function,
        _ executeTonlibFunctionWithContext: (RequestContext<T>) -> ()
    
    ) async throws -> T {
        
        let id = tonlib.generateRequestID()
        
        let pretry: @Sendable (Int) async throws -> () = { attemptNumber in
            var configuration = await GTTONConfiguration.with(self.configuration, reload: attemptNumber > 0)
            do {
                try await self._initializeIfNeeded(configuration)
            } catch {
                configuration = await GTTONConfiguration.with(self.configuration, reload: true)
                try await self._initializeIfNeeded(configuration)
            }
            try await self._updateCurrentConfiguration(configuration)
            try await self._validateCurrentConfiguration()
        }
        
        
        return try await withTaskCancellationHandler {
            try await retryingIfAvailable(function: function, pretry: pretry) { continuation in

                let callback: (T?, Error?) -> () = { value, error in
                    if let value {
                        continuation.resume(returning: value)
                    } else {
                        continuation.resume(throwing: TonlibError(error))
                    }
                }
                executeTonlibFunctionWithContext(RequestContext(callback: callback, requestID: id))
                
            }
        } onCancel: {
            tonlib.cancel(id)
        }
        
    }
    
    /// Should be used insted of `withCheckedThrowingContinuation` for TON calls
    ///
    /// - parameter update: Should be `true` if request did requre network updates
    /// - warning: Should be called before all requests
    /// - Throws: TODO
    fileprivate func request<T>(
        id: GTRequestID,
        function: String = #function,
        _ body: (CheckedContinuation<T, Error>) -> Void
    ) async throws -> T {
        try await withTaskCancellationHandler(
            operation: {
                try await retryingIfAvailable(
                    function: function,
                    pretry: { attemptNumber in
                        var configuration = await GTTONConfiguration.with(
                            self.configuration,
                            reload: attemptNumber > 0
                        )
                        
                        do {
                            try await self._initializeIfNeeded(configuration)
                        } catch {
                            configuration = await GTTONConfiguration.with(
                                self.configuration,
                                reload: true
                            )
                            
                            try await self._initializeIfNeeded(configuration)
                        }
                        
                        try await self._updateCurrentConfiguration(configuration)
                        try await self._validateCurrentConfiguration()
                    },
                    body
                )
            },
            onCancel: { [weak self] in
                self?.tonlib.cancel(id)
            }
        )
    }
    
    /// Initialize TON with given configuration
    ///
    /// - Throws: TODO
    /// - Returns: prefixWalletID
    private func _initializeIfNeeded(
        _ configuration: GTTONConfiguration
    ) async throws {
        guard !flags.contains(.initialized)
        else {
            return
        }
        
        // Here we don't need to retry
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(), Error>) in
            self.tonlib.initialize(
                with: configuration,
                completionBlock: { error in
                    if let error = error {
                        continuation.resume(throwingSwiftyTONError: error)
                    } else {
                        self.flags.insert(.initialized)
                        continuation.resume(returning: ())
                    }
                }
            )
        })
    }
    
    /// Updates TON with given configuration
    ///
    /// - Parameter configuration: An network configuration
    ///
    /// - Throws: TODO
    /// - Returns: prefixWalletID
    private func _updateCurrentConfiguration(
        _ configuration: GTTONConfiguration
    ) async throws {
        // Here we don't need to retry
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(), Error>) in
            self.tonlib.updateConfiguration(
                configuration,
                completionBlock: { error in
                    if let error = error {
                        continuation.resume(throwingSwiftyTONError: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                },
                requestID: nil
            )
        })
    }
    
    /// Validate current `Configuration` configuration and return `prefixWalletID`
    ///
    /// - Throws: TODO
    /// - Returns: prefixWalletID
    @discardableResult
    private func _validateCurrentConfiguration() async throws -> Int64 {
        // Here we don't need to retry
        try await withCheckedThrowingContinuation({ continuation in
            self.tonlib.validateCurrentConfiguration(
                completionBlock: { prefixWalletID, errror in
                    if let error = errror {
                        continuation.resume(throwingSwiftyTONError: error)
                    } else {
                        continuation.resume(returning: prefixWalletID)
                    }
                },
                requestID: nil
            )
        })
    }
}

// MARK: - GTTONDelegate

extension TonlibWrapper: GTTONDelegate {
    
    public func ton(
        _ ton: GTTON,
        didUpdateSynchronizationProgress progress: Double
    ) {
//        AnnouncementCenter.shared.post(
//            announcement: AnnouncementSynchronization.self,
//            with: .init(progress: progress)
//        )
    }
}

extension TonlibWrapper {
    
    public func changeConfiguration(
        to _configuration: Configuration
    ) {
        Task {
            let configuration = await GTTONConfiguration.with(
                _configuration,
                reload: false
            )
            
            self.configuration = _configuration
            
            try await self._updateCurrentConfiguration(configuration)
            try await self._validateCurrentConfiguration()
        }
    }
}

// MARK: - API
    
// request<V>:
//   generates id
//   calls function with callback, returning

extension TonlibWrapper {
    
    // MARK: - Keys
    
    public func createKey() async throws -> GTTONKey {
        return try await request { context in
            tonlib.createKey(withUserPassword: password, mnemonicPassword: Data(), completionBlock: context.callback, requestID: context.requestID)
        }
    }
    
    /// Import and store key
    ///
    /// - Parameter userPassword: An user password
    /// - Parameter mnemonicPassword: An mnemonic password
    /// - Parameter words: An 24 words
    ///
    /// - Throws: TODO
    /// - Returns: Imported `Key`
    ///
    /// - Warning: Key not be assotiated with address automatically
    public func importKey(words: [String]) async throws -> GTTONKey {
        return try await request { context in
            self.tonlib.importKey(withUserPassword: password, mnemonicPassword: Data(), words: words, completionBlock: context.callback, requestID: context.requestID)
        }
    }
    
    /// Removes key
    ///
    /// - Parameter key: key
    ///
    /// - Throws: TODO
    /// - Warning: Danger! Key can't be restored!
    public func removeKey(
        _ key: GTTONKey
    ) async throws {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { (continuation: CheckedContinuation<(), Error>) in
            self.tonlib.delete(
                key,
                completionBlock: { error in
                    if let error = error {
                        continuation.resume(throwingSwiftyTONError: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                },
                requestID: id
            )
        })
    }
    
    /// Removes all keys
    ///
    /// - Throws: TODO
    /// - Warning: Danger! Keys can't be restored!
    public func removeAllKeys() async throws {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { (continuation: CheckedContinuation<(), Error>) in
            self.tonlib.deleteAllKeys(
                completionBlock: { error in
                    if let error = error {
                        continuation.resume(throwingSwiftyTONError: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                },
                requestID: id
            )
        })
    }
    
    // MARK: - Security

    /// Returns decrypted key for given `key` and it's `userPassword`
    ///
    /// - Parameter key: An public `Key`
    ///
    /// - Throws: TODO
    /// - Returns: Decrypted secret key`
    public func decryptedSecretKeyForKey(_ key: GTTONKey) async throws -> Data {
        return try await request { context in
            self.tonlib.exportDecryptedKey(
                withEncryptedKey: key,
                withUserPassword: password,
                completionBlock: context.callback,
                requestID: context.requestID
            )
        }
    }
    
    /// Returns word list for given key `key` and it's `userPassword`
    ///
    /// - Parameter key: An key of wallet
    /// - Parameter userPassword: An password of  given `key`
    ///
    /// - Throws: TODO
    /// - Returns: Words list
    public func wordsForKey(
        _ key: GTTONKey
    ) async throws -> [String] {
        return try await request { context in
            self.tonlib.exportWords(
                for: key,
                withUserPassword: password,
                completionBlock: context.callback,
                requestID: context.requestID
            )
        }
    }
    
    /// Returns unencrypted messages if available
    ///
    /// - Parameter key: An key of wallet
    /// - Parameter userPassword: An password of  given `key`
    /// - Parameter messages: An encrypted messages
    ///
    /// - Throws: TODO
    /// - Returns: Words list
    public func decryptMessagesWithKey(
        _ key: GTTONKey,
        userPassword: Data,
        messages: [GTEncryptedData]
    ) async throws -> [GTTransactionMessageContents] {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { continuation in
            self.tonlib.decryptMessages(
                with: key,
                userPassword: userPassword,
                messages: messages,
                completionBlock: { contents, error in
                    if let contents = contents {
                        continuation.resume(returning: contents)
                    } else {
                        continuation.resume(throwingSwiftyTONError: error)
                    }
                },
                requestID: id
            )
        })
    }
    
    /// Returns current account address depended on `data` and `code`
    ///
    /// - Parameter data: An storage of smart contract
    /// - Parameter code: An code of smart contract
    ///
    /// - Throws: TODO
    /// - Returns: Wallet address string value
    public func accountAddress(
        code: Data,
        data: Data,
        workchain: Int32
    ) async throws -> String {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { continuation in
            self.tonlib.accountAddress(
                withCode: code,
                data: data,
                workchain: workchain,
                completionBlock: { address, error in
                    if let address = address {
                        continuation.resume(returning: address)
                    } else {
                        continuation.resume(throwingSwiftyTONError: error)
                    }
                },
                requestID: id
            )
        })
    }

    /// Returns raw account for given address
    ///
    /// - Parameter accountAddress: An account address
    ///
    /// - Throws: TODO
    /// - Returns: Current state `AccountState` of given address
    public func accountWithAddress(
        _ accountAddress: String
    ) async throws -> GTAccountState {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { continuation in
            self.tonlib.accountState(
                withAddress: accountAddress,
                completionBlock: { account, error in
                    if let account = account {
                        continuation.resume(returning: account)
                    } else {
                        continuation.resume(throwingSwiftyTONError: error)
                    }
                },
                requestID: id
            )
        })
    }
    
    /// Returns account (smart contract) local id for given address
    ///
    /// - Parameter accountAddress: An account address
    ///
    /// - Throws: TODO
    /// - Returns: local id of account (smart contract)
    public func accountLocalIDWithAccountAddress(
        _ accountAddress: String
    ) async throws -> Int64 {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { continuation in
            self.tonlib.accountLocalID(
                withAccountAddress: accountAddress,
                completionBlock: { id, error in
                    if let error = error {
                        continuation.resume(throwingSwiftyTONError: error)
                    } else {
                        continuation.resume(returning: id)
                    }
                },
                requestID: id
            )
        })
    }
    
    /// Runs method on account (smart contract) with given method name
    ///
    /// - Parameter localID: local id of account (smart contract)
    ///
    /// - Throws: TODO
    /// - Returns: result of execution
    public func accountLocalID(
        _ localID: Int64,
        runGetMethodNamed methodName: String,
        arguments: [GTExecutionStackValue]
    ) async throws -> GTExecutionResult {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { continuation in
            self.tonlib.accountLocalID(
                localID,
                runGetMethodNamed: methodName,
                arguments: arguments,
                completionBlock: { result, error in
                    if let result = result {
                        continuation.resume(returning: result)
                    } else {
                        continuation.resume(throwingSwiftyTONError: error)
                    }
                },
                requestID: id
            )
        })
    }
    
    // MARK: Queries
    
    /// Prepare raw query
    ///
    /// - Parameter address: key of account
    /// - Parameter initialStateCode:
    /// - Parameter initialStateData:
    /// - Parameter body:
    ///
    /// - Throws: TODO
    /// - Returns: prepared query
    public func prepareQueryWithDestinationAddress(
        _ address: String,
        initialStateCode: Data?,
        initialStateData: Data?,
        body: Data
    ) async throws -> GTPreparedQuery {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { continuation in
            self.tonlib.prepareQuery(
                withDestinationAddress: address,
                initialAccountStateData: initialStateData,
                initialAccountStateCode: initialStateCode,
                body: body,
                completionBlock: { query, error in
                    if let query = query {
                        continuation.resume(returning: query)
                    } else {
                        continuation.resume(throwingSwiftyTONError: error)
                    }
                },
                requestID: id
            )
        })
    }
    
    /// Estimate fees for query
    ///
    /// - Parameter preparedQuery: query that shoud be estimated
    ///
    /// - Throws: TODO
    /// - Returns: fees for query
    public func estimateFees(
        preparedQueryID: Int64
    ) async throws -> GTFeesQuery {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { continuation in
            self.tonlib.estimateFeesForPreparedQuery(
                withID: preparedQueryID,
                completionBlock: { fees, error in
                    if let fees = fees {
                        continuation.resume(returning: fees)
                    } else {
                        continuation.resume(throwingSwiftyTONError: error)
                    }
                },
                requestID: id
            )
        })
    }
    
    /// Send prepared query
    ///
    /// - Parameter preparedQuery: query that shoud be sent
    ///
    /// - Throws: TODO
    /// - Returns: fees for query
    public func send(
        preparedQueryID: Int64
    ) async throws {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { (continuation: CheckedContinuation<(), Error>) in
            self.tonlib.sendPreparedQuery(
                withID: preparedQueryID,
                completionBlock: { error in
                    if let error = error {
                        continuation.resume(throwingSwiftyTONError: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                },
                requestID: id
            )
        })
    }
    
    /// Remove local copy of prepared query
    ///
    /// - Parameter preparedQuery: query that shoud be removed
    ///
    /// - Throws: TODO
    public func remove(
        preparedQueryID: Int64
    ) async throws {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { (continuation: CheckedContinuation<(), Error>) in
            self.tonlib.deletePreparedQuery(
                withID: preparedQueryID,
                completionBlock: { error in
                    if let error = error {
                        continuation.resume(throwingSwiftyTONError: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                },
                requestID: id
            )
        })
    }
    
    // MARK: DNS
    
    public enum DNSResolverCategory: String {
        
        case next = "dns_next_resolver"
        case wallet = "wallet"
        case site = "site"
    }
    
    /// Resolve `.ton` to address
    ///
    /// - parameter rootDNSAccountAddress: address of root DNS contract account
    /// - parameter name: domain nam e.g. `durov.ton`
    ///
    /// - throws: TODO
    /// - returns: fees for query
    public func resolvedDNSWithRootDNSAccountAddress(
        _ rootDNSAccountAddress: String?,
        name: String,
        category: DNSResolverCategory,
        ttl: Int32
    ) async throws -> GTDNS {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { continuation in
            self.tonlib.resolvedDNS(
                withRootDNSAccountAddress: rootDNSAccountAddress,
                domainName: name,
                category: category.rawValue,
                ttl: ttl,
                completionBlock: { dns, error in
                    if let dns = dns {
                        continuation.resume(returning: dns)
                    } else {
                        continuation.resume(throwingSwiftyTONError: error)
                    }
                },
                requestID: id
            )
        })
    }
    
    // MARK: Transactions
    
    /// Get transactions for account address
    ///
    /// - Parameter accountAddress: address of account
    ///
    /// - Throws: TODO
    /// - Returns: fees for query
    public func transactionsForAccountAddress(
        _ accountAddress: String,
        lastTransactionID: GTTransactionID
    ) async throws -> [GTTransaction] {
        let id = tonlib.generateRequestID()
        return try await request(id: id, { continuation in
            self.tonlib.transactions(
                forAccountAddress: accountAddress,
                last: lastTransactionID,
                completionBlock: { transactions, error in
                    if let transactions = transactions {
                        continuation.resume(returning: transactions)
                    } else {
                        continuation.resume(throwingSwiftyTONError: error)
                    }
                },
                requestID: id
            )
        })
    }
}
