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
    
    private var isInitialized = false
    private(set) var configuration: Configuration
    
    private let tonlib = GTTON()
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init()
        self.tonlib.delegate = self
        Task { [tonlib] in
            do {
                do {
                    try await tonlib.initialize(with: GTTONConfiguration.with(configuration, reload: false))
                    isInitialized = true
                } catch {
                    try await tonlib.initialize(with: GTTONConfiguration.with(configuration, reload: false))
                    isInitialized = true
                }
            } catch {
                print(error)
            }
        }
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


// MARK: - API

extension TonlibWrapper {
    
    func performRequest<T>(
        _ executeTonlibFunctionWithContext: (_ completionBlock: @escaping (T?, Error?) -> (), _ requestID: GTRequestID) -> ()
    ) async throws -> T {
        
        while !isInitialized {
            print("not initialized")
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        let requestID = tonlib.generateRequestID()

        return try await withTaskCancellationHandler {
            
            try await withUnsafeThrowingContinuation { continuation in
            
                let callback: (T?, Error?) -> () = { value, error in
                    if let value {
                        continuation.resume(returning: value)
                    } else {
                        continuation.resume(throwing: TonlibError(error))
                    }
                }
                executeTonlibFunctionWithContext(callback, requestID)
            }
        } onCancel: {
            tonlib.cancel(requestID)
        }
    }
    
    func performVoidRequest(
        _ executeTonlibFunctionWithContext: (_ completionBlock: @escaping (Error?) -> (), _ requestID: GTRequestID) -> ()
    ) async throws {
        
        while !isInitialized {
            print("not initialized")
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        

        let requestID = tonlib.generateRequestID()

        return try await withTaskCancellationHandler {
            
            try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
            
                let callback: (Error?) -> () = { error in
                    if let error {
                        continuation.resume(throwing: TonlibError(error))
                    } else {
                        continuation.resume()
                    }
                }
                executeTonlibFunctionWithContext(callback, requestID)
                
            }
        } onCancel: {
            tonlib.cancel(requestID)
        }
    }
    
    
    // MARK: - Keys
    
    public func createKey() async throws -> GTTONKey {
        try await performRequest { completionBlock, requestID in
            tonlib.createKey(withUserPassword: password, mnemonicPassword: Data(), completionBlock: completionBlock, requestID: requestID)
        }
    }
    
    /// Import and store key
    ///
    /// - Parameter userPassword: An user password
    /// - Parameter mnemonicPassword: An mnemonic password
    /// - Parameter words: An 24 words
    ///
    
    /// - Returns: Imported `Key`
    ///
    /// - Warning: Key not be assotiated with address automatically
    public func importKey(words: [String]) async throws -> GTTONKey {
        try await performRequest { completionBlock, requestID in
            tonlib.importKey(withUserPassword: password, mnemonicPassword: Data(), words: words, completionBlock: completionBlock, requestID: requestID)
        }
    }
        
    // MARK: - Security

    /// Returns decrypted key for given `key` and it's `userPassword`
    ///
    /// - Parameter key: An public `Key`
    ///
    
    /// - Returns: Decrypted secret key`
    public func decryptedSecretKeyForKey(_ key: GTTONKey) async throws -> Data {
        try await performRequest { completionBlock, requestID in
            self.tonlib.exportDecryptedKey(
                withEncryptedKey: key,
                withUserPassword: password,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    /// Returns word list for given key `key` and it's `userPassword`
    ///
    /// - Parameter key: An key of wallet
    /// - Parameter userPassword: An password of  given `key`
    ///
    
    /// - Returns: Words list
    public func wordsForKey(
        _ key: GTTONKey
    ) async throws -> [String] {
        try await performRequest { completionBlock, requestID in
            self.tonlib.exportWords(
                for: key,
                withUserPassword: password,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    /// Returns unencrypted messages if available
    ///
    /// - Parameter key: An key of wallet
    /// - Parameter userPassword: An password of  given `key`
    /// - Parameter messages: An encrypted messages
    ///
    
    /// - Returns: Words list
    public func decryptMessagesWithKey(
        _ key: GTTONKey,
        userPassword: Data,
        messages: [GTEncryptedData]
    ) async throws -> [GTTransactionMessageContents] {
        try await performRequest { completionBlock, requestID in
            tonlib.decryptMessages(
                with: key,
                userPassword: userPassword,
                messages: messages,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    /// Returns current account address depended on `data` and `code`
    ///
    /// - Parameter data: An storage of smart contract
    /// - Parameter code: An code of smart contract
    ///
    
    /// - Returns: Wallet address string value
    public func accountAddress(
        code: Data,
        data: Data,
        workchain: Int32
    ) async throws -> String {
        try await performRequest { completionBlock, requestID in
            self.tonlib.accountAddress(
                withCode: code,
                data: data,
                workchain: workchain,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }

    /// Returns raw account for given address
    ///
    /// - Parameter accountAddress: An account address
    ///
    
    /// - Returns: Current state `AccountState` of given address
    public func accountWithAddress(
        _ accountAddress: String
    ) async throws -> GTAccountState {
        try await performRequest { completionBlock, requestID in
            tonlib.accountState(
                withAddress: accountAddress,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    /// Returns account (smart contract) local id for given address
    ///
    /// - Parameter accountAddress: An account address
    ///
    
    /// - Returns: local id of account (smart contract)
    public func accountLocalIDWithAccountAddress(
        _ accountAddress: String
    ) async throws -> Int64 {
        try await performRequest { completionBlock, requestID in
            self.tonlib.accountLocalID(
                withAccountAddress: accountAddress,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    /// Runs method on account (smart contract) with given method name
    ///
    /// - Parameter localID: local id of account (smart contract)
    ///
    
    /// - Returns: result of execution
    public func accountLocalID(
        _ localID: Int64,
        runGetMethodNamed methodName: String,
        arguments: [GTExecutionStackValue]
    ) async throws -> GTExecutionResult {
        try await performRequest { completionBlock, requestID in
            self.tonlib.accountLocalID(
                localID,
                runGetMethodNamed: methodName,
                arguments: arguments,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    // MARK: - Queries
    
    /// Prepare raw query
    ///
    /// - Parameter address: key of account
    /// - Parameter initialStateCode:
    /// - Parameter initialStateData:
    /// - Parameter body:
    ///
    
    /// - Returns: prepared query
    public func prepareQueryWithDestinationAddress(
        _ address: String,
        initialStateCode: Data?,
        initialStateData: Data?,
        body: Data
    ) async throws -> GTPreparedQuery {
        try await performRequest { completionBlock, requestID in
            tonlib.prepareQuery(
                withDestinationAddress: address,
                initialAccountStateData: initialStateData,
                initialAccountStateCode: initialStateCode,
                body: body,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    /// Estimate fees for query
    ///
    /// - Parameter preparedQuery: query that shoud be estimated
    ///
    
    /// - Returns: fees for query
    public func estimateFees(
        preparedQueryID: Int64
    ) async throws -> GTFeesQuery {
        try await performRequest { completionBlock, requestID in
            self.tonlib.estimateFeesForPreparedQuery(
                withID: preparedQueryID,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    /// Send prepared query
    ///
    /// - Parameter preparedQuery: query that shoud be sent
    ///
    
    /// - Returns: fees for query
    public func send(
        preparedQueryID: Int64
    ) async throws {
        try await performVoidRequest { completionBlock, requestID in
            tonlib.sendPreparedQuery(
                withID: preparedQueryID,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    /// Remove local copy of prepared query
    ///
    /// - Parameter preparedQuery: query that shoud be removed
    ///
    
    public func remove(
        preparedQueryID: Int64
    ) async throws {
        try await performVoidRequest { completionBlock, requestID in
            self.tonlib.deletePreparedQuery(
                withID: preparedQueryID,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
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
    
    /// - returns: fees for query
    public func resolvedDNSWithRootDNSAccountAddress(
        _ rootDNSAccountAddress: String?,
        name: String,
        category: DNSResolverCategory,
        ttl: Int32
    ) async throws -> GTDNS {
        
        try await performRequest { completionBlock, requestID in
            self.tonlib.resolvedDNS(
                withRootDNSAccountAddress: rootDNSAccountAddress,
                domainName: name,
                category: category.rawValue,
                ttl: ttl,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
    
    // MARK: Transactions
    
    /// Get transactions for account address
    ///
    /// - Parameter accountAddress: address of account
    ///
    
    /// - Returns: fees for query
    public func transactionsForAccountAddress(
        _ accountAddress: String,
        lastTransactionID: GTTransactionID
    ) async throws -> [GTTransaction] {
        try await performRequest { completionBlock, requestID in
            self.tonlib.transactions(
                forAccountAddress: accountAddress,
                last: lastTransactionID,
                completionBlock: completionBlock,
                requestID: requestID
            )
        }
    }
}
