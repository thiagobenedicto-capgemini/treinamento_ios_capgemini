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
                Section("Título") {
                    TextField("Dê um título ao seu post", text: $title, axis: .vertical)
                        .font(.title3.weight(.semibold))
                        .lineLimit(1...4)
                }
                Section {
                    TextField("Comece a escrever…", text: $bodyText, axis: .vertical)
                        .font(.body)
                        .lineLimit(8...16)
                } header: {
                    Text("Conteúdo")
                } footer: {
                    Text("\(bodyText.count) caracteres")
                }
                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(Color.red)
                    }
                }
                Section {
                    Button(action: save) {
                        Label("Salvar post", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!canSave)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                } footer: {
                    Label("Sua publicação fica salva somente neste dispositivo.", systemImage: "lock")
                }
            }
            .navigationTitle("Novo post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar", action: save)
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
        }
        .tint(.blue)
    }

    private func save() {
        if viewModel.addPost(title: title, body: bodyText) {
            onSaved()
            dismiss()
        } else {
            errorMessage = viewModel.storageErrorMessage
        }
    }
}
