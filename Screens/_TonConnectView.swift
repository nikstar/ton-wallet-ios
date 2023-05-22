
import SwiftUI


struct TonConnectView: View {
    
    @Environment(\.backportDismiss) var dismiss
    
    var body: some View {
        NavigationView {
            EmptyView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                }
            }
        }
    }

    
}
