
import SwiftUI
import SwiftUIBackports
import TonCore


public struct NewWalletFlow: View {
    
    @StateObject private var viewModel: ViewModel
    
    @State private var password = ""
    @State private var path: [Step] = []
    
    @State private var showAlert = false
    @State private var alertTitle: String = "Error"
    @State private var alertDescription: String = "Unexpected error occured"
    
    public init(onSuccess: @escaping (NewWalletResult) -> ()) {
        self._viewModel = StateObject(wrappedValue: ViewModel(onSuccess: onSuccess))
    }
    
    public var body: some View {
        if #available(iOS 16, *) {
            NavigationStack(path: $path) {
                start
                    .navigationDestination(for: Step.self, destination: makePage(_:))
                    .alert(alertTitle, isPresented: $showAlert, actions: {
                        Button(role: .cancel, action: {
                            showAlert = false
                        }, label: {
                            Text("OK").bold()
                        })
                    }, message: {
                        Text(alertDescription)
                    })
                
            }
        } else {
            NavigationView {
                start
                    .backport.navigationDestination(for: Step.self, destination: makePage(_:))
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertTitle), message: Text(alertDescription), dismissButton: .cancel(Text("OK")))
                    }
            }
        }
    }
    
    @ViewBuilder
    func makePage(_ step: Step) -> some View {
        switch step {
        case .start:
            start
        case .congratulations:
            congratulations
        case .recoveryPhrase:
            recoveryPhrase
        case .testTime:
            testTime
        case .passcode:
            passcode
        case .confirmPasscode:
            confirmPasscode
        case .biometricsPermission:
            biometricsPermission
        case .done:
            done
        case .importExisting:
            importExisting
        case .importSuccess:
            importSuccess
        case .importFailure:
            importFailure
        }
    }
    
    var start: some View {
        Start(
            createNew: {
                Task { @MainActor in
                    do {
                        viewModel.key = try await TonKey.create()
                        path.append(.congratulations)
                    } catch {
                        alertDescription = "Unexpected error occured: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }, importExisting: {
                self.path.append(.importExisting)
            })
    }
    
    var congratulations: some View {
        Congratulations(proceed: {
            self.path.append(.recoveryPhrase)
        })
    }
    
    @ViewBuilder var recoveryPhrase: some View {
        if let seedPhrase = viewModel.key?.seedPhrase {
            RecoveryPhrase(seedPhrase: seedPhrase, done: {
                self.path.append(.testTime)
            })
        }
    }
    
    @ViewBuilder var testTime: some View {
        if let (positions, answers) = viewModel.key?.seedPhrase.pickThree() {
            TestTime(checkWords: positions, answers: answers, seeWords: {
                if !path.isEmpty {
                    path.removeLast()
                }
            }, done: {
                self.path.append(.passcode)
            })
        }
    }
    
    var passcode: some View {
        Passcode(done: { passcode in
            viewModel.passcode = passcode
            self.path.append(.confirmPasscode)
        })
    }
    
    @ViewBuilder var confirmPasscode: some View {
        PasscodeCheck(correctCode: viewModel.passcode, done: { _ in
            self.path.append(.biometricsPermission)
        })
    }
    
    var biometricsPermission: some View {
        BiometricsPermission(done: {
            self.path.append(.done)
        })
    }
    
    var done: some View {
        Done(done: {
            success()
        })
    }
    
    var importExisting: some View {
        ImportExisting(checkWords: { _ in self.path.append(.importSuccess); return true }, doNotHave: { self.path.append(.importFailure) })
    }
    
    var importSuccess: some View {
        ImportSuccess(proceed: {
            success()
        })
    }
    
    var importFailure: some View {
        ImportFailure(tryAgain: { self.path.removeLast() }, createNew: { self.path = [.congratulations] })
    }
    
    func success() {
        viewModel.done()
    }
}

