-- EDU-BOT : catalogue initial des matières (70 lignes)
-- À exécuter APRÈS sql/schema.sql dans Supabase > SQL Editor.
-- Ce catalogue est une base de départ, pas un programme universitaire officiel.
-- Les intitulés et leur répartition par niveau doivent être validés par les enseignants.

insert into public.matieres (filiere_id, niveau, nom, description)
select f.id, v.niveau, v.nom, v.description
from public.filieres f
join (values
  ('Gestion', 'Licence 1', 'Comptabilité générale', 'Intitulé anglais : General accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 1', 'Comptabilité analytique', 'Intitulé anglais : Cost accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 1', 'Gestion financière', 'Intitulé anglais : Financial management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 1', 'Marketing', 'Intitulé anglais : Marketing. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 1', 'Management', 'Intitulé anglais : Management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 1', 'Économie', 'Intitulé anglais : Economics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 1', 'Mathématiques financières', 'Intitulé anglais : Financial mathematics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 2', 'Comptabilité générale', 'Intitulé anglais : General accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 2', 'Comptabilité analytique', 'Intitulé anglais : Cost accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 2', 'Gestion financière', 'Intitulé anglais : Financial management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 2', 'Marketing', 'Intitulé anglais : Marketing. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 2', 'Management', 'Intitulé anglais : Management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 2', 'Économie', 'Intitulé anglais : Economics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 2', 'Mathématiques financières', 'Intitulé anglais : Financial mathematics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 3', 'Comptabilité générale', 'Intitulé anglais : General accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 3', 'Comptabilité analytique', 'Intitulé anglais : Cost accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 3', 'Gestion financière', 'Intitulé anglais : Financial management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 3', 'Marketing', 'Intitulé anglais : Marketing. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 3', 'Management', 'Intitulé anglais : Management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 3', 'Économie', 'Intitulé anglais : Economics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Licence 3', 'Mathématiques financières', 'Intitulé anglais : Financial mathematics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 1', 'Comptabilité générale', 'Intitulé anglais : General accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 1', 'Comptabilité analytique', 'Intitulé anglais : Cost accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 1', 'Gestion financière', 'Intitulé anglais : Financial management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 1', 'Marketing', 'Intitulé anglais : Marketing. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 1', 'Management', 'Intitulé anglais : Management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 1', 'Économie', 'Intitulé anglais : Economics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 1', 'Mathématiques financières', 'Intitulé anglais : Financial mathematics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 2', 'Comptabilité générale', 'Intitulé anglais : General accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 2', 'Comptabilité analytique', 'Intitulé anglais : Cost accounting. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 2', 'Gestion financière', 'Intitulé anglais : Financial management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 2', 'Marketing', 'Intitulé anglais : Marketing. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 2', 'Management', 'Intitulé anglais : Management. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 2', 'Économie', 'Intitulé anglais : Economics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Gestion', 'Master 2', 'Mathématiques financières', 'Intitulé anglais : Financial mathematics. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 1', 'Hématologie', 'Intitulé anglais : Hematology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 1', 'Biochimie clinique', 'Intitulé anglais : Clinical biochemistry. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 1', 'Microbiologie', 'Intitulé anglais : Microbiology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 1', 'Parasitologie', 'Intitulé anglais : Parasitology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 1', 'Immunologie', 'Intitulé anglais : Immunology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 1', 'Sérologie', 'Intitulé anglais : Serology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 1', 'Techniques de laboratoire', 'Intitulé anglais : Laboratory techniques. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 2', 'Hématologie', 'Intitulé anglais : Hematology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 2', 'Biochimie clinique', 'Intitulé anglais : Clinical biochemistry. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 2', 'Microbiologie', 'Intitulé anglais : Microbiology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 2', 'Parasitologie', 'Intitulé anglais : Parasitology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 2', 'Immunologie', 'Intitulé anglais : Immunology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 2', 'Sérologie', 'Intitulé anglais : Serology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 2', 'Techniques de laboratoire', 'Intitulé anglais : Laboratory techniques. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 3', 'Hématologie', 'Intitulé anglais : Hematology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 3', 'Biochimie clinique', 'Intitulé anglais : Clinical biochemistry. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 3', 'Microbiologie', 'Intitulé anglais : Microbiology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 3', 'Parasitologie', 'Intitulé anglais : Parasitology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 3', 'Immunologie', 'Intitulé anglais : Immunology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 3', 'Sérologie', 'Intitulé anglais : Serology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Licence 3', 'Techniques de laboratoire', 'Intitulé anglais : Laboratory techniques. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 1', 'Hématologie', 'Intitulé anglais : Hematology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 1', 'Biochimie clinique', 'Intitulé anglais : Clinical biochemistry. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 1', 'Microbiologie', 'Intitulé anglais : Microbiology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 1', 'Parasitologie', 'Intitulé anglais : Parasitology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 1', 'Immunologie', 'Intitulé anglais : Immunology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 1', 'Sérologie', 'Intitulé anglais : Serology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 1', 'Techniques de laboratoire', 'Intitulé anglais : Laboratory techniques. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 2', 'Hématologie', 'Intitulé anglais : Hematology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 2', 'Biochimie clinique', 'Intitulé anglais : Clinical biochemistry. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 2', 'Microbiologie', 'Intitulé anglais : Microbiology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 2', 'Parasitologie', 'Intitulé anglais : Parasitology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 2', 'Immunologie', 'Intitulé anglais : Immunology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 2', 'Sérologie', 'Intitulé anglais : Serology. Matière de départ à adapter au programme officiel de l''établissement.'),
  ('Analyse biomédicale', 'Master 2', 'Techniques de laboratoire', 'Intitulé anglais : Laboratory techniques. Matière de départ à adapter au programme officiel de l''établissement.')
) as v(filiere, niveau, nom, description)
  on f.nom = v.filiere
on conflict (filiere_id, niveau, nom) do nothing;

-- Contrôle : afficher le nombre de matières par filière et par niveau.
select f.nom as filiere, m.niveau, count(*) as nombre_matieres
from public.matieres m
join public.filieres f on f.id = m.filiere_id
group by f.nom, m.niveau
order by f.nom, m.niveau;
