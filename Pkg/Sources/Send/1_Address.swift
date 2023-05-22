
import SwiftUI
import SwiftUIBackports
import SharedUI
import TonCore

struct EnterAddressView: View {
    
     var next: () -> ()
    
    @State var addressText: String = ""
    @State var addressIsFocused: Bool = false
    @EnvironmentObject var model: Model
    
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
        .onAppear {
            addressText = model.destinationAddress?.string(.base64url) ?? ""
        }
        .continueButton {
            Button(action: continueAction) {
                        Text("Continue")
                
            }
            .buttonStyle(.tonBlue)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Actions
    
    func paste() {
        if let s = UIPasteboard.general.string, !s.isEmpty {
            addressText = s
            
        }
    }
    
    func scan() {
        // todo; use button in main view instead
    }

    func continueAction() {
        Task {
            if let a = TonAddress.parse(addressText) {
                model.destinationAddress = a
                next()
            } else {
                addressText = ""
            }
        }
    }
}


extension View {
    
    @ViewBuilder fileprivate func continueButton(v: () -> some View) -> some View {
        if #available(iOS 16, *) {
            self.safeAreaInset(edge: .bottom) {
                v()
            }
        } else {
            self.backport.overlay(alignment: .bottom) {
                v()
            }
        }
    }
}


struct EnterAddress_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnterAddressView(next: { EmptyView() })
        }
    }
}


