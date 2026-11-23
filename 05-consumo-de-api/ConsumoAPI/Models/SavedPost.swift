import Foundation

// Representa um post salvo localmente.
// apiID é nil quando o post foi criado pelo próprio usuário.
struct SavedPost: Identifiable, Codable {
    let id: UUID
    let apiID: Int?
    let title: String
    let body: String
}
