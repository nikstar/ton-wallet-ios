
import Foundation
import TonCore

public struct TonURL: Equatable {

    public let address: TonAddress
    public let amount: Toncoin?
    public let text: String?
    
    public init?(string: String) {
        guard let url = URL(string: string) else { return nil }
        self.init(url: url)
    }
    
    public init?(url: URL) {

        guard url.scheme == "ton" && url.host == "transfer" else { return nil }

        let addressString = url.path
        guard !addressString.isEmpty, let address = TonAddress.parse(String(addressString.dropFirst())) else { return nil }
        
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        var amountNano: Int?
        var text: String?
        
        for i in (comps.queryItems ?? []) {
            if i.name == "amount", let s = i.value, let v = Int(s) {
                amountNano = v
            } else if i.name == "text", let s = i.value {
                text = s
            }
        }
        
        self.address = address
        if let amountNano {
            self.amount = Toncoin(nano: amountNano)
        } else {
            self.amount = nil
        }
        self.text = text
    }
    
}
