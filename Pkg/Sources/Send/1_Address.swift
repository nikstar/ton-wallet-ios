
import SwiftUI
import SwiftUIBackports
import SharedUI

struct EnterAddressView<V: View>: View {
    
    @ViewBuilder var next: () -> V
    
    @State var addressText: String = ""
    @State var addressIsFocused: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                AddressTextField(text: $addressText, isFocused: $addressIsFocused, placeholder: "Enter Wallet Address or Domain...")
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                
                Text("Paste the 24-letter wallet address of the recipient here or TON DNS.")
                    .font(.callout)
                    .foregroundColor(.theme.secondary)
                    .padding(.bottom, 12)
                
                HStack(alignment: .firstTextBaseline, spacing: 20) {
                    
                    Button(action: paste) {
                        Label("Paste", systemImage: "doc.on.clipboard")
                    }
                    
                    Button(action: scan) {
                        Label("Scan", image: "minus.viewfinder")
                    }
                }
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
            
            
            .navigationTitle(Text("Send TON"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .fakeBackButton()
        }
        .continueButton(v: next)
    }
    
    // MARK: - Actions
    
    func paste() {
        if let s = UIPasteboard.general.string, !s.isEmpty {
            addressText = s
        }
    }
    
    func scan() {
        // todo
    }
}


extension View {
    
    @ViewBuilder fileprivate func continueButton(v: () -> some View) -> some View {
        if #available(iOS 16, *) {
            self.safeAreaInset(edge: .bottom) {
                _continueButton(v: v)
            }
        } else {
            self.backport.overlay(alignment: .bottom) {
                _continueButton(v: v)
            }
        }
    }
    
    private func _continueButton(v: () -> some View) -> some View {
        NavigationLink(destination: { v() }) {
            Text("Continue")
        }
        .buttonStyle(.tonBlue)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}


struct EnterAddress_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnterAddressView(next: { EmptyView() })
        }
    }
}
