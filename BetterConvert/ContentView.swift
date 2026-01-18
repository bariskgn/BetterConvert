import SwiftUI
import SwiftData

struct ContentView: View {
    // The App calls ContentView, so we just redirect to MainView
    var body: some View {
        MainView()
    }
}
