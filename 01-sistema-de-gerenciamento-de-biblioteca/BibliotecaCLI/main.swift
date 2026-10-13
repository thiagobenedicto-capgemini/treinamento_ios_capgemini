import Foundation

var livros: [Livro] = []
var executando = true

// Centraliza a leitura e encerra o programa se a entrada padrão terminar.
func lerEntrada(_ mensagem: String) -> String? {
    print(mensagem)
    if let entrada = readLine() {
        return entrada.trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
        print("\nEntrada encerrada. Encerrando o programa.")
        executando = false
        return nil
    }
}

func lerTexto(_ mensagem: String) -> String? {
    while executando {
        if let texto = lerEntrada(mensagem) {
            if texto.isEmpty {
                print("O texto não pode ficar vazio. Tente novamente.")
            } else {
                return texto
            }
        }
    }
    return nil
}

func lerInteiro(_ mensagem: String) -> Int? {
    while executando {
        if let texto = lerEntrada(mensagem) {
            if let numero = Int(texto) {
                return numero
            } else {
                print("Digite um número inteiro válido.")
            }
        }
    }
    return nil
}

func lerAno() -> Int? {
    while executando {
        if let ano = lerInteiro("Ano de publicação:") {
            if ano > 0 {
                return ano
            } else {
                print("O ano deve ser maior que zero.")
            }
        }
    }
    return nil
}

// Retorna o livro encontrado, ou nil quando o ID não existe.
func encontrarLivroPorID(_ id: Int) -> Livro? {
    for livro in livros {
        if livro.id == id {
            return livro
        }
    }
    return nil
}

func cadastrarLivro() {
    if let id = lerInteiro("ID do livro:") {
        if let livroExistente = encontrarLivroPorID(id) {
            print("Já existe um livro com o ID \(livroExistente.id). Cadastro não realizado.")
            return
        }

        // O livro só é adicionado depois que todos os dados forem recebidos.
        if let titulo = lerTexto("Título:"),
           let autor = lerTexto("Autor:"),
           let ano = lerAno() {
            let livro = Livro(id: id, titulo: titulo, autor: autor, anoPublicacao: ano)
            livros.append(livro)
            print("Livro cadastrado com sucesso.")
        }
    }
}

func listarLivros() {
    if livros.isEmpty {
        print("Nenhum livro cadastrado.")
    } else {
        for livro in livros {
            livro.exibirDetalhes()
        }
    }
}

func buscarLivro() {
    print("\n1 - Buscar por ID")
    print("2 - Buscar por título")
    print("0 - Voltar ao menu")

    if let opcao = lerInteiro("Escolha uma opção:") {
        switch opcao {
        case 1:
            if let id = lerInteiro("ID do livro:") {
                if let livro = encontrarLivroPorID(id) {
                    livro.exibirDetalhes()
                } else {
                    print("Livro com esse ID não encontrado.")
                }
            }
        case 2:
            if let titulo = lerTexto("Título ou parte do título:") {
                var encontrou = false
                for livro in livros {
                    if livro.titulo.lowercased().contains(titulo.lowercased()) {
                        livro.exibirDetalhes()
                        encontrou = true
                    }
                }
                if encontrou == false {
                    print("Nenhum livro encontrado com esse título.")
                }
            }
        case 0:
            break
        default:
            print("Opção inválida.")
        }
    }
}

func editarLivro() {
    if let id = lerInteiro("ID do livro que deseja editar:") {
        if let livro = encontrarLivroPorID(id) {
            livro.exibirDetalhes()
            print("\n1 - Alterar título")
            print("2 - Alterar autor")
            print("3 - Alterar ano de publicação")
            print("4 - Alterar status de empréstimo")
            print("0 - Voltar ao menu")

            if let opcao = lerInteiro("Escolha o campo:") {
                switch opcao {
                case 1:
                    if let titulo = lerTexto("Novo título:") {
                        livro.alterarTitulo(titulo)
                        print("Título atualizado.")
                    }
                case 2:
                    if let autor = lerTexto("Novo autor:") {
                        livro.alterarAutor(autor)
                        print("Autor atualizado.")
                    }
                case 3:
                    if let ano = lerAno() {
                        livro.alterarAnoPublicacao(ano)
                        print("Ano atualizado.")
                    }
                case 4:
                    print("1 - Marcar como Emprestado")
                    print("2 - Marcar como Disponível")
                    if let status = lerInteiro("Escolha o status:") {
                        switch status {
                        case 1:
                            livro.emprestar()
                            print("Livro marcado como Emprestado.")
                        case 2:
                            livro.devolver()
                            print("Livro marcado como Disponível.")
                        default:
                            print("Status inválido. Nenhuma alteração realizada.")
                        }
                    }
                case 0:
                    break
                default:
                    print("Opção inválida. Nenhuma alteração realizada.")
                }
            }
        } else {
            print("Livro com esse ID não encontrado.")
        }
    }
}

func removerLivro() {
    if let id = lerInteiro("ID do livro que deseja remover:") {
        // indices fornece somente posições válidas, inclusive para array vazio.
        for indice in livros.indices {
            if livros[indice].id == id {
                livros.remove(at: indice)
                print("Livro removido com sucesso.")
                return
            }
        }
        print("Livro com esse ID não encontrado.")
    }
}

while executando {
    print("\n==============================")
    print("    SISTEMA DA BIBLIOTECA")
    print("==============================")
    print("1 - Cadastrar livro")
    print("2 - Listar livros")
    print("3 - Buscar livro")
    print("4 - Editar livro")
    print("5 - Remover livro")
    print("0 - Sair")

    if let opcao = lerInteiro("Escolha uma opção:") {
        switch opcao {
        case 1:
            cadastrarLivro()
        case 2:
            listarLivros()
        case 3:
            buscarLivro()
        case 4:
            editarLivro()
        case 5:
            removerLivro()
        case 0:
            executando = false
            print("Programa encerrado.")
        default:
            print("Opção inválida. Escolha uma opção do menu.")
        }
    }
}
