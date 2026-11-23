import SwiftUI
import SwiftData

// Tela do formulário para cadastrar um evento.
struct CadastroEventoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let viewModel: EventoViewModel

    @State private var titulo = ""
    @State private var descricao = ""
    @State private var data = Date()
    @State private var local = ""
    @State private var mostrarErro = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Informações do evento") {
                    TextField("Título", text: $titulo)

                    TextField("Descrição", text: $descricao, axis: .vertical)
                        .lineLimit(3...5)

                    DatePicker(
                        "Data e hora",
                        selection: $data,
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    TextField("Local", text: $local)
                }

                Section {
                    Text("Todos os campos são obrigatórios.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Novo evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        salvarEvento()
                    }
                }
            }
            .alert("Verifique os dados", isPresented: $mostrarErro) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.mensagemErro)
            }
        }
    }

    private func salvarEvento() {
        let salvou = viewModel.adicionarEvento(
            titulo: titulo,
            descricao: descricao,
            data: data,
            local: local,
            context: modelContext
        )

        if salvou {
            dismiss()
        } else {
            mostrarErro = true
        }
    }
}
