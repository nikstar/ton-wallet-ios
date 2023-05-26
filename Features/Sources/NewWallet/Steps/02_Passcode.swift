
import SwiftUI
import SwiftUIBackports
import SharedUI
import TonCore


struct Passcode: View {
    
    var done: (String) -> ()
    
    @State var password = ""
    @State var length = 4
    @FocusState var passwordEntryFocused
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 26)
                Sticker("Password")
                    .padding(.bottom, 20)
                Text("Set a Passcode")
                    .font(.theme.title)
                    .padding(.bottom, 12)
                Text("Enter the \(length) digits in the passcode.")
                    .padding(.bottom, 36)
                    .padding(.trailing, 8)
                
                PasscodeTextField($password, length: length, done: done)
                
                settings
            }
            .padding(.horizontal, 32)
            .multilineTextAlignment(.center)
            .ignoresSafeArea(.keyboard)
        }
    }
    
    var settings: some View {
        Menu("Passcode options") {
            Button {
                if length != 4 {
                    password = ""
                    length = 4
                }
            } label: {
                Text("4-digit code")
            }
            Button {
                if length != 6 {
                    password = ""
                    length = 6
                }
            } label: {
                Text("6-digit code")
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}


struct PasscodeCheck: View {
    
    var correctCode: String
    var done: (String) -> ()
    
    @State var password = ""
    @State var length = 4
    @FocusState var passwordEntryFocused
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 26)
                Sticker("Password")
                    .padding(.bottom, 20)
                Text("Set a Passcode")
                    .font(.theme.title)
                    .padding(.bottom, 12)
                Text("Enter the \(length) digits in the passcode.")
                    .padding(.bottom, 36)
                    .padding(.trailing, 8)
                
                PasscodeTextField($password, length: length, done: done)

            }
            .padding(.horizontal, 32)
            .multilineTextAlignment(.center)
            .ignoresSafeArea(.keyboard)
        }
    }
}



struct PasscodeTextField: View {
    
    var length: Int
    var done: (String) -> ()
    
    private var _passcode: Binding<String>
    @FocusState private var passwordEntryFocused
    
    var passcode: String {
        get {
            _passcode.wrappedValue
        }
        set {
            _passcode.wrappedValue = newValue
        }
    }
    
    init(_ passcode: Binding<String>, length: Int, done: @escaping (String) -> ()) {
        self._passcode = passcode
        self.length = length
        self.done = done
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if #available(iOS 15, *) {
                TextField("", text: _passcode)
                    .textSelection(.disabled)
                    .textInputAutocapitalization(.never)
                    .textContentType(.password)
                    .keyboardType(.decimalPad)
                    .focused($passwordEntryFocused)
                    .frame(width: 0)
                    .onChange(of: passcode, perform: { password in
                        if password.count == length {
                            done(password)
                        }
                    })
                
                HStack(spacing: 16) {
                    if length == 4 {
                        ForEach(0..<4) { i in
                            ZStack {
                                Circle().stroke(lineWidth: 1).foregroundColor(Color(UIColor.separator)).frame(width: 16, height: 16)
                                if i + 1 <= passcode.count {
                                    Circle().fill().frame(width: 16, height: 16)
                                }
                            }
                        }
                    } else {
                        ForEach(0..<6) { i in
                            ZStack {
                                Circle().stroke(lineWidth: 1).foregroundColor(Color(UIColor.separator)).frame(width: 16, height: 16)
                                if i + 1 <= passcode.count {
                                    Circle().fill().frame(width: 16, height: 16)
                                }
                            }
                        }
                    }
                }
                .onTapGesture {
                    passwordEntryFocused = true
                }
                .onAppear {
                    passwordEntryFocused = true
                }
            } else {
                TextField("", text: _passcode)
                    .textContentType(.password)
                    .keyboardType(.decimalPad)
                    .frame(width: 0)
                    .onChange(of: passcode, perform: { password in
                        if password.count == length {
                            done(password)
                        }
                    })
                
                HStack(spacing: 16) {
                    if length == 4 {
                        ForEach(0..<4) { i in
                            ZStack {
                                Circle().stroke(lineWidth: 1).foregroundColor(Color(UIColor.separator)).frame(width: 16, height: 16)
                                if i + 1 <= passcode.count {
                                    Circle().fill().frame(width: 16, height: 16)
                                }
                            }
                        }
                    } else {
                        ForEach(0..<6) { i in
                            ZStack {
                                Circle().stroke(lineWidth: 1).foregroundColor(Color(UIColor.separator)).frame(width: 16, height: 16)
                                if i + 1 <= passcode.count {
                                    Circle().fill().frame(width: 16, height: 16)
                                }
                            }
                        }
                    }
                }

            }
        }

    }
    
}
