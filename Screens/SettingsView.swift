
import SwiftUI
import AppState
import TonCore


struct SettingsView: View {
    
    @Environment(\.backportDismiss) var dismiss
    @EnvironmentObject private var appState: AppState
    
    @State private var notificationsEnabled = true
    @State private var selectedAddressVersion = TonWallet.Version.default
    @State private var selectedCurrency = 0
    @State private var faceIDEnabled = true
    
    private let addressTypes = TonWallet.Version.allCases.reversed()
    private let currency = ["USD", "EUR"]
    
    var body: some View {
        NavigationView {
            
            List {
                Section(header: Text("General")) {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                    Picker("Active address", selection: $selectedAddressVersion) {
                        ForEach(addressTypes, id: \.self) { ver in
                            Text(ver.rawValue + (ver.isDefault ? " (default)" : ""))
                                .tag(ver)
                        }
                    }
                    Picker("Primary currency", selection: $selectedCurrency) {
                        ForEach(currency.indices, id: \.self) { idx in
                            Text(currency[idx])
                                .tag(idx)
                        }
                    }
                }
                
                Section(header: Text("Security")) {
                    NavigationLink("Show recovery phrase", destination: { EmptyView() })
                    NavigationLink("Change passcode", destination: { EmptyView() })
                    Toggle("Face ID", isOn: $faceIDEnabled)
                }
                
                Section {
                    Text("Delete Wallet")
                        .foregroundColor(.red)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(Text("Wallet Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .fakeBackButton()
            .onChange(of: selectedAddressVersion) { selectedAddressVersion in
                Task {
                    do {
                        guard let wallet = appState.wallet, wallet.version != selectedAddressVersion else { return }
                        let newWallet = try await TonWallet(version: selectedAddressVersion, keyPair: wallet.keyPair)
                        await appState.setWallet(newWallet)
                    } catch {}
                }
            }
            .onAppear {
                guard let wallet = appState.wallet else { return }
                selectedAddressVersion = wallet.version
            }
        }
    }
}
