
import TonCore
import SwiftUI
import SharedUI


struct EditableToncoinView: View {
    
    @Binding var amount: Toncoin?
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Gem()
                .frame(width: 48, height: 48)
                .padding(.trailing, 2)
            _ToncoinTextField(amount: _amount)
        }
    }
}


private let wholeFont = UIFont.systemRounded(ofSize: 48, weight: .bold)
private let fractionalFont = UIFont.systemRounded(ofSize: 30, weight: .bold)

private let wholeAttrs: [NSAttributedString.Key : Any] = [.font: wholeFont]
private let fractionalAttrs: [NSAttributedString.Key : Any]  = [.font: fractionalFont]


fileprivate struct _ToncoinTextField: UIViewRepresentable {
    
    @Binding var amount: Toncoin?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = "0"

        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)

        textField.font = wholeFont
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .decimalPad
        textField.layer.backgroundColor = UIColor.clear.cgColor
        textField.clearButtonMode = .never
        textField.attributedText = amount?.attributedString ?? NSAttributedString(string: "")
        
        textField.becomeFirstResponder()
        return textField
    }
    
    func updateUIView(_ textField: UITextField, context: Context) {
        
        if amount != context.coordinator.displayedAmount {
            textField.attributedText = amount?.attributedString
            context.coordinator.reformat(textField: textField)
        }
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        
        var parent: _ToncoinTextField
        
        var needsReformat = false
        var displayedAmount: Toncoin?

        init(parent: _ToncoinTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
            
            let currentString = textField.attributedText?.string ?? ""
            
            if replacementString.isEmpty { // deleting characters
                
                if NSString(string: currentString).substring(with: range).contains(".") {
                    needsReformat = true
                }
                
                return true
                
            } else if replacementString.count == 1 {
            
                let dotIdx = currentString.firstIndex { $0 == "." }?.utf16Offset(in: currentString)
                let insertingFractional = (dotIdx != nil && range.location > dotIdx!)
                
                let char = Character(replacementString)
                
                if char.isNumber {
                    
                    if !insertingFractional {
                        textField.typingAttributes = wholeAttrs
                        return true
                    } else {
                        let split = currentString.split(separator: ".")
                        if split.count == 2 && split[1].count >= 9 {
                            return false
                        } else {
                            textField.typingAttributes =  fractionalAttrs
                            return true
                        }
                    }

                } else if char == "." {
                    
                    if currentString.contains(".") {
                        return false
                    }
                    if currentString == "" {
                        let str = NSMutableAttributedString(string: "0.")
                        str.setAttributes(wholeAttrs, range: NSMakeRange(0, 1))
                        str.setAttributes(fractionalAttrs, range: NSMakeRange(1, 1))
                        textField.attributedText = str
                        textField.typingAttributes = fractionalAttrs
                        return false
                    }
                    textField.typingAttributes = fractionalAttrs
                    if range.upperBound != currentString.count {
                        needsReformat = true
                    }
                    return true
                    
                } else { // not digit or dot
                    return false
                }
                
            } else { // inserting multiple characters
                
                let s = currentString.index(currentString.startIndex, offsetBy: range.location)
                let e = currentString.index(s, offsetBy: range.length)
                var newString = currentString
                newString.removeSubrange(s..<e)
                newString.insert(contentsOf: replacementString, at: s)
                if Toncoin(string: newString) != nil {
                    needsReformat = true
                    return true
                } else {
                    return false
                }
            }
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            
            if needsReformat {
                needsReformat = false
                reformat(textField: textField)
            }

            let v = Toncoin(string: textField.attributedText?.string ?? "")
            displayedAmount = v
            parent.amount = v
        }
        
        func reformat(textField: UITextField) {
            needsReformat = false
            
            let string = textField.attributedText?.string ?? ""
            let value = Toncoin(string: string)
            self.displayedAmount = value
            if let value {
                textField.attributedText = value.attributedString
            } else {
                textField.attributedText = NSAttributedString(string: "")
                textField.typingAttributes = wholeAttrs
            }
        }
    }
}


extension UIFont {
    class func systemRounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}


fileprivate extension Toncoin {
    
    init?(string: String) {
        var s = string.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
        if s.isEmpty {
            return nil
        }
        if s.first == "." {
            s = "0" + s
        }
        if s.last == "." {
            s = s + "0"
        }
        var decimal: Decimal?
        if #available(iOS 15.0, *) {
            decimal = try? Decimal(s, format: .number, lenient: true)
        }
        if decimal == nil {
            decimal = Decimal(string: s)
        }
        if decimal == nil {
            decimal = Decimal(string: s, locale: .init(identifier: "en_US"))
        }
        if decimal == nil {
            decimal = Decimal(string: s, locale: .init(identifier: "en_GB"))
        }
        if decimal == nil {
            decimal = Decimal(string: s, locale: .init(identifier: "ru_RU"))
        }
        guard var decimal else {
            return nil
        }
        decimal *= 1_000_000_000
        self = Toncoin(nano: NSDecimalNumber(decimal: decimal).intValue)
    }

    var attributedString: NSAttributedString {
        let s = NSMutableAttributedString(string: wholePart + fractionalPart)
        let pointIdx = wholePart.utf16.count
        s.setAttributes([
            NSAttributedString.Key.font : UIFont.systemRounded(ofSize: 48, weight: .bold),
        ], range: NSRange(location: 0, length: pointIdx))
        if fractionalPart != "" {
            s.setAttributes([
                NSAttributedString.Key.font : UIFont.systemRounded(ofSize: 30, weight: .bold),
            ], range: NSRange(location: pointIdx, length: fractionalPart.utf16.count))
        }
        return s
    }
    
    var wholePart: String {
        "\(nano/1_000_000_000)"
    }

    var fractionalPart: String {
        var v = abs(nano) % 1_000_000_000
        while (v != 0) && (v % 10 == 0) {
            v /= 10
        }
        if v == 0 {
            return ""
        } else {
            return String(".\(v)".prefix(5))
        }
    }
}


// MARK: - Preview

fileprivate struct Test: View {
    
    @State var toncoin: Toncoin?
    
    var body: some View {
        VStack {
            EditableToncoinView(amount: $toncoin)
            Text(String(describing: toncoin))
            Button(action: { toncoin = Toncoin(nano: 1234_567_000_000) }) {
                Text("Set to 1234.56")
            }
            Button(action: { toncoin = nil }) {
                Text("Set to nil")
            }
        }
    }
    
}

struct EditableToncoin_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Test()
            EditableToncoinView(amount: .constant(nil))
            EditableToncoinView(amount: .constant(.init(nano: 1234_567_000_000)))
        }
        .border(Color.red)
    }
}
