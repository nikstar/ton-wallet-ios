
import Foundation
import Algorithms
import CryptoSwift


public extension Cell {
    
    func bocString(withChecksum: Bool = true) -> String {
        let boc = BOC2(hasCrc32: withChecksum, cell: self)
        return boc.bytes.toHexString()
    }
}


public struct BOC2 {
    
    public let bytes: [UInt8]
    
    init(bytes: [UInt8]) {
        self.bytes = bytes 
    }
    
    public init(hasCrc32: Bool, cell: Cell) {
        
        let numberOfCells = 1
        
        let bitsNeededToStoreNumberOfCells = log2(Double(numberOfCells + 1))
        let bytesNeededToStoreNumberOfCells = UInt8(ceil(bitsNeededToStoreNumberOfCells / 8))
        
        var payloadBits = cell.bits
//        let paddingNeeded = 4 - (payloadBits.count % 4)
//        let padding = [Bit](repeating: 0, count: paddingNeeded)
//        payloadBits.append(contentsOf: padding)
        
        let payloadCount = UInt8(ceil(Double(payloadBits.count) / 4))
        if payloadBits.count % 8 != 0 {
            payloadBits.append(1)
            // hack:
        }
        let payload = [0x00, UInt8(payloadCount)] + payloadBits.bytes
        
        let bitsNeededToStoreSizeOfPayload = log2(Double(payload.count + 1))
        let bytesNeededToStoreSizeOfPayload = UInt8(ceil(bitsNeededToStoreSizeOfPayload / 8))
        
        // Now to bring it all together...
        
        var bytes: [UInt8] = []
        
        bytes += UInt32(0xb5ee9c72).bigEndian.bytes // BOC's magic prefix
        print(bytes.toHexString())
        
        var flagsAndBytesNeededToStoreNumberOfCells: UInt8 = 0
        if hasCrc32 {
            flagsAndBytesNeededToStoreNumberOfCells |= 0b0_1_0_00_000
        }
        flagsAndBytesNeededToStoreNumberOfCells |= bytesNeededToStoreNumberOfCells
        bytes.append(flagsAndBytesNeededToStoreNumberOfCells)
        print(bytes.toHexString())
        
        bytes.append(bytesNeededToStoreSizeOfPayload)
        print(bytes.toHexString())
        
        bytes += IntN(numberOfCells, nBytes: Int(bytesNeededToStoreNumberOfCells)).bytes
        print(bytes.toHexString())
        
        // number of roots (1)
        bytes += IntN(1            , nBytes: Int(bytesNeededToStoreNumberOfCells)).bytes
        print(bytes.toHexString())
        // number of complete BOCs (0)
        bytes += IntN(0            , nBytes: Int(bytesNeededToStoreNumberOfCells)).bytes
        print(bytes.toHexString())
        // size of payload
        bytes += IntN(payload.count, nBytes: Int(bytesNeededToStoreSizeOfPayload)).bytes
        print(bytes.toHexString())
        // root index (0)
        bytes += IntN(0            , nBytes: Int(bytesNeededToStoreNumberOfCells)).bytes
        print(bytes.toHexString())
        
        bytes += payload
        print(bytes.toHexString())
        
        if hasCrc32 {
            bytes += Checksum.crc32c(bytes).bytes
            print(bytes.toHexString())
        }
        print(bytes.toHexString())
        self = BOC2(bytes: bytes)
    }
}

