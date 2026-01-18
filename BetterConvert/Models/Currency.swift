import Foundation
import SwiftData
import SwiftUI

@Model
final class Currency {
    @Attribute(.unique) var code: String
    var name: String
    var symbol: String
    var flagEmoji: String
    var colorHex: String
    var isFavorite: Bool = false
    var rateToUSD: Decimal?
    var lastUpdated: Date?
    // Added for sorting if needed, or we rely on name/code
    var orderIndex: Int = 0 

    init(code: String, name: String, symbol: String, flagEmoji: String, colorHex: String) {
        self.code = code
        self.name = name
        self.symbol = symbol
        self.flagEmoji = flagEmoji
        self.colorHex = colorHex
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
}

// Helper for Hex Color
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
