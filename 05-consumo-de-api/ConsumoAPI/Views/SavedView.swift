import SwiftUI

struct SavedView: View {
    @ObservedObject var viewModel: PostsViewModel
    @Binding var showingAddPost: Bool
    @State private var postToDelete: SavedPost?
    @State private var showingDelete = false

    private var createdCount: Int {
        viewModel.savedPosts.filter { $0.apiID == nil }.count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("ARMAZENAMENTO LOCAL", systemImage: "doc.text")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.indigo)
                        Text("Sua coleção")
                            .font(.title2.bold())
                        HStack(spacing: 12) {
                            counter("Criados", count: createdCount, icon: "square.and.pencil")
                            counter("Favoritos", count: viewModel.savedPosts.count - createdCount, icon: "bookmark.fill")
                        }
                        Button {
                            showingAddPost = true
                        } label: {
                            Label("Cadastrar novo post", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        Label("Dados mantidos em um arquivo JSON no dispositivo.", systemImage: "internaldrive")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                if let error = viewModel.storageErrorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(Color.orange)
                    }
                }

                Section("Meus posts · \(viewModel.savedPosts.count)") {
                    if viewModel.savedPosts.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "bookmark.square")
                                .font(.system(size: 42))
                                .foregroundStyle(Color.indigo)
                            Text("Nenhum post salvo").font(.headline)
                            Text("Cadastre um novo post ou salve uma publicação na aba Explorar.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                    ForEach(viewModel.savedPosts) { post in
                        VStack(alignment: .leading, spacing: 10) {
                            Label(post.apiID == nil ? "Criado por mim" : "Favorito da API",
                                  systemImage: post.apiID == nil ? "square.and.pencil" : "bookmark.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.indigo)
                            Text(post.title).font(.headline)
                            Text(post.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Button(role: .destructive) {
                                requestDelete(post)
                            } label: {
                                Label("Excluir post", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.vertical, 8)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                requestDelete(post)
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Meus posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPost = true
                    } label: {
                        Label("Novo post", systemImage: "plus")
                    }
                }
            }
            .alert("Excluir post?", isPresented: $showingDelete, presenting: postToDelete) { post in
                Button("Excluir", role: .destructive) {
                    // Em caso de falha, a mensagem aparece na seção de armazenamento.
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

    private func counter(_ title: String, count: Int, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(count)")
                .font(.title.bold())
                .foregroundStyle(Color.indigo)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
