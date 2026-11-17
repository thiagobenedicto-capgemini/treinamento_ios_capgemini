import SwiftUI

struct ContentView: View {
    @State private var viewModel = TodoViewModel()
    @State private var newTaskTitle = ""

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Digite uma tarefa", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addTask)

                    Button("Adicionar", action: addTask)
                }
                .padding()

                List {
                    ForEach(viewModel.tasks) { task in
                        Button {
                            viewModel.toggleTask(id: task.id)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: task.isCompleted
                                      ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.isCompleted
                                                     ? Color.green : Color.gray)

                                Text(task.title)
                                    .strikethrough(task.isCompleted)
                                    .foregroundStyle(task.isCompleted
                                                     ? Color.secondary : Color.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: viewModel.deleteTasks)
                }
            }
            .navigationTitle("Minhas Tarefas")
        }
    }

    // Envia o texto para a ViewModel e limpa o campo.
    private func addTask() {
        viewModel.addTask(title: newTaskTitle)
        newTaskTitle = ""
    }
}

#Preview {
    ContentView()
}
