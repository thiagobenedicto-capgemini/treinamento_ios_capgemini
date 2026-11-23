import Foundation

// Representa um post recebido da API JSONPlaceholder.
// Codable permite converter JSON em objetos Swift.
struct APIPost: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
