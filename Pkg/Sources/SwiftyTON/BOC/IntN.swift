
import Foundation


struct IntN {
    
    let value: Int
    let nBits: Int
    var nBytes: Int { (nBits + 7) / 8 }
    
    init(_ value: Int, nBits: Int) {
        self.value = value
        self.nBits = nBits
    }
    
    init(_ value: Int, nBytes: Int) {
        self.value = value
        self.nBits = nBytes * 8
    }
}
