class Livro: Documento {
    let id: Int
    private(set) var titulo: String
    private(set) var autor: String
    private(set) var anoPublicacao: Int
    private(set) var isEmprestado: Bool

    init(id: Int, titulo: String, autor: String, anoPublicacao: Int) {
        self.id = id
        self.titulo = titulo
        self.autor = autor
        self.anoPublicacao = anoPublicacao
        self.isEmprestado = false
    }

    func exibirDetalhes() {
        print("------------------------------")
        print("ID: \(id)")
        print("Título: \(titulo)")
        print("Autor: \(autor)")
        print("Ano de publicação: \(anoPublicacao)")
        if isEmprestado {
            print("Status: Emprestado")
        } else {
            print("Status: Disponível")
        }
    }

    func alterarTitulo(_ novoTitulo: String) {
        titulo = novoTitulo
    }

    func alterarAutor(_ novoAutor: String) {
        autor = novoAutor
    }

    func alterarAnoPublicacao(_ novoAno: Int) {
        anoPublicacao = novoAno
    }

    func emprestar() {
        isEmprestado = true
    }

    func devolver() {
        isEmprestado = false
    }
}
