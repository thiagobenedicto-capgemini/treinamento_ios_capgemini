import SwiftUI

struct ContentView: View {
    // Um único ViewModel é compartilhado pelas duas abas.
    @StateObject private var viewModel = PostsViewModel()

    var body: some View {
        TabView {
            ExploreView(viewModel: viewModel)
                .tabItem {
                    Label("Explorar", systemImage: "globe")
                }

            SavedView(viewModel: viewModel)
                .tabItem {
                    Label("Meus salvos", systemImage: "bookmark.fill")
                }
        }
        .alert("Erro de armazenamento", isPresented: $viewModel.showStorageError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.storageErrorMessage)
        }
    }
}
