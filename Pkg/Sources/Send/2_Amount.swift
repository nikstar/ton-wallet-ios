
import SwiftUI
import SwiftUIBackports
import SharedUI
import TonCore


struct AmountView: View {

    @State private var sendAll: Bool = false
    @State private var toncoin: Toncoin?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    (Text("Send to: ") + Text("EQcC...9ZLD").bold())
                    Spacer()
                    Button(action: {}) {
                        Text("Edit")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 120)
                
                EditableToncoinView(amount: $toncoin)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
            .navigationTitle(Text("Send TON"))
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar(.visible, for: .navigationBar)
        }
        .backport.overlay(alignment: .bottom) {
            VStack(spacing: 10) {
                Toggle(isOn: $sendAll) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Send all")
                        InlineToncoinView(Toncoin(nano: 0))
                    }
                }
                NavigationLink(destination: { EmptyView() }, label: {
                    Text("Continue")
                })
                    .buttonStyle(.tonBlue)
                    .padding(.bottom, 16)

            }
            .padding(.horizontal, 16)
        }
    }
}
