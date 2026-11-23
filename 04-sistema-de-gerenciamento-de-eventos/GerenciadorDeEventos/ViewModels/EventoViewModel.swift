import Foundation
import Observation
import SwiftData

// A ViewModel concentra a validação e as operações com o SwiftData.
@MainActor
@Observable
final class EventoViewModel {
    var eventos: [Evento] = []
    var mensagemErro = ""

    // READ: busca os eventos salvos e ordena pela data.
    func carregarEventos(context: ModelContext) -> Bool {
        do {
            let busca = FetchDescriptor<Evento>(
                sortBy: [SortDescriptor(\Evento.data, order: .forward)]
            )
            eventos = try context.fetch(busca)
            mensagemErro = ""
            return true
        } catch {
            mensagemErro = "Não foi possível carregar os eventos."
            return false
        }
    }

    // CREATE: verifica os campos e salva um novo evento.
    func adicionarEvento(
        titulo: String,
        descricao: String,
        data: Date,
        local: String,
        context: ModelContext
    ) -> Bool {
        let tituloLimpo = titulo.trimmingCharacters(in: .whitespacesAndNewlines)
        let descricaoLimpa = descricao.trimmingCharacters(in: .whitespacesAndNewlines)
        let localLimpo = local.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !tituloLimpo.isEmpty, !descricaoLimpa.isEmpty, !localLimpo.isEmpty else {
            mensagemErro = "Preencha título, descrição e local."
            return false
        }

        let evento = Evento(
            titulo: tituloLimpo,
            descricao: descricaoLimpa,
            data: data,
            local: localLimpo
        )

        context.insert(evento)

        do {
            try context.save()
            return carregarEventos(context: context)
        } catch {
            context.rollback()
            mensagemErro = "Não foi possível salvar o evento."
            return false
        }
    }

    // DELETE: remove os eventos selecionados pelo gesto de deslizar.
    func removerEventos(nos indices: IndexSet, context: ModelContext) -> Bool {
        for indice in indices {
            context.delete(eventos[indice])
        }

        do {
            try context.save()
            return carregarEventos(context: context)
        } catch {
            context.rollback()
            mensagemErro = "Não foi possível excluir o evento."
            return false
        }
    }
}
