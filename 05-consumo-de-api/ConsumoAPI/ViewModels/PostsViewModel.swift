import Foundation
import SwiftUI

// O ViewModel reúne as ações da tela e os dados do aplicativo.
@MainActor
final class PostsViewModel: ObservableObject {
    @Published private(set) var apiPosts: [APIPost] = []
    @Published private(set) var savedPosts: [SavedPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var apiErrorMessage: String?
    @Published private(set) var storageErrorMessage: String?

    private let fileURL: URL
    private var canWrite = true

    init(fileURL: URL? = nil) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = fileURL ?? documents.appendingPathComponent("posts_salvos.json")
        loadSavedPosts()
    }

    // GET: consulta a API e transforma o JSON em uma lista de posts.
    func fetchPosts() async {
        guard !isLoading else { return }
        isLoading = true
        apiErrorMessage = nil
        defer { isLoading = false }

        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            apiErrorMessage = "Endereço da API inválido."
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                apiErrorMessage = "A API retornou um erro. Tente novamente."
                return
            }
            apiPosts = try JSONDecoder().decode([APIPost].self, from: data)
        } catch {
            if !Task.isCancelled {
                apiErrorMessage = "Não foi possível carregar os posts. Verifique sua conexão."
            }
        }
    }

    func isSaved(_ post: APIPost) -> Bool {
        savedPosts.contains { $0.apiID == post.id }
    }

    // Salva uma cópia local, sem alterar os dados do servidor.
    @discardableResult
    func savePost(_ post: APIPost) -> Bool {
        guard !isSaved(post) else { return true }
        let newPost = SavedPost(id: UUID(), apiID: post.id, title: post.title, body: post.body)
        return saveToFile(savedPosts + [newPost])
    }

    @discardableResult
    func addPost(title: String, body: String) -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty, !cleanBody.isEmpty else {
            storageErrorMessage = "Preencha o título e o conteúdo."
            return false
        }
        let newPost = SavedPost(id: UUID(), apiID: nil, title: cleanTitle, body: cleanBody)
        return saveToFile(savedPosts + [newPost])
    }

    @discardableResult
    func deletePost(_ post: SavedPost) -> Bool {
        let updatedPosts = savedPosts.filter { $0.id != post.id }
        return saveToFile(updatedPosts)
    }

    private func loadSavedPosts() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            savedPosts = try JSONDecoder().decode([SavedPost].self, from: data)
        } catch {
            // Evita sobrescrever um arquivo que não pôde ser lido.
            canWrite = false
            storageErrorMessage = "Não foi possível ler o arquivo de posts salvos. Os dados originais foram preservados."
        }
    }

    // A lista só é atualizada se a gravação realmente funcionar.
    private func saveToFile(_ posts: [SavedPost]) -> Bool {
        guard canWrite else { return false }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(posts)
            try data.write(to: fileURL, options: .atomic)
            savedPosts = posts
            storageErrorMessage = nil
            return true
        } catch {
            storageErrorMessage = "Não foi possível gravar o arquivo JSON. Nenhuma alteração foi salva."
            return false
        }
    }
}
