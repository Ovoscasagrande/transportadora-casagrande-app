-- ==========================================================================
-- CASAGRANDE — TRANSPORTADORA · schema completo
-- Banco INDEPENDENTE. Gerado da estrutura real de produção.
-- Colunas "empresa"/"empresas" removidas: cada banco JÁ é uma empresa.
-- Idempotente: pode rodar mais de uma vez.
-- ==========================================================================

create extension if not exists "pgcrypto";

-- ------------------------------------------------------------------ usuarios
create table if not exists public."usuarios" (
  "id" uuid primary key,
  "nome" text,
  "perfil" text,
  "ativo" boolean default true,
  "criado_em" timestamptz default now(),
  "email" text,
  "cpf" text,
  "cnh" text,
  "cnh_categoria" text,
  "cnh_validade" date,
  "contato" text,
  "perfis_extra" jsonb default '[]'::jsonb,
  "is_master" boolean default false
);
-- o perfil vive no mesmo id do usuário do Auth
alter table public."usuarios" drop constraint if exists usuarios_id_fkey;
alter table public."usuarios" add constraint usuarios_id_fkey foreign key (id) references auth.users(id) on delete cascade;

-- ------------------------------------------------------------------ motoristas
create table if not exists public."motoristas" (
  "id" uuid primary key default gen_random_uuid(),
  "usuario_id" uuid,
  "nome" text,
  "cpf" text,
  "cnh" text,
  "cnh_categoria" text,
  "cnh_validade" date,
  "contato" text,
  "situacao" text default 'incompleto',
  "ativo" boolean default true,
  "criado_em" timestamptz default now()
);
create index if not exists "motoristas_usuario_id_idx" on public."motoristas" ("usuario_id");

-- ------------------------------------------------------------------ veiculos
create table if not exists public."veiculos" (
  "id" uuid primary key default gen_random_uuid(),
  "placa" text,
  "renavam" text,
  "marca" text,
  "modelo" text,
  "ano" integer,
  "cor" text,
  "ativo" boolean default true,
  "intervalo_oleo_km" integer,
  "ultima_troca_oleo_km" integer,
  "ultima_troca_oleo_data" date,
  "criado_em" timestamptz default now(),
  "km_atual" numeric,
  "proxima_manutencao_km" numeric
);

-- ------------------------------------------------------------------ motorista_veiculo
create table if not exists public."motorista_veiculo" (
  "id" uuid primary key default gen_random_uuid(),
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "ativo" boolean default true
);
create index if not exists "motorista_veiculo_motorista_id_idx" on public."motorista_veiculo" ("motorista_id");
create index if not exists "motorista_veiculo_veiculo_id_idx" on public."motorista_veiculo" ("veiculo_id");

-- ------------------------------------------------------------------ veiculos_documentos
create table if not exists public."veiculos_documentos" (
  "id" uuid primary key default gen_random_uuid(),
  "veiculo_id" uuid,
  "tipo" text default 'CRLV-e',
  "arquivo_path" text,
  "vencimento" date,
  "enviado_por" uuid,
  "criado_em" timestamptz default now()
);
create index if not exists "veiculos_documentos_veiculo_id_idx" on public."veiculos_documentos" ("veiculo_id");

-- ------------------------------------------------------------------ postos
create table if not exists public."postos" (
  "id" uuid primary key default gen_random_uuid(),
  "nome" text,
  "ativo" boolean default true,
  "criado_em" timestamptz default now()
);

-- ------------------------------------------------------------------ jornadas
create table if not exists public."jornadas" (
  "id" uuid primary key default gen_random_uuid(),
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "roteiro" integer,
  "km_inicial" numeric,
  "km_final" numeric,
  "inicio" timestamptz default now(),
  "fim" timestamptz,
  "ocorrencias" text,
  "status" text default 'aberta',
  "conferida_por" uuid,
  "conferida_em" timestamptz,
  "roteiros_extra" jsonb default '[]'::jsonb,
  "motivo_cancelamento" text,
  "cancelada_por" uuid,
  "cancelada_em" timestamptz
);
create index if not exists "jornadas_motorista_id_idx" on public."jornadas" ("motorista_id");
create index if not exists "jornadas_veiculo_id_idx" on public."jornadas" ("veiculo_id");

-- ------------------------------------------------------------------ jornada_carregamentos
create table if not exists public."jornada_carregamentos" (
  "id" uuid primary key default gen_random_uuid(),
  "jornada_id" uuid,
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "observacao" text,
  "criado_em" timestamptz default now()
);
create index if not exists "jornada_carregamentos_jornada_id_idx" on public."jornada_carregamentos" ("jornada_id");
create index if not exists "jornada_carregamentos_motorista_id_idx" on public."jornada_carregamentos" ("motorista_id");
create index if not exists "jornada_carregamentos_veiculo_id_idx" on public."jornada_carregamentos" ("veiculo_id");

-- ------------------------------------------------------------------ jornada_conferencia
create table if not exists public."jornada_conferencia" (
  "id" uuid primary key default gen_random_uuid(),
  "jornada_id" uuid,
  "item" text,
  "ok" boolean,
  "obs" text,
  "conferido_por" uuid,
  "conferido_em" timestamptz
);
create index if not exists "jornada_conferencia_jornada_id_idx" on public."jornada_conferencia" ("jornada_id");

-- ------------------------------------------------------------------ abastecimentos
create table if not exists public."abastecimentos" (
  "id" uuid primary key default gen_random_uuid(),
  "jornada_id" uuid,
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "data" timestamptz default now(),
  "posto" text,
  "km" numeric,
  "combustivel" text,
  "litros" numeric,
  "preco_litro" numeric,
  "valor_total" numeric,
  "foto_path" text,
  "parcial" boolean default false,
  "criado_em" timestamptz default now()
);
create index if not exists "abastecimentos_jornada_id_idx" on public."abastecimentos" ("jornada_id");
create index if not exists "abastecimentos_motorista_id_idx" on public."abastecimentos" ("motorista_id");
create index if not exists "abastecimentos_veiculo_id_idx" on public."abastecimentos" ("veiculo_id");

-- ------------------------------------------------------------------ despesas
create table if not exists public."despesas" (
  "id" uuid primary key default gen_random_uuid(),
  "jornada_id" uuid,
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "categoria" text,
  "descricao" text,
  "data" timestamptz default now(),
  "km" numeric,
  "valor" numeric,
  "foto_path" text,
  "obs" text,
  "status" text default 'aguardando',
  "motivo_reprovacao" text,
  "aprovada_por" uuid,
  "aprovada_em" timestamptz,
  "reembolsada_em" timestamptz,
  "criado_em" timestamptz default now(),
  "extras" jsonb default '{}'::jsonb
);
create index if not exists "despesas_jornada_id_idx" on public."despesas" ("jornada_id");
create index if not exists "despesas_motorista_id_idx" on public."despesas" ("motorista_id");
create index if not exists "despesas_veiculo_id_idx" on public."despesas" ("veiculo_id");

-- ------------------------------------------------------------------ recebimentos
create table if not exists public."recebimentos" (
  "id" uuid primary key default gen_random_uuid(),
  "tipo" text,
  "valor" numeric,
  "veiculo_id" uuid,
  "motorista_id" uuid,
  "data" timestamptz default now(),
  "foto_path" text,
  "obs" text,
  "extras" jsonb default '{}'::jsonb,
  "lancado_por" uuid,
  "criado_em" timestamptz default now()
);
create index if not exists "recebimentos_veiculo_id_idx" on public."recebimentos" ("veiculo_id");
create index if not exists "recebimentos_motorista_id_idx" on public."recebimentos" ("motorista_id");

-- ------------------------------------------------------------------ avisos
create table if not exists public."avisos" (
  "id" uuid primary key default gen_random_uuid(),
  "motorista_id" uuid,
  "veiculo_id" uuid,
  "categoria" text,
  "texto" text,
  "fotos" jsonb default '[]'::jsonb,
  "status" text default 'recebido',
  "criado_em" timestamptz default now(),
  "atualizado_em" timestamptz default now()
);
create index if not exists "avisos_motorista_id_idx" on public."avisos" ("motorista_id");
create index if not exists "avisos_veiculo_id_idx" on public."avisos" ("veiculo_id");

-- ------------------------------------------------------------------ multas
create table if not exists public."multas" (
  "id" uuid primary key default gen_random_uuid(),
  "veiculo_id" uuid,
  "motorista_id" uuid,
  "orgao" text,
  "data_infracao" date,
  "data_recebimento" date,
  "prazo" date,
  "valor" numeric,
  "notificacao_path" text,
  "obs" text,
  "status" text default 'aguardando_ciencia',
  "ciencia_em" timestamptz,
  "cadastrada_por" uuid,
  "criado_em" timestamptz default now()
);
create index if not exists "multas_veiculo_id_idx" on public."multas" ("veiculo_id");
create index if not exists "multas_motorista_id_idx" on public."multas" ("motorista_id");

-- ------------------------------------------------------------------ ordens_servico
create table if not exists public."ordens_servico" (
  "id" uuid primary key default gen_random_uuid(),
  "aviso_id" uuid,
  "veiculo_id" uuid,
  "aberta_por" uuid,
  "descricao" text,
  "diagnostico" text,
  "servico" text,
  "pecas" text,
  "mao_obra" numeric,
  "custos" numeric,
  "km" numeric,
  "fotos" jsonb default '[]'::jsonb,
  "status" text default 'recebida',
  "mecanico_id" uuid,
  "aberta_em" timestamptz default now(),
  "concluida_em" timestamptz
);
create index if not exists "ordens_servico_aviso_id_idx" on public."ordens_servico" ("aviso_id");
create index if not exists "ordens_servico_veiculo_id_idx" on public."ordens_servico" ("veiculo_id");
create index if not exists "ordens_servico_mecanico_id_idx" on public."ordens_servico" ("mecanico_id");

-- ------------------------------------------------------------------ trocas_oleo
create table if not exists public."trocas_oleo" (
  "id" uuid primary key default gen_random_uuid(),
  "veiculo_id" uuid,
  "km" numeric,
  "data" date,
  "obs" text,
  "registrado_por" uuid,
  "criado_em" timestamptz default now()
);
create index if not exists "trocas_oleo_veiculo_id_idx" on public."trocas_oleo" ("veiculo_id");

-- ------------------------------------------------------------------ tipos_despesa
create table if not exists public."tipos_despesa" (
  "id" uuid primary key default gen_random_uuid(),
  "nome" text,
  "campos" jsonb default '[]'::jsonb,
  "ativo" boolean default true,
  "criado_em" timestamptz default now()
);

-- ------------------------------------------------------------------ tipos_recebimento
create table if not exists public."tipos_recebimento" (
  "id" uuid primary key default gen_random_uuid(),
  "nome" text,
  "campos" jsonb default '[]'::jsonb,
  "ativo" boolean default true,
  "criado_em" timestamptz default now()
);

-- ------------------------------------------------------------------ auditoria
create table if not exists public."auditoria" (
  "id" uuid primary key default gen_random_uuid(),
  "usuario_id" uuid,
  "acao" text,
  "detalhe" jsonb,
  "criado_em" timestamptz default now()
);
create index if not exists "auditoria_usuario_id_idx" on public."auditoria" ("usuario_id");

-- ------------------------------------------------------------------ notificacoes
create table if not exists public."notificacoes" (
  "id" uuid primary key default gen_random_uuid(),
  "usuario_id" uuid,
  "titulo" text,
  "corpo" text,
  "lida" boolean default false,
  "criado_em" timestamptz default now(),
  "link" text
);
create index if not exists "notificacoes_usuario_id_idx" on public."notificacoes" ("usuario_id");

-- ------------------------------------------------------------------ convites
create table if not exists public."convites" (
  "token" uuid,
  "perfil" text,
  "criado_por" uuid,
  "criado_em" timestamptz default now(),
  "expira_em" timestamptz default now(),
  "usado_em" timestamptz,
  "usado_por" uuid
);

-- ------------------------------------------------------------------ produtos
create table if not exists public."produtos" (
  "id" uuid primary key default gen_random_uuid(),
  "nome" text,
  "sku" text,
  "unidade" text default 'UN',
  "ativo" boolean default true,
  "criado_em" timestamptz default now(),
  "custo" numeric,
  "tabelas" jsonb default '{}'::jsonb,
  "un" text,
  "est_disp" numeric,
  "mg_real" numeric,
  "queima" boolean default false,
  "interno" boolean default false
);

-- ==========================================================================
-- RLS
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
alter table public."recebimentos" enable row level security;
alter table public."avisos" enable row level security;
alter table public."multas" enable row level security;
alter table public."ordens_servico" enable row level security;
alter table public."trocas_oleo" enable row level security;
alter table public."tipos_despesa" enable row level security;
alter table public."tipos_recebimento" enable row level security;
alter table public."auditoria" enable row level security;
alter table public."notificacoes" enable row level security;
alter table public."convites" enable row level security;
alter table public."produtos" enable row level security;


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

drop policy if exists recebimentos_sel on public."recebimentos";
create policy recebimentos_sel on public."recebimentos" for select to authenticated using (true);
drop policy if exists recebimentos_ins on public."recebimentos";
create policy recebimentos_ins on public."recebimentos" for insert to authenticated with check (true);
drop policy if exists recebimentos_upd on public."recebimentos";
create policy recebimentos_upd on public."recebimentos" for update to authenticated using (true);

drop policy if exists avisos_sel on public."avisos";
create policy avisos_sel on public."avisos" for select to authenticated using (true);
drop policy if exists avisos_ins on public."avisos";
create policy avisos_ins on public."avisos" for insert to authenticated with check (true);
drop policy if exists avisos_upd on public."avisos";
create policy avisos_upd on public."avisos" for update to authenticated using (true);

drop policy if exists multas_sel on public."multas";
create policy multas_sel on public."multas" for select to authenticated using (true);
drop policy if exists multas_ins on public."multas";
create policy multas_ins on public."multas" for insert to authenticated with check (true);
drop policy if exists multas_upd on public."multas";
create policy multas_upd on public."multas" for update to authenticated using (true);

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
-- todo cadastro novo entra PENDENTE; a gerência aprova
-- ===========================================================================
create or replace function public.novo_usuario()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.usuarios (id, nome, email, perfil, ativo)
  values (new.id,
          coalesce(new.raw_user_meta_data->>'nome', split_part(new.email,'@',1)),
          new.email, 'pendente', false)
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists trg_novo_usuario on auth.users;
create trigger trg_novo_usuario
  after insert on auth.users
  for each row execute function public.novo_usuario();

create or replace function public.veiculos_bloqueados()
returns table (veiculo_id uuid) language sql stable security definer set search_path = public as $$
  select j.veiculo_id from public.jornadas j where j.status in ('aberta','conferencia');
$$;

grant execute on function public.veiculos_bloqueados() to authenticated;
