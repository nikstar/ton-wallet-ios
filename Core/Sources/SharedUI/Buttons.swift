
import SwiftUI
import SwiftUIBackports

public struct WalletButtonStyle: ButtonStyle {
    
    var textColor: Color = .white
    var backgroundColor: Color = .tonBlue
    var font: Font = .body.bold()
    var padding: CGFloat = 14
    var cornerRadius: CGFloat = 12
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundColor(textColor)
            .padding(.all, padding)
            .frame(maxWidth: .infinity)
            .backport.background {
                backgroundColor
            }
            .backport.overlay {
                Color.black.opacity(0.1)
                    .blendMode(.multiply)
                    .opacity(configuration.isPressed ? 1 : 0)
            }
            .cornerRadius(cornerRadius)
    }
}

public func placeholderButton() -> some View {
    Button(action: {}) {
        Text("Placeholder")
    }
    .buttonStyle(WalletButtonStyle(textColor: .clear, backgroundColor: .clear))
    .disabled(true)
    .accessibilityHidden(true)
}

extension ButtonStyle where Self == WalletButtonStyle {
    
    public static func wallet(textColor: Color = .white, backgroundColor: Color = .theme.accent) -> WalletButtonStyle {
        WalletButtonStyle(textColor: textColor, backgroundColor: backgroundColor)
    }
    
    public static var tonBlue: WalletButtonStyle {
        WalletButtonStyle(textColor: .white, backgroundColor: .tonBlue)
    }

    public static var tonLightBlue: WalletButtonStyle {
        WalletButtonStyle(textColor: .white, backgroundColor: .tonLightBlue)
    }

    public static var tonClearBackground: WalletButtonStyle {
        WalletButtonStyle(textColor: .tonBlue, backgroundColor: .clear)
    }
}

