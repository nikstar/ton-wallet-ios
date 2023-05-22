
import SwiftUI
import SwiftUIBackports


struct CommentView: View {
    
    @State private var commentText = ""
    @Environment(\.backportDismiss) private var dismiss
    
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
            }.border(Color.red)
            Section  {
                Backport.LabeledContent {
                    Text("EQCc…9ZLD")
                } label: {
                    Text("Recipient")
                }
                Backport.LabeledContent {
                    Text("56")
                } label: {
                    Text("Amount")
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
            Button(action: { dismiss() }, label: {
                Text("Confirm and send")
            })
            .padding(.horizontal, 16)
            .buttonStyle(.tonBlue)
            .padding(.bottom, 16)
        }
    }
}
