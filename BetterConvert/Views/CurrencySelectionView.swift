import SwiftUI
import SwiftData

struct CurrencySelectionView: View {
    @Binding var selectedCurrency: Currency?
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \Currency.name) private var currencies: [Currency]
    @State private var searchText = ""
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return currencies
        } else {
            return currencies.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCurrencies) { currency in
                    HStack {
                        Text(currency.flagEmoji)
                            .font(.largeTitle)
                        
                        VStack(alignment: .leading) {
                            Text(currency.code)
                                .font(.headline)
                            Text(currency.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedCurrency?.code == currency.code {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCurrency = currency
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
