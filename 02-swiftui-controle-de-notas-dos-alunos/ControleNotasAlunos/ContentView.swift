import SwiftUI

struct ContentView: View {
    @State private var nome = ""
    @State private var nota1 = ""
    @State private var nota2 = ""
    @State private var alunos: [Aluno] = []
    @State private var mensagemErro: String? = nil

    private var totalAprovados: Int {
        alunos.filter { $0.aprovado }.count
    }

    private var totalReprovados: Int {
        alunos.count - totalAprovados
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Controle de Notas")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    Text("Cadastre alunos e acompanhe os resultados da turma.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)

            Section {
                TextField("Nome do aluno", text: $nome)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()

                TextField("Nota 1 (0 a 10)", text: $nota1)
                    .keyboardType(.decimalPad)

                TextField("Nota 2 (0 a 10)", text: $nota2)
                    .keyboardType(.decimalPad)

                if let mensagemErro {
                    Label(mensagemErro, systemImage: "exclamationmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button(action: cadastrarAluno) {
                    HStack {
                        Spacer()
                        Label("Cadastrar aluno", systemImage: "plus.circle.fill")
                        Spacer()
                    }
                    .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
            } header: {
                Text("Cadastro")
            } footer: {
                Text("Informe notas entre 0 e 10. Use vírgula ou ponto para decimais.")
            }

            Section {
                if alunos.isEmpty {
                    ContentUnavailableView(
                        "Nenhum aluno cadastrado",
                        systemImage: "person.2.slash",
                        description: Text("Preencha o formulário acima para começar.")
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    ForEach(alunos) { aluno in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 8) {
                                Text(aluno.nome)
                                    .font(.headline)

                                Spacer(minLength: 4)

                                Text(aluno.situacao)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(aluno.aprovado ? Color.green : Color.red)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        (aluno.aprovado ? Color.green : Color.red).opacity(0.12),
                                        in: Capsule()
                                    )
                            }

                            HStack(spacing: 16) {
                                Text("Nota 1: \(formatarNota(aluno.nota1))")
                                Text("Nota 2: \(formatarNota(aluno.nota2))")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                            HStack {
                                Text("Média: \(formatarNota(aluno.media))")
                                    .font(.subheadline.weight(.semibold))

                                Spacer()

                                Button(role: .destructive) {
                                    removerAluno(aluno.id)
                                } label: {
                                    Label("Remover", systemImage: "trash")
                                        .font(.subheadline)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Remover \(aluno.nome)")
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            } header: {
                Text("Alunos cadastrados (\(alunos.count))")
            }

            Section("Resumo da turma") {
                HStack {
                    Label("Total de alunos", systemImage: "person.2")
                    Spacer()
                    Text("\(alunos.count)")
                        .fontWeight(.semibold)
                }

                HStack {
                    Label("Aprovados", systemImage: "checkmark.circle")
                    Spacer()
                    Text("\(totalAprovados)")
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }

                HStack {
                    Label("Reprovados", systemImage: "xmark.circle")
                    Spacer()
                    Text("\(totalReprovados)")
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }
        }
        .tint(.indigo)
        .scrollDismissesKeyboard(.interactively)
    }

    private func cadastrarAluno() {
        let nomeLimpo = nome.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nomeLimpo.isEmpty else {
            mensagemErro = "Informe o nome do aluno."
            return
        }

        guard let primeiraNota = converterNota(nota1) else {
            mensagemErro = "A Nota 1 deve ser um número entre 0 e 10."
            return
        }

        guard let segundaNota = converterNota(nota2) else {
            mensagemErro = "A Nota 2 deve ser um número entre 0 e 10."
            return
        }

        alunos.append(Aluno(nome: nomeLimpo, nota1: primeiraNota, nota2: segundaNota))

        // Limpa o formulário apenas quando o cadastro é válido.
        nome = ""
        nota1 = ""
        nota2 = ""
        mensagemErro = nil
    }

    private func removerAluno(_ id: UUID) {
        alunos.removeAll { $0.id == id }
    }
}

#Preview {
    ContentView()
}
