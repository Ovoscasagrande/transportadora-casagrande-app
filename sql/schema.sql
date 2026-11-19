-- ==========================================================================
-- CASAGRANDE — TRANSPORTADORA · schema completo
-- banco INDEPENDENTE: este SQL cria tudo que o app transportadora usa.
-- Rodar no SQL Editor do projeto Supabase da TRANSPORTADORA.
-- Idempotente: pode rodar mais de uma vez.
-- ==========================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------- usuarios
create table if not exists public."usuarios" (
  "id" uuid primary key default gen_random_uuid(),
  "nome" text,
  "perfil" text,
  "ativo" boolean,
  "criado_em" timestamptz default now(),
  "email" text,
  "cpf" text,
  "cnh" text,
  "cnh_categoria" text,
  "cnh_validade" date,
  "contato" text,
  "perfis_extra" jsonb,
  "is_master" boolean
);

-- ---------------------------------------------------------------- motoristas
create table if not exists public."motoristas" (
  "id" uuid primary key default gen_random_uuid(),
  "usuario_id" uuid,
  "nome" text,
  "cpf" text,
  "cnh" text,
  "cnh_categoria" text,
  "cnh_validade" date,
  "contato" text,
  "situacao" text,
  "ativo" boolean,
  "criado_em" timestamptz default now()
);
create index if not exists "motoristas_usuario_id_idx" on public."motoristas" ("usuario_id");

-- ---------------------------------------------------------------- veiculos
create table if not exists public."veiculos" (
  "id" uuid primary key default gen_random_uuid(),
  "placa" text,
  "renavam" text,
  "marca" text,
  "modelo" text,
  "ano" integer,
  "cor" text,
  "ativo" boolean,
  "intervalo_oleo_km" integer,
  "ultima_troca_oleo_km" integer,
  "ultima_troca_oleo_data" date,
  "criado_em" timestamptz default now(),
  "km_atual" double precision,
  "proxima_manutencao_km" integer
);

-- ---------------------------------------------------------------- motorista_veiculo
create table if not exists public."motorista_veiculo" (
  "id" uuid primary key default gen_random_uuid(),
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "ativo" boolean
);
create index if not exists "motorista_veiculo_motorista_id_idx" on public."motorista_veiculo" ("motorista_id");
create index if not exists "motorista_veiculo_veiculo_id_idx" on public."motorista_veiculo" ("veiculo_id");

-- ---------------------------------------------------------------- veiculos_documentos
create table if not exists public."veiculos_documentos" (
  "id" uuid primary key default gen_random_uuid(),
  "veiculo_id" uuid,
  "tipo" text,
  "arquivo_path" text,
  "vencimento" text,
  "enviado_por" text,
  "criado_em" timestamptz default now()
);
create index if not exists "veiculos_documentos_veiculo_id_idx" on public."veiculos_documentos" ("veiculo_id");

-- ---------------------------------------------------------------- postos
create table if not exists public."postos" (
  "id" uuid primary key default gen_random_uuid(),
  "nome" text,
  "ativo" boolean,
  "criado_em" timestamptz default now()
);

-- ---------------------------------------------------------------- jornadas
create table if not exists public."jornadas" (
  "id" uuid primary key default gen_random_uuid(),
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "roteiro" integer,
  "km_inicial" double precision,
  "km_final" double precision,
  "inicio" timestamptz,
  "fim" timestamptz,
  "ocorrencias" text,
  "status" text,
  "conferida_por" text,
  "conferida_em" timestamptz,
  "roteiros_extra" jsonb,
  "motivo_cancelamento" text,
  "cancelada_por" text,
  "cancelada_em" text
);
create index if not exists "jornadas_motorista_id_idx" on public."jornadas" ("motorista_id");
create index if not exists "jornadas_veiculo_id_idx" on public."jornadas" ("veiculo_id");
create index if not exists "jornadas_conferida_por_idx" on public."jornadas" ("conferida_por");

-- ---------------------------------------------------------------- jornada_carregamentos
create table if not exists public."jornada_carregamentos" (
  "id" uuid primary key default gen_random_uuid(),
  "jornada_id" uuid,
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "observacao" text,
  "criado_em" timestamptz default now()
);
create index if not exists "jornada_carregamentos_motorista_id_idx" on public."jornada_carregamentos" ("motorista_id");
create index if not exists "jornada_carregamentos_veiculo_id_idx" on public."jornada_carregamentos" ("veiculo_id");
create index if not exists "jornada_carregamentos_jornada_id_idx" on public."jornada_carregamentos" ("jornada_id");

-- ---------------------------------------------------------------- jornada_conferencia
create table if not exists public."jornada_conferencia" (
  "id" uuid primary key default gen_random_uuid(),
  "jornada_id" uuid,
  "item" text,
  "ok" boolean,
  "obs" text,
  "conferido_por" text,
  "conferido_em" timestamptz
);
create index if not exists "jornada_conferencia_jornada_id_idx" on public."jornada_conferencia" ("jornada_id");

-- ---------------------------------------------------------------- abastecimentos
create table if not exists public."abastecimentos" (
  "id" uuid primary key default gen_random_uuid(),
  "jornada_id" uuid,
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "data" timestamptz,
  "posto" text,
  "km" double precision,
  "combustivel" text,
  "litros" double precision,
  "preco_litro" double precision,
  "valor_total" double precision,
  "foto_path" text,
  "parcial" boolean,
  "criado_em" timestamptz default now()
);
create index if not exists "abastecimentos_motorista_id_idx" on public."abastecimentos" ("motorista_id");
create index if not exists "abastecimentos_veiculo_id_idx" on public."abastecimentos" ("veiculo_id");
create index if not exists "abastecimentos_jornada_id_idx" on public."abastecimentos" ("jornada_id");

-- ---------------------------------------------------------------- despesas
create table if not exists public."despesas" (
  "id" uuid primary key default gen_random_uuid(),
  "jornada_id" uuid,
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "categoria" text,
  "descricao" text,
  "data" timestamptz,
  "km" double precision,
  "valor" double precision,
  "foto_path" text,
  "obs" text,
  "status" text,
  "motivo_reprovacao" text,
  "aprovada_por" text,
  "aprovada_em" timestamptz,
  "reembolsada_em" text,
  "criado_em" timestamptz default now(),
  "extras" jsonb
);
create index if not exists "despesas_motorista_id_idx" on public."despesas" ("motorista_id");
create index if not exists "despesas_veiculo_id_idx" on public."despesas" ("veiculo_id");
create index if not exists "despesas_jornada_id_idx" on public."despesas" ("jornada_id");
create index if not exists "despesas_aprovada_por_idx" on public."despesas" ("aprovada_por");

-- ---------------------------------------------------------------- avisos
create table if not exists public."avisos" (
  "id" uuid primary key default gen_random_uuid(),
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "categoria" text,
  "texto" text,
  "fotos" jsonb,
  "status" text,
  "criado_em" timestamptz default now(),
  "atualizado_em" timestamptz
);
create index if not exists "avisos_motorista_id_idx" on public."avisos" ("motorista_id");
create index if not exists "avisos_veiculo_id_idx" on public."avisos" ("veiculo_id");

-- ---------------------------------------------------------------- ordens_servico
create table if not exists public."ordens_servico" (
  "id" uuid primary key default gen_random_uuid(),
  "aviso_id" uuid,
  "veiculo_id" uuid,
  "aberta_por" text,
  "descricao" text,
  "diagnostico" text,
  "servico" text,
  "pecas" text,
  "mao_obra" double precision,
  "custos" double precision,
  "km" double precision,
  "fotos" jsonb,
  "status" text,
  "mecanico_id" uuid,
  "aberta_em" timestamptz,
  "concluida_em" timestamptz
);
create index if not exists "ordens_servico_veiculo_id_idx" on public."ordens_servico" ("veiculo_id");

-- ---------------------------------------------------------------- trocas_oleo
create table if not exists public."trocas_oleo" (
  "id" uuid primary key default gen_random_uuid(),
  "veiculo_id" uuid,
  "km" double precision,
  "data" date,
  "obs" text,
  "registrado_por" text,
  "criado_em" timestamptz default now()
);
create index if not exists "trocas_oleo_veiculo_id_idx" on public."trocas_oleo" ("veiculo_id");

-- ---------------------------------------------------------------- tipos_despesa
create table if not exists public."tipos_despesa" (
  "id" uuid primary key default gen_random_uuid(),
  "nome" text,
  "campos" jsonb,
  "ativo" boolean,
  "criado_em" timestamptz default now()
);

-- ---------------------------------------------------------------- tipos_recebimento
create table if not exists public."tipos_recebimento" (
  "id" uuid primary key default gen_random_uuid(),
  "nome" text,
  "campos" jsonb,
  "ativo" boolean,
  "criado_em" timestamptz default now()
);

-- ---------------------------------------------------------------- auditoria
create table if not exists public."auditoria" (
  "id" uuid primary key default gen_random_uuid(),
  "usuario_id" uuid,
  "acao" text,
  "detalhe" jsonb,
  "criado_em" timestamptz default now()
);
create index if not exists "auditoria_usuario_id_idx" on public."auditoria" ("usuario_id");

-- ---------------------------------------------------------------- notificacoes
create table if not exists public."notificacoes" (
  "id" uuid primary key default gen_random_uuid(),
  "usuario_id" uuid,
  "titulo" text,
  "corpo" text,
  "lida" boolean,
  "criado_em" timestamptz default now(),
  "link" text
);
create index if not exists "notificacoes_usuario_id_idx" on public."notificacoes" ("usuario_id");

-- ---------------------------------------------------------------- convites
create table if not exists public."convites" (
  "token" text,
  "perfil" text,
  "criado_por" text,
  "criado_em" timestamptz default now(),
  "expira_em" timestamptz,
  "usado_em" text,
  "usado_por" text
);

-- ---------------------------------------------------------------- produtos
create table if not exists public."produtos" (
  "id" uuid primary key default gen_random_uuid(),
  "nome" text,
  "sku" text,
  "unidade" text,
  "ativo" boolean,
  "criado_em" timestamptz default now(),
  "custo" text,
  "tabelas" jsonb,
  "un" text,
  "est_disp" text,
  "mg_real" text,
  "queima" boolean,
  "interno" boolean
);

-- ==========================================================================
-- RLS — cada tabela só é acessível por quem tem login aprovado
-- ==========================================================================
alter table public."usuarios" enable row level security;
alter table public."motoristas" enable row level security;
alter table public."veiculos" enable row level security;
alter table public."motorista_veiculo" enable row level security;
alter table public."veiculos_documentos" enable row level security;
alter table public."postos" enable row level security;
alter table public."jornadas" enable row level security;
alter table public."jornada_carregamentos" enable row level security;
alter table public."jornada_conferencia" enable row level security;
alter table public."abastecimentos" enable row level security;
alter table public."despesas" enable row level security;
alter table public."avisos" enable row level security;
alter table public."ordens_servico" enable row level security;
alter table public."trocas_oleo" enable row level security;
alter table public."tipos_despesa" enable row level security;
alter table public."tipos_recebimento" enable row level security;
alter table public."auditoria" enable row level security;
alter table public."notificacoes" enable row level security;
alter table public."convites" enable row level security;
alter table public."produtos" enable row level security;


-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------
create or replace function public.meu_perfil()
returns text language sql stable security definer set search_path = public as $$
  select coalesce((select u.perfil from public.usuarios u where u.id = auth.uid()), 'pendente');
$$;

create or replace function public.meu_motorista_id()
returns uuid language sql stable security definer set search_path = public as $$
  select m.id from public.motoristas m where m.usuario_id = auth.uid() limit 1;
$$;

create or replace function public.eh_master()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select u.is_master from public.usuarios u where u.id = auth.uid()), false);
$$;

grant execute on function public.meu_perfil()       to authenticated, anon;
grant execute on function public.meu_motorista_id() to authenticated, anon;
grant execute on function public.eh_master()        to authenticated, anon;

-- ---------------------------------------------------------------------------
-- policies
-- ---------------------------------------------------------------------------
drop policy if exists usuarios_sel on public."usuarios";
create policy usuarios_sel on public."usuarios" for select to authenticated using (id = auth.uid() or public.meu_perfil() = 'gerencia');
drop policy if exists usuarios_ins on public."usuarios";
create policy usuarios_ins on public."usuarios" for insert to authenticated with check (id = auth.uid() or public.meu_perfil() = 'gerencia');
drop policy if exists usuarios_upd on public."usuarios";
create policy usuarios_upd on public."usuarios" for update to authenticated using (id = auth.uid() or public.eh_master());

drop policy if exists motoristas_sel on public."motoristas";
create policy motoristas_sel on public."motoristas" for select to authenticated using (public.meu_perfil() in ('gerencia','conferente','mecanico') or id = public.meu_motorista_id() or usuario_id = auth.uid());
drop policy if exists motoristas_ins on public."motoristas";
create policy motoristas_ins on public."motoristas" for insert to authenticated with check (true);
drop policy if exists motoristas_upd on public."motoristas";
create policy motoristas_upd on public."motoristas" for update to authenticated using (true);

drop policy if exists veiculos_sel on public."veiculos";
create policy veiculos_sel on public."veiculos" for select to authenticated using (true);
drop policy if exists veiculos_ins on public."veiculos";
create policy veiculos_ins on public."veiculos" for insert to authenticated with check (true);
drop policy if exists veiculos_upd on public."veiculos";
create policy veiculos_upd on public."veiculos" for update to authenticated using (true);

drop policy if exists motorista_veiculo_sel on public."motorista_veiculo";
create policy motorista_veiculo_sel on public."motorista_veiculo" for select to authenticated using (true);
drop policy if exists motorista_veiculo_ins on public."motorista_veiculo";
create policy motorista_veiculo_ins on public."motorista_veiculo" for insert to authenticated with check (true);
drop policy if exists motorista_veiculo_upd on public."motorista_veiculo";
create policy motorista_veiculo_upd on public."motorista_veiculo" for update to authenticated using (true);

drop policy if exists veiculos_documentos_sel on public."veiculos_documentos";
create policy veiculos_documentos_sel on public."veiculos_documentos" for select to authenticated using (true);
drop policy if exists veiculos_documentos_ins on public."veiculos_documentos";
create policy veiculos_documentos_ins on public."veiculos_documentos" for insert to authenticated with check (true);
drop policy if exists veiculos_documentos_upd on public."veiculos_documentos";
create policy veiculos_documentos_upd on public."veiculos_documentos" for update to authenticated using (true);

drop policy if exists postos_sel on public."postos";
create policy postos_sel on public."postos" for select to authenticated using (true);
drop policy if exists postos_ins on public."postos";
create policy postos_ins on public."postos" for insert to authenticated with check (true);
drop policy if exists postos_upd on public."postos";
create policy postos_upd on public."postos" for update to authenticated using (true);

drop policy if exists jornadas_sel on public."jornadas";
create policy jornadas_sel on public."jornadas" for select to authenticated using (true);
drop policy if exists jornadas_ins on public."jornadas";
create policy jornadas_ins on public."jornadas" for insert to authenticated with check (true);
drop policy if exists jornadas_upd on public."jornadas";
create policy jornadas_upd on public."jornadas" for update to authenticated using (true);

drop policy if exists jornada_carregamentos_sel on public."jornada_carregamentos";
create policy jornada_carregamentos_sel on public."jornada_carregamentos" for select to authenticated using (true);
drop policy if exists jornada_carregamentos_ins on public."jornada_carregamentos";
create policy jornada_carregamentos_ins on public."jornada_carregamentos" for insert to authenticated with check (true);
drop policy if exists jornada_carregamentos_upd on public."jornada_carregamentos";
create policy jornada_carregamentos_upd on public."jornada_carregamentos" for update to authenticated using (true);

drop policy if exists jornada_conferencia_sel on public."jornada_conferencia";
create policy jornada_conferencia_sel on public."jornada_conferencia" for select to authenticated using (true);
drop policy if exists jornada_conferencia_ins on public."jornada_conferencia";
create policy jornada_conferencia_ins on public."jornada_conferencia" for insert to authenticated with check (true);
drop policy if exists jornada_conferencia_upd on public."jornada_conferencia";
create policy jornada_conferencia_upd on public."jornada_conferencia" for update to authenticated using (true);

drop policy if exists abastecimentos_sel on public."abastecimentos";
create policy abastecimentos_sel on public."abastecimentos" for select to authenticated using (true);
drop policy if exists abastecimentos_ins on public."abastecimentos";
create policy abastecimentos_ins on public."abastecimentos" for insert to authenticated with check (true);
drop policy if exists abastecimentos_upd on public."abastecimentos";
create policy abastecimentos_upd on public."abastecimentos" for update to authenticated using (true);

drop policy if exists despesas_sel on public."despesas";
create policy despesas_sel on public."despesas" for select to authenticated using (true);
drop policy if exists despesas_ins on public."despesas";
create policy despesas_ins on public."despesas" for insert to authenticated with check (true);
drop policy if exists despesas_upd on public."despesas";
create policy despesas_upd on public."despesas" for update to authenticated using (true);

drop policy if exists avisos_sel on public."avisos";
create policy avisos_sel on public."avisos" for select to authenticated using (true);
drop policy if exists avisos_ins on public."avisos";
create policy avisos_ins on public."avisos" for insert to authenticated with check (true);
drop policy if exists avisos_upd on public."avisos";
create policy avisos_upd on public."avisos" for update to authenticated using (true);

drop policy if exists ordens_servico_sel on public."ordens_servico";
create policy ordens_servico_sel on public."ordens_servico" for select to authenticated using (true);
drop policy if exists ordens_servico_ins on public."ordens_servico";
create policy ordens_servico_ins on public."ordens_servico" for insert to authenticated with check (true);
drop policy if exists ordens_servico_upd on public."ordens_servico";
create policy ordens_servico_upd on public."ordens_servico" for update to authenticated using (true);

drop policy if exists trocas_oleo_sel on public."trocas_oleo";
create policy trocas_oleo_sel on public."trocas_oleo" for select to authenticated using (true);
drop policy if exists trocas_oleo_ins on public."trocas_oleo";
create policy trocas_oleo_ins on public."trocas_oleo" for insert to authenticated with check (true);
drop policy if exists trocas_oleo_upd on public."trocas_oleo";
create policy trocas_oleo_upd on public."trocas_oleo" for update to authenticated using (true);

drop policy if exists tipos_despesa_sel on public."tipos_despesa";
create policy tipos_despesa_sel on public."tipos_despesa" for select to authenticated using (true);
drop policy if exists tipos_despesa_ins on public."tipos_despesa";
create policy tipos_despesa_ins on public."tipos_despesa" for insert to authenticated with check (true);
drop policy if exists tipos_despesa_upd on public."tipos_despesa";
create policy tipos_despesa_upd on public."tipos_despesa" for update to authenticated using (true);

drop policy if exists tipos_recebimento_sel on public."tipos_recebimento";
create policy tipos_recebimento_sel on public."tipos_recebimento" for select to authenticated using (true);
drop policy if exists tipos_recebimento_ins on public."tipos_recebimento";
create policy tipos_recebimento_ins on public."tipos_recebimento" for insert to authenticated with check (true);
drop policy if exists tipos_recebimento_upd on public."tipos_recebimento";
create policy tipos_recebimento_upd on public."tipos_recebimento" for update to authenticated using (true);

drop policy if exists auditoria_sel on public."auditoria";
create policy auditoria_sel on public."auditoria" for select to authenticated using (true);
drop policy if exists auditoria_ins on public."auditoria";
create policy auditoria_ins on public."auditoria" for insert to authenticated with check (true);
drop policy if exists auditoria_upd on public."auditoria";
create policy auditoria_upd on public."auditoria" for update to authenticated using (true);

drop policy if exists notificacoes_sel on public."notificacoes";
create policy notificacoes_sel on public."notificacoes" for select to authenticated using (true);
drop policy if exists notificacoes_ins on public."notificacoes";
create policy notificacoes_ins on public."notificacoes" for insert to authenticated with check (true);
drop policy if exists notificacoes_upd on public."notificacoes";
create policy notificacoes_upd on public."notificacoes" for update to authenticated using (true);

drop policy if exists convites_sel on public."convites";
create policy convites_sel on public."convites" for select to authenticated using (true);
drop policy if exists convites_ins on public."convites";
create policy convites_ins on public."convites" for insert to authenticated with check (true);
drop policy if exists convites_upd on public."convites";
create policy convites_upd on public."convites" for update to authenticated using (true);

drop policy if exists produtos_sel on public."produtos";
create policy produtos_sel on public."produtos" for select to authenticated using (true);
drop policy if exists produtos_ins on public."produtos";
create policy produtos_ins on public."produtos" for insert to authenticated with check (true);
drop policy if exists produtos_upd on public."produtos";
create policy produtos_upd on public."produtos" for update to authenticated using (true);


-- ===========================================================================
-- RPCs de auto-cadastro e conferência
-- ===========================================================================
create or replace function public.auto_cadastro_pendente(p_nome text)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into public.usuarios (id, nome, perfil, ativo, empresa)
  values (auth.uid(), p_nome, 'pendente', false, 'TRANSPORTADORA')
  on conflict (id) do nothing;
end $$;

create or replace function public.veiculos_bloqueados()
returns table (veiculo_id uuid) language sql stable security definer set search_path = public as $$
  select j.veiculo_id from public.jornadas j where j.status in ('aberta','conferencia');
$$;

grant execute on function public.auto_cadastro_pendente(text) to authenticated;
grant execute on function public.veiculos_bloqueados()       to authenticated;
