import Foundation
import Observation

// Guarda as tarefas e controla as ações do aplicativo.
@Observable
class TodoViewModel {
    private(set) var tasks: [TodoItem] = []

    // Adiciona uma tarefa, desde que o título não esteja vazio.
    func addTask(title: String) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty else { return }

        let newTask = TodoItem(title: cleanTitle)
        tasks.append(newTask)
    }

    // Marca uma tarefa como concluída ou pendente.
    func toggleTask(id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    // Apaga as tarefas selecionadas pelo gesto de arrastar.
    func deleteTasks(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            tasks.remove(at: index)
        }
    }
}
