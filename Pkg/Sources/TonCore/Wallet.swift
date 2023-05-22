
import Foundation
import SwiftyTON


public struct TonWallet: Hashable, Codable {

    public enum Version: String, Hashable, Codable, CaseIterable {
        
        case v2r1
        case v2r2
        
        case v3r1
        case v3r2
        
        case v4r1
        case v4r2
        
        public static var `default`: Self { .v4r2 }
        public var isDefault: Bool { self == .v4r2 }
    }

    public let version: Version
    public let initialState: Contract.InitialCondition
    public let address: TonAddress
    public let keyPair: TonKey
    
    public init(version walletVersion: Version, keyPair: TonKey) async throws {
        self.version = walletVersion
        switch walletVersion {
        case .v2r1:
            self.initialState = try await Wallet2.initial(revision: .r1, deserializedPublicKey: keyPair.publicKey.data)
        case .v2r2:
            self.initialState = try await Wallet2.initial(revision: .r2, deserializedPublicKey: keyPair.publicKey.data)
        case .v3r1:
            self.initialState = try await Wallet3.initial(revision: .r1, deserializedPublicKey: keyPair.publicKey.data)
        case .v3r2:
            self.initialState = try await Wallet3.initial(revision: .r2, deserializedPublicKey: keyPair.publicKey.data)
        case .v4r1:
            self.initialState = try await Wallet4.initial(revision: .r1, deserializedPublicKey: keyPair.publicKey.data)
        case .v4r2:
            self.initialState = try await Wallet4.initial(revision: .r2, deserializedPublicKey: keyPair.publicKey.data)
        }
        let a = await Address(initial: initialState)!
        self.address = TonAddress(workchain: a.workchain, hash: Data(a.hash))
        self.keyPair = keyPair
    }
}
