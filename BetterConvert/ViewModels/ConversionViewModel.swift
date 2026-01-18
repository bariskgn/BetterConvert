import Foundation
import SwiftData
import Combine

@MainActor
final class ConversionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var inputString: String = "100" {
        didSet {
            calculateAndConvert()
        }
    }
    
    @Published var sourceCurrency: Currency? {
        didSet {
            calculateAndConvert()
        }
    }
    
    @Published var targetCurrency: Currency? {
        didSet {
            calculateAndConvert()
        }
    }
    
    @Published var convertedAmount: Decimal = 0.0
    
    // For the UI to show the calculated intermediate value (e.g. "50 + 50" -> "100")
    // This effectively "reflects" the value in the calculator as the user requested.
    @Published var calculatedValue: Decimal? = nil
    
    // MARK: - Services
    let calculator = CalculatorService.shared
    let converter = ConverterService.shared
    
    init() {}
    
    // MARK: - Logic
    
    private func calculateAndConvert() {
        // 1. Calculate the value from the input string (which might be an expression)
        guard let calculated = calculator.evaluate(expression: inputString) else {
            // If invalid or empty, we might reset strings or keep last valid?
            // For now, let's just zero out result to indicate invalid state
            convertedAmount = 0.0
            calculatedValue = nil
            return
        }
        
        calculatedValue = calculated
        
        // 2. Convert the calculated value
        guard let source = sourceCurrency, let target = targetCurrency else {
            return
        }
        
        convertedAmount = converter.convert(calculated, from: source, to: target)
    }
    
    func swapCurrencies() {
        let temp = sourceCurrency
        sourceCurrency = targetCurrency
        targetCurrency = temp
    }
    
    func solve() {
        if let result = calculator.evaluate(expression: inputString) {
            // Update input string with result
            let nsResult = result as NSDecimalNumber
             if nsResult.doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                 inputString = "\(nsResult.intValue)"
             } else {
                 inputString = "\(nsResult.doubleValue)"
             }
        }
    }
    
    func applyPercentage() {
        // Standard Calculator % Logic
        // 1. If single number: val / 100
        // 2. If A + B % -> A + (A * B/100)
        // 3. If A - B % -> A - (A * B/100)
        // 4. If A * B % -> A * (B/100)
        // 5. If A / B % -> A / (B/100)
        
        let ops = ["+", "-", "*", "/"]
        
        // Find last operator
        var lastOpIndex: String.Index? = nil
        var lastOp = ""
        
        for index in inputString.indices.reversed() {
            let char = String(inputString[index])
            if ops.contains(char) {
                lastOpIndex = index
                lastOp = char
                break
            }
        }
        
        guard let opIndex = lastOpIndex else {
            // Case 1: No operator, just divide by 100
            inputString += "*0.01"
            solve()
            return
        }
        
        // Split into A and B
        let partAString = String(inputString[..<opIndex])
        let partBString = String(inputString[inputString.index(after: opIndex)...])
        
        guard let valA = calculator.evaluate(expression: partAString),
              let valB = Decimal(string: partBString) else {
            return
        }
        
        var newValue: Decimal = 0
        
        if lastOp == "+" || lastOp == "-" {
            // Case 2 & 3: Percentage of Part A
            // e.g. 100 + 10 (%) -> 100 + 10
            // logic: 10 becomes 10% of 100 -> 10
            newValue = valA * (valB / 100)
        } else {
            // Case 4 & 5: Simple percentage
            // e.g. 100 * 10 (%) -> 100 * 0.1
            newValue = valB / 100
        }
        
        // Check if newValue is whole number for clean display
        let nsResult = newValue as NSDecimalNumber
        let newBString = (nsResult.doubleValue.truncatingRemainder(dividingBy: 1) == 0) 
            ? "\(nsResult.intValue)" 
            : "\(nsResult.doubleValue)"
        
        // Reconstruct string
        inputString = partAString + lastOp + newBString
        // Note: Standard calculators usually solve immediately after %.
        // Let's solve it to show final result (e.g. 110) or keep expression?
        // User request: "only applies two zero remove, not an actual % function"
        // Usually, 100 + 10% shows 110 instantly.
        solve()
    }
}
