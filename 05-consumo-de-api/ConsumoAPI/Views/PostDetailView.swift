import SwiftUI

// A mesma apresentação é usada para posts da API e posts locais.
struct PostRowView: View {
    let title: String
    let bodyText: String
    let source: String
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 30)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(bodyText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(source)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

// Tela de leitura: mostra o conteúdo inteiro, sem truncar o texto.
struct PostDetailView: View {
    @ObservedObject var viewModel: PostsViewModel
    var apiPost: APIPost? = nil
    var savedPost: SavedPost? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var showingDelete = false
    @State private var showingError = false

    private var title: String { apiPost?.title ?? savedPost?.title ?? "" }
    private var bodyText: String { apiPost?.body ?? savedPost?.body ?? "" }
    private var source: String {
        if let apiPost { return "Usuário \(apiPost.userId) · Post #\(apiPost.id)" }
        if let id = savedPost?.apiID { return "Favorito · Post #\(id)" }
        return "Criado por mim"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Label(source, systemImage: apiPost != nil ? "person.crop.circle" : "doc.text")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                Divider()
                Text(bodyText)
                    .font(.body)
                    .lineSpacing(6)
                    .textSelection(.enabled)
                Divider()
                if let apiPost {
                    Button {
                        if !viewModel.savePost(apiPost) { showingError = true }
                    } label: {
                        Label(viewModel.isSaved(apiPost) ? "Post salvo" : "Salvar post",
                              systemImage: viewModel.isSaved(apiPost) ? "bookmark.fill" : "bookmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(viewModel.isSaved(apiPost))
                } else if savedPost != nil {
                    Button(role: .destructive) {
                        showingDelete = true
                    } label: {
                        Label("Excluir post", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .navigationTitle("Publicação")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: title + "\n\n" + bodyText)
                    .accessibilityLabel("Compartilhar publicação")
            }
        }
        .alert("Excluir post?", isPresented: $showingDelete) {
            Button("Excluir", role: .destructive) {
                if let savedPost {
                    if viewModel.deletePost(savedPost) {
                        dismiss()
                    } else {
                        showingError = true
                    }
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Esta publicação será removida apenas deste dispositivo.")
        }
        .alert("Não foi possível concluir", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.storageErrorMessage ?? "Tente novamente.")
        }
    }
}
