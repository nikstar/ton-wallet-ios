
import SwiftUI
import TonCore

public final class ViewModel: ObservableObject {
    
    @Published var key: TonKey? = nil
    @Published var step: Step = .start
    @Published var words: [String] = []
    @Published var passcode: String = ""
    @Published var biometricsEnabled: Bool = false
    
    var onSuccess: (NewWalletResult) -> ()
    
    init(onSuccess: @escaping (NewWalletResult) -> Void) {
        self.onSuccess = onSuccess
    }
    
    func done() {
        Task {
            do {
                if let key {
                    let wallet = try await TonWallet(version: .v4r2, keyPair: key)
                    onSuccess(.init(wallet: wallet, isNew: true, passcode: passcode, biometricsEnabled: biometricsEnabled))
                }
            } catch {
                print(error)
            }
        }
    }
}

public struct NewWalletResult {
    
    public var wallet: TonWallet
    public var isNew: Bool
    public var passcode: String
    public var biometricsEnabled: Bool
}


enum Step: Codable {
    case start
    
    case congratulations
    case recoveryPhrase
    case testTime
    case passcode
    case confirmPasscode
    case biometricsPermission
    case done
    
    case importExisting
    case importSuccess
    case importFailure
}
