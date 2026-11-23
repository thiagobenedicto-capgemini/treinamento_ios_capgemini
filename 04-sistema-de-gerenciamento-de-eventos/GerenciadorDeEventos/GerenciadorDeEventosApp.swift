import SwiftUI
import SwiftData

@main
struct GerenciadorDeEventosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Evento.self)
    }
}
