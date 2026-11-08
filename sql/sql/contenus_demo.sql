-- EDU-BOT : premiers contenus de démonstration bilingues
-- À exécuter après schema.sql et catalogue_matieres.sql.
-- Contenu introductif à faire valider par les enseignants.
-- Réexécutable : les cours, exercices et examens sont repérés par leur titre.

do $$
declare
  v_gestion uuid;
  v_bio uuid;
  v_course uuid;
  v_exam uuid;
  v_question uuid;
  v_option_a uuid;
  v_option_b uuid;
  v_option_c uuid;
begin
  select m.id into v_gestion
  from public.matieres m join public.filieres f on f.id=m.filiere_id
  where f.nom='Gestion' and m.niveau='Licence 1'
    and m.nom='Comptabilité générale'
  limit 1;

  select m.id into v_bio
  from public.matieres m join public.filieres f on f.id=m.filiere_id
  where f.nom='Analyse biomédicale' and m.niveau='Licence 1'
    and m.nom='Biochimie clinique'
  limit 1;

  if v_gestion is null or v_bio is null then
    raise exception 'Matières manquantes. Exécutez d''abord sql/catalogue_matieres.sql.';
  end if;

  -- COURS 1 : Gestion / Comptabilité générale
  if not exists (select 1 from public.cours where matiere_id=v_gestion and titre='Introduction à la comptabilité générale | Introduction to Financial Accounting') then
    insert into public.cours(matiere_id,titre,contenu,publie)
    values (
      v_gestion,
      'Introduction à la comptabilité générale | Introduction to Financial Accounting',
      $content$
FRANÇAIS
1. Définition
La comptabilité générale est un système organisé qui enregistre les opérations financières d'une organisation afin de produire une information fiable sur son patrimoine, sa situation financière et son résultat.

2. Le patrimoine
Le patrimoine comprend notamment les biens et les droits (actif), ainsi que les ressources qui financent ces éléments : capitaux propres et dettes (passif).

3. L''équilibre fondamental
ACTIF = CAPITAUX PROPRES + DETTES
Chaque opération doit préserver l''équilibre comptable. Par exemple, lorsqu''une entreprise achète du matériel au comptant, le matériel augmente et la trésorerie diminue du même montant.

4. Exemple
Une entreprise possède 500 000 FCFA en banque et un matériel de 300 000 FCFA. Son actif total est de 800 000 FCFA. Si elle doit 200 000 FCFA à un fournisseur, ses capitaux propres sont de 600 000 FCFA.

À retenir : la comptabilité permet de suivre, classer et présenter les opérations de manière cohérente.

ENGLISH
1. Definition
Financial accounting is an organized system for recording an organization''s financial transactions and producing reliable information about its assets, financial position and performance.

2. The accounting equation
ASSETS = EQUITY + LIABILITIES
Every transaction must preserve this balance. For example, buying equipment for cash increases equipment and decreases cash by the same amount.

3. Example
An organization has cash of 500,000 FCFA and equipment worth 300,000 FCFA. Total assets are 800,000 FCFA. If it owes a supplier 200,000 FCFA, equity is 600,000 FCFA.

Key idea: accounting records, classifies and presents transactions consistently.
$content$,
      true
    ) returning id into v_course;
  end if;

  if not exists (select 1 from public.exercices where matiere_id=v_gestion and titre='Exercice 1 — Équation comptable | Exercise 1 — Accounting Equation') then
    insert into public.exercices(matiere_id,titre,enonce,correction,publie)
    values (
      v_gestion,
      'Exercice 1 — Équation comptable | Exercise 1 — Accounting Equation',
      'FR : Une entreprise possède 1 200 000 FCFA d''actifs et doit 450 000 FCFA. Calculez les capitaux propres. Expliquez votre calcul.' || E'\n\n' ||
      'EN: A business has assets of 1,200,000 FCFA and liabilities of 450,000 FCFA. Calculate equity and explain your calculation.',
      'FR : Actif = Capitaux propres + Dettes. Donc Capitaux propres = 1 200 000 - 450 000 = 750 000 FCFA.' || E'\n\n' ||
      'EN: Equity = Assets - Liabilities = 1,200,000 - 450,000 = 750,000 FCFA.',
      true
    );
  end if;

  if not exists (select 1 from public.examens where matiere_id=v_gestion and titre='QCM de démarrage — Comptabilité | Introductory Accounting Quiz') then
    insert into public.examens(matiere_id,titre,duree_minutes,publie)
    values (v_gestion,'QCM de démarrage — Comptabilité | Introductory Accounting Quiz',10,true)
    returning id into v_exam;

    insert into public.questions(examen_id,enonce,points)
    values (v_exam,'FR/EN : Quelle est l''équation comptable fondamentale ? / What is the basic accounting equation?',2)
    returning id into v_question;

    insert into public.options_questions(question_id,texte)
    values (v_question,'Actif = Capitaux propres + Dettes / Assets = Equity + Liabilities')
    returning id into v_option_a;
    insert into public.options_questions(question_id,texte)
    values (v_question,'Actif = Produits - Charges / Assets = Revenue - Expenses')
    returning id into v_option_b;
    insert into public.options_questions(question_id,texte)
    values (v_question,'Dettes = Actif + Capitaux propres / Liabilities = Assets + Equity')
    returning id into v_option_c;

    insert into public.corriges_questions(question_id,bonne_option_id,explication)
    values (v_question,v_option_a,'FR : Les actifs sont financés par les capitaux propres et les dettes. EN: Assets are financed by equity and liabilities.');
  end if;

  -- COURS 2 : Analyse biomédicale / Biochimie clinique
  if not exists (select 1 from public.cours where matiere_id=v_bio and titre='Introduction à la biochimie clinique | Introduction to Clinical Biochemistry') then
    insert into public.cours(matiere_id,titre,contenu,publie)
    values (
      v_bio,
      'Introduction à la biochimie clinique | Introduction to Clinical Biochemistry',
      $content$
FRANÇAIS
1. Définition
La biochimie clinique étudie les constituants chimiques des liquides biologiques et leurs variations. Elle contribue à l''évaluation de l''état physiologique et au suivi des maladies, en complément de l''examen clinique.

2. Exemples d''analyses
- Glycémie : mesure de la concentration du glucose dans le sang.
- Créatinine : marqueur utilisé dans l''évaluation de la fonction rénale.
- Bilirubine : substance issue notamment de la dégradation de l''hémoglobine, étudiée dans l''exploration hépatobiliaire.

3. Étapes générales
Prélèvement et identification, préparation de l''échantillon, analyse avec une méthode adaptée, contrôle qualité, validation technique et transmission du résultat.

4. Qualité et sécurité
L''identification correcte du patient et de l''échantillon, le respect des procédures, les contrôles et la traçabilité sont essentiels.

ENGLISH
1. Definition
Clinical biochemistry studies the chemical components of biological fluids and how they vary. It supports the assessment of physiological conditions and disease monitoring, alongside clinical examination.

2. Examples
- Blood glucose: measurement of glucose concentration in blood.
- Creatinine: a marker used when assessing kidney function.
- Bilirubin: a substance formed partly through haemoglobin breakdown and studied in hepatobiliary assessment.

3. General workflow
Sample collection and identification, sample preparation, analysis using an appropriate method, quality control, technical validation and reporting.

4. Quality and safety
Correct patient and sample identification, standard procedures, quality controls and traceability are essential.

Note pédagogique : ce cours est introductif. Il ne constitue ni un protocole de laboratoire ni une interprétation médicale individuelle.
$content$,
      true
    ) returning id into v_course;
  end if;

  if not exists (select 1 from public.exercices where matiere_id=v_bio and titre='Exercice 1 — Étapes préanalytiques | Exercise 1 — Pre-analytical Steps') then
    insert into public.exercices(matiere_id,titre,enonce,correction,publie)
    values (
      v_bio,
      'Exercice 1 — Étapes préanalytiques | Exercise 1 — Pre-analytical Steps',
      'FR : Citez trois vérifications importantes à effectuer avant l''analyse d''un échantillon sanguin.' || E'\n\n' ||
      'EN: Name three important checks to perform before analysing a blood sample.',
      'FR : Exemples : vérifier l''identité du patient, vérifier l''étiquetage et la concordance du tube avec la demande, contrôler l''intégrité et les conditions de conservation de l''échantillon.' || E'\n\n' ||
      'EN: Examples: verify patient identity, check that the tube label matches the request, and assess sample integrity and storage conditions.',
      true
    );
  end if;

  if not exists (select 1 from public.examens where matiere_id=v_bio and titre='QCM de démarrage — Biochimie clinique | Introductory Clinical Biochemistry Quiz') then
    insert into public.examens(matiere_id,titre,duree_minutes,publie)
    values (v_bio,'QCM de démarrage — Biochimie clinique | Introductory Clinical Biochemistry Quiz',10,true)
    returning id into v_exam;

    insert into public.questions(examen_id,enonce,points)
    values (v_exam,'FR/EN : Quel élément est essentiel pour assurer la traçabilité d''un échantillon ? / Which item is essential for sample traceability?',2)
    returning id into v_question;

    insert into public.options_questions(question_id,texte)
    values (v_question,'Une identification correcte et un étiquetage concordant / Correct identification and matching labelling')
    returning id into v_option_a;
    insert into public.options_questions(question_id,texte)
    values (v_question,'La couleur préférée du patient / The patient''s favourite colour')
    returning id into v_option_b;
    insert into public.options_questions(question_id,texte)
    values (v_question,'L''absence de toute documentation / No documentation')
    returning id into v_option_c;

    insert into public.corriges_questions(question_id,bonne_option_id,explication)
    values (v_question,v_option_a,'FR : L''identification et l''étiquetage permettent de relier sans ambiguïté l''échantillon au patient et à la demande. EN: Identification and labelling link the sample unambiguously to the patient and request.');
