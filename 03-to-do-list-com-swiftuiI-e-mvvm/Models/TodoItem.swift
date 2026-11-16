import Foundation

// Representa uma tarefa da lista.
struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
}
