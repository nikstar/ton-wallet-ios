
import SwiftUI


struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let ov = value
        let nv = nextValue()
        if nv != 0 {
            value = nv
        }
        print("\(ov) -> \(nv)", value)
    }
}

struct SelfSizingSheet<SheetContent: View>: ViewModifier {
    
    var isPresented: Binding<Bool>
    var sheetContent: () -> SheetContent
    
    @State private var height: CGFloat = 0
    
    func body(content: Content) -> some View {
        content.sheet(isPresented: isPresented) {
            sheetContent()
                .padding(.bottom, 8)
                .backport.background {
                    GeometryReader { proxy in
                        Color.clear.preference(key: InnerHeightPreferenceKey.self, value: proxy.size.height)
                    }
                }
                .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in print(height, newHeight); height = newHeight }
//                .presentationDetents([.height(height)])
        }
    }
}

extension View {
    
    func selfSizingSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(SelfSizingSheet(isPresented: isPresented, sheetContent: content))
    }
}

