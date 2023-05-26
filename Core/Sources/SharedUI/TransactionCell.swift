
import SwiftUI
import SwiftUIBackports
import TonCore

fileprivate var timeFormatter: DateFormatter {
    let f = DateFormatter()
    f.dateStyle = .none
    f.timeStyle = .short
    return f
}

public struct TransactionCell: View {
    
    var transaction: TonTransaction
    
    public init(_ transaction: TonTransaction) {
        self.transaction = transaction
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                ToncoinView(transaction.value)
                    .with(fontWholePart: .headline.weight(.medium), fontFractionalPart: .subheadline, maxDigits: nil, gemSize: 18, spacing: 1, kerning: nil)
                    .foregroundColor(transaction.direction == .incoming ? .theme.green : .theme.red)
                Text(transaction.direction == .incoming ? "from" : "to")
                    .padding(.leading, 4)
                    .foregroundColor(.theme.secondary)
                Spacer()
                Text(transaction.date, formatter: timeFormatter)
                    .foregroundColor(.theme.secondary)
            }
            .padding(.bottom, -2)
            Text(transaction.counterparty.string(.base64, characters: (6, 7)))
                .font(.system(.body, design: .monospaced))
            Text("0.000065732 storage fee")
                .foregroundColor(.theme.secondary)
            if let text = transaction.message {
                SpeechBubble {
                    Text(text)
                }
            }
        }
        .font(.subheadline.monospacedDigit())
        .foregroundColor(.theme.primary)
        .frame(maxWidth: .infinity)
    }
}


