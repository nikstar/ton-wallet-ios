
import SwiftUI
import TonCore

public struct ToncoinView: View {
    
    var value: TonCore.Toncoin?
    
    var fontWholePart: Font = .system(size: 48, weight: .semibold, design: .rounded).monospacedDigit()
    var fontFractionalPart: Font = .system(size: 30, weight: .semibold, design: .rounded).monospacedDigit()
    var maxDigits: Int? = 4
    var gemSize: CGFloat = 48
    var spacing: CGFloat = 4
    var kerning: CGFloat = 0
    
    public init(_ value: Toncoin?) {
        self.value = value
    }
    
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Gem()
                .frame(width: gemSize, height: gemSize)
                .padding(.trailing, spacing)
            if let value {
                Text(value.wholePart)
                    .font(fontWholePart)
                Text(value.fractionalPart(maxDigits: maxDigits))
                    .font(fontFractionalPart)
                    .padding(.leading, kerning)
            } else {
                Text("")
                    .font(fontWholePart)
                    .foregroundColor(.clear)
            }
        }
        .animation(.linear, value: value)

        
    }
    
    func with(fontWholePart: Font? = nil, fontFractionalPart: Font? = nil, maxDigits: Int?, gemSize: CGFloat? = nil, spacing: CGFloat? = nil, kerning: CGFloat? = nil) -> ToncoinView {
        var copy = self
        if let fontWholePart {
            copy.fontWholePart = fontWholePart
        }
        if let fontFractionalPart {
            copy.fontFractionalPart = fontFractionalPart
        }
        copy.maxDigits = maxDigits
        if let gemSize {
            copy.gemSize = gemSize
        }
        if let spacing {
            copy.spacing = spacing
        }
        if let kerning {
            copy.kerning = kerning
        }
        return copy
    }
}
        

extension Toncoin {
    
    var wholePart: String {
        "\(nano/1_000_000_000)"
    }
    
    func fractionalPart(maxDigits: Int?) -> String {
        let v = abs(nano) % 1_000_000_000
        var s = String(format: "%09lld", v)
        while s.last == "0" {
            s.removeLast()
        }
        if s.isEmpty {
            return ""
        } else if let maxDigits {
            return "." + s.prefix(maxDigits)
        } else {
            return "." + s
        }
    }
}



public struct InlineToncoinView: View {
    
    @Environment(\.font) var font
    
    var amount: Toncoin
    
    public init(_ amount: Toncoin) {
        self.amount = amount
    }
    
    public var body: some View {
        ToncoinView(amount)
            .with(fontWholePart: font ?? .body, fontFractionalPart: font ?? .body, maxDigits: nil, gemSize: 22)
    }
}


struct ToncoinView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            InlineToncoinView(Toncoin(nano: 1234))
            InlineToncoinView(Toncoin(nano: 123412341234))
        }
        
    }
}
