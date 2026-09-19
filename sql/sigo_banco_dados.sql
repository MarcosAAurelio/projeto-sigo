-- SIGO - Sistema Integrado de Gestao de Ocorrencias e Patrulhamento Comunitario
-- Disciplina: Laboratorio de Banco de Dados - UCB
-- Professor: Jefferson Salomao Rodrigues
-- Integrantes: Marcos Aurelio Moreira Costa Rabelo (UC25104233)
--              Pedro Caua Valentin de Moraes (UC25200946)
-- SGBD: MySQL 8.0.16 ou superior

CREATE DATABASE projeto_sigo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE projeto_sigo;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS vw_fila_ocorrencias;
DROP TABLE IF EXISTS encerramento_ocorrencia;
DROP TABLE IF EXISTS historico_status;
DROP TABLE IF EXISTS evidencia;
DROP TABLE IF EXISTS acionamento;
DROP TABLE IF EXISTS envolvimento;
DROP TABLE IF EXISTS ocorrencia;
DROP TABLE IF EXISTS categoria_ocorrencia;
DROP TABLE IF EXISTS equipe_agente;
DROP TABLE IF EXISTS veiculo;
DROP TABLE IF EXISTS equipe;
DROP TABLE IF EXISTS operador;
DROP TABLE IF EXISTS agente;
DROP TABLE IF EXISTS cidadao;
DROP TABLE IF EXISTS pessoa_telefone;
DROP TABLE IF EXISTS pessoa;
DROP TABLE IF EXISTS endereco;
DROP TABLE IF EXISTS unidade_seguranca;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. DDL - CRIACAO DAS 17 TABELAS

CREATE TABLE unidade_seguranca (
    id_unidade INT UNSIGNED AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    tipo ENUM('CENTRAL','BASE','POSTO') NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(120) UNIQUE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_unidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE endereco (
    id_endereco INT UNSIGNED AUTO_INCREMENT,
    logradouro VARCHAR(120) NOT NULL,
    numero VARCHAR(12),
    complemento VARCHAR(60),
    bairro VARCHAR(80) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    uf CHAR(2) NOT NULL,
    cep CHAR(8),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    PRIMARY KEY (id_endereco),
    CONSTRAINT ck_endereco_uf CHECK (uf REGEXP '^[A-Z]{2}$'),
    CONSTRAINT ck_endereco_cep CHECK (cep IS NULL OR cep REGEXP '^[0-9]{8}$'),
    CONSTRAINT ck_endereco_latitude CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT ck_endereco_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pessoa (
    id_pessoa INT UNSIGNED AUTO_INCREMENT,
    primeiro_nome VARCHAR(60) NOT NULL,
    sobrenome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(120),
    tipo_pessoa ENUM('CIDADAO','AGENTE','OPERADOR') NOT NULL,
    id_endereco INT UNSIGNED,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_pessoa_cpf UNIQUE (cpf),
    CONSTRAINT uq_pessoa_email UNIQUE (email),
    CONSTRAINT uq_pessoa_tipo UNIQUE (id_pessoa, tipo_pessoa),
    CONSTRAINT ck_pessoa_cpf CHECK (cpf REGEXP '^[0-9]{11}$'),
    CONSTRAINT fk_pessoa_endereco FOREIGN KEY (id_endereco)
        REFERENCES endereco (id_endereco) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pessoa_telefone (
    id_pessoa INT UNSIGNED NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    tipo ENUM('CELULAR','FIXO','RECADO') NOT NULL,
    principal BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id_pessoa, telefone),
    CONSTRAINT fk_telefone_pessoa FOREIGN KEY (id_pessoa)
        REFERENCES pessoa (id_pessoa) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cidadao (
    id_pessoa INT UNSIGNED NOT NULL,
    tipo_pessoa ENUM('CIDADAO','AGENTE','OPERADOR') NOT NULL DEFAULT 'CIDADAO',
    aceita_contato BOOLEAN NOT NULL DEFAULT TRUE,
    observacao VARCHAR(255),
    PRIMARY KEY (id_pessoa),
    CONSTRAINT ck_cidadao_tipo CHECK (tipo_pessoa = 'CIDADAO'),
    CONSTRAINT fk_cidadao_pessoa FOREIGN KEY (id_pessoa, tipo_pessoa)
        REFERENCES pessoa (id_pessoa, tipo_pessoa) ON UPDATE RESTRICT ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE agente (
    id_pessoa INT UNSIGNED NOT NULL,
    tipo_pessoa ENUM('CIDADAO','AGENTE','OPERADOR') NOT NULL DEFAULT 'AGENTE',
    matricula VARCHAR(20) NOT NULL,
    patente_cargo VARCHAR(60),
    data_admissao DATE NOT NULL,
    id_unidade INT UNSIGNED,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_agente_matricula UNIQUE (matricula),
    CONSTRAINT ck_agente_tipo CHECK (tipo_pessoa = 'AGENTE'),
    CONSTRAINT fk_agente_pessoa FOREIGN KEY (id_pessoa, tipo_pessoa)
        REFERENCES pessoa (id_pessoa, tipo_pessoa) ON UPDATE RESTRICT ON DELETE CASCADE,
    CONSTRAINT fk_agente_unidade FOREIGN KEY (id_unidade)
        REFERENCES unidade_seguranca (id_unidade) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE operador (
    id_pessoa INT UNSIGNED NOT NULL,
    tipo_pessoa ENUM('CIDADAO','AGENTE','OPERADOR') NOT NULL DEFAULT 'OPERADOR',
    codigo_funcional VARCHAR(20) NOT NULL,
    nivel_acesso ENUM('BASICO','PLENO','SUPERVISOR') NOT NULL,
    id_unidade INT UNSIGNED,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_operador_codigo UNIQUE (codigo_funcional),
    CONSTRAINT ck_operador_tipo CHECK (tipo_pessoa = 'OPERADOR'),
    CONSTRAINT fk_operador_pessoa FOREIGN KEY (id_pessoa, tipo_pessoa)
        REFERENCES pessoa (id_pessoa, tipo_pessoa) ON UPDATE RESTRICT ON DELETE CASCADE,
    CONSTRAINT fk_operador_unidade FOREIGN KEY (id_unidade)
        REFERENCES unidade_seguranca (id_unidade) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE equipe (
    id_equipe INT UNSIGNED AUTO_INCREMENT,
    nome VARCHAR(80) NOT NULL,
    turno ENUM('MANHA','TARDE','NOITE') NOT NULL,
    especialidade VARCHAR(60),
    id_unidade INT UNSIGNED NOT NULL,
    ativa BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_equipe),
    CONSTRAINT uq_equipe_nome_unidade UNIQUE (nome, id_unidade),
    CONSTRAINT fk_equipe_unidade FOREIGN KEY (id_unidade)
        REFERENCES unidade_seguranca (id_unidade) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE veiculo (
    id_veiculo INT UNSIGNED AUTO_INCREMENT,
    prefixo VARCHAR(20) NOT NULL,
    placa CHAR(7) NOT NULL,
    tipo ENUM('VIATURA','MOTO','UTILITARIO') NOT NULL,
    modelo VARCHAR(60),
    ano SMALLINT UNSIGNED,
    status_veiculo ENUM('DISPONIVEL','EM_USO','MANUTENCAO') NOT NULL,
    id_unidade INT UNSIGNED,
    PRIMARY KEY (id_veiculo),
    CONSTRAINT uq_veiculo_prefixo UNIQUE (prefixo),
    CONSTRAINT uq_veiculo_placa UNIQUE (placa),
    CONSTRAINT ck_veiculo_placa CHECK (placa REGEXP '^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$'),
    CONSTRAINT ck_veiculo_ano CHECK (ano IS NULL OR ano BETWEEN 1980 AND 2100),
    CONSTRAINT fk_veiculo_unidade FOREIGN KEY (id_unidade)
        REFERENCES unidade_seguranca (id_unidade) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE equipe_agente (
    id_equipe INT UNSIGNED NOT NULL,
    id_agente INT UNSIGNED NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    funcao_na_equipe ENUM('COMANDO','APOIO','CONDUCAO') NOT NULL,
    PRIMARY KEY (id_equipe, id_agente, data_inicio),
    CONSTRAINT ck_equipe_agente_periodo CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT fk_ea_equipe FOREIGN KEY (id_equipe)
        REFERENCES equipe (id_equipe) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ea_agente FOREIGN KEY (id_agente)
        REFERENCES agente (id_pessoa) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categoria_ocorrencia (
    id_categoria SMALLINT UNSIGNED AUTO_INCREMENT,
    nome VARCHAR(80) NOT NULL,
    descricao VARCHAR(255),
    nivel_padrao ENUM('BAIXA','MEDIA','ALTA','CRITICA') NOT NULL,
    ativa BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nome UNIQUE (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ocorrencia (
    id_ocorrencia BIGINT UNSIGNED AUTO_INCREMENT,
    protocolo VARCHAR(24) NOT NULL,
    titulo VARCHAR(120) NOT NULL,
    descricao TEXT NOT NULL,
    canal_abertura ENUM('TELEFONE','APP','PRESENCIAL','RADIO') NOT NULL,
    prioridade ENUM('BAIXA','MEDIA','ALTA','CRITICA') NOT NULL,
    status_atual ENUM('ABERTA','EM_TRIAGEM','DESPACHADA','EM_ATENDIMENTO','ENCERRADA','CANCELADA') NOT NULL,
    data_abertura DATETIME NOT NULL,
    data_atualizacao DATETIME NOT NULL,
    id_categoria SMALLINT UNSIGNED NOT NULL,
    id_endereco INT UNSIGNED NOT NULL,
    id_operador INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_ocorrencia),
    CONSTRAINT uq_ocorrencia_protocolo UNIQUE (protocolo),
    CONSTRAINT ck_ocorrencia_datas CHECK (data_atualizacao >= data_abertura),
    CONSTRAINT fk_ocorrencia_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria_ocorrencia (id_categoria) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ocorrencia_endereco FOREIGN KEY (id_endereco)
        REFERENCES endereco (id_endereco) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ocorrencia_operador FOREIGN KEY (id_operador)
        REFERENCES operador (id_pessoa) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE envolvimento (
    id_ocorrencia BIGINT UNSIGNED NOT NULL,
    id_cidadao INT UNSIGNED NOT NULL,
    papel ENUM('COMUNICANTE','VITIMA','TESTEMUNHA','ENVOLVIDO') NOT NULL,
    relato TEXT,
    deseja_anonimato BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id_ocorrencia, id_cidadao, papel),
    CONSTRAINT fk_envolvimento_ocorrencia FOREIGN KEY (id_ocorrencia)
        REFERENCES ocorrencia (id_ocorrencia) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_envolvimento_cidadao FOREIGN KEY (id_cidadao)
        REFERENCES cidadao (id_pessoa) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE acionamento (
    id_acionamento BIGINT UNSIGNED AUTO_INCREMENT,
    id_ocorrencia BIGINT UNSIGNED NOT NULL,
    id_equipe INT UNSIGNED NOT NULL,
    id_veiculo INT UNSIGNED NOT NULL,
    data_despacho DATETIME NOT NULL,
    data_chegada DATETIME,
    data_liberacao DATETIME,
    resultado VARCHAR(255),
    status ENUM('DESPACHADO','NO_LOCAL','LIBERADO','CANCELADO') NOT NULL,
    PRIMARY KEY (id_acionamento),
    CONSTRAINT uq_acionamento UNIQUE (id_ocorrencia, id_equipe, id_veiculo, data_despacho),
    CONSTRAINT ck_acionamento_chegada CHECK (data_chegada IS NULL OR data_chegada >= data_despacho),
    CONSTRAINT ck_acionamento_liberacao CHECK (
        data_liberacao IS NULL OR (data_chegada IS NOT NULL AND data_liberacao >= data_chegada)
    ),
    CONSTRAINT fk_acionamento_ocorrencia FOREIGN KEY (id_ocorrencia)
        REFERENCES ocorrencia (id_ocorrencia) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_acionamento_equipe FOREIGN KEY (id_equipe)
        REFERENCES equipe (id_equipe) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_acionamento_veiculo FOREIGN KEY (id_veiculo)
        REFERENCES veiculo (id_veiculo) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE evidencia (
    id_ocorrencia BIGINT UNSIGNED NOT NULL,
    numero_evidencia SMALLINT UNSIGNED NOT NULL,
    tipo ENUM('FOTO','VIDEO','AUDIO','DOCUMENTO') NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    uri_arquivo VARCHAR(500),
    hash_sha256 CHAR(64),
    coletada_em DATETIME NOT NULL,
    id_agente_coleta INT UNSIGNED,
    PRIMARY KEY (id_ocorrencia, numero_evidencia),
    CONSTRAINT ck_evidencia_numero CHECK (numero_evidencia > 0),
    CONSTRAINT ck_evidencia_hash CHECK (hash_sha256 IS NULL OR hash_sha256 REGEXP '^[0-9A-Fa-f]{64}$'),
    CONSTRAINT fk_evidencia_ocorrencia FOREIGN KEY (id_ocorrencia)
        REFERENCES ocorrencia (id_ocorrencia) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_evidencia_agente FOREIGN KEY (id_agente_coleta)
        REFERENCES agente (id_pessoa) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE historico_status (
    id_ocorrencia BIGINT UNSIGNED NOT NULL,
    sequencia SMALLINT UNSIGNED NOT NULL,
    status_anterior ENUM('ABERTA','EM_TRIAGEM','DESPACHADA','EM_ATENDIMENTO','ENCERRADA','CANCELADA'),
    status_novo ENUM('ABERTA','EM_TRIAGEM','DESPACHADA','EM_ATENDIMENTO','ENCERRADA','CANCELADA') NOT NULL,
    alterado_em DATETIME NOT NULL,
    id_operador INT UNSIGNED,
    justificativa VARCHAR(255),
    PRIMARY KEY (id_ocorrencia, sequencia),
    CONSTRAINT ck_historico_sequencia CHECK (sequencia > 0),
    CONSTRAINT fk_historico_ocorrencia FOREIGN KEY (id_ocorrencia)
        REFERENCES ocorrencia (id_ocorrencia) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_historico_operador FOREIGN KEY (id_operador)
        REFERENCES operador (id_pessoa) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE encerramento_ocorrencia (
    id_ocorrencia BIGINT UNSIGNED NOT NULL,
    data_encerramento DATETIME NOT NULL,
    solucao_adotada TEXT NOT NULL,
    houve_encaminhamento BOOLEAN NOT NULL DEFAULT FALSE,
    orgao_encaminhado VARCHAR(120),
    id_agente_responsavel INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_ocorrencia),
    CONSTRAINT ck_encerramento_orgao CHECK (
        houve_encaminhamento = FALSE OR orgao_encaminhado IS NOT NULL
    ),
    CONSTRAINT fk_encerramento_ocorrencia FOREIGN KEY (id_ocorrencia)
        REFERENCES ocorrencia (id_ocorrencia) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_encerramento_agente FOREIGN KEY (id_agente_responsavel)
        REFERENCES agente (id_pessoa) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices associados as consultas entregues.
CREATE INDEX idx_ocorrencia_status_data ON ocorrencia (status_atual, data_abertura);
CREATE INDEX idx_ocorrencia_categoria_prioridade ON ocorrencia (id_categoria, prioridade);
CREATE INDEX idx_ocorrencia_endereco ON ocorrencia (id_endereco);
CREATE INDEX idx_acionamento_ocorrencia_status ON acionamento (id_ocorrencia, status);
CREATE INDEX idx_acionamento_equipe_data ON acionamento (id_equipe, data_despacho);
CREATE INDEX idx_historico_data ON historico_status (id_ocorrencia, alterado_em);
CREATE INDEX idx_veiculo_unidade_status ON veiculo (id_unidade, status_veiculo);

-- 2. POPULACAO DO BANCO

INSERT INTO unidade_seguranca (nome, tipo, telefone, email, ativo) VALUES
('Central Integrada de Operacoes', 'CENTRAL', '6133011000', 'central@sigo.gov.br', TRUE),
('Base Norte', 'BASE', '6133012000', 'norte@sigo.gov.br', TRUE),
('Posto Comunitario Sul', 'POSTO', '6133013000', 'sul@sigo.gov.br', TRUE);

INSERT INTO endereco (logradouro, numero, complemento, bairro, cidade, uf, cep, latitude, longitude) VALUES
('Avenida Central', '100', NULL, 'Centro', 'Brasilia', 'DF', '70040900', -15.793889, -47.882778),
('Rua das Flores', '25', 'Casa 2', 'Asa Norte', 'Brasilia', 'DF', '70710900', -15.760100, -47.882100),
('Quadra Comunitaria', '18', NULL, 'Ceilandia', 'Brasilia', 'DF', '72220180', -15.817100, -48.107700),
('Avenida Comercial', '450', 'Loja 12', 'Taguatinga', 'Brasilia', 'DF', '72010010', -15.833300, -48.056700),
('Via Publica', 'S/N', 'Proximo ao parque', 'Aguas Claras', 'Brasilia', 'DF', '71936900', -15.839800, -48.027700),
('Rua do Lago', '77', NULL, 'Lago Norte', 'Brasilia', 'DF', '71503900', -15.740000, -47.840000),
('Praca da Estacao', '5', NULL, 'Guara', 'Brasilia', 'DF', '71020000', -15.824000, -47.980000),
('Setor Residencial', '310', 'Bloco B', 'Samambaia', 'Brasilia', 'DF', '72310100', -15.878000, -48.085000);

INSERT INTO pessoa
    (primeiro_nome, sobrenome, cpf, data_nascimento, email, tipo_pessoa, id_endereco)
VALUES
('Ana', 'Souza Lima', '11111111111', '1994-03-12', 'ana.souza@email.com', 'CIDADAO', 2),
('Bruno', 'Alves Rocha', '22222222222', '1988-07-20', 'bruno.rocha@email.com', 'CIDADAO', 3),
('Carla', 'Mendes Silva', '33333333333', '2000-11-05', 'carla.mendes@email.com', 'CIDADAO', 4),
('Diego', 'Ferreira Santos', '44444444444', '1987-02-14', 'diego.ferreira@sigo.gov.br', 'AGENTE', 5),
('Elisa', 'Martins Costa', '55555555555', '1991-09-30', 'elisa.martins@sigo.gov.br', 'AGENTE', 6),
('Fabio', 'Nunes Pereira', '66666666666', '1985-05-22', 'fabio.nunes@sigo.gov.br', 'OPERADOR', 1),
('Gabriela', 'Oliveira Reis', '77777777777', '1993-08-17', 'gabriela.reis@sigo.gov.br', 'AGENTE', 7),
('Hugo', 'Barbosa Melo', '88888888888', '1989-12-09', 'hugo.melo@sigo.gov.br', 'OPERADOR', 1);

INSERT INTO pessoa_telefone (id_pessoa, telefone, tipo, principal) VALUES
(1, '61999990001', 'CELULAR', TRUE),
(1, '6133330001', 'FIXO', FALSE),
(2, '61999990002', 'CELULAR', TRUE),
(3, '61999990003', 'CELULAR', TRUE),
(4, '61988880004', 'CELULAR', TRUE),
(6, '6133011006', 'FIXO', TRUE);

INSERT INTO cidadao (id_pessoa, tipo_pessoa, aceita_contato, observacao) VALUES
(1, 'CIDADAO', TRUE, 'Prefere contato por telefone.'),
(2, 'CIDADAO', TRUE, NULL),
(3, 'CIDADAO', FALSE, 'Solicitou preservacao dos dados na exibicao.');

INSERT INTO agente
    (id_pessoa, tipo_pessoa, matricula, patente_cargo, data_admissao, id_unidade, ativo)
VALUES
(4, 'AGENTE', 'AGT-1001', 'Inspetor', '2018-01-15', 1, TRUE),
(5, 'AGENTE', 'AGT-1002', 'Agente', '2020-06-10', 2, TRUE),
(7, 'AGENTE', 'AGT-1003', 'Agente', '2021-02-08', 3, TRUE);

INSERT INTO operador
    (id_pessoa, tipo_pessoa, codigo_funcional, nivel_acesso, id_unidade, ativo)
VALUES
(6, 'OPERADOR', 'OP-2001', 'SUPERVISOR', 1, TRUE),
(8, 'OPERADOR', 'OP-2002', 'PLENO', 1, TRUE);

INSERT INTO equipe (nome, turno, especialidade, id_unidade, ativa) VALUES
('Alfa', 'MANHA', 'Patrulhamento comunitario', 1, TRUE),
('Bravo', 'TARDE', 'Atendimento rapido', 2, TRUE),
('Charlie', 'NOITE', 'Apoio operacional', 3, TRUE);

INSERT INTO equipe_agente (id_equipe, id_agente, data_inicio, data_fim, funcao_na_equipe) VALUES
(1, 4, '2026-01-01', NULL, 'COMANDO'),
(1, 5, '2026-01-01', NULL, 'CONDUCAO'),
(2, 5, '2026-03-01', NULL, 'COMANDO'),
(2, 7, '2026-03-01', NULL, 'APOIO'),
(3, 7, '2026-02-01', NULL, 'COMANDO');

INSERT INTO veiculo (prefixo, placa, tipo, modelo, ano, status_veiculo, id_unidade) VALUES
('VTR-01', 'ABC1D23', 'VIATURA', 'SUV Operacional', 2024, 'EM_USO', 1),
('VTR-02', 'DEF4G56', 'VIATURA', 'Sedan Operacional', 2023, 'DISPONIVEL', 2),
('MTO-01', 'GHI7J89', 'MOTO', 'Moto Patrulha', 2025, 'DISPONIVEL', 3),
('UTL-01', 'KLM0N12', 'UTILITARIO', 'Utilitario', 2022, 'MANUTENCAO', 1);

INSERT INTO categoria_ocorrencia (nome, descricao, nivel_padrao, ativa) VALUES
('Perturbacao do sossego', 'Ruido excessivo ou atividade que afete o sossego.', 'BAIXA', TRUE),
('Furto', 'Subtracao de bem sem violencia.', 'ALTA', TRUE),
('Acidente de transito', 'Sinistro viario com ou sem vitimas.', 'ALTA', TRUE),
('Apoio comunitario', 'Atendimento preventivo ou assistencial.', 'MEDIA', TRUE),
('Situacao suspeita', 'Atividade atipica que demande verificacao.', 'MEDIA', TRUE);

INSERT INTO ocorrencia
    (protocolo, titulo, descricao, canal_abertura, prioridade, status_atual,
     data_abertura, data_atualizacao, id_categoria, id_endereco, id_operador)
VALUES
('SIGO-2026-0001', 'Som alto durante a madrugada', 'Morador relata som excessivo em residencia proxima.', 'TELEFONE', 'BAIXA', 'ABERTA', '2026-09-15 18:10:00', '2026-09-15 18:10:00', 1, 3, 6),
('SIGO-2026-0002', 'Furto em estabelecimento', 'Comerciante informou desaparecimento de equipamentos.', 'PRESENCIAL', 'ALTA', 'EM_ATENDIMENTO', '2026-09-15 18:35:00', '2026-09-15 19:22:00', 2, 4, 8),
('SIGO-2026-0003', 'Colisao sem vitimas', 'Dois veiculos colidiram e bloqueiam parcialmente a via.', 'APP', 'MEDIA', 'DESPACHADA', '2026-09-15 20:00:00', '2026-09-15 20:08:00', 3, 5, 6),
('SIGO-2026-0004', 'Pessoa idosa desorientada', 'Cidadao solicita apoio para localizar familiares.', 'TELEFONE', 'MEDIA', 'ENCERRADA', '2026-09-14 15:00:00', '2026-09-14 16:25:00', 4, 7, 8),
('SIGO-2026-0005', 'Movimentacao suspeita', 'Veiculo desconhecido circulando repetidamente no bairro.', 'RADIO', 'ALTA', 'EM_TRIAGEM', '2026-09-15 21:10:00', '2026-09-15 21:15:00', 5, 8, 6);

INSERT INTO envolvimento (id_ocorrencia, id_cidadao, papel, relato, deseja_anonimato) VALUES
(1, 1, 'COMUNICANTE', 'Relatou ruido recorrente.', FALSE),
(2, 2, 'VITIMA', 'Responsavel pelo estabelecimento.', FALSE),
(3, 3, 'TESTEMUNHA', 'Presenciou a colisao.', TRUE),
(4, 1, 'COMUNICANTE', 'Encontrou a pessoa proxima a estacao.', FALSE),
(5, 3, 'COMUNICANTE', 'Prefere nao ser identificada publicamente.', TRUE);

INSERT INTO acionamento
    (id_ocorrencia, id_equipe, id_veiculo, data_despacho, data_chegada, data_liberacao, resultado, status)
VALUES
(2, 1, 1, '2026-09-15 18:45:00', '2026-09-15 19:02:00', NULL, 'Equipe realizando levantamento inicial.', 'NO_LOCAL'),
(4, 2, 2, '2026-09-14 15:12:00', '2026-09-14 15:26:00', '2026-09-14 16:20:00', 'Familia localizada e cidadao entregue em seguranca.', 'LIBERADO'),
(3, 3, 3, '2026-09-15 20:08:00', NULL, NULL, NULL, 'DESPACHADO');

INSERT INTO evidencia
    (id_ocorrencia, numero_evidencia, tipo, descricao, uri_arquivo, hash_sha256, coletada_em, id_agente_coleta)
VALUES
(2, 1, 'FOTO', 'Imagem da entrada do estabelecimento.', 's3://sigo/ocorrencias/2/evidencia-1.jpg', REPEAT('a', 64), '2026-09-15 19:10:00', 4),
(2, 2, 'VIDEO', 'Trecho disponibilizado pela camera de seguranca.', 's3://sigo/ocorrencias/2/evidencia-2.mp4', REPEAT('b', 64), '2026-09-15 19:15:00', 4),
(3, 1, 'FOTO', 'Posicao dos veiculos na via.', 's3://sigo/ocorrencias/3/evidencia-1.jpg', REPEAT('c', 64), '2026-09-15 20:30:00', 7);

INSERT INTO historico_status
    (id_ocorrencia, sequencia, status_anterior, status_novo, alterado_em, id_operador, justificativa)
VALUES
(1, 1, NULL, 'ABERTA', '2026-09-15 18:10:00', 6, 'Registro inicial.'),
(2, 1, NULL, 'ABERTA', '2026-09-15 18:35:00', 8, 'Registro inicial.'),
(2, 2, 'ABERTA', 'DESPACHADA', '2026-09-15 18:45:00', 8, 'Equipe Alfa acionada.'),
(2, 3, 'DESPACHADA', 'EM_ATENDIMENTO', '2026-09-15 19:02:00', 8, 'Equipe no local.'),
(3, 1, NULL, 'ABERTA', '2026-09-15 20:00:00', 6, 'Registro inicial.'),
(3, 2, 'ABERTA', 'DESPACHADA', '2026-09-15 20:08:00', 6, 'Equipe Charlie acionada.'),
(4, 1, NULL, 'ABERTA', '2026-09-14 15:00:00', 8, 'Registro inicial.'),
(4, 2, 'ABERTA', 'EM_ATENDIMENTO', '2026-09-14 15:26:00', 8, 'Equipe no local.'),
(4, 3, 'EM_ATENDIMENTO', 'ENCERRADA', '2026-09-14 16:25:00', 8, 'Atendimento concluido.'),
(5, 1, NULL, 'ABERTA', '2026-09-15 21:10:00', 6, 'Registro inicial.'),
(5, 2, 'ABERTA', 'EM_TRIAGEM', '2026-09-15 21:15:00', 6, 'Informacoes em verificacao.');

INSERT INTO encerramento_ocorrencia
    (id_ocorrencia, data_encerramento, solucao_adotada, houve_encaminhamento,
     orgao_encaminhado, id_agente_responsavel)
VALUES
(4, '2026-09-14 16:25:00', 'Familia localizada; pessoa entregue aos responsaveis.', FALSE, NULL, 5);

-- 3. VIEW E CONSULTAS SELECT (Q1 A Q12)

CREATE OR REPLACE VIEW vw_fila_ocorrencias AS
SELECT o.id_ocorrencia, o.protocolo, o.titulo, c.nome AS categoria,
       o.prioridade, o.status_atual, o.data_abertura,
       e.bairro, e.cidade, e.uf
FROM ocorrencia o
JOIN categoria_ocorrencia c ON c.id_categoria = o.id_categoria
JOIN endereco e ON e.id_endereco = o.id_endereco
WHERE o.status_atual NOT IN ('ENCERRADA', 'CANCELADA');

-- Q1 - fila operacional por prioridade e antiguidade.
SELECT * FROM vw_fila_ocorrencias
ORDER BY FIELD(prioridade, 'CRITICA','ALTA','MEDIA','BAIXA'), data_abertura;

-- Q2 - volume por categoria e prioridade.
SELECT c.nome AS categoria, o.prioridade, COUNT(*) AS total
FROM ocorrencia o
JOIN categoria_ocorrencia c ON c.id_categoria = o.id_categoria
GROUP BY c.id_categoria, c.nome, o.prioridade
ORDER BY c.nome, total DESC;

-- Q3 - composicao atual das equipes.
SELECT e.nome AS equipe, e.turno, CONCAT(p.primeiro_nome, ' ', p.sobrenome) AS agente,
       ea.funcao_na_equipe, u.nome AS unidade
FROM equipe_agente ea
JOIN equipe e ON e.id_equipe = ea.id_equipe
JOIN agente a ON a.id_pessoa = ea.id_agente
JOIN pessoa p ON p.id_pessoa = a.id_pessoa
JOIN unidade_seguranca u ON u.id_unidade = e.id_unidade
WHERE ea.data_inicio <= CURRENT_DATE
  AND (ea.data_fim IS NULL OR ea.data_fim >= CURRENT_DATE)
ORDER BY e.nome, ea.funcao_na_equipe;

-- Q4 - tempo de deslocamento de cada acionamento concluido.
SELECT a.id_acionamento, o.protocolo, e.nome AS equipe,
       TIMESTAMPDIFF(MINUTE, a.data_despacho, a.data_chegada) AS minutos_deslocamento
FROM acionamento a
JOIN ocorrencia o ON o.id_ocorrencia = a.id_ocorrencia
JOIN equipe e ON e.id_equipe = a.id_equipe
WHERE a.data_chegada IS NOT NULL
ORDER BY minutos_deslocamento;

-- Q5 - media de deslocamento por equipe.
SELECT e.nome AS equipe,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, a.data_despacho, a.data_chegada)), 2) AS media_minutos
FROM acionamento a
JOIN equipe e ON e.id_equipe = a.id_equipe
WHERE a.data_chegada IS NOT NULL
GROUP BY e.id_equipe, e.nome;

-- Q6 - envolvidos com protecao do anonimato.
SELECT o.protocolo, en.papel,
       CASE WHEN en.deseja_anonimato THEN 'IDENTIDADE PRESERVADA'
            ELSE CONCAT(p.primeiro_nome, ' ', p.sobrenome) END AS pessoa_exibida,
       en.relato
FROM envolvimento en
JOIN ocorrencia o ON o.id_ocorrencia = en.id_ocorrencia
JOIN pessoa p ON p.id_pessoa = en.id_cidadao
ORDER BY o.id_ocorrencia, en.papel;

-- Q7 - ocorrencias com mais de uma evidencia.
SELECT o.protocolo, o.titulo, COUNT(*) AS total_evidencias
FROM evidencia ev
JOIN ocorrencia o ON o.id_ocorrencia = ev.id_ocorrencia
GROUP BY o.id_ocorrencia, o.protocolo, o.titulo
HAVING COUNT(*) > 1;

-- Q8 - veiculos disponiveis nas unidades das equipes ativas.
SELECT v.prefixo, v.placa, v.tipo, u.nome AS unidade
FROM veiculo v
JOIN unidade_seguranca u ON u.id_unidade = v.id_unidade
WHERE v.status_veiculo = 'DISPONIVEL'
  AND v.id_unidade IN (SELECT DISTINCT id_unidade FROM equipe WHERE ativa = TRUE)
ORDER BY u.nome, v.prefixo;

-- Q9 - linha do tempo de uma ocorrencia (exemplo: id 4).
SELECT h.sequencia, h.status_anterior, h.status_novo, h.alterado_em,
       CONCAT(p.primeiro_nome, ' ', p.sobrenome) AS operador, h.justificativa
FROM historico_status h
LEFT JOIN pessoa p ON p.id_pessoa = h.id_operador
WHERE h.id_ocorrencia = 4
ORDER BY h.sequencia;

-- Q10 - ranking territorial de ocorrencias.
SELECT e.bairro, COUNT(*) AS total_ocorrencias
FROM ocorrencia o
JOIN endereco e ON e.id_endereco = o.id_endereco
GROUP BY e.bairro
ORDER BY total_ocorrencias DESC, e.bairro;

-- Q11 - ocorrencias ainda sem despacho.
SELECT o.protocolo, o.titulo, o.prioridade, o.status_atual
FROM ocorrencia o
LEFT JOIN acionamento a ON a.id_ocorrencia = o.id_ocorrencia
WHERE a.id_acionamento IS NULL
  AND o.status_atual NOT IN ('ENCERRADA','CANCELADA')
ORDER BY o.data_abertura;

-- Q12 - taxa de encerramento por categoria.
SELECT c.nome AS categoria, COUNT(*) AS total,
       SUM(o.status_atual = 'ENCERRADA') AS encerradas,
       ROUND(100 * SUM(o.status_atual = 'ENCERRADA') / COUNT(*), 2) AS taxa_encerramento_pct
FROM categoria_ocorrencia c
JOIN ocorrencia o ON o.id_categoria = c.id_categoria
GROUP BY c.id_categoria, c.nome
ORDER BY taxa_encerramento_pct DESC;

-- 4. UPDATES E TRANSACOES (U1 A U4)
-- Executados com ROLLBACK para demonstracao sem alterar a massa final.
-- Em uma operacao real validada, a aplicacao confirmaria a transacao com COMMIT.

-- U1 - chegada da equipe, mudanca de status e historico atomicos.
START TRANSACTION;
UPDATE acionamento
SET data_chegada = '2026-09-15 20:28:00', status = 'NO_LOCAL'
WHERE id_acionamento = 3 AND status = 'DESPACHADO';
UPDATE ocorrencia
SET status_atual = 'EM_ATENDIMENTO', data_atualizacao = '2026-09-15 20:28:00'
WHERE id_ocorrencia = 3 AND status_atual = 'DESPACHADA';
INSERT INTO historico_status
    (id_ocorrencia, sequencia, status_anterior, status_novo, alterado_em, id_operador, justificativa)
VALUES
    (3, 3, 'DESPACHADA', 'EM_ATENDIMENTO', '2026-09-15 20:28:00', 6, 'Equipe chegou ao local.');
ROLLBACK;

-- U2 - retorno de veiculo apos manutencao.
START TRANSACTION;
UPDATE veiculo SET status_veiculo = 'DISPONIVEL'
WHERE prefixo = 'UTL-01' AND status_veiculo = 'MANUTENCAO';
ROLLBACK;

-- U3 - atualizacao de preferencia de contato.
START TRANSACTION;
UPDATE cidadao SET aceita_contato = TRUE, observacao = 'Contato autorizado por telefone.'
WHERE id_pessoa = 3 AND tipo_pessoa = 'CIDADAO';
ROLLBACK;

-- U4 - correcao de prioridade de acidentes sem vitimas.
START TRANSACTION;
UPDATE ocorrencia
SET prioridade = 'MEDIA', data_atualizacao = GREATEST(data_atualizacao, '2026-09-15 20:09:00')
WHERE id_categoria = 3 AND descricao LIKE '%sem vitimas%' AND prioridade = 'ALTA';
ROLLBACK;

-- 5. TESTE T11 - EXCLUSIVIDADE DA ESPECIALIZACAO (RN03)

-- A pessoa 4 possui tipo_pessoa = 'AGENTE'. A tentativa abaixo deve falhar
-- pela FK composta, pois nao existe pessoa (4, 'OPERADOR').
-- Descomente apenas para executar o teste negativo:
-- INSERT INTO operador
--   (id_pessoa, tipo_pessoa, codigo_funcional, nivel_acesso, id_unidade, ativo)
-- VALUES
--   (4, 'OPERADOR', 'OP-TESTE-RN03', 'BASICO', 1, TRUE);

-- Totais esperados apos a carga.
SELECT 'unidade_seguranca' AS tabela, COUNT(*) AS total FROM unidade_seguranca
UNION ALL SELECT 'endereco', COUNT(*) FROM endereco
UNION ALL SELECT 'pessoa', COUNT(*) FROM pessoa
UNION ALL SELECT 'pessoa_telefone', COUNT(*) FROM pessoa_telefone
UNION ALL SELECT 'cidadao', COUNT(*) FROM cidadao
UNION ALL SELECT 'agente', COUNT(*) FROM agente
UNION ALL SELECT 'operador', COUNT(*) FROM operador
UNION ALL SELECT 'equipe', COUNT(*) FROM equipe
UNION ALL SELECT 'equipe_agente', COUNT(*) FROM equipe_agente
UNION ALL SELECT 'veiculo', COUNT(*) FROM veiculo
UNION ALL SELECT 'categoria_ocorrencia', COUNT(*) FROM categoria_ocorrencia
UNION ALL SELECT 'ocorrencia', COUNT(*) FROM ocorrencia
UNION ALL SELECT 'envolvimento', COUNT(*) FROM envolvimento
UNION ALL SELECT 'acionamento', COUNT(*) FROM acionamento
UNION ALL SELECT 'evidencia', COUNT(*) FROM evidencia
UNION ALL SELECT 'historico_status', COUNT(*) FROM historico_status
UNION ALL SELECT 'encerramento_ocorrencia', COUNT(*) FROM encerramento_ocorrencia;
