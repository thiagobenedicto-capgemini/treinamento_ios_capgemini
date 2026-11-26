import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PostsViewModel()
    @State private var selectedTab = 0
    @State private var showingAddPost = false

    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView(viewModel: viewModel, showingAddPost: $showingAddPost)
                .tabItem { Label("Explorar", systemImage: "globe") }
                .tag(0)

            SavedView(viewModel: viewModel, showingAddPost: $showingAddPost)
                .tabItem { Label("Meus posts", systemImage: "bookmark.fill") }
                .badge(viewModel.savedPosts.count)
                .tag(1)
        }
        .tint(.indigo)
        .sheet(isPresented: $showingAddPost) {
            AddPostView(viewModel: viewModel) {
                selectedTab = 1
            }
        }
    }
}
