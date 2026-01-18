import Foundation
import SwiftData

struct DataLoader {
    static let currencies: [Currency] = [
        // Fiat
        Currency(code: "USD", name: "United States Dollar", symbol: "$", flagEmoji: "🇺🇸", colorHex: "#85bb65"),
        Currency(code: "EUR", name: "Euro", symbol: "€", flagEmoji: "🇪🇺", colorHex: "#003399"),
        Currency(code: "JPY", name: "Japanese Yen", symbol: "¥", flagEmoji: "🇯🇵", colorHex: "#BC002D"),
        Currency(code: "GBP", name: "British Pound", symbol: "£", flagEmoji: "🇬🇧", colorHex: "#cf0a2c"),
        Currency(code: "AUD", name: "Australian Dollar", symbol: "A$", flagEmoji: "🇦🇺", colorHex: "#00008b"),
        Currency(code: "CAD", name: "Canadian Dollar", symbol: "C$", flagEmoji: "🇨🇦", colorHex: "#FF0000"),
        Currency(code: "CHF", name: "Swiss Franc", symbol: "Fr", flagEmoji: "🇨🇭", colorHex: "#D52B1E"),
        Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥", flagEmoji: "🇨🇳", colorHex: "#DE2910"),
        Currency(code: "SEK", name: "Swedish Krona", symbol: "kr", flagEmoji: "🇸🇪", colorHex: "#006AA7"),
        Currency(code: "NZD", name: "New Zealand Dollar", symbol: "NZ$", flagEmoji: "🇳🇿", colorHex: "#1e1e1e"),
        Currency(code: "MXN", name: "Mexican Peso", symbol: "$", flagEmoji: "🇲🇽", colorHex: "#006847"),
        Currency(code: "SGD", name: "Singapore Dollar", symbol: "S$", flagEmoji: "🇸🇬", colorHex: "#ED2939"),
        Currency(code: "HKD", name: "Hong Kong Dollar", symbol: "HK$", flagEmoji: "🇭🇰", colorHex: "#4169E1"),
        Currency(code: "NOK", name: "Norwegian Krone", symbol: "kr", flagEmoji: "🇳🇴", colorHex: "#BA0C2F"),
        Currency(code: "KRW", name: "South Korean Won", symbol: "₩", flagEmoji: "🇰🇷", colorHex: "#0F64CD"),
        Currency(code: "TRY", name: "Turkish Lira", symbol: "₺", flagEmoji: "🇹🇷", colorHex: "#E30A17"),
        Currency(code: "RUB", name: "Russian Ruble", symbol: "₽", flagEmoji: "🇷🇺", colorHex: "#0039A6"),
        Currency(code: "INR", name: "Indian Rupee", symbol: "₹", flagEmoji: "🇮🇳", colorHex: "#FF9933"),
        Currency(code: "BRL", name: "Brazilian Real", symbol: "R$", flagEmoji: "🇧🇷", colorHex: "#009C3B"),
        Currency(code: "ZAR", name: "South African Rand", symbol: "R", flagEmoji: "🇿🇦", colorHex: "#007A4D"),
        Currency(code: "PHP", name: "Philippine Peso", symbol: "₱", flagEmoji: "🇵🇭", colorHex: "#0038A8"),
        Currency(code: "CZK", name: "Czech Koruna", symbol: "Kč", flagEmoji: "🇨🇿", colorHex: "#D7141A"),
        Currency(code: "IDR", name: "Indonesian Rupiah", symbol: "Rp", flagEmoji: "🇮🇩", colorHex: "#DC143C"),
        Currency(code: "MYR", name: "Malaysian Ringgit", symbol: "RM", flagEmoji: "🇲🇾", colorHex: "#0032A0"),
        Currency(code: "HUF", name: "Hungarian Forint", symbol: "Ft", flagEmoji: "🇭🇺", colorHex: "#436F4D"),
        Currency(code: "PLN", name: "Polish Zloty", symbol: "zł", flagEmoji: "🇵🇱", colorHex: "#C1272D"),
        Currency(code: "THB", name: "Thai Baht", symbol: "฿", flagEmoji: "🇹🇭", colorHex: "#800080"),
        Currency(code: "AED", name: "UAE Dirham", symbol: "dh", flagEmoji: "🇦🇪", colorHex: "#00732F"),
        Currency(code: "SAR", name: "Saudi Riyal", symbol: "﷼", flagEmoji: "🇸🇦", colorHex: "#2E8B57"),
        Currency(code: "DKK", name: "Danish Krone", symbol: "kr", flagEmoji: "🇩🇰", colorHex: "#C60C30"),
        
        // Crypto
        Currency(code: "BTC", name: "Bitcoin", symbol: "₿", flagEmoji: "🪙", colorHex: "#F7931A"),
        Currency(code: "ETH", name: "Ethereum", symbol: "Ξ", flagEmoji: "💎", colorHex: "#627EEA"),
        Currency(code: "USDT", name: "Tether", symbol: "₮", flagEmoji: "💵", colorHex: "#26A17B"),
        Currency(code: "BNB", name: "Binance Coin", symbol: "BNB", flagEmoji: "🟡", colorHex: "#F3BA2F"),
        Currency(code: "SOL", name: "Solana", symbol: "SOL", flagEmoji: "🟣", colorHex: "#9945FF")
    ]
    
    @MainActor
    static func seed(context: ModelContext) {
        // Check if data already exists to avoid duplicates
        let descriptor = FetchDescriptor<Currency>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        
        if count == 0 {
            for currency in currencies {
                context.insert(currency)
            }
            try? context.save()
            print("Database seeded with initial currencies.")
        }
    }
}
