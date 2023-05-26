
import SharedUI
import SwiftUI
import SwiftUIBackports
import TonCore


struct RecoveryPhrase: View {
    
    var seedPhrase: TonSeedPhrase
    var done: () -> ()
    
    @State private var appearDate: Date? = nil
    @State private var didWarn = false
    @State private var showAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 26)
                Sticker("Recovery Phrase", play: .playOnce)
                    .padding(.bottom, 20)
                Text("Your Recovery Phrase")
                    .font(.theme.title)
                    .padding(.bottom, 12)
                Text("Write down these 24 words in this exact order and keep them in a secure place. Do not share this list with anyone. If you lose it, you will irrevocably lose access to your TON account.")
                    .padding(.bottom, 40)
                gridView
                    .padding(.trailing, 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 52)
                    .onAppear {
                        if appearDate == nil {
                            appearDate = Date()
                        }
                    }
                
                Button(action: maybeDone) {
                    Text("Done")
                }
                .buttonStyle(.wallet())
                .padding(.horizontal, 16)
                .padding(.bottom, 44)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .alert(isPresented: $showAlert, content: {
                if didWarn == false {
                    return Alert(
                        title: Text("Sure done?"),
                        message: Text("You didn’t have enough time to write these words down."),
                        dismissButton: .cancel(Text("OK, sorry").bold()) {
                            didWarn = true
                        }
                    )
                } else {
                    return Alert(
                        title: Text("Sure done?"),
                        message: Text("You didn’t have enough time to write these words down."),
                        primaryButton: .cancel(Text("OK, sorry").bold()),
                        secondaryButton: .default(Text("Skip")) {
                            showAlert = false
                            done()
                        }
                    )
                }
            })
        }
    }
    
    @ViewBuilder var gridView: some View {
        if #available(iOS 16, *) {
            Grid(alignment: .leading, horizontalSpacing: 6, verticalSpacing: 12) {
                ForEach(0..<12) { i in
                    GridRow {
                        Text("\(i+1).")
                            .font(.body.monospacedDigit())
                            .foregroundColor(.secondary)
                            .gridColumnAlignment(.trailing)
                        Text("\(seedPhrase.words[i])")
                            .font(.system(.body, weight: .semibold))
                            .gridColumnAlignment(.leading)
                        Spacer()
                        Text("\(i+12+1).")
                            .font(.body.monospacedDigit())
                            .foregroundColor(.secondary)
                            .gridColumnAlignment(.trailing)
                        Text("\(seedPhrase.words[i+12])")
                            .gridColumnAlignment(.leading)
                            .font(.system(.body, weight: .semibold))
                    }
                    
                }
            }
        } else {
            VStack(spacing: 12) {
                ForEach(0..<12) { i in
                    HStack(spacing: 6) {
                        Text("\(i+1).")
                            .font(.body.monospacedDigit())
                            .foregroundColor(.secondary)
                            .frame(width: 20, alignment: .trailing)
                        Text("\(seedPhrase.words[i])")
                            .font(.body.weight(.semibold))
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text("\(i+12+1).")
                            .font(.body.monospacedDigit())
                            .foregroundColor(.secondary)
                            .frame(width: 20, alignment: .trailing)
                        Text("\(seedPhrase.words[i+12])")
                            .font(.body.weight(.semibold))
                            .frame(width: 80, alignment: .leading)
                    }
                }
            }
        }
    }
    
    func maybeDone() {
        
        let now = Date()
        if let appearDate, now > appearDate.addingTimeInterval(15) {
            done()
        } else {
            showAlert = true
        }
        
    }
}


struct TestTime: View {
    
    var checkWords: [Int]
    var answers: [String]
    var seeWords: () -> ()
    var done: () -> ()
    
    @State private var showAlert = false
    @State private var words = ["", "", ""]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 26)
                Sticker("Test Time")
                    .padding(.bottom, 20)
                Text("Test Time!")
                    .font(.theme.title)
                    .padding(.bottom, 12)
                Text("Let’s check that you wrote them down correctly. Please enter the words \(checkWords[0]+1), \(checkWords[1]+1) and \(checkWords[2]+1).")
                    .padding(.bottom, 36)
                    .padding(.trailing, 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
                
                ForEach(0..<3) { i in
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(checkWords[i]+1): ")
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
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                }
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Incorrect words"),
                    message: Text("The secret words you have entered do not match the ones in the list."),
                    primaryButton: .default(Text("See words")) {
                        showAlert = false
                        seeWords()
                    },
                    secondaryButton: .default(Text("Try again")) {
                        showAlert = false
                    }
                )
            }
        }
    }
    
    func check() {
        let words = words.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
        if words != answers {
            showAlert = true
        } else {
            done()
        }
    }
}
