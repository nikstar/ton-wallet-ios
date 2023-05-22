
import UIKit
import UniformTypeIdentifiers
import TonCore

public final class PasteboardManager: ObservableObject {
    
    public static func copy(address: TonAddress) {
        UIPasteboard.general.setItems([[UTType.plainText.identifier: address.string(.base64url)]], options: [.expirationDate: Date().addingTimeInterval(300)])
    }
}
