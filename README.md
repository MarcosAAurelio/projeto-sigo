# SIGO — Sistema Integrado de Gestão de Ocorrências e Patrulhamento Comunitário

Projeto acadêmico de banco de dados relacional para registro, triagem, despacho e acompanhamento de ocorrências de segurança em contexto municipal ou comunitário.

## Identificação

- **Instituição:** Universidade Católica de Brasília
- **Disciplina:** Laboratório de Banco de Dados
- **Professor:** Jefferson Salomão Rodrigues
- **Data de entrega:** 20/09/2026
- **Tema:** Segurança

| Integrante | Matrícula |
|---|---|
| Marcos Aurélio Moreira Costa Rabelo | UC25104233 |
| Pedro Cauã Valentin de Moraes | UC25200946 |

## Estrutura do projeto

```text
projeto-sigo/
├── .gitignore
├── README.md
├── docs/
│   ├── Trabalho_Completo_SIGO_Seguranca_REVISADO.pdf
│   └── diagramas/
│       ├── Fig01_conceitual_pessoa.(png|svg)
│       ├── Fig02_conceitual_ocorrencia.(png|svg)
│       ├── Fig03_conceitual_entidades_fracas.(png|svg)
│       ├── Fig04_conceitual_recursos.(png|svg)
│       ├── Fig05_logico_pessoas.(png|svg)
│       ├── Fig06_logico_recursos.(png|svg)
│       ├── Fig07_logico_ocorrencia.(png|svg)
│       ├── Fig08_logico_despacho.(png|svg)
│       ├── Fig09_fisico_visao_geral.(png|svg)
│       ├── Fig10_fisico_identidades.(png|svg)
│       ├── Fig11_fisico_recursos_ocorrencia.(png|svg)
│       └── Fig12_fisico_vinculos_auditoria.(png|svg)
└── sql/
    └── sigo_banco_dados.sql
```

## Conteúdo entregue

- descrição, contexto, justificativa e escopo do tema;
- DER conceitual em notação de Chen;
- entidades fortes, fracas, associativas e especializadas;
- relacionamentos 1:1, 1:N, M:N e ternário;
- atributos simples, compostos, multivalorados, derivados e identificadores;
- diagrama lógico com tipos, PKs, FKs, restrições e coerência com o DER;
- quatro diagramas físicos voltados ao MySQL;
- normalização e regras de integridade;
- script autocontido com 17 tabelas;
- população de dados;
- consultas Q1 a Q12;
- atualizações U1 a U4 com transações;
- teste T11 da especialização exclusiva de `pessoa`;
- documentação, plano de testes e divisão das atividades.

O projeto contém diagramas conceituais, lógicos e físicos. As 12 figuras também estão disponíveis em `docs/diagramas/` nos formatos PNG, para visualização rápida, e SVG, para ampliação sem perda de qualidade. `Envolvimento` e `Equipe_Agente` são entidades associativas que representam relacionamentos M:N e guardam atributos próprios. O relacionamento ternário entre Ocorrência, Equipe e Veículo é convertido na tabela `acionamento`.

## Requisitos

- MySQL **8.0.16 ou superior**;
- mecanismo InnoDB;
- codificação `utf8mb4`.

A versão mínima é necessária porque versões anteriores do MySQL aceitavam cláusulas `CHECK`, mas não realizavam sua validação efetiva.

## Como executar

1. Abra uma conexão MySQL 8 e selecione um schema no qual tenha permissão para criar tabelas.
2. Abra `sql/sigo_banco_dados.sql`.
3. Se possuir permissão para criar bancos, descomente as linhas `CREATE DATABASE` e `USE` do início do arquivo. Caso contrário, mantenha-as comentadas.
4. Execute o arquivo completo.
5. Confira os totais apresentados ao final e os resultados das consultas Q1 a Q12.
6. Execute o teste negativo T11 separadamente, depois da carga, usando a instrução comentada indicada no SQL. A tentativa de cadastrar como operador uma pessoa já marcada como agente deve ser rejeitada pela FK composta.

Pela linha de comando, com um schema existente chamado `projeto_sigo`, a execução equivalente é:

```bash
mysql -u SEU_USUARIO -p projeto_sigo < sql/sigo_banco_dados.sql
```

O nome do schema é apenas um exemplo e pode ser substituído pelo schema fornecido pelo ambiente acadêmico.

O script inicia com `DROP TABLE IF EXISTS` em ordem segura, permitindo repetir a execução em ambiente de desenvolvimento. As atualizações U1 a U4 são demonstradas dentro de transações encerradas com `ROLLBACK`, preservando a massa de dados acadêmica. Em produção, após validar todas as operações da transação, a aplicação confirmaria a operação com `COMMIT`.

Para testar o T11 isoladamente, conecte-se ao schema já carregado e execute apenas o `INSERT` indicado na seção T11 do SQL. A rejeição pela FK composta é o resultado esperado; não execute esse teste como parte de uma carga bem-sucedida.

## Regra RN03

A especialização de `pessoa` em `cidadao`, `agente` e `operador` é disjunta. A tabela `pessoa` possui o discriminador `tipo_pessoa` e a chave candidata `(id_pessoa, tipo_pessoa)`. Cada subtipo fixa seu discriminador com `CHECK` e referencia esse par por uma FK composta. Assim, uma pessoa cadastrada como agente não pode ser inserida também como operador ou cidadão.

A totalidade da especialização permanece como regra da aplicação, pois sua imposição declarativa entre três tabelas exigiria verificação diferida, não disponível no MySQL 8.

## Repositório

Nome previsto: `projeto-sigo`

Endereço: `https://github.com/MarcosAAurelio/projeto-sigo`

## Observação

Este é um trabalho acadêmico. O SIGO não substitui serviços oficiais de emergência. Em uma implantação real, seriam necessários controles adicionais de autenticação, autorização, auditoria, retenção, criptografia e adequação à LGPD.
