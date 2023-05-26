import Foundation


extension Array<Bit> {
    
    var bytes: [UInt8] {
        
        var bytes: [UInt8] = []
        
        for bits in self.chunks(ofCount: 8) {
            let padding = [Bit](repeating: 0, count: 8 - bits.count)
            let s = (bits + padding).map { "\($0.value)" }.joined()
            bytes.append(UInt8(s, radix: 2)!)
        }
        
        return bytes
    }
}



