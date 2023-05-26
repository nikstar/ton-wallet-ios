
import SwiftUI
import AppState
import SwiftyTON
import TonCore


struct DebugOverlay: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    var body: some View {
        VStack {
            Button(action: { appState.debug_toggleSetupComplete() }) {
                Text("setupComplete.toggle()")
            }
            Button(action: { appState.debug_loadTestWallet() }) {
                Text("Load test wallet")
            }
            Button(action: { appState.debug_fullReset() }) {
                Text("Delete all data end reset")
            }
            Button(action: {
                Task {
                    try! await appState.tonBlockchain.sendTransaction(usingWallet: appState.wallet!, to: appState.wallet!.address, amount: Toncoin(nano: 1_000), comment: "Test") }
                }) {
                    Text("Send test transaction")
                }
            
        }
        .padding(.top, safeAreaInsets.top)
    }
}
