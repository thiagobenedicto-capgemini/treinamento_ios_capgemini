import SwiftUI

struct AddPostView: View {
    @ObservedObject var viewModel: PostsViewModel
    var onSaved: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var bodyText = ""
    @State private var errorMessage: String?

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Escreva sua publicação", systemImage: "square.and.pencil")
                        .font(.headline)
                        .foregroundStyle(Color.indigo)
                    Text("O post será salvo somente neste dispositivo.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("Título · obrigatório") {
                    TextField("Digite o título", text: $title)
                }
                Section("Conteúdo · obrigatório") {
                    TextField("Escreva o conteúdo do post", text: $bodyText, axis: .vertical)
                        .lineLimit(5...10)
                }
                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(Color.red)
                    }
                }
                Section {
                    Button {
                        if viewModel.addPost(title: title, body: bodyText) {
                            onSaved()
                            dismiss()
                        } else {
                            errorMessage = viewModel.storageErrorMessage
                        }
                    } label: {
                        Label("Salvar post", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!canSave)
                    .listRowBackground(Color.clear)
                } footer: {
                    Text("Preencha os dois campos para habilitar o botão Salvar post.")
                }
            }
            .navigationTitle("Novo post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .tint(.indigo)
    }
}
