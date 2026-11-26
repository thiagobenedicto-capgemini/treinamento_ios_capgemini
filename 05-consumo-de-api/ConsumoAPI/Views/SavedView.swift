import SwiftUI

struct SavedView: View {
    @ObservedObject var viewModel: PostsViewModel
    @State private var showingAddPost = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedPosts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("Nenhum post salvo")
                            .font(.headline)

                        Text("Salve posts da API ou toque em + para cadastrar um novo.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.savedPosts) { post in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(post.title)
                                    .font(.headline)

                                Text(post.body)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text(post.apiID == nil ? "Criado por mim" : "Salvo da API")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: viewModel.deleteSavedPosts)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Meus salvos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPost = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Cadastrar novo post")
                }
            }
            .sheet(isPresented: $showingAddPost) {
                AddPostView { title, body in
                    viewModel.addPost(title: title, body: body)
                }
            }
        }
    }
}
