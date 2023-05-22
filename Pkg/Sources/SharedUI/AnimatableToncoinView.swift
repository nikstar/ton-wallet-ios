
import TonCore
import SwiftUI
import SwiftUIBackports


public struct AnimatableToncoinView: View {
    
    var value: Toncoin?
    let maxFractionalDigits: Int?
    
    public init(_ value: Toncoin?, maxFractionalDigits: Int? = 4) {
        self.value = value
        self.maxFractionalDigits = maxFractionalDigits
    }
    
    private struct Digit: Hashable {
        
        var position: Int
        var value: String
        var isWholePart: Bool
        var index: Int
        
        static func ==(lhs: Digit, rhs: Digit) -> Bool {
            return lhs.position == rhs.position && lhs.value == rhs.value
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(position)
            hasher.combine(value)
        }
    }
    
    @State private var digits: [Digit] = []
    @State private var displayedValue: Toncoin? = nil
    @State private var amountIncreased: Bool = true
    
    private var fontWholePart: Font = .system(size: 48, weight: .semibold, design: .rounded).monospacedDigit()
    private var fontFractionalPart: Font = .system(size: 30, weight: .semibold, design: .rounded).monospacedDigit()
    
        
    public var body: some View {
    
        ToncoinView(value)
            .foregroundColor(.red)
            .border(Color.red)
            .opacity(0)
            .backport.overlay(alignment: .top) {
                HStack(alignment: .center, spacing: 4) {
                    Gem()
                        .frame(width: 48, height: 48)
                    ZStack {
                        Color.clear
                        HStack(alignment: .center, spacing: 0) {
                            
                            ForEach(digits, id: \.self) { digit in
                                Text(digit.value)
                                    .font(digit.isWholePart ? fontWholePart : fontFractionalPart)
//                                    .border(Color.red)
                                    .padding(.top, digit.isWholePart ? 0 : 13) // fake firstTextBaseline alignment
//                                    .border(Color.red)
                                    .transaction { t in
                                        if let animation = t.animation {
                                            t.animation = animation.delay(0.05 * pow(CGFloat(digit.index), 1))
                                        }
                                    }
                                    .transition(
//                                        amountIncreased ?
//                                            .asymmetric(
//                                                insertion: .move(edge: .top),
//                                                removal: .move(edge: .bottom)
//                                            ).combined(with: .opacity)
//                                        :
//                                            .asymmetric(
//                                                insertion: .move(edge: .bottom),
//                                                removal: .move(edge: .top)
//                                            ).combined(with: .opacity)
                                        amountIncreased ?
                                            .scale.combined(with: .opacity)
                                        :
                                            .asymmetric(
                                                insertion: .move(edge: .bottom),
                                                removal: .move(edge: .top)
                                            ).combined(with: .opacity)

                                    )
                            }
                        }
                    }
                }
            }
        .font(fontWholePart)
        .onChange(of: value) { newValue in
            if let newValue, let displayedValue {
                amountIncreased = newValue.nano > displayedValue.nano
            }
            displayedValue = newValue
            
            withAnimation(.default) {
                digits = makeDigits(from: newValue)
            }
        }
        .onAppear {
            digits = makeDigits(from: value)
            displayedValue = value
        }
    }
    
    private func makeDigits(from value: Toncoin?) -> [Digit] {
        guard let value else { return [] }
        var digits: [Digit] = []
        let wholePart = value.wholePart
        for (index, c) in wholePart.enumerated().reversed() {
            digits.append(Digit(position: index, value: String(c), isWholePart: true, index: wholePart.count - 1 - index))
        }
        digits = digits.reversed()
        let fractionalPart = value.fractionalPart(maxDigits: maxFractionalDigits)
        for (index, c) in fractionalPart.enumerated() {
            digits.append(Digit(position: -index - 1, value: String(c), isWholePart: false, index: wholePart.count + index))
        }
        return digits
    }
}


private struct TestView: View {
    
    @State var value: Toncoin = .init(nano: 10_000_000)
    
    var body: some View {
        VStack {
            AnimatableToncoinView(value)
//                .frame(minHeight: 100, alignment: .top)
            Button(action: {
                withAnimation {
                    value = .init(nano: Int.random(in: 10_000..<20_000_000)*1000)
                }
            }) {
                Text("Change")
            }
        }
    }
    
}



struct _ATonvoinView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
