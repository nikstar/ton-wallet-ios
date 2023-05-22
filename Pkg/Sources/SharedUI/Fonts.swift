
import SwiftUI

extension Font {
    public static var theme: ThemeFonts.Type { ThemeFonts.self }
}


public final class ThemeFonts {

    public static var title: Font { .title.weight(.semibold) }
    public static var monospaced: Font { .system(.body, design: .monospaced) }
    
}
