import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PostsViewModel()
    @State private var selectedTab = 0
    @State private var showingAddPost = false
    @State private var savedFilter: SavedFilter = .all
    @State private var savedSearch = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView(viewModel: viewModel, showingAddPost: $showingAddPost)
                .tabItem { Label("Explorar", systemImage: "globe") }
                .tag(0)

            SavedView(viewModel: viewModel, showingAddPost: $showingAddPost,
                      filter: $savedFilter, searchText: $savedSearch)
                .tabItem { Label("Meus posts", systemImage: "bookmark") }
                .badge(viewModel.savedPosts.count)
                .tag(1)
        }
        .tint(.blue)
        .sheet(isPresented: $showingAddPost) {
            AddPostView(viewModel: viewModel) {
                // O novo post deve aparecer mesmo se havia um filtro ativo.
                savedFilter = .all
                savedSearch = ""
                selectedTab = 1
            }
        }
    }
}
