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

O trabalho acadêmico contém 12 diagramas conceituais, lógicos e físicos incorporados ao PDF entregue separadamente. O repositório do GitHub contém somente este README, o `.gitignore` e o script `sql/sigo_banco_dados.sql`. `Envolvimento` e `Equipe_Agente` são entidades associativas que representam relacionamentos M:N e guardam atributos próprios. O relacionamento ternário entre Ocorrência, Equipe e Veículo é convertido na tabela `acionamento`.

## Requisitos

- MySQL **8.0.16 ou superior**;
- mecanismo InnoDB;
- codificação `utf8mb4`.

A versão mínima é necessária porque versões anteriores do MySQL aceitavam cláusulas `CHECK`, mas não realizavam sua validação efetiva.

## Como executar

1. Abra uma conexão MySQL 8 com um usuário que tenha permissão para criar bancos de dados.
2. Abra `sql/sigo_banco_dados.sql`.
3. Execute o arquivo completo. O próprio script cria o banco `projeto_sigo` com codificação `utf8mb4` e seleciona esse banco antes de criar as tabelas.
4. Confira os totais apresentados ao final e os resultados das consultas Q1 a Q12.
5. Execute o teste negativo T11 separadamente, depois da carga, usando a instrução comentada indicada no SQL. A tentativa de cadastrar como operador uma pessoa já marcada como agente deve ser rejeitada pela FK composta.

Pela linha de comando, a execução equivalente é:

```bash
mysql -u SEU_USUARIO -p < sql/sigo_banco_dados.sql
```

O script executa estas instruções no início:

```sql
CREATE DATABASE projeto_sigo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE projeto_sigo;
```

O script inicia com `DROP TABLE IF EXISTS` em ordem segura, permitindo repetir a execução em ambiente de desenvolvimento. As atualizações U1 a U4 são demonstradas dentro de transações encerradas com `ROLLBACK`, preservando a massa de dados acadêmica. Em produção, após validar todas as operações da transação, a aplicação confirmaria a operação com `COMMIT`.

Para testar o T11 isoladamente, conecte-se ao schema já carregado e execute apenas o `INSERT` indicado na seção T11 do SQL. A rejeição pela FK composta é o resultado esperado; não execute esse teste como parte de uma carga bem-sucedida.

## Regra RN03

A especialização de `pessoa` em `cidadao`, `agente` e `operador` é disjunta. A tabela `pessoa` possui o discriminador `tipo_pessoa` e a chave candidata `(id_pessoa, tipo_pessoa)`. Cada subtipo fixa seu discriminador com `CHECK` e referencia esse par por uma FK composta. Assim, uma pessoa cadastrada como agente não pode ser inserida também como operador ou cidadão.

A totalidade da especialização permanece como regra da aplicação, pois sua imposição declarativa entre três tabelas exigiria verificação diferida, não disponível no MySQL 8.

## Repositório

Nome previsto: `projeto-sigo`

Endereço: `https://github.com/MarcosAAurelio/projeto-sigo`
