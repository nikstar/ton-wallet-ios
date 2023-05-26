
import SwiftUI
import TonCore
import SharedUI

struct AddressTextField: View {

    @Binding var text: String
    @Binding var isFocused: Bool
    var placeholder: String
    
    var body: some View {
        if #available(iOS 16, *) {
            _ios16AddressTextField(text: _text, placeholder: placeholder)
        } else {
            _CompatAddressTextField(text: _text, isFocused: _isFocused, placeholder: placeholder)
        }
    }
}

@available(iOS 16, *)
struct _ios16AddressTextField: View {
    
    @Binding var text: String
    var placeholder: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .autocorrectionDisabled()
            .autocapitalization(.none)
            .textContentType(.username)
            .textFieldStyle(_AddressTextFieldStyle(showClearButton: true, onClear: { text = "" }))
            .focused($isFocused)
            .onSubmit {
                // verify
            }
            .onAppear {
                isFocused = true
            }
    }
}

struct _AddressTextFieldStyle: TextFieldStyle {
    
    var showClearButton: Bool
    var onClear: () -> ()
    
    func _body(configuration: TextField<_Label>) -> some View {
        HStack(alignment: .center, spacing: 10) {
            configuration
            if showClearButton {
                xButton
            }
        }
            .padding(14)
            .background(Color.theme.secondaryBackground)
            .cornerRadius(10)
            .multilineTextAlignment(.leading)
        
    }
    
    var xButton: some View {
        Button(action: onClear) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.theme.xButton)
        }
    }
}

@available(iOS, deprecated: 16)
struct _CompatAddressTextField: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var isFocused: Bool
    var placeholder: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> _UITextField {
        let textField = _UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.textContentType = .username
        textField.keyboardType = .asciiCapable
        textField.layer.cornerRadius = 10
        textField.layer.backgroundColor = Color.theme.secondaryBackground.cgColor
        textField.clearButtonMode = .whileEditing
        
        return textField
    }
    
    func updateUIView(_ textField: _UITextField, context: Context) {
        textField.text = text
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        
        var parent: _CompatAddressTextField

        init(parent: _CompatAddressTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}


class _UITextField: UITextField {
    
    private func inset(_ bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 16, dy: 14)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        inset(bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        inset(bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        inset(bounds)
    }
}



struct AddressTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AddressTextField(text: .constant(""), isFocused: .constant(false), placeholder: "placeholder")
            if #available(iOS 16, *) {
                _ios16AddressTextField(text: .constant(""), placeholder: "placeholder")
            }
            _CompatAddressTextField(text: .constant(""), isFocused: .constant(false), placeholder: "placeholder")
        }
        .padding()
    }
}
