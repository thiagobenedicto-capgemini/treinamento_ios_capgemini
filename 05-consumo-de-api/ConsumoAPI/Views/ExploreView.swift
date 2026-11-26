import SwiftUI

struct ExploreView: View {
    @ObservedObject var viewModel: PostsViewModel
    @Binding var showingAddPost: Bool
    @State private var searchText = ""
    @State private var showingError = false

    private var filteredPosts: [APIPost] {
        if searchText.isEmpty { return viewModel.apiPosts }
        return viewModel.apiPosts.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("JSONPlaceholder · API REST", systemImage: "network")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.indigo)
                        Text("Descubra novos posts")
                            .font(.title2.bold())
                        Text("Explore publicações da internet, salve suas favoritas ou escreva a sua própria.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            Label("\(viewModel.apiPosts.count) da API", systemImage: "globe")
                            Spacer()
                            Label("\(viewModel.savedPosts.count) salvos", systemImage: "bookmark.fill")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.indigo)
                        .padding(.vertical, 4)
                        Button {
                            showingAddPost = true
                        } label: {
                            Label("Cadastrar novo post", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(.vertical, 8)
                }

                Section("Publicações da API") {
                    if viewModel.isLoading && viewModel.apiPosts.isEmpty {
                        ProgressView("Carregando posts…")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let error = viewModel.apiErrorMessage {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Conexão indisponível", systemImage: "wifi.exclamationmark")
                                .font(.headline)
                            Text(error).font(.subheadline).foregroundStyle(.secondary)
                            Button("Tentar novamente") {
                                Task { await viewModel.fetchPosts() }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 8)
                    } else if filteredPosts.isEmpty {
                        Label("Nenhum post encontrado", systemImage: "magnifyingglass")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(filteredPosts) { post in
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Post #\(post.id)  ·  Usuário \(post.userId)", systemImage: "person.crop.circle")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                            Text(post.title).font(.headline)
                            Text(post.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Button {
                                if !viewModel.savePost(post) { showingError = true }
                            } label: {
                                Label(viewModel.isSaved(post) ? "Post salvo" : "Salvar post",
                                      systemImage: viewModel.isSaved(post) ? "checkmark.circle.fill" : "bookmark")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isSaved(post))
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Explorar")
            .searchable(text: $searchText, prompt: "Buscar posts da API")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.fetchPosts() }
                    } label: {
                        Label("Atualizar", systemImage: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .refreshable { await viewModel.fetchPosts() }
            .task {
                if viewModel.apiPosts.isEmpty { await viewModel.fetchPosts() }
            }
            .alert("Não foi possível salvar", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.storageErrorMessage ?? "Tente novamente.")
            }
        }
    }
}
