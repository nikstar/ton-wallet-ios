
import SwiftUI
import CodeScanner
import AppState


struct ScannerView: View {
    
    @Environment(\.backportDismiss) var dismiss
    @EnvironmentObject private var appState: AppState
    
    var completion: (TonURL?) -> ()
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, showViewfinder: true, simulatedData: "ton://transfer/EQDxqxT1zemcb4vfO1azdErbfomWJc6ZvhCMQKshiQntSifa", shouldVibrateOnSuccess: true, isTorchOn: false) { result in
            switch result {
            case .success(let r):
                print(r.string)
                let url = TonURL(string: r.string)
                dismiss()
                appState.requestedTonURL = url

            case .failure(let e):
                print(e)
            }
        }
//        .preferredColorScheme(.dark)
    }

    
}
