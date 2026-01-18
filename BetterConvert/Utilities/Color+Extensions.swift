import SwiftUI

extension Color {
    // Already have init(hex:) in Currency context, but let's make a general one if needed
    // or extend the existing one. For now, we need a way to get a "darker" version.
    
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return adjust(by: -1 * abs(percentage) ) ?? .black
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> Color? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        
        // Use UIColor to extract components easily
        if UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return Color(red: min(Double(red + percentage/100), 1.0),
                         green: min(Double(green + percentage/100), 1.0),
                         blue: min(Double(blue + percentage/100), 1.0),
                         opacity: Double(alpha))
        } else {
            return nil
        }
    }
}
