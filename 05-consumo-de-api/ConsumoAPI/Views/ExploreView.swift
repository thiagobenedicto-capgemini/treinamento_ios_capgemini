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
                if searchText.isEmpty {
                    Section {
                        Button {
                            showingAddPost = true
                        } label: {
                            Label("Cadastrar novo post", systemImage: "square.and.pencil")
                                .font(.body.weight(.semibold))
                                .padding(.vertical, 4)
                        }
                    } footer: {
                        Text("Crie suas próprias publicações ou salve as que encontrar.")
                    }
                }

                Section {
                    if viewModel.isLoading && viewModel.apiPosts.isEmpty {
                        ProgressView("Carregando publicações…")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    } else if let error = viewModel.apiErrorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Conexão indisponível", systemImage: "wifi.slash")
                                .font(.headline)
                            Text(error)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button("Tentar novamente") {
                                Task { await viewModel.fetchPosts() }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 8)
                    } else if filteredPosts.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("Nenhum post encontrado").font(.headline)
                            Text("Experimente outro termo de busca.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }

                    ForEach(filteredPosts) { post in
                        VStack(alignment: .leading, spacing: 10) {
                            NavigationLink {
                                PostDetailView(viewModel: viewModel, apiPost: post)
                            } label: {
                                PostRowView(title: post.title, bodyText: post.body,
                                            source: "Usuário \(post.userId) · Post #\(post.id)",
                                            symbol: "person.crop.circle.fill")
                            }

                            // A ação de salvar fica visível, sem precisar abrir o post.
                            if viewModel.isSaved(post) {
                                Label("Salvo", systemImage: "bookmark.fill")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                            } else {
                                Button {
                                    if !viewModel.savePost(post) { showingError = true }
                                } label: {
                                    Label("Salvar post", systemImage: "bookmark")
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.vertical, 5)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                } header: {
                    HStack {
                        Text("Publicações")
                        Spacer()
                        Text("\(filteredPosts.count)")
                            .monospacedDigit()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Explorar")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Buscar publicações")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.fetchPosts() }
                    } label: {
                        Label("Atualizar", systemImage: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)

                    Button {
                        showingAddPost = true
                    } label: {
                        Label("Cadastrar novo post", systemImage: "square.and.pencil")
                    }
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
