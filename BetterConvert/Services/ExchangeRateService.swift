import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case badRequest
    case decodingError
}

struct ExchangeRateResponse: Codable {
    let result: String
    let base_code: String
    let conversion_rates: [String: Double]
}

final class ExchangeRateService {
    static let shared = ExchangeRateService()
    
    // We use the standard request endpoint
    // GET https://v6.exchangerate-api.com/v6/YOUR-API-KEY/latest/USD
    private let baseURL = "https://v6.exchangerate-api.com/v6"
    
    private init() {}
    
    func fetchRates(baseCurrency: String = "USD") async throws -> [String: Decimal] {
        let apiKey = APIConfig.exchangeRateAPIKey
        let urlString = "\(baseURL)/\(apiKey)/latest/\(baseCurrency)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badRequest
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            
            // Convert Double to Decimal for better precision implementation
            var rates: [String: Decimal] = [:]
            for (key, value) in decodedResponse.conversion_rates {
                rates[key] = Decimal(value)
            }
            
            return rates
        } catch {
            throw NetworkError.decodingError
        }
    }
}
