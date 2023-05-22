
import SwiftUI
import SwiftUIBackports


public struct SpeechBubble<Content: View>: View {
    
    @ViewBuilder public var content: Content
    
    public var body: some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .backport.background {
                ZStack {
                    RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .fill(Color.theme.secondaryBackground)
                    SpeechBubbleShape()
                        .fill(Color.theme.secondaryBackground)
                }
            }
    }
    
}


fileprivate struct SpeechBubbleShape: Shape {
    
    let r1: CGFloat = 10
    let r2: CGFloat = 20
    let ofs: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to:         .init(x: rect.minX,            y: rect.midY     ))
            p.addLine(to:      .init(x: rect.minX,            y: rect.maxY - r1))
            p.addQuadCurve(to: .init(x: rect.minX - ofs,      y: rect.maxY     ),
                      control: .init(x: rect.minX,            y: rect.maxY     ))
            p.addQuadCurve(to: .init(x: rect.minX - ofs + r2, y: rect.maxY - r2 + 1),
                      control: .init(x: rect.minX - ofs + r2, y: rect.maxY + 1 ))
            p.closeSubpath()
        }
    }
    
}

struct SpeechBubble_Previews: PreviewProvider {
    static var previews: some View {
        SpeechBubble {
//            Text("Hello,\n world!")
            Text("Hello, world!")
            
        }
        
//        .scaleEffect(8)
//        .offset(x: 400)
//        .previewLayout(.fixed(width: 100, height: 100))
    }
}
