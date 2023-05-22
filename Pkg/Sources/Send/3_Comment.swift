
import SwiftUI
import SwiftUIBackports
import TonCore
import SharedUI

struct CommentView: View {
    
    var next: () -> ()
    
    @State private var commentText = ""
    @Environment(\.backportDismiss) private var dismiss
    @EnvironmentObject var model: Model
    
    var body: some View {
        List {
            Section {
                if #available(iOS 16, *) {
                    TextField("Description of payment", text: $commentText, axis: .vertical)
                } else {
                    TextField("Description of payment", text: $commentText)
                }
            } header: {
                Text("Comment (optional)")
            } footer: {
                Text("The comment is visible to everyone. You must include the note when sending to an exchange.")
            }
            
            Section  {
                if let a = model.destinationAddress {
                    Backport.LabeledContent {
                        Text(a.string(.base64url, characters: (4, 4)))
                    } label: {
                        Text("Recipient")
                    }
                }
                if let v = model.amount {
                    Backport.LabeledContent {
                       InlineToncoinView(v)
                    } label: {
                        Text("Amount")
                    }
                }
                Backport.LabeledContent {
                    Text("≈ 0.007")
                } label: {
                    Text("Fee")
                }
            } header: {
                Text("Info")
            }
        }
        .listStyle(.insetGrouped)
        .border(Color.red)
        .navigationTitle(Text("Send TON"))
        .navigationBarTitleDisplayMode(.inline)
        .backport.overlay(alignment: .bottom) {
            Button(action: {
                Task {
                    do {
                        if let a = model.destinationAddress, let amount = model.amount {
                            let outgoingTransaction = OutgoingTransaction(destinationAddress: a, amount: amount, comment: commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : commentText )
                            try await model.sendTransaction(outgoingTransaction)
                            
                        }
                        next()
                    } catch {
                        print(error)
                    }
                }
                
                
            }, label: {
                Text("Confirm and send")
            })
            .padding(.horizontal, 16)
            .buttonStyle(.tonBlue)
            .padding(.bottom, 16)
        }
    }
}
