
import SwiftUI


extension UIColor {
    var dark: UIColor  { resolvedColor(with: .init(userInterfaceStyle: .dark))  }
    var light: UIColor { resolvedColor(with: .init(userInterfaceStyle: .light)) }
}


extension Color {
    
    init(_ uiColor: UIColor, _ colorScheme: ColorScheme) {
        switch colorScheme {
        case .light:
            self.init(uiColor.light)
        case .dark:
            self.init(uiColor.dark)
        @unknown default:
            self.init(uiColor)
        }
    }
    
    
    init(_ hex: Int) {
        let hex = UInt(hex)
        let r = (hex >> 16) & 0xFF
        let g = (hex >>  8) & 0xFF
        let b = (hex >>  0) & 0xFF
        self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
}


extension Color {
    
    public static var theme: ThemeColors.Type { ThemeColors.self }
    
    static var tonBlue: Color {
        return .blue
    }
    
    static var tonLightBlue: Color {
        return .init(red: Double(0x32)/255, green: Double(0xAA)/255, blue: Double(0xFE)/255)
    }
}


public final class ThemeColors {
    
    public static var accent: Color { .init(UIColor.systemBlue.light) }
    public static var primary: Color { .init(UIColor.label.light) }
    public static var background: Color { .white }
    public static var secondary: Color { .init(UIColor.secondaryLabel.light) }
    public static var secondaryBackground: Color { .init(0xEFEFF3) }
    public static var walletAccent: Color { .init(0x32AAFE) }
    public static var xButton: Color { .init(0x8E8E92) }
    public static var green: Color { .init(UIColor.systemGreen.light) }
    public static var red: Color { .init(UIColor.systemRed.light) }
}
