# TON Wallet App for iOS

Contest entry for **TON Wallet app contest**. This app is entirely implemented in SwiftUI, which will allow for quick iteration on future features. It connects to TON using **tonlib** using **modified SwiftyTON** wrapper. It might be replaced in the future. This submission does not implement all features yet but is a good base that I thought was worth submitting.

## Build instructions

1. Development environment used: Xcode 14.2, macOS 13.2.1 (Intel). Building on ARM-based Macs should work but has not been tested.

2. Open `ton-wallet.xcodeproj`.

3. Wait for Swift Package Manager to download dependencies. Among other things this downloads tonlib binaries.

4. You may want to enable debug overlay in `App.swift` for testing.

5. Build and run.

## Project status

- [x] creation of new wallet or importing existing one using recovery phrase - implemented
- [x] secure wallet lock using passcode or biometrics on supported platforms - implemented
- [x] main screen with user’s Toncoin balance and transaction’s list - mostly implemented
- [x] “receive Toncoin” screen with QR code - implemented
- [x] ability to send Toncoins directly by address, by scanning QR code or via TON DNS address - partially implemented
- [x] support different wallet versions - implemented, switch in settings
- [ ] TON Connect 2.0 support - not implemented
- [x] your app should support at least last 3 major releases of target platform - supports iOS 14.5+ but support on pre-iOS 16 versions has not been extensively tested and can be improved
- [x] `ton://` links - implemented
