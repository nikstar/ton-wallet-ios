//import SwiftyTON
//import SwiftUI
//import TonCore

//
//
//struct SwiftyContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
//            Text("Hello, world!")
//        }
//        .padding()
//        .backport.task {
//            do {
//
//                let words = testWords
//                let seedPhrase = try TonSeedPhrase(words)
//                let keyPair = try await TonKey.derive(from: seedPhrase)
//                let wallet = try await TonWallet(version: .v4r2, keyPair: keyPair)
//                print("""
//                ------------------------------------------------
//                My Version:
//                raw       = \(wallet.address.string(.raw))
//                base64    = \(wallet.address.string(.base64))
//                base64url = \(wallet.address.string(.base64url))
//                ------------------------------------------------
//                """)
////                balance   = \(await wallet.address.balance)
////                transactions = \(await wallet.address.transactions)
//
//                let passcode = "parole".data(using: .utf8)!
//
//                // Configurate SwiftyTON with mainnet
//                let keystoreDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("keystore", isDirectory: true)
//                try? FileManager.default.createDirectory(at: keystoreDir, withIntermediateDirectories: true)
//
//                SwiftyTON.configure(with: Configuration(network: .main, logging: .info, keystoreURL: keystoreDir))
//                print(keystoreDir.path)
//
//                // Import key
//                let key = try await Key.import(password: passcode, words: words)
//
//                print(key)
//                print(try! await key.decryptedSecretKey(password: passcode))
//                print(try! await key.words(password: passcode))
//                print(key.publicKey)
//                print(try! key.deserializedPublicKey())
//
////                let seedPhrase = try! TonSeedPhrase(testWords)
//
////                let myWallet = Wallet4(address: ConcreteAddress(string: "))
//
//                let myWallet = try await Wallet4.initial(
//                    revision: .r2,
//                    deserializedPublicKey: try key.deserializedPublicKey()
//                )
//
//                // Get address from initial data
//                guard let myAddress = await Address(initial: myWallet)
//                else {
//                    fatalError()
//                }
//                print(ConcreteAddress(address: myAddress))
//                print(ConcreteAddress(address: myAddress, representation: ConcreteAddress.StringRepresentation.base64(flags: .bounceable)))
//                print(ConcreteAddress(address: myAddress, representation: ConcreteAddress.StringRepresentation.base64(flags: .testable)))
//                print(ConcreteAddress(address: myAddress, representation: ConcreteAddress.StringRepresentation.base64url(flags: .bounceable)))
//                print(ConcreteAddress(address: myAddress, representation: ConcreteAddress.StringRepresentation.base64url(flags: .testable)))
//
//                let walletV3R1 = try await Wallet3.initial(revision: .r2, deserializedPublicKey: key.deserializedPublicKey())
//                let addressV3R1 = await Address(initial: walletV3R1)!
//                print(ConcreteAddress(address: addressV3R1))
//                print(ConcreteAddress(address: addressV3R1, representation: ConcreteAddress.StringRepresentation.base64(flags: .bounceable)))
//                print(ConcreteAddress(address: addressV3R1, representation: ConcreteAddress.StringRepresentation.base64(flags: .testable)))
//                print(ConcreteAddress(address: addressV3R1, representation: ConcreteAddress.StringRepresentation.base64url(flags: .bounceable)))
//                print(ConcreteAddress(address: addressV3R1, representation: ConcreteAddress.StringRepresentation.base64url(flags: .testable)))
//
//
////                // Parse address (and resolve, if needed) from example.ton, example.t.me or simple address string
////                guard let displayableAddress = await DisplayableAddress(string: "EQDxqxT1zemcb4vfO1azdErbfomWJc6ZvhCMQKshiQntSifa")
////                else {
////                    fatalError()
////                }
//
////                // Transfer
//                var myContract = try await Contract(address: myAddress)
//                let selectedContractInfo = myContract.info
//                print(myContract)
//                print(myContract.info)
//                print(myContract.info.balance)
//
//
//                print(try! await myContract.transactions(after: nil))
////
////                switch myContract.kind {
////                case .none:
////                    fatalError()
////                case .uninitialized: // for uninited state we should pass initial data
////                    myContract = Contract(
////                        address: myAddress,
////                        info: selectedContractInfo,
////                        kind: .walletV4R2,
////                        data: .zero // will be created automatically
////                    )
////                default:
////                    break
////                }
////
////                guard let myAnyWallet = AnyWallet(contract: myContract) else {
////                  fatalError()
////                }
////
////                let message = try await myAnyWallet.subsequentTransferMessage(
////                    to: displayableAddress.concreteAddress,
////                    amount: Currency(0.01), // 0.5 TON
////                    message: ("SwiftyTON".data(using: .utf8), nil),
////                    key: key,
////                    passcode: passcode
////                )
////
////                let fees = try await message.fees() // get estimated fees
////                print("Estimated fees - \(fees)")
//
////                try await message.send() // send transaction
//
//            } catch {
//                print(error)
//            }
//        }
//    }
//}
//
