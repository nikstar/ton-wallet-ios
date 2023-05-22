

import SwiftUI


extension View {
    
    func overrideStatusBarColor(_ style: UIStatusBarStyle) -> Self {
        UIApplication.shared.statusBarStyle = style
        return self
    }
    
}
