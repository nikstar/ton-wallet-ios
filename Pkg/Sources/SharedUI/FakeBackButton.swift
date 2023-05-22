
import SwiftUI


extension View {
    
    public func fakeBackButton() -> some View {
        modifier(FakeBackButton())
    }
}


public struct FakeBackButton: ViewModifier {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.self) var environment
    
    public func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    Button(action: compatDismiss) {
                        if #available(iOS 14.5, *) {
                            Label {
                                Text("Back")
                            } icon: {
                                Image(systemName: "chevron.backward")
                            }
                            .labelStyle(.titleAndIcon)
                        } else {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Image(systemName: "chevron.backward")
                                Text("Back")
                            }
                        }
                    }
                }
            }
    }
    
    @available(iOS, deprecated: 15)
    func compatDismiss() {
        if #available(iOS 15, *) {
            environment.dismiss()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
}


struct FakeButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: "chevron.backward")
            Text("Back")
        }
    }
}
