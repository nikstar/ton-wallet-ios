
import SwiftUI
import AppState

#if DEBUG
let showsDebugOverlay = false // set to true
#else
let showsDebugOverlay = false
#endif


@main
struct WalletApp: SwiftUI.App {
    
    @StateObject private var appState: AppState = .load()
    
    var body: some Scene {
        WindowGroup {
                RootView()
//            MainWalletView()
                    .environmentObject(appState)
                    .onOpenURL { tonURL in
                        if let url = TonURL(url: tonURL) {
                            appState.requestedTonURL = url
                        }
                    }
        }
    }
}

