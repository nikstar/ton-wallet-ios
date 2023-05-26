//
//  Created by Anton Spivak
//

import Foundation
import TON3
import GlossyTON
import BigInt

public struct Wallet4: Wallet {

    public let contract: Contract
    public let revision: Revision
    
    public var publicKey: String {
        get async throws {
            try checkInitialization()
            let bytes = try await contract.data.rootCellDataIfAvailable()
            return bytes[8..<40].toHexString()
        }
    }

    public var subwalletID: SubwalletID {
        get async throws {
            try checkInitialization()
            let bytes = try await contract.data.rootCellDataIfAvailable()
            return SubwalletID(
                rawValue: try bytes[4..<8].downcast()
            )
        }
    }

    public init?(
        contract: Contract
    ) {
        switch contract.kind {
        case .walletV4R1:
            revision = .r1
        case .walletV4R2:
            revision = .r2
        default:
            return nil
        }

        self.contract = contract
    }

    /// - returns: Initial data for wallet V3
    public static func initial(
        workchain: Int32 = 0,
        subwalletID: SubwalletID = .default,
        revision: Revision = .r2,
        deserializedPublicKey: Data
    ) async throws -> Contract.InitialCondition {
        let builder = try await TON3.Builder()
        await builder.store(UInt32(0)) // seqno
        await builder.store(UInt32(subwalletID.rawValue))
        await builder.store(deserializedPublicKey.bytes)
        await builder.store(false)

        let c = Cell {
            UInt32(0) // seqno
            UInt32(subwalletID.rawValue)
            deserializedPublicKey.bytes.flatMap(\.bits)
            Bit(false)
        }
        print(c)
        let boc = try await builder.boc()
        print(boc)

        let boc2 = BOC2(hasCrc32: true, cell: c)
        print(boc2.bytes.toHexString())
        assert(boc == boc2.bytes.toHexString())
        
        let c2 = Cell {
            Bit(1)
        }
        let c3 = Cell {
            VarInt(-1, size: 7)
        }
        let c4 = Cell {
            VarInt(0x0AAAAA, size: 24)
        }
        
        print(c2)
        print(c3)
        print(c4)

        return Contract.InitialCondition(
            kind: revision.kind,
            data: Data(hex: boc)
        )
    }
    
    public func subsequentExternalMessage() async throws -> [UInt8] {
        let subwalletID = (try? await subwalletID) ?? .default
        let seqno = (try? await seqno) ?? 0
        
        let date = Date().timeIntervalSince1970 + 60
        let builder = try await TON3.Builder()
        await builder.store(UInt32(subwalletID.rawValue))
        await builder.store(UInt32(date))
        await builder.store(UInt32(seqno))
        await builder.store(UInt8(0)) // op
        await builder.store(UInt8(3)) // 3 default `send mode`
        let boc = try await builder.boc()
        
        let boc2 = Cell {
            UInt32(subwalletID.rawValue)
            UInt32(date)
            UInt32(seqno)
            UInt8(0) // op
            UInt8(3) // send mode
        }.bocString()
        assert(boc == boc2)

        return [UInt8](hex: boc)
    }
    
    public func subsequentExternalMessageInitialCondition(
        key: Key
    ) async throws -> Contract.InitialCondition {
        try await Self.initial(
            deserializedPublicKey: try key.deserializedPublicKey()
        )
    }
}

extension Wallet4: Codable {}
extension Wallet4: Hashable {}
