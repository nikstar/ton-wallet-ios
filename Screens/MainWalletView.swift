
import SwiftUI
import TonCore
import SharedUI
import AppState
import Send

struct MainWalletView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    @State private var scannerSheetPresented = false
    @State private var settingsSheetPresented = false
    @State private var sendSheetPresented = false
    @State private var receiveSheetPresented = false
    @State private var transactionSheetPresented = false
    @State private var displayedTransaction: TonTransaction? = nil
    
    @State private var requestedSendAddress: TonAddress?
    @State private var requestedAmount: Toncoin?
    @State private var requestedText: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                mainView
                transactionsView
                    .backport.overlay(alignment: .top) {
                        if appState.currentTransactionsLoadedAtLeastOnce && appState.currentTransactionsGroupedByDate.isEmpty {
                            newWalletOverlay
                                .animation(.default, value: appState.currentTransactionsGroupedByDate.isEmpty)
                                .animation(.default, value: appState.currentTransactionsLoadedAtLeastOnce)
                                .opacity(appState.currentTransactionsGroupedByDate.isEmpty ? 1 : 0)

                        }
                    }
                    .backport.overlay(alignment: .top) {
                        if appState.currentTransactionsLoadedAtLeastOnce == false {
                            loadingTransactionsOverlay
                                .animation(.default, value: appState.currentTransactionsLoadedAtLeastOnce)
                        }
                    }

            }
            .padding(.top, safeAreaInsets.top)
                .animation(.default, value: appState.currentTransactions)
                .animation(.default, value: appState.currentTransactionsGroupedByDate)
                .animation(.default, value: appState.currentTransactionsLoadedAtLeastOnce)
            
        }
        .cornerRadius(16)
        .backport.overlay(alignment: .top) {
            topRow
        }
        .padding(.top, safeAreaInsets.top)
//        .safeAreaInset(edge: .top) {
//            topRow
//        }
//        .ignoresSafeArea(edges: .bottom)
//        .background(Color.black, ignoresSafeAreaEdges: .all)
        .background(Color.black)
        .sheet(isPresented: $scannerSheetPresented) {
            ScannerView(completion: { requestedTonURL in
            })
        }
        .sheet(isPresented: $settingsSheetPresented) {
            SettingsView()
        }
        .sheet(isPresented: $receiveSheetPresented) {
            Receive()
        }
        .sheet(isPresented: $sendSheetPresented) {
            SendView(
                destinationAddress: requestedSendAddress,
                amount: requestedAmount,
                comment: requestedText,
                currentBalance: { appState.currentBalance },
                resolveAddress: { string in
                    if let address = TonAddress.parse(string) {
                        return address
                    } else {
                        throw NSError()
                    }
                },
                authorizeTransaction: { _ in },
                sendTransaction: { _ in }
            )
        }
        .onChange(of: appState.requestedTonURL) { requestedTonURL in
            guard appState.wallet != nil, let requestedTonURL else { return }
            scannerSheetPresented = false
            settingsSheetPresented = false
            receiveSheetPresented = false
            transactionSheetPresented = false
            displayedTransaction = nil

            requestedSendAddress = requestedTonURL.address
            requestedAmount = requestedTonURL.amount
            requestedText = requestedTonURL.text
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sendSheetPresented = true
            }
        }
//        .selfSizingSheet(isPresented: $transactionSheetPresented) {
//            if let displayedTransaction {
//                TransactionView(transaction: displayedTransaction)
//            }
//        }
    }
    
    var topRow: some View {
        HStack {
            Button(action: { scannerSheetPresented = true }) {
                ZStack {
                    Image(systemName: "viewfinder")
                        .resizable()
                    Image(systemName: "minus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 4)
                }
                .padding(3)
                .padding(8)
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
            }
            Spacer()
            Button(action: { settingsSheetPresented = true }) {
                ZStack {
                    Image(systemName: "gear")
                        .resizable()
                }
                .padding(2)
                .padding(8)
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
            }
        }
        .padding(.top, 6)
        .padding(.horizontal, 6)
    }
    
    var mainView: some View {
        VStack(spacing: 0) {
            Text(appState.wallet?.address.string(.base64url, characters: (4, 4)) ?? " ")
                .padding(.bottom, 2)
            AnimatableToncoinView(appState.currentBalance)
                .padding(.trailing, 8)
                .padding(.bottom, 74)
            HStack(spacing: 12) {
                Button(action: { receiveSheetPresented = true }) {
                    Label {
                        Text("Receive")
                    } icon: {
                        Image(systemName: "arrow.down.left")
                    }
                }
                Button(action: { sendSheetPresented = true }) {
                    Label {
                        Text("Send")
                    } icon: {
                        Image(systemName: "arrow.up.right")
                    }
                }
            }
            .padding(.horizontal, 16)
            .buttonStyle(.wallet(textColor: .white, backgroundColor: .theme.walletAccent))
        }
        .padding(.top, 28-6)
        .padding(.bottom, 16)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
    }
    
    var transactionsView: some View {
        ZStack {
            Color.white.cornerRadius(16)
//                .border(Color.red)
            if !appState.currentTransactionsGroupedByDate.isEmpty {
                List {
                    ForEach(appState.currentTransactionsGroupedByDate.keys, id: \.self) { dc in
                        Section {
                            ForEach(appState.currentTransactionsGroupedByDate[dc] ?? [], id: \.self) { transaction in
                                Button(action: { displayedTransaction = transaction; transactionSheetPresented = true }) {
                                    TransactionCell(transaction)
                                }
//                                .border(Color.red)
                            }
                        } header: {
                            Text(string(for: dc))
                                .font(.body.bold())
                        }
//                        .border(Color.red)
                    }
                    .compat_listSectionSeparatorHidden()

                    .listRowBackground(Color.white)
                    .foregroundColor(.black)
                    
                }
//                .border(Color.red)
                .listRowBackground(Color.white)
                .listStyle(PlainListStyle())
            }
        }
        .frame(maxWidth: .infinity, minHeight: 800, alignment: .top)
        .backport.background {
            Color.white.cornerRadius(16)
//                .border(Color.red)
        }
//        .border(Color.red)
    }
    
    
    var newWalletOverlay: some View {
        ZStack(alignment: .top) {
            Color.theme.background
            VStack(spacing: 8) {
                Sticker("Created", play: .playOnce)
                    .frame(width: 124, height: 124)
                    .padding(.bottom, 10)
                Text("Wallet Created")
                    .font(.theme.title)
                    .padding(.bottom, 20)
                Text("Your wallet address")
                    .foregroundColor(.theme.secondary)
                if let a = appState.wallet?.address, let address = a.string(.base64url) {
                    Text(address.prefix(address.count/2)+"\n"+address.dropFirst(address.count/2))
                        .font(.theme.monospaced)
                        .padding(.bottom, 6)
                        .onTapGesture {
                            PasteboardManager.copy(address: a)
                        }
                }
                
            }
            .padding(.top, 70)
        }
        .cornerRadius(20)
    }
    
    var loadingTransactionsOverlay: some View {
        ZStack(alignment: .top) {
            Color.theme.background
            Sticker("Loading", play: .loop)
                .frame(width: 124, height: 124)
                .padding(.top, 70)
        }
        .cornerRadius(20)
    }
    
    
    func string(for dc: DateComponents) -> String {
        guard let date = Calendar.current.date(from: dc) else { return "" }
        
        
        let f = DateFormatter()
        f.dateStyle = .medium
    
        f.timeStyle = .none
        f.locale = Locale(identifier: "en")
        if dc.year == Calendar.current.dateComponents([.year], from: Date()).year {
            f.setLocalizedDateFormatFromTemplate("MMMMd")
        } else {
            f.setLocalizedDateFormatFromTemplate("yMMMMd")
        }
        return f.string(from: date)

        // Note: DateComponentsFormatter crashes, at least in simulator
//        let f = DateComponentsFormatter()
//        if dc.year == Calendar.current.dateComponents([.year], from: .now).year {
//            f.allowedUnits = [.month, .day]
//        } else {
//            f.allowedUnits = [.year, .month, .day]
//        }
//        print(Locale.current)
//        f.calendar?.locale = Locale(identifier: "en")
//        return f.string(from: dc) ?? "" // here
        
    }
    
    private let dateFormatter: DateComponentsFormatter = {
        var f = DateComponentsFormatter()
        f.allowedUnits = [.month, .day]
        return f
    }()
}



extension View {
    
    
    @ViewBuilder fileprivate func compat_listSectionSeparatorHidden() -> some View {
        if #available(iOS 15.0, *) {
            self.listSectionSeparator(.hidden)
        } else {
            self
        }
    }
}
