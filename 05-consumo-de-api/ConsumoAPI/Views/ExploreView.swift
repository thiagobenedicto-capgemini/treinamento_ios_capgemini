import SwiftUI

struct ExploreView: View {
    @ObservedObject var viewModel: PostsViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.apiPosts.isEmpty {
                    ProgressView("Carregando posts...")
                } else if viewModel.apiPosts.isEmpty {
                    // Estado de erro ou de lista vazia.
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text(viewModel.apiErrorMessage ?? "Nenhum post encontrado.")
                            .multilineTextAlignment(.center)

                        Button("Tentar novamente") {
                            Task { await viewModel.fetchPosts() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    VStack(spacing: 0) {
                        if let errorMessage = viewModel.apiErrorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .padding()
                        }

                        List(viewModel.apiPosts) { post in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(post.title.capitalized)
                                    .font(.headline)

                                Text(post.body)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)

                                HStack {
                                    Text("Post #\(post.id)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Button {
                                        viewModel.savePost(post)
                                    } label: {
                                        Label(
                                            viewModel.isSaved(post) ? "Salvo" : "Salvar",
                                            systemImage: viewModel.isSaved(post)
                                                ? "bookmark.fill" : "bookmark"
                                        )
                                    }
                                    .buttonStyle(.borderless)
                                    .disabled(viewModel.isSaved(post))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.fetchPosts()
                        }
                    }
                }
            }
            .navigationTitle("Explorar posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.fetchPosts() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Atualizar posts")
                }
            }
            .task {
                // Executa a requisição ao entrar na tela pela primeira vez.
                if viewModel.apiPosts.isEmpty {
                    await viewModel.fetchPosts()
                }
            }
        }
    }
}
