import SwiftUI

// Filtros da lista local, sem alterar os dados gravados.
enum SavedFilter: String, CaseIterable {
    case all = "Todos"
    case created = "Criados"
    case favorites = "Favoritos"
}

struct SavedView: View {
    @ObservedObject var viewModel: PostsViewModel
    @Binding var showingAddPost: Bool
    @Binding var filter: SavedFilter
    @Binding var searchText: String
    @State private var postToDelete: SavedPost?
    @State private var showingDelete = false

    private var filteredPosts: [SavedPost] {
        var posts = viewModel.savedPosts
        if filter == .created {
            posts = posts.filter { $0.apiID == nil }
        } else if filter == .favorites {
            posts = posts.filter { $0.apiID != nil }
        }
        if !searchText.isEmpty {
            posts = posts.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.body.localizedCaseInsensitiveContains(searchText)
            }
        }
        return Array(posts.reversed())
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Tipo de publicação", selection: $filter) {
                        ForEach(SavedFilter.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }

                if searchText.isEmpty {
                    Section {
                        Button {
                            showingAddPost = true
                        } label: {
                            Label("Cadastrar novo post", systemImage: "square.and.pencil")
                                .font(.body.weight(.semibold))
                                .padding(.vertical, 4)
                        }
                    }
                }

                if let error = viewModel.storageErrorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(Color.orange)
                    }
                }

                Section {
                    if filteredPosts.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 38))
                                .foregroundStyle(.secondary)
                            Text(viewModel.savedPosts.isEmpty ? "Nenhum post salvo" : "Nenhum resultado")
                                .font(.headline)
                            Text(viewModel.savedPosts.isEmpty
                                 ? "Salve publicações da aba Explorar ou crie seu primeiro post."
                                 : "Tente outro filtro ou termo de busca.")
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
                                PostDetailView(viewModel: viewModel, savedPost: post)
                            } label: {
                                PostRowView(title: post.title, bodyText: post.body,
                                            source: post.apiID == nil ? "Criado por mim" : "Favorito da API",
                                            symbol: post.apiID == nil ? "doc.text.fill" : "bookmark.fill")
                            }

                            Button(role: .destructive) {
                                requestDelete(post)
                            } label: {
                                Label("Excluir post", systemImage: "trash")
                                    .font(.subheadline.weight(.medium))
                                    .padding(.vertical, 5)
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(Color.red)
                        }
                        .padding(.vertical, 5)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                requestDelete(post)
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                } header: {
                    HStack {
                        Text(filter.rawValue)
                        Spacer()
                        Text("\(filteredPosts.count)")
                            .monospacedDigit()
                    }
                } footer: {
                    Label("Salvos neste dispositivo · disponíveis offline", systemImage: "internaldrive")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Meus posts")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Buscar meus posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPost = true
                    } label: {
                        Label("Cadastrar novo post", systemImage: "square.and.pencil")
                    }
                }
            }
            .alert("Excluir post?", isPresented: $showingDelete, presenting: postToDelete) { post in
                Button("Excluir", role: .destructive) {
                    viewModel.deletePost(post)
                    postToDelete = nil
                }
                Button("Cancelar", role: .cancel) { postToDelete = nil }
            } message: { post in
                Text("\(post.title) será removido apenas deste dispositivo.")
            }
        }
    }

    private func requestDelete(_ post: SavedPost) {
        postToDelete = post
        showingDelete = true
    }
}
