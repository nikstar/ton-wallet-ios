
import Foundation
import SwiftyTON
import CryptoSwift

public struct TonAddress: Hashable, Codable {
    
    /// Address wprkchain. Currently two chains are supported: -1 (masterchain) and 0 (base workchain).
    public var workchain: Int32
    
    /// Address within the workchain. It is a hash of contract's initial state.
    public var hash: Data
    
    /// Whether message should bounce if sent to uninitialized address. Usually defaults to bouncable. Optional.
    public var isBouncable: Bool? = nil
    
    /// Wherher address is used for testing and should not be accepted in production systems. Defaults to not testable.
    public var isTestable: Bool? = nil
    
    public var rawValue: (Int32, Data) { (workchain, hash) }
}


// MARK: - String conversions


extension TonAddress: CustomStringConvertible {
    
    public static func parse(_ string: String) -> TonAddress? {
        if let a = parseBase64(string) {
            return a
        }
        return parseRaw(string)
    }
    
    
    private static func parseRaw(_ s: String) -> TonAddress? {
        let s = s.lowercased()
//        let regex = /^(0|-1):([a-f0-9]{64})$/
//        guard let match = s.firstMatch(of: regex) else { return nil }
//        let chain = Int32(match.1)!
//        let hash = Data(hex: String(match.2))
        let p = s.split(separator: ":")
        guard p.count == 2 else { return nil }
        guard let chain = Int(p[0]), chain == -1 || chain == 0 else { return nil }
        let hash = Data(hex: String(p[1]))
        guard hash.count > 0 else { return nil}
        return TonAddress(workchain: Int32(chain), hash: hash)
    }
    
    private static func parseBase64(_ s: String) -> TonAddress? {
        let s = s.base64URLUnescaped()
        guard let data = Data(base64Encoded: s) else { return nil }
        
        // 0..<1: one tag byte (0x11 for "bounceable" addresses, 0x51 for "non-bounceable";
        // add +0x80 if the address should not be accepted by software running in the production network)
        // ---
        // 1..<2: one byte containing a signed 8-bit integer with the workchain_id (0x00 for the basic workchain, 0xff for the masterchain)
        // ---
        // 2..<34: 32 bytes containing 256 bits of the smart-contract address inside the workchain (big-endian)
        // ---
        // 34..<36: 2 bytes containing CRC16-CCITT of the previous 34 bytes
        
        guard
            data.count == 36,
            data[0..<34].crc16ccitt() == data[34..<36] else { return nil }
        
        let tag = data[0]
        if tag & 0x80 != 0 {
            return nil // testable addresses will not be accespted
        }
        let bouncable: Bool
        if tag == 0x51 {
            bouncable = false
        } else {
            bouncable = true
        }
        
        let worchainRaw = data[1]
        let workchain: Int32
        if worchainRaw == 0xFF {
            workchain = -1
        } else if worchainRaw == 0 {
            workchain = 0
        } else {
            return nil // Unsupported. New workchains might in theory use different address scheme
        }
        
        let hash = data[2..<34]
        
        return TonAddress(workchain: workchain, hash: hash, isBouncable: bouncable)
    }
    
    public var description: String {
        let r = string(.raw, characters: (6, 4))
        let h = string(.base64url, characters: (4, 4))
        return "\(r)/\(h)"
    }
    
    public enum DisplayMode {
        case raw
        case base64
        case base64url
    }
    
    ///  Returns a string representation of the address, formatted according to the specified display mode.
    ///
    ///  - Parameters:
    ///      - displayMode: The desired display mode for the address.
    ///      - characters: An optional tuple specifying how many characters to include at the start and end of the returned string. If not provided, the entire string is returned.
    public func string(_ displayMode: DisplayMode, characters: (start: Int, end: Int)? = nil) -> String {
        let s: String
        switch displayMode {
        case .raw:
            s = "\(workchain):\(hash.toHexString())"
        case .base64:
            s = rawBase64().base64EncodedString()
        case .base64url:
            s = rawBase64().base64EncodedString().base64URLEscaped()
        }
        if let characters {
            return "\(s.prefix(characters.start))...\(s.suffix(characters.end))"
        } else {
            return s
        }
    }
    
    private func rawBase64() -> Data {
        var data = Data()
        
        var tag: UInt8
        switch isBouncable {
        case .some(true), .none: // defaults to bouncable
            tag = 0x11
        case .some(false):
            tag = 0x51
        }
        if isTestable == true {
            tag |= 0x80
        }
        
        let workchain: UInt8
        switch self.workchain {
        case 0:
            workchain = 0x00
        case -1:
            workchain = 0xff
        default:
            workchain = UInt8(self.workchain + 127) // might want to trap instead
        }
        
        data.append(tag)
        data.append(workchain)
        data.append(contentsOf: hash)
        data.append(data.crc16ccitt())
        return data
    }
}


extension TonAddress {
    
    static func fromSwiftyAddress(_ address: Address) -> TonAddress {
        return TonAddress(workchain: address.workchain, hash: Data(address.hash))
    }
    
    func toSwiftyAddress() -> Address {
        return Address(workchain: workchain, hash: hash.bytes)
    }
}


extension String {
    
    /// Converts a base64-url encoded string to a base64 encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    func base64URLUnescaped() -> String {
        let replaced = replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        /// https://stackoverflow.com/questions/43499651/decode-base64url-to-base64-swift
        let padding = replaced.count % 4
        if padding > 0 {
            return replaced + String(repeating: "=", count: 4 - padding)
        } else {
            return replaced
        }
    }

    /// Converts a base64 encoded string to a base64-url encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    func base64URLEscaped() -> String {
        return replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}


extension Data {
    
    func crc16ccitt(seed: UInt16 = 0x0000) -> Data {
        var value = seed
        for byte in bytes {
            let index = Int((value >> 8) ^ UInt16(byte))
            value = Data.crc15ccittTable[index] ^ (value << 8)
        }
        let data = Swift.withUnsafeBytes(of: value, { Data($0) })
        return Data(data.reversed())
    }
    
    private static let crc15ccittTable: [UInt16] = [
        0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7, 0x8108,
        0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF, 0x1231, 0x0210,
        0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6, 0x9339, 0x8318, 0xB37B,
        0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE, 0x2462, 0x3443, 0x0420, 0x1401,
        0x64E6, 0x74C7, 0x44A4, 0x5485, 0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE,
        0xF5CF, 0xC5AC, 0xD58D, 0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6,
        0x5695, 0x46B4, 0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D,
        0xC7BC, 0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
        0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B, 0x5AF5,
        0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12, 0xDBFD, 0xCBDC,
        0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A, 0x6CA6, 0x7C87, 0x4CE4,
        0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41, 0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD,
        0xAD2A, 0xBD0B, 0x8D68, 0x9D49, 0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13,
        0x2E32, 0x1E51, 0x0E70, 0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A,
        0x9F59, 0x8F78, 0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E,
        0xE16F, 0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
        0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E, 0x02B1,
        0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256, 0xB5EA, 0xA5CB,
        0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D, 0x34E2, 0x24C3, 0x14A0,
        0x0481, 0x7466, 0x6447, 0x5424, 0x4405, 0xA7DB, 0xB7FA, 0x8799, 0x97B8,
        0xE75F, 0xF77E, 0xC71D, 0xD73C, 0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657,
        0x7676, 0x4615, 0x5634, 0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9,
        0xB98A, 0xA9AB, 0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882,
        0x28A3, 0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
        0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92, 0xFD2E,
        0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9, 0x7C26, 0x6C07,
        0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1, 0xEF1F, 0xFF3E, 0xCF5D,
        0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8, 0x6E17, 0x7E36, 0x4E55, 0x5E74,
        0x2E93, 0x3EB2, 0x0ED1, 0x1EF0,
    ]
}

