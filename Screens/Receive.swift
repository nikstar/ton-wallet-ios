
import SwiftUI
import CoreImage.CIFilterBuiltins
import SharedUI
import SwiftUIBackports
import AppState

struct Receive: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.backportDismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Receive Toncoin")
                    .font(.theme.title)
                    .padding(.bottom, 12)
                Text("Send only **Toncoin (TON)** to this address. Sending other coins may result in permanent loss.")
                    .padding(.horizontal, 8)
                Spacer()
                if let address = appState.wallet?.address.string(.base64url) {
                    Image(uiImage: generateQRCode(from: address))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .backport.overlay {
                            ZStack {
                                Circle().fill(.white)
                                Gem()
                                    .padding(4)
                            }
                            .frame(width: 66, height: 66)
                        }
                    Spacer()
                    Text(address.prefix(address.count/2)+"\n"+address.dropFirst(address.count/2))
                        .font(.theme.monospaced)
                        .padding(.bottom, 6)
                    Text("Your wallet address")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {}) {
                        Label {
                            Text("Share Wallet Address")
                        } icon: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .buttonStyle(.wallet())
                } else {
                    Text("Failed to load address")
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .fakeBackButton()
        }
        .multilineTextAlignment(.center)
        
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "H"
        let ciImage = filter.outputImage!
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        return UIImage(cgImage: cgImage)
    }
}



struct Receive_Previews: PreviewProvider {
    static var previews: some View {
        Receive()
            .environmentObject(AppState.load())
    }
}
