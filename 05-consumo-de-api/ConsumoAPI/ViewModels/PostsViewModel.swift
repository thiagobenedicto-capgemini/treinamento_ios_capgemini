import Foundation
import SwiftUI

// O ViewModel controla os dados e as ações das telas.
// @MainActor garante que as mudanças da interface ocorram na thread principal.
@MainActor
final class PostsViewModel: ObservableObject {
    @Published var apiPosts: [APIPost] = []
    @Published var savedPosts: [SavedPost] = []
    @Published var isLoading = false
    @Published var apiErrorMessage: String?
    @Published var storageErrorMessage = ""
    @Published var showStorageError = false

    init() {
        loadSavedPosts()
    }

    // GET: busca os posts da API pública.
    func fetchPosts() async {
        isLoading = true
        apiErrorMessage = nil
        defer { isLoading = false }

        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            apiErrorMessage = "O endereço da API é inválido."
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // Verifica se o servidor respondeu com sucesso (HTTP 200 a 299).
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                apiErrorMessage = "A API retornou um erro. Tente novamente."
                return
            }

            apiPosts = try JSONDecoder().decode([APIPost].self, from: data)
        } catch {
            apiErrorMessage = "Não foi possível carregar os posts. Verifique sua internet."
        }
    }

    // Verifica se um post da API já está na lista de salvos.
    func isSaved(_ post: APIPost) -> Bool {
        savedPosts.contains { $0.apiID == post.id }
    }

    // Salva uma cópia do post da API no arquivo local.
    func savePost(_ post: APIPost) {
        guard !isSaved(post) else { return }

        let newPost = SavedPost(
            id: UUID(),
            apiID: post.id,
            title: post.title,
            body: post.body
        )

        savedPosts.append(newPost)
        saveToFile()
    }

    // Cadastra um post que foi digitado pelo usuário.
    func addPost(title: String, body: String) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBody = body.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty && !cleanBody.isEmpty else { return }

        let newPost = SavedPost(
            id: UUID(),
            apiID: nil,
            title: cleanTitle,
            body: cleanBody
        )

        savedPosts.append(newPost)
        saveToFile()
    }

    // Remove os itens selecionados com o gesto de deslizar na lista.
    func deleteSavedPosts(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            savedPosts.remove(at: index)
        }
        saveToFile()
    }

    // Caminho do arquivo JSON na pasta Documents do aplicativo.
    private var fileURL: URL {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return documents.appendingPathComponent("posts_salvos.json")
    }

    // Lê os posts salvos quando o aplicativo é aberto.
    private func loadSavedPosts() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            savedPosts = try JSONDecoder().decode([SavedPost].self, from: data)
        } catch {
            showFileError("Não foi possível ler o arquivo de posts salvos.")
        }
    }

    // Grava os posts em um arquivo JSON. Não utiliza banco de dados.
    private func saveToFile() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(savedPosts)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            showFileError("Não foi possível gravar os posts no arquivo JSON.")
        }
    }

    private func showFileError(_ message: String) {
        storageErrorMessage = message
        showStorageError = true
    }
}
