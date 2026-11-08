# Premiers contenus pédagogiques EDU-BOT

Exécuter ce fichier après `schema.sql` et `catalogue_matieres.sql` dans Supabase SQL Editor.

Il crée, pour les étudiants de Licence 1 :
- Gestion / Comptabilité générale : un cours introductif, un exercice corrigé et un QCM ;
- Analyse biomédicale / Biochimie clinique : un cours introductif, un exercice corrigé et un QCM.

Les contenus sont bilingues français/anglais. Ils sont publiés pour permettre un premier test fonctionnel. Ils restent des exemples pédagogiques généraux : un enseignant doit les vérifier et les adapter au référentiel de l'établissement.

Le script évite de recréer les mêmes cours, exercices et examens s'il est exécuté plusieurs fois. Il est toutefois recommandé de faire une sauvegarde avant toute importation dans une base contenant déjà des données.
