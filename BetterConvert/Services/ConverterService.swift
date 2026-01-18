import Foundation
import SwiftData

final class ConverterService {
    static let shared = ConverterService()
    
    private init() {}
    
    /// Converts an amount from one currency to another using USD as the base.
    /// Formula: (Amount / SourceRateToUSD) * TargetRateToUSD
    func convert(_ amount: Decimal, from source: Currency, to target: Currency) -> Decimal {
        // If same currency, return amount
        if source.code == target.code {
            return amount
        }
        
        guard let sourceRate = source.rateToUSD,
              let targetRate = target.rateToUSD,
              sourceRate > 0 else {
            return 0
        }
        
        // Convert source to USD
        // Example: 100 EUR (Rate 0.9) -> 100 / 0.9 = 111.11 USD
        let amountInUSD = amount / sourceRate
        
        // Convert USD to target
        // Example: 111.11 USD -> GBP (Rate 0.76) -> 111.11 * 0.76 = 84.44 GBP
        let result = amountInUSD * targetRate
        
        return result
    }
    
    /// Fetches latest rates from API and updates the local database
    @MainActor
    func updateRates(context: ModelContext) async throws {
        // Fetch rates with USD base
        let rates = try await ExchangeRateService.shared.fetchRates(baseCurrency: "USD")
        
        // Fetch all currencies from context to update them
        let descriptor = FetchDescriptor<Currency>()
        let currencies = try context.fetch(descriptor)
        
        for currency in currencies {
            // Check if we have a rate for this currency
            if let rate = rates[currency.code] {
                currency.rateToUSD = rate
                currency.lastUpdated = Date()
            } else if currency.code == "USD" {
                // Explicitly set USD to 1.0 if not returned (though usually it is)
                currency.rateToUSD = 1.0
                currency.lastUpdated = Date()
            }
        }
        
        try context.save()
    }
}
