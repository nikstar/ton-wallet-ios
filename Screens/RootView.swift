
import SwiftUI
import NewWallet
import AppState

/// Root view of the view hierarchy that manages transition between `MainWalletView` and `NewWallet` flow
struct RootView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    enum ViewState {
        case main, transition, setup
    }
    @State private var state: ViewState = .transition
    @State private var padding: CGFloat = 300
    
    
    var body: some View {
        MainWalletView()
            .backport.overlay {
                transitionView
            }
            .backport.overlay {
                if state == .setup {
                    NewWalletFlow(onSuccess: { result in
                        Task {
                            await appState.setWallet(result.wallet)
                            appState.setSetupComplete(true)
                            appState.setPasscode(result.passcode)
                            appState.biometricsEnabled = result.biometricsEnabled
                        }
                    })
                }
            }
            .backport.overlay(alignment: .top) {
                if showsDebugOverlay {
                    DebugOverlay()
                }
            }
            .onAppear {
                maybeShowSetup(setupComplete: appState.setupComplete)
            }
            .onChange(of: appState.setupComplete) { setupComplete in
                maybeShowSetup(setupComplete: setupComplete)
            }
            .ignoresSafeArea()
            .overrideStatusBarColor(state == .setup ? .darkContent : .lightContent)
            .preferredColorScheme(.light)
    }
    
    @ViewBuilder var transitionView: some View {
        Color.black
            .backport.overlay(alignment: .bottom) {
                Color.white
                    .cornerRadius(16)
                    .ignoresSafeArea(edges: .bottom)
                    .padding(.top, padding + safeAreaInsets.top)
                    .padding(.bottom, -16)
            }
            .ignoresSafeArea()
            .blendMode(.lighten)
            .opacity(state == .main ? 0 : 1)
    }

    // MARK: - Animations
    
    func maybeShowSetup(setupComplete: Bool) {
        if setupComplete == false {
            showSetup()
        } else {
            if state == .setup {
                hideSetup()
            } else {
                state = .main
            }
        }
    }
    
    func showSetup() {
        withAnimation(.easeOut(duration: 0.45).delay(0.15)) {
            padding = -50
        }
        withAnimation(.linear(duration: 0.3).delay(0.3)) {
            state = .setup
        }
//        Task { @MainActor in
//            try? await Task.sleep(nanoseconds: 300_000_000)
//            withAnimation(.linear(duration: 0.3)) {
//            }
//        }
    }
    
    func hideSetup() {
        withAnimation(.linear(duration: 0.2)) {
            state = .transition
        }
        withAnimation(.easeInOut(duration: 0.45)) {
            padding = 300
        }
        withAnimation(.linear(duration: 0.25).delay(0.5)) {
            state = .main
        }
    }
}

