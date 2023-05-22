
import SwiftUI
import TonCore
import SharedUI
import AppState


struct TransactionView: View {

    var transaction: TonCore.TonTransaction
    
    @EnvironmentObject var appState: AppState
    @Environment(\.backportDismiss) var dismiss
    
    var body: some View {
//        NavigationStack {
            VStack(spacing: 0) {
                ToncoinView(transaction.value)
                    .foregroundColor(transaction.direction == .incoming ? .green : .red)
                Text("0.004638685 transaction fee")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(transaction.date, style: .date)
                List {
                    Section(header: Text("Details")) {
                        Group {
                            Text("Sender address")
                            Text(transaction.counterparty.string(.base64url, characters: (4, 4)))
                        }
                        Group {
                            Text("Transaction")
                            Text(transaction.counterparty.string(.base64url, characters: (4, 4)))
                        }
                        Button(action: {}) {
                            Text("View in explorer")
                        }
                    }
                }
                Button(action: {}) {
                    Text("Send TON to this address")
                }
                .buttonStyle(.wallet())
            }
            .padding(.top, 32)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
            .navigationTitle(Text("Transaction"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                }
            }
//        }
    }
}
