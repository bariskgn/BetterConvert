import SwiftUI
import SwiftData

struct MainView: View {
    @StateObject private var viewModel = ConversionViewModel()
    @Query(sort: \Currency.orderIndex) private var currencies: [Currency]
    
    @State private var showSourceSelection = false
    @State private var showTargetSelection = false
    
    @Environment(\.modelContext) private var context

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            let availableHeight = geometry.size.height
            // Calculate strict split: 35% Top, 65% Bottom approx, but let's just use flexible
            // Actually, user standard is 1/3 currency, 2/3 calc.
            
            ZStack {
                // Layer 1: Global Background (Source Color - Left side & Calculator)
                (viewModel.sourceCurrency?.color ?? Color.blue)
                    .ignoresSafeArea()
                
                // Layer 2: Top Right Quadrant (Target Color - Darker)
                // We want this to cover the right side of the top 35% of the screen.
                GeometryReader { geo in
                    let topHeight = geo.size.height * 0.45 // Increased to 45%
                    (viewModel.sourceCurrency?.color.darker() ?? Color.blue.darker())
                        .frame(width: geo.size.width / 2, height: topHeight)
                        .position(x: geo.size.width * 0.75, y: topHeight / 2) 
                }
                .ignoresSafeArea()

                // Layer 3: Main Content
                VStack(spacing: 0) {
                        
                    // MARK: - Header & Currency (Top 45%)
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("BetterConvert")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: { /* Settings */ }) {
                                Text("Settings")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, safeArea.top)
                        .padding(.bottom, 10)
                        
                        Spacer()
                        
                        // Currency Row
                        HStack(alignment: .center, spacing: 0) {
                            // Left Source
                            Button(action: { showSourceSelection = true }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(viewModel.sourceCurrency?.name.uppercased() ?? "---")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    HStack(spacing: 2) {
                                        Text(viewModel.sourceCurrency?.symbol ?? "")
                                        Text(viewModel.inputString)
                                    }
                                    .font(.system(size: 48, weight: .medium)) // Reverted to 48
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                }
                                .padding(.leading, 30)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            
                            // Center Badge
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.25))
                                    .frame(width: 44, height: 44)
                                Text("To")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .offset(y: 4)
                            .zIndex(10)
                            
                            // Right Target
                            Button(action: { showTargetSelection = true }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(viewModel.targetCurrency?.code.uppercased() ?? "---")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    HStack(spacing: 2) {
                                        Text(viewModel.targetCurrency?.symbol ?? "")
                                        Text(formatDecimal(viewModel.convertedAmount))
                                    }
                                    .font(.system(size: 48, weight: .medium)) // Reverted to 48
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                }
                                .padding(.leading, 30)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                        }
                        .padding(.bottom, 40) // Reverted padding
                    }
                    .frame(height: availableHeight * 0.45) 
                    
                    
                    // MARK: - Calculator Section (Bottom 55%)
                    VStack(spacing: 0) { // Reverted spacing
                        
                        // Operators
                        OperatorRow { op in handleKeyPress(op) }
                            .padding(.horizontal, 24)
                            .padding(.top, 10) // Reverted padding
                            .padding(.bottom, 0)
                        
                        // Keypad
                        KeypadView(onKeyPress: { key in
                            handleKeyPress(key)
                        }, onDelete: {
                            handleDelete()
                        })
                        .padding(.horizontal, 10)
                        
                        Spacer(minLength: 0)
                        
                        // Footer
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                                .padding(.horizontal, 0)
                            
                            HStack {
                                Text("Exchange Rate")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                if let source = viewModel.sourceCurrency, let target = viewModel.targetCurrency {
                                     let rate = viewModel.converter.convert(1, from: source, to: target)
                                    Text("1 \(source.code) = \(formatDecimal(rate, maxFraction: 5)) \(target.code)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, safeArea.bottom > 0 ? safeArea.bottom : 16)
                            .padding(.horizontal, 24)
                        }
                    }
                    .frame(height: availableHeight * 0.55)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            initializeViewModel()
            Task { try? await viewModel.converter.updateRates(context: context) }
        }
        .sheet(isPresented: $showSourceSelection) {
            CurrencySelectionView(selectedCurrency: $viewModel.sourceCurrency)
        }
        .sheet(isPresented: $showTargetSelection) {
             CurrencySelectionView(selectedCurrency: $viewModel.targetCurrency)
        }
    }
    
    // MARK: - Logic
    
    private func initializeViewModel() {
        if viewModel.sourceCurrency == nil {
            viewModel.sourceCurrency = currencies.first(where: { $0.code == "JPY" }) ?? currencies.first
        }
        if viewModel.targetCurrency == nil {
            viewModel.targetCurrency = currencies.first(where: { $0.code == "USD" }) ?? currencies.last
        }
    }
    
    private func handleKeyPress(_ key: String) {
        if key == "CLEAR" {
            viewModel.inputString = "0"
            return
        }
        
        if key == "=" {
             viewModel.solve()
             return 
        }
        


        let validOps = ["+", "-", "*", "/"]
        
        if viewModel.inputString == "0" && !validOps.contains(key) && key != "." {
            viewModel.inputString = key
        } else {
             if let last = viewModel.inputString.last, 
               validOps.contains(String(last)) && validOps.contains(key) {
               viewModel.inputString.removeLast()
            }
            viewModel.inputString += key
        }
    }
    
    private func handleDelete() {
        if !viewModel.inputString.isEmpty {
            viewModel.inputString.removeLast()
            if viewModel.inputString.isEmpty {
                viewModel.inputString = "0"
            }
        }
    }
    
    private func formatDecimal(_ value: Decimal, maxFraction: Int = 2, symbol: String? = nil) -> String {
        MainView.currencyFormatter.currencySymbol = symbol ?? ""
        MainView.currencyFormatter.maximumFractionDigits = maxFraction
        return MainView.currencyFormatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}
