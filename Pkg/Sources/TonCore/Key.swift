
import Foundation
import SwiftyTON

public struct TonSeedPhrase: Hashable, Codable {
    
    public let words: [String]
    
    public init(_ words: [String]) throws {
        guard words.count == 24 else { throw Error.not24Words }
        self.words = words
    }
    
    public enum Error: Swift.Error {
        case not24Words
    }
    
    public func pickThree() -> (positions: [Int], answers: [String]) {
        srand48(self.hashValue)
        var p = Set<Int>()
        while p.count < 3 {
            p.insert(Int(drand48() * 24))
        }
        let positions = p.sorted()
        let answers = [
            words[positions[0]], words[positions[1]], words[positions[2]],
        ]
        return (positions, answers)
    }
}

public struct TonKey: Hashable, Codable {
    
    public struct PrivateKey: Hashable, Codable {
        public var data: Data
    }
    
    public struct PublicKey: Hashable, Codable {
        public var data: Data
    }
    
    public let privateKey: PrivateKey
    public let publicKey: PublicKey
    public let seedPhrase: TonSeedPhrase
}

public extension TonKey {
    
    static func create() async throws -> TonKey {
        
        let encryptedKey = try await tonlibWrapper.createKey()
        let pub = PublicKey(data: try! deserializedPublicKey(encryptedKey.publicKey))
        let secret = try await tonlibWrapper.decryptedSecretKeyForKey(encryptedKey)
        let words = try await tonlibWrapper.wordsForKey(encryptedKey)

        
        return TonKey(privateKey: PrivateKey(data: secret), publicKey: pub, seedPhrase: try TonSeedPhrase(words))
    }
    
    static func derive(from seedPhrase: TonSeedPhrase) async throws -> TonKey {
        let encryptedKey = try await tonlibWrapper.importKey(words: seedPhrase.words)
        let pub = PublicKey(data: try! deserializedPublicKey(encryptedKey.publicKey))
        let secret = try await tonlibWrapper.decryptedSecretKeyForKey(encryptedKey)
        return TonKey(privateKey: PrivateKey(data: secret), publicKey: pub, seedPhrase: seedPhrase)
    }
}



fileprivate func deserializedPublicKey(_ publicKey: String) throws -> Data {
    guard publicKey.count == 48
    else {
        throw KeyError.invalidPublicKey
    }
    
    let base64Unescaped = publicKey.base64URLUnescaped()
    guard let base64KeyData = Data(base64Encoded: base64Unescaped),
          base64KeyData.count == 36
    else {
        throw KeyError.invalidPublicKey
    }
    
    let hash = Data([base64KeyData[34], base64KeyData[35]])
    guard hash == base64KeyData[0..<34].crc16ccitt()
    else {
        throw KeyError.incorrectCRC16Hash
    }
    
    guard base64KeyData[0] == 0x3e
    else {
        throw KeyError.notPublicByte
    }
    
    guard base64KeyData[1] == 0xe6
    else {
        throw KeyError.notED25519Byte
    }
    
    return Data(base64KeyData[2..<34])
}
