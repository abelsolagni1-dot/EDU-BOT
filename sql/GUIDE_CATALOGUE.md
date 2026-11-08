# Catalogue initial des matières EDU-BOT

## Contenu
Ce fichier ajoute 70 matières :
- 2 filières : Gestion et Analyse biomédicale ;
- 5 niveaux : Licence 1, Licence 2, Licence 3, Master 1 et Master 2 ;
- 7 matières de départ par filière et par niveau.

## Importation
1. Ouvrir Supabase > SQL Editor.
2. Vérifier que `sql/schema.sql` a déjà été exécuté.
3. Ouvrir `sql/catalogue_matieres.sql`, copier tout son contenu dans SQL Editor.
4. Cliquer sur Run.
5. Vérifier le tableau récapitulatif renvoyé à la fin.

Le script est réexécutable : il n'ajoute pas de doublons grâce à la contrainte unique de la table `matieres`.

## Important
Ce catalogue sert à préparer l'application et à tester les filtres par filière/niveau. Il ne prétend pas représenter le programme officiel d'une université. Les enseignants devront confirmer les matières de chaque niveau et fournir les cours, exercices et corrigés validés avant une utilisation pédagogique réelle.
