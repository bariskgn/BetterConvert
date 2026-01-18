import Foundation

struct CalculatorService {
    static let shared = CalculatorService()
    
    private init() {}
    
    /// Evaluates a mathematical string expression and returns the result as a Decimal?
    /// Returns nil if the expression is incomplete or invalid.
    func evaluate(expression: String) -> Decimal? {
        // 1. Basic sanitization
        // Allow digits, decimal separator (.), and operators (+, -, *, /)
        // We might want to handle locale specific separators later, but for now assuming "."
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.+-*/ ")
        let sanitized = expression.components(separatedBy: allowedCharacters.inverted).joined()
        
        // If empty or just operators, return nil
        if sanitized.isEmpty || sanitized.trimmingCharacters(in: .whitespaces).isEmpty {
            return nil
        }
        
        // 2. Logic to prevent crashes with NSExpression on partial inputs (e.g. "10 + ")
        // If the last character is an operator, ignore it for evaluation or treat as invalid?
        // Usually, for "10 +", we might want to just return 10, or return nil until completed.
        // Returning nil is safer for "live" conversion, so we don't convert partial states strangely.
        // However, "10 +" resulting in "nil" effectively "pausing" conversion updates is good UI.
        
        // Check for trailing operators
        let operators = ["+", "-", "*", "/"]
        let trimmed = sanitized.trimmingCharacters(in: .whitespaces)
        
        if let last = trimmed.last, operators.contains(String(last)) {
            // Expression ends with operator, incomplete.
            // Option: Try to evaluate without the last operator?
            // "10 +" -> 10.
            // This feels better for a live calculator.
             let partialExpr = String(trimmed.dropLast()).trimmingCharacters(in: .whitespaces)
             return evaluateCore(partialExpr)
        }
        
        return evaluateCore(trimmed)
    }
    
    private func evaluateCore(_ input: String) -> Decimal? {
        guard !input.isEmpty else { return nil }
        
        // Sanitize input: safely handle trailing decimals or operators
        // NSExpression can crash on strings like "10." or "10+"
        var safeInput = input
        if let last = safeInput.last, !last.isNumber {
            // If it ends with a dot, append 0 (e.g. "10." -> "10.0")
            if last == "." {
                 safeInput += "0"
            } else {
                // If it ends with an operator (e.g. "10+"), drop it for evaluation, 
                // OR don't evaluate yet.
                // For live typing strings like "10+", we usually can't eval. Return nil.
                return nil 
            }
        }

        // NSExpression is somewhat limited but safe for basic arithmetic.
        // Note: NSExpression uses floating point math by default.
        let expr = NSExpression(format: safeInput)
        if let result = expr.expressionValue(with: nil, context: nil) as? NSNumber {
            return Decimal(result.doubleValue)
        }
        return nil
    }
}
