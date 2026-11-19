-- ==========================================================================
-- TRANSPORTADORA CASAGRANDE — o primeiro usuário (dono/gerência)
-- Rode DEPOIS do schema.sql.
-- Troque o e-mail abaixo pelo do Francisco antes de rodar.
-- ==========================================================================

-- 1) cria o usuário no Auth (faça pela tela: Authentication > Users > Add user)
--    e-mail: SEU_EMAIL_AQUI
--    marque "Auto Confirm User"
--
-- 2) depois de criar, pegue o id do usuário e rode:

-- update public.usuarios set perfil='gerencia', ativo=true, is_master=true
--  where email = 'SEU_EMAIL_AQUI';

-- se o trigger de auto-cadastro ainda não criou a linha, crie manualmente:
-- insert into public.usuarios (id, nome, email, perfil, ativo, is_master)
-- values ('COLE_O_UUID_AQUI', 'Francisco Casagrande', 'SEU_EMAIL_AQUI', 'gerencia', true, true);
