
import SwiftUI


public struct Gem: View {
    
    public init() {}
    
    public var body: some View {
        Image("gem")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .alignmentGuide(.firstTextBaseline) { dims in
                dims.height * (1 - 6/48)
            }
            
    }
    
}
