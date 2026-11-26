import SwiftUI

struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var bodyText = ""

    // A tela informa o título e o conteúdo ao salvar.
    var onSave: (String, String) -> Void

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Informações do post") {
                    TextField("Título", text: $title)

                    TextEditor(text: $bodyText)
                        .frame(minHeight: 140)
                }
            }
            .navigationTitle("Novo post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        onSave(title, bodyText)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
