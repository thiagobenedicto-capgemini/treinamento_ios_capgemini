import SwiftUI
import SwiftData

// A View apenas mostra os dados e chama os métodos da ViewModel.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = EventoViewModel()
    @State private var mostrarCadastro = false
    @State private var mostrarErro = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.eventos.isEmpty {
                    ContentUnavailableView(
                        "Nenhum evento cadastrado",
                        systemImage: "calendar.badge.plus",
                        description: Text("Toque em + para cadastrar seu primeiro evento.")
                    )
                } else {
                    List {
                        ForEach(viewModel.eventos) { evento in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(evento.titulo)
                                    .font(.headline)

                                Text(evento.descricao)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Label(evento.local, systemImage: "mappin.and.ellipse")
                                    .font(.subheadline)

                                Label(
                                    evento.data.formatted(date: .abbreviated, time: .shortened),
                                    systemImage: "calendar"
                                )
                                .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: removerEventos)
                    }
                }
            }
            .navigationTitle("Eventos")
            .toolbar {
                Button {
                    mostrarCadastro = true
                } label: {
                    Label("Novo evento", systemImage: "plus")
                }
            }
            .sheet(isPresented: $mostrarCadastro) {
                CadastroEventoView(viewModel: viewModel)
            }
            .onAppear {
                if !viewModel.carregarEventos(context: modelContext) {
                    mostrarErro = true
                }
            }
            .alert("Atenção", isPresented: $mostrarErro) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.mensagemErro)
            }
        }
    }

    private func removerEventos(nos indices: IndexSet) {
        if !viewModel.removerEventos(nos: indices, context: modelContext) {
            mostrarErro = true
        }
    }
}
