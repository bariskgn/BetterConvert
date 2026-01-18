import SwiftUI

struct KeypadView: View {
    let onKeyPress: (String) -> Void
    let onDelete: () -> Void
    
    // Grid layout for keypad
    // 7 8 9
    // 4 5 6
    // 1 2 3
    // C 0 <
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) { // No extra vertical spacing
            // Row 1: 7 8 9
            ForEach(7...9, id: \.self) { number in
                KeypadButton(text: "\(number)") { onKeyPress("\(number)") }
            }
            
            // Row 2: 4 5 6
            ForEach(4...6, id: \.self) { number in
                KeypadButton(text: "\(number)") { onKeyPress("\(number)") }
            }
            
            // Row 3: 1 2 3
            ForEach(1...3, id: \.self) { number in
                KeypadButton(text: "\(number)") { onKeyPress("\(number)") }
            }
            
            // Row 4: C 0 Delete
            KeypadButton(text: "C") {
                onKeyPress("CLEAR")
            }
            
            KeypadButton(text: "0") {
                onKeyPress("0")
            }
            
            KeypadButton(content: Image(systemName: "delete.left.fill")) {
                onDelete()
            }
            
            // Row 5: = .
             KeypadButton(text: "=") {
                 onKeyPress("=")
             }
             
             KeypadButton(text: ".") {
                 onKeyPress(".")
             }
        }
        .padding()
    }
}

// Separate component for the operator row to be placed above numbers if needed,
// OR we can integrate it. The design shows operators in a row ABOVE the numbers.
// [ ÷ ] [ x ] [ + ] [ - ]

struct OperatorRow: View {
    let onKeyPress: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            OperatorButton(symbol: "÷") { onKeyPress("/") }
            OperatorButton(symbol: "×") { onKeyPress("*") }
            OperatorButton(symbol: "+") { onKeyPress("+") }
            OperatorButton(symbol: "-") { onKeyPress("-") }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}


// MARK: - Subcomponents

struct KeypadButton<Content: View>: View {
    let content: Content
    let action: () -> Void
    
    init(text: String, action: @escaping () -> Void) where Content == Text {
        self.content = Text(text)
        self.action = action
    }
    
    init(content: Content, action: @escaping () -> Void) {
        self.content = content
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            content
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 60) // Fixed smaller height for buttons
                .contentShape(Rectangle()) 
        }
    }
}

struct OperatorButton: View {
    let symbol: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(symbol)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
    }
}
