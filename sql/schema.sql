-- EDU-BOT : schéma initial consolidé pour Supabase
-- Exécuter dans SQL Editor d'un projet neuf ou après sauvegarde.
create extension if not exists pgcrypto;

create table if not exists public.filieres (
  id uuid primary key default gen_random_uuid(),
  nom text not null unique
);

insert into public.filieres(nom) values
 ('Gestion'), ('Analyse biomédicale')
on conflict (nom) do nothing;

create table if not exists public.etudiants (
  id uuid primary key references auth.users(id) on delete cascade,
  nom_complet text not null default '',
  filiere_id uuid references public.filieres(id),
  niveau text not null default 'Licence 1'
    check (niveau in ('Licence 1','Licence 2','Licence 3','Master 1','Master 2')),
  langue text not null default 'fr' check (langue in ('fr','en')),
  created_at timestamptz not null default now()
);

create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'etudiant' check (role in ('etudiant','admin'))
);

create table if not exists public.matieres (
  id uuid primary key default gen_random_uuid(),
  filiere_id uuid not null references public.filieres(id) on delete cascade,
  niveau text not null check (niveau in ('Licence 1','Licence 2','Licence 3','Master 1','Master 2')),
  nom text not null,
  description text default '',
  created_at timestamptz not null default now(),
  unique(filiere_id,niveau,nom)
);

create table if not exists public.cours (
  id uuid primary key default gen_random_uuid(),
  matiere_id uuid not null references public.matieres(id) on delete cascade,
  titre text not null,
  contenu text not null,
  publie boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.exercices (
  id uuid primary key default gen_random_uuid(),
  matiere_id uuid not null references public.matieres(id) on delete cascade,
  titre text not null,
  enonce text not null,
  correction text not null,
  publie boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.examens (
  id uuid primary key default gen_random_uuid(),
  matiere_id uuid not null references public.matieres(id) on delete cascade,
  titre text not null,
  duree_minutes integer not null default 30 check (duree_minutes between 1 and 300),
  publie boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  examen_id uuid not null references public.examens(id) on delete cascade,
  enonce text not null,
  points numeric(7,2) not null default 1 check (points > 0)
);

create table if not exists public.options_questions (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  texte text not null
);

create table if not exists public.corriges_questions (
  question_id uuid primary key references public.questions(id) on delete cascade,
  bonne_option_id uuid not null references public.options_questions(id),
  explication text default ''
);

create table if not exists public.tentatives_examens (
  id uuid primary key default gen_random_uuid(),
  etudiant_id uuid not null references public.etudiants(id) on delete cascade,
  examen_id uuid not null references public.examens(id) on delete cascade,
  debut timestamptz not null default now(),
  fin timestamptz,
  note numeric(8,2),
  statut text not null default 'en_cours'
    check (statut in ('en_cours','termine','expire'))
);

create table if not exists public.reponses_etudiants (
  id uuid primary key default gen_random_uuid(),
  tentative_id uuid not null references public.tentatives_examens(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete cascade,
  option_id uuid references public.options_questions(id),
  unique(tentative_id,question_id)
);

create table if not exists public.progression_cours (
  id uuid primary key default gen_random_uuid(),
  etudiant_id uuid not null references public.etudiants(id) on delete cascade,
  cours_id uuid not null references public.cours(id) on delete cascade,
  termine boolean not null default false,
  updated_at timestamptz not null default now(),
  unique(etudiant_id,cours_id)
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  etudiant_id uuid not null references public.etudiants(id) on delete cascade,
  titre text default 'Conversation',
  created_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  auteur text not null check (auteur in ('etudiant','assistant')),
  contenu text not null,
  created_at timestamptz not null default now()
);

-- Profil créé automatiquement après inscription Auth.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_filiere uuid;
  v_niveau text;
begin
  select f.id into v_filiere
  from public.filieres f
  where f.nom = coalesce(new.raw_user_meta_data->>'filiere','Gestion')
  limit 1;

  v_niveau := coalesce(new.raw_user_meta_data->>'niveau','Licence 1');
  if v_niveau not in ('Licence 1','Licence 2','Licence 3','Master 1','Master 2') then
    v_niveau := 'Licence 1';
  end if;

  insert into public.etudiants(id,nom_complet,filiere_id,niveau,langue)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nom_complet',''),
    v_filiere,
    v_niveau,
    case when new.raw_user_meta_data->>'langue' = 'en' then 'en' else 'fr' end
  )
  on conflict (id) do nothing;

  insert into public.user_roles(user_id,role)
  values(new.id,'etudiant')
  on conflict(user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_edubot on auth.users;
create trigger on_auth_user_created_edubot
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Fonction admin sécurisée : le rôle n'est jamais lu depuis les métadonnées modifiables.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.user_roles r
    where r.user_id = (select auth.uid()) and r.role = 'admin'
  );
$$;

grant execute on function public.is_admin() to authenticated;

-- RLS activé sur toutes les tables.
do $$
declare t text;
begin
  foreach t in array array[
    'filieres','etudiants','user_roles','matieres','cours','exercices',
    'examens','questions','options_questions','corriges_questions',
    'tentatives_examens','reponses_etudiants','progression_cours',
    'conversations','messages'
  ] loop
    execute format('alter table public.%I enable row level security',t);
  end loop;
end $$;

-- Politiques idempotentes : retirer les versions précédentes.
do $$
declare p record;
begin
  for p in
    select schemaname, tablename, policyname
    from pg_policies where schemaname='public'
      and tablename = any(array[
       'filieres','etudiants','user_roles','matieres','cours','exercices',
       'examens','questions','options_questions','corriges_questions',
       'tentatives_examens','reponses_etudiants','progression_cours',
       'conversations','messages'
      ])
  loop
    execute format('drop policy if exists %I on %I.%I',p.policyname,p.schemaname,p.tablename);
  end loop;
end $$;

create policy "filieres_read_auth" on public.filieres
for select to authenticated using (true);

create policy "profile_read_own" on public.etudiants
for select to authenticated using (id = (select auth.uid()));
create policy "profile_update_own" on public.etudiants
for update to authenticated using (id = (select auth.uid()))
with check (id = (select auth.uid()));
create policy "profile_admin_all" on public.etudiants
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "roles_read_own_or_admin" on public.user_roles
for select to authenticated using (user_id = (select auth.uid()) or public.is_admin());
create policy "roles_admin_manage" on public.user_roles
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "subjects_read_matching" on public.matieres
for select to authenticated using (
 public.is_admin() or exists (
  select 1 from public.etudiants e
  where e.id=(select auth.uid()) and e.filiere_id=matieres.filiere_id
    and e.niveau=matieres.niveau
 )
);
create policy "subjects_admin_manage" on public.matieres
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "courses_read_matching" on public.cours
for select to authenticated using (
 public.is_admin() or (publie and exists (
  select 1 from public.matieres m join public.etudiants e
    on e.filiere_id=m.filiere_id and e.niveau=m.niveau
  where m.id=cours.matiere_id and e.id=(select auth.uid())
 ))
);
create policy "courses_admin_manage" on public.cours
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "exercises_read_matching" on public.exercices
for select to authenticated using (
 public.is_admin() or (publie and exists (
  select 1 from public.matieres m join public.etudiants e
    on e.filiere_id=m.filiere_id and e.niveau=m.niveau
  where m.id=exercices.matiere_id and e.id=(select auth.uid())
 ))
);
create policy "exercises_admin_manage" on public.exercices
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "exams_read_matching" on public.examens
for select to authenticated using (
 public.is_admin() or (publie and exists (
  select 1 from public.matieres m join public.etudiants e
    on e.filiere_id=m.filiere_id and e.niveau=m.niveau
  where m.id=examens.matiere_id and e.id=(select auth.uid())
 ))
);
create policy "exams_admin_manage" on public.examens
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "questions_read_published_exam" on public.questions
for select to authenticated using (
 public.is_admin() or exists (
  select 1 from public.examens x join public.matieres m on m.id=x.matiere_id
  join public.etudiants e on e.filiere_id=m.filiere_id and e.niveau=m.niveau
  where x.id=questions.examen_id and x.publie
    and e.id=(select auth.uid())
 )
);
create policy "questions_admin_manage" on public.questions
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "options_read_published_exam" on public.options_questions
for select to authenticated using (
 public.is_admin() or exists (
  select 1 from public.questions q join public.examens x on x.id=q.examen_id
  join public.matieres m on m.id=x.matiere_id
  join public.etudiants e on e.filiere_id=m.filiere_id and e.niveau=m.niveau
  where q.id=options_questions.question_id and x.publie
    and e.id=(select auth.uid())
 )
);
create policy "options_admin_manage" on public.options_questions
for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Les corrigés sont réservés aux administrateurs dans cette version.
create policy "answers_admin_only" on public.corriges_questions
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "attempts_own" on public.tentatives_examens
for select to authenticated using (etudiant_id=(select auth.uid()) or public.is_admin());
create policy "attempts_insert_own" on public.tentatives_examens
for insert to authenticated with check (etudiant_id=(select auth.uid()));
create policy "attempts_admin_manage" on public.tentatives_examens
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "responses_own_read" on public.reponses_etudiants
for select to authenticated using (
 public.is_admin() or exists (
  select 1 from public.tentatives_examens t
  where t.id=reponses_etudiants.tentative_id and t.etudiant_id=(select auth.uid())
 )
);
create policy "responses_own_insert" on public.reponses_etudiants
for insert to authenticated with check (
 exists (
  select 1 from public.tentatives_examens t
  where t.id=reponses_etudiants.tentative_id
    and t.etudiant_id=(select auth.uid()) and t.statut='en_cours'
 )
);
create policy "responses_admin_manage" on public.reponses_etudiants
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "progress_own_read" on public.progression_cours
for select to authenticated using (etudiant_id=(select auth.uid()) or public.is_admin());
create policy "progress_own_insert" on public.progression_cours
for insert to authenticated with check (etudiant_id=(select auth.uid()));
create policy "progress_own_update" on public.progression_cours
for update to authenticated using (etudiant_id=(select auth.uid()))
with check (etudiant_id=(select auth.uid()));
create policy "progress_admin_manage" on public.progression_cours
for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "conversations_own" on public.conversations
for all to authenticated using (etudiant_id=(select auth.uid()))
with check (etudiant_id=(select auth.uid()));
create policy "conversations_admin_read" on public.conversations
for select to authenticated using (public.is_admin());

create policy "messages_own" on public.messages
for select to authenticated using (
 exists (select 1 from public.conversations c
  where c.id=messages.conversation_id and c.etudiant_id=(select auth.uid()))
);
create policy "messages_student_insert" on public.messages
for insert to authenticated with check (
 auteur='etudiant' and exists (
  select 1 from public.conversations c
  where c.id=messages.conversation_id and c.etudiant_id=(select auth.uid())
 )
);
create policy "messages_admin_read" on public.messages
for select to authenticated using (public.is_admin());

-- Droits SQL explicites pour les rôles Supabase.
grant usage on schema public to authenticated;
grant select on public.filieres to authenticated;
grant select, update on public.etudiants to authenticated;
grant select on public.user_roles to authenticated;
grant select on public.matieres, public.cours, public.exercices, public.examens,
  public.questions, public.options_questions to authenticated;
grant select, insert, update on public.tentatives_examens,
  public.reponses_etudiants, public.progression_cours,
  public.conversations, public.messages to authenticated;
grant all on public.matieres, public.cours, public.exercices, public.examens,
  public.questions, public.options_questions, public.corriges_questions,
  public.etudiants, public.user_roles, public.tentatives_examens,
  public.reponses_etudiants, public.progression_cours,
  public.conversations, public.messages to authenticated;


-- =========================================
-- EXAMENS : démarrage et correction côté SQL
-- Les fonctions utilisent auth.uid() et ne révèlent
-- jamais les bonnes réponses au navigateur.
-- =========================================

create or replace function public.start_exam(p_exam_id uuid)
returns table(attempt_id uuid, started_at timestamptz, duration_minutes integer)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_duration integer;
  v_attempt uuid;
begin
  if v_uid is null then
    raise exception 'Authentification requise';
  end if;

  select x.duree_minutes into v_duration
  from public.examens x
  join public.matieres m on m.id=x.matiere_id
  join public.etudiants e on e.filiere_id=m.filiere_id and e.niveau=m.niveau
  where x.id=p_exam_id and x.publie=true and e.id=v_uid;

  if v_duration is null then
    raise exception 'Examen introuvable ou non autorisé';
  end if;

  update public.tentatives_examens t
  set statut='expire', fin=now()
  where t.etudiant_id=v_uid and t.statut='en_cours'
    and exists (
      select 1 from public.examens x
      where x.id=t.examen_id
        and now() > t.debut + make_interval(mins => x.duree_minutes)
    );

  if exists (
    select 1 from public.tentatives_examens t
    where t.etudiant_id=v_uid and t.examen_id=p_exam_id and t.statut='en_cours'
  ) then
    raise exception 'Une tentative est déjà en cours pour cet examen';
  end if;

  insert into public.tentatives_examens(etudiant_id,examen_id,statut)
  values(v_uid,p_exam_id,'en_cours')
  returning id into v_attempt;

  return query select v_attempt, now(), v_duration;
end;
$$;

create or replace function public.submit_exam(p_attempt_id uuid, p_answers jsonb)
returns table(score numeric, score_sur numeric, statut text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_exam uuid;
  v_duration integer;
  v_started timestamptz;
  v_status text;
  v_max numeric;
  v_score numeric;
  v_count integer;
  v_valid integer;
begin
  if v_uid is null then
    raise exception 'Authentification requise';
  end if;
  if jsonb_typeof(p_answers) <> 'array' then
    raise exception 'Format des réponses invalide';
  end if;

  select t.examen_id,t.debut,t.statut,x.duree_minutes
    into v_exam,v_started,v_status,v_duration
  from public.tentatives_examens t
  join public.examens x on x.id=t.examen_id
  where t.id=p_attempt_id and t.etudiant_id=v_uid
  for update;

  if v_exam is null then
    raise exception 'Tentative introuvable';
  end if;
  if v_status <> 'en_cours' then
    raise exception 'Cette tentative est déjà terminée';
  end if;
  if now() > v_started + make_interval(mins => v_duration) then
    update public.tentatives_examens
      set statut='expire',fin=now()
      where id=p_attempt_id;
    raise exception 'Temps écoulé : examen expiré';
  end if;

  -- Refuser les doublons et les questions/options étrangères à cet examen.
  select count(*) into v_count from jsonb_array_elements(p_answers);
  select count(distinct (a->>'question_id')) into v_valid
  from jsonb_array_elements(p_answers) a;
  if v_count <> v_valid then
    raise exception 'Une question apparaît plusieurs fois';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(p_answers) a
    left join public.questions q
      on q.id=(a->>'question_id')::uuid and q.examen_id=v_exam
    left join public.options_questions o
      on o.id=(a->>'option_id')::uuid and o.question_id=q.id
    where q.id is null or o.id is null
  ) then
    raise exception 'Réponse ou option invalide';
  end if;

  insert into public.reponses_etudiants(tentative_id,question_id,option_id)
  select p_attempt_id,(a->>'question_id')::uuid,(a->>'option_id')::uuid
  from jsonb_array_elements(p_answers) a;

  select coalesce(sum(q.points),0) into v_max
  from public.questions q where q.examen_id=v_exam;

  select coalesce(sum(q.points),0) into v_score
  from public.reponses_etudiants r
  join public.questions q on q.id=r.question_id
  join public.corriges_questions c on c.question_id=q.id and c.bonne_option_id=r.option_id
  where r.tentative_id=p_attempt_id;

  update public.tentatives_examens
  set note=case when v_max > 0 then round((v_score/v_max)*20,2) else 0 end,
      statut='termine',fin=now()
  where id=p_attempt_id;

  return query
  select case when v_max > 0 then round((v_score/v_max)*20,2) else 0 end,
         20::numeric,'termine'::text;
end;
$$;

revoke all on function public.start_exam(uuid) from public;
revoke all on function public.submit_exam(uuid,jsonb) from public;
grant execute on function public.start_exam(uuid) to authenticated;
grant execute on function public.submit_exam(uuid,jsonb) to authenticated;
