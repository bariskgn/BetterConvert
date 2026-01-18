import SwiftUI
import SwiftData

@main
struct BetterConvertApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                Currency.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = modelContainer
            
            // Seed data
            Task { @MainActor in
                DataLoader.seed(context: modelContainer.mainContext)
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
