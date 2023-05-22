
import SwiftUI
import SwiftUIBackports
import SharedUI
import TonCore


struct Start: View {
    
    var createNew: () -> ()
    var importExisting: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 180)
            Sticker("Start")
                .padding(.bottom, 20)
            Text("TON Wallet")
                .font(.theme.title)
                .padding(.bottom, 12)
            Text("TON Wallet allows you to make fast and secure blockchain-based payments without intermediaries.")
            Spacer()
            Button(action: createNew) {
                Text("Create my wallet")
            }
            .buttonStyle(.wallet())
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
            Button(action: importExisting) {
                Text("Import existing wallet")
            }
            .buttonStyle(.wallet(textColor: .theme.accent, backgroundColor: .clear))
            .padding(.horizontal, 16)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .padding(.bottom, 58)
        
    }
}


struct Congratulations: View {
    
    var proceed: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 136)
            Sticker("Congratulations")
                .padding(.bottom, 20)
            Text("Congratulations")
                .font(.theme.title)
                .padding(.bottom, 12)
            Text("Your TON Wallet has just been created.\nOnly you control it.\n\nTo be able to always have access to it, please write down secret words and set up a secure passcode.")
            Spacer()
            Button(action: proceed) {
                Text("Proceed")
            }
            .buttonStyle(.wallet())
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
            placeholderButton()
            .padding(.horizontal, 16)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .padding(.bottom, 58)
        .navigationBarBackButtonHidden()
    }
}







struct BiometricsPermission: View {
    
    var done: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 180)
            Image(systemName: "faceid")
                .resizable()
                .frame(width: 124, height: 124)
                .padding(.bottom, 20)
                .foregroundColor(.theme.accent)
            Text("Enable Face ID")
                .font(.theme.title)
                .padding(.bottom, 12)
            Text("Face ID allows you to open your wallet faster without having to enter your password.")
            Spacer()
            Button(action: askPermissionToUseBiometrics) {
                Text("Enable Face ID")
            }
            .buttonStyle(.wallet())
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
            Button(action: done) {
                Text("Skip")
            }
            .buttonStyle(.wallet(textColor: .theme.accent, backgroundColor: .clear))
            .padding(.horizontal, 16)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .padding(.bottom, 58)
    }
    
    func askPermissionToUseBiometrics() {
        done()
    }
}


struct Done: View {
    
    var done: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 180)
            Sticker("Start")
                .padding(.bottom, 20)
            Text("Ready to go!")
                .font(.theme.title)
                .padding(.bottom, 12)
            Text("You are all set. Now you have a wallet that only you control — directly, without middlemen or bankers.")
            Spacer()
            Button(action: done) {
                Text("View my wallet")
            }
            .buttonStyle(.wallet())
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
            placeholderButton()
                .padding(.horizontal, 16)
                .disabled(true)
            
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .padding(.bottom, 58)
    }
}


struct ImportExisting: View {
    
    var checkWords: ([String]) -> Bool
    var doNotHave: () -> ()
    
    @State private var showAlert = false
    @State private var words = [String](repeating: "", count: 24)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Sticker("Recovery Phrase", play: .playOnce)
                    .padding(.bottom, 20)
                Text("24 Secret Words")
                    .font(.theme.title)
                    .padding(.bottom, 12)
                Text("You can restore access to your wallet by entering 24 words you wrote when down you creating the wallet.")
                    .padding(.bottom, 40)
                Button(action: doNotHave) {
                    Text("I don’t have those")
                        .foregroundColor(.theme.accent)
                }
                ForEach(0..<24) { i in
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(i+1): ")
                            .font(.body.monospacedDigit())
                            .foregroundColor(.secondary)
                            .frame(minWidth: 26, alignment: .trailing)
                        TextField("", text: $words[i])
                            .textCase(.lowercase)
                            .autocapitalization(.none)
//                            .textInputAutocapitalization(.never)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.all, 14)
                    .backport.background {
                        Color(UIColor.tertiarySystemFill).cornerRadius(10)
                    }
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 16)
                .multilineTextAlignment(.leading)
                                
                Button(action: check) {
                    Text("Continue")
                }
                .buttonStyle(.wallet())
                .padding(.horizontal, 16)
                .padding(.bottom, 44)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.bottom, 8)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Incorrect words"),
                    message: Text("The secret words are not a valid recovery phrase."),
                    dismissButton: .cancel(Text("Try again"))
                )
            }
        }
    }
    
    func check() {
        let words = words.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
        if !checkWords(words) {
            showAlert = true
        }
    }
}


struct ImportSuccess: View {
    
    var proceed: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 136)
            Sticker("Congratulations")
                .padding(.bottom, 20)
            Text("Your wallet has just been imported!")
                .font(.theme.title)
                .padding(.bottom, 12)
            Spacer()
            Button(action: proceed) {
                Text("View my wallet")
            }
            .buttonStyle(.wallet())
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
            placeholderButton()
            .padding(.horizontal, 16)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .padding(.bottom, 58)
    }
}


struct ImportFailure: View {
    
    var tryAgain: () -> ()
    var createNew: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 180)
            Sticker("Too Bad")
                .padding(.bottom, 20)
            Text("Too Bad!")
                .font(.theme.title)
                .padding(.bottom, 12)
            Text("Without the secret words you can’t restore access to the wallet.")
            Spacer()
            Button(action: tryAgain) {
                Text("Enter 24 secret words")
            }
            .buttonStyle(.wallet())
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
            Button(action: createNew) {
                Text("Create a new empty wallet instead")
            }
            .buttonStyle(.wallet(textColor: .theme.accent, backgroundColor: .clear))
            .padding(.horizontal, 16)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .padding(.bottom, 58)
        
    }
}

