import Foundation

// Representa um aluno cadastrado na turma.
struct Aluno: Identifiable {
    let id = UUID()
    let nome: String
    let nota1: Double
    let nota2: Double

    var media: Double {
        (nota1 + nota2) / 2
    }

    var aprovado: Bool {
        media >= 7.0
    }

    var situacao: String {
        aprovado ? "Aprovado" : "Reprovado"
    }
}

// Converte uma nota digitada, aceitando vírgula ou ponto decimal.
// Retorna nil quando a entrada não é um número entre 0 e 10.
func converterNota(_ texto: String) -> Double? {
    let entrada = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: ",", with: ".")

    // Aceita somente algarismos e, opcionalmente, um separador decimal.
    let partes = entrada.split(separator: ".", omittingEmptySubsequences: false)
    guard (1...2).contains(partes.count),
          partes.allSatisfy({ parte in
              !parte.isEmpty && parte.allSatisfy({ $0.isASCII && $0.isNumber })
          }),
          let numero = Double(entrada),
          numero.isFinite,
          (0.0...10.0).contains(numero) else {
        return nil
    }

    return numero
}

// Todas as notas aparecem com uma casa decimal no padrão brasileiro.
func formatarNota(_ nota: Double) -> String {
    nota.formatted(
        .number
            .precision(.fractionLength(1))
            .locale(Locale(identifier: "pt_BR"))
    )
}
