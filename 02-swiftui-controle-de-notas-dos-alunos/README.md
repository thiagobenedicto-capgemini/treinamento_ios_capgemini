# Controle de Notas dos Alunos

Aplicativo acadêmico para iPhone desenvolvido em **Swift e SwiftUI** como projeto final de um módulo introdutório de desenvolvimento iOS.

## Funcionalidades

- Cadastro de alunos com nome e duas notas entre **0 e 10**.
- Validação de campos obrigatórios e valores numéricos, com mensagens de erro.
- Aceita notas decimais com **vírgula ou ponto**.
- Cálculo automático da média: `(nota1 + nota2) / 2`.
- Situação **Aprovado** para média maior ou igual a 7,0; caso contrário, **Reprovado**.
- Lista de alunos com notas, média de uma casa decimal e botão de remoção.
- Resumo automático de total de alunos, aprovados e reprovados.
- Uma única tela e dados mantidos somente em memória.

## Tecnologias

- Swift
- SwiftUI
- `@State` para atualizar formulário e listagem

Não utiliza MVVM, banco de dados, APIs, bibliotecas externas nem persistência local.
