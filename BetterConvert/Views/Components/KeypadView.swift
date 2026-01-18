import SwiftUI

struct KeypadView: View {
    let onKeyPress: (String) -> Void
    let onDelete: () -> Void
    
    // Grid layout for keypad
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            // Row 1: 1 2 3
            ForEach(1...3, id: \.self) { number in
                KeypadButton(text: "\(number)") { onKeyPress("\(number)") }
            }
            
            // Row 2: 4 5 6
            ForEach(4...6, id: \.self) { number in
                KeypadButton(text: "\(number)") { onKeyPress("\(number)") }
            }
            
            // Row 3: 7 8 9
            ForEach(7...9, id: \.self) { number in
                KeypadButton(text: "\(number)") { onKeyPress("\(number)") }
            }
            
            // Row 4: C 0 =
            KeypadButton(text: "C") {
                onKeyPress("CLEAR")
            }
            
            KeypadButton(text: "0") {
                onKeyPress("0")
            }
            
            KeypadButton(text: "=") {
                onKeyPress("=")
            }

            // Row 5: , Space Delete
            KeypadButton(text: ",") {
                onKeyPress(".")
            }
            
            Color.clear.frame(height: 50)
            
            KeypadButton(content: Image(systemName: "delete.left")) {
                onDelete()
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

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
                .font(.system(size: 22, weight: .medium)) // Reduced size
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 50) // Reduced height
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
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
