
import SwiftUI


struct SettingsView: View {
    
    @Environment(\.backportDismiss) var dismiss
    
    @State private var notificationsEnabled = true
    @State private var selectedAddress = 0
    @State private var selectedCurrency = 0
    @State private var faceIDEnabled = true
    
    private let addressTypes = ["v4R2", "v3R3", "v3R1"]
    private let currency = ["USD", "EUR"]
    
    var body: some View {
        NavigationView {
            
            List {
                Section(header: Text("General")) {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                    Picker("Active address", selection: $selectedAddress) {
                        ForEach(addressTypes.indices, id: \.self) { idx in
                            Text(addressTypes[idx])
                                .tag(idx)
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
        }
    }
}
