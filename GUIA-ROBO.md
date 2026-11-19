# TRANSPORTADORA CASAGRANDE — banco, código e regras

Este é o repositório do app **TRANSPORTADORA CASAGRANDE**, um dos três apps do grupo Casagrande.
Ele é **independente**: tem o seu banco, o seu código e o seu robô. Não compartilha
nada com os outros dois.

> **Leia inteiro antes de mexer em qualquer linha.**

---

## 1. O que é este app

| | |
|---|---|
| Nome | **TRANSPORTADORA CASAGRANDE** |
| URL | `https://ovoscasagrande.github.io/transportadora-casagrande-app/` |
| Repositório | `Ovoscasagrande/transportadora-casagrande-app` |
| Banco | projeto Supabase **próprio** (transportadora-casagrande) |
| Cor de destaque | `#1E5AA8` |

## 2. O banco é SEU e só seu

Diferente do app antigo (que juntava as três empresas no mesmo banco e filtrava
pelo JavaScript), aqui:

- **Cada banco tem o schema completo desta empresa.**
- **Não existe coluna `empresa`** — não precisa: todo registro deste banco é desta empresa.
- **Não existe `empFilter`, nem `window.APP`, nem troca de empresa.**
- **Nenhuma consulta cruza com outro app.**

O único sistema que olha os três bancos é o **robô de análises**, e só **lê**.

### Criar o banco
1. Crie um projeto no Supabase (região `sa-east-1` São Paulo).
2. Abra **SQL Editor** e cole o conteúdo de `sql/schema.sql` deste repositório.
3. Rode. É idempotente: pode rodar mais de uma vez.
4. Em **Settings → API**, copie `Project URL` e `anon public key`.
5. Cole os dois no topo do `index.html` (constantes `SUPABASE_URL` e `SUPABASE_ANON_KEY`).

## 3. Regras de desenvolvimento

### PODE
- Melhorar telas, layout, textos, atalhos, relatórios, filtros
- Criar telas novas desta empresa
- Corrigir bugs
- **Ter as suas próprias ideias.** O dono quer diversidade entre os três apps — não copie o caminho dos outros.

### NÃO PODE
| Proibido | Por quê |
|---|---|
| Renomear ou remover `id="..."` | O JS busca por `getElementById`; quebrar um derruba a tela |
| Renomear tabela, coluna ou RPC | O app e as automações dependem dos nomes |
| Usar `alert()` / `confirm()` / `prompt()` | O dono proíbe. Use `toast()` e o modal `#modal-wrap` |
| Colocar emoji dentro de `doc.text()` ou `toast()` | jsPDF vira ■ e toast é texto puro |
| Trocar os CDNs | Só os existentes (supabase-js v2, Chart.js 4, pdf.js 3.11.174, jsPDF 2.5.1, Lucide, Inter, Leaflet) |
| Mexer no `sw.js` sem subir a versão do cache | O celular continua com a versão velha |
| Rodar SQL por conta própria | Peça ao **CASA**, que avalia o impacto e roda |

### Regras de produto (não negociáveis)
- **Datas em DD-MM-AAAA** (ou DD/MM/AAAA).
- **Valores em pt-BR com vírgula decimal.** Use `parseBR()`; **nunca** `parseFloat` em campo digitado.
  Atenção: `21.500` = vinte e um mil e quinhentos.
- **KM inicial** vem de `veiculos.km_atual` e é `readonly`.
- **Alvos de toque ≥ 48 px** — o app é usado em caminhão e galpão.
- **Tema escuro** (fundo `#121212`, card `#1E1E1E`, campo `#262626`, texto `#f5f5f5`).

## 4. Perfis deste app

`gerencia` · `motorista` · `conferente` · `mecanico` · `pendente`

## 5. Tabelas deste banco

- `usuarios`
- `motoristas`
- `veiculos`
- `motorista_veiculo`
- `veiculos_documentos`
- `postos`
- `jornadas`
- `jornada_carregamentos`
- `jornada_conferencia`
- `abastecimentos`
- `despesas`
- `avisos`
- `ordens_servico`
- `trocas_oleo`
- `tipos_despesa`
- `tipos_recebimento`
- `auditoria`
- `notificacoes`
- `convites`
- `produtos`

## 6. Antes de publicar

1. `node validar_integracao.js NOVO.html ORIGINAL.html` → tem de terminar em **APROVADO**
2. Testar em **390 px** de largura (celular)
3. Testar logado como **gerência** e como **motorista**
4. Subir a versão do cache no `sw.js`

## 7. Sobre o motorista de 2 empresas

Quem trabalha na TRANSPORTADORA **e** em outra empresa tem uma conta em cada app.
O login é o **mesmo e-mail e a mesma senha** nos dois — o cadastro é criado
uma vez em cada banco, mas a pessoa não decora senha nova.

---

## Dúvida? Pergunte antes de inventar.

Uma linha errada derruba a tela de um motorista em produção.
Perguntar custa 2 minutos; errar custa um dia de operação parada.
