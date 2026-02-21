# User Stories pour l'App Élève

#### Interface : Onboarding et Authentification

Module : Inscription et Connexion

- **User Story** : En tant qu'élève, je veux un onboarding Duolingo-like afin de configurer rapidement mon profil et commencer l'apprentissage.
  - Critères d'Acceptation :
    - **Détection du profil dès la première question :** "Quel est ton statut ?" → options : Lycéen/Collégien | Étudiant | Adulte (formation continue / reconversion). Le choix active le flag `adult_learner` (booléen sur `UserProfile`) et adapte les écrans suivants.
    - **Écrans communs :** prénom, pays, objectif/échéance, handicap (dyslexie, autisme, etc.).
    - **Si `adult_learner = false` (mineur) :** âge, niveau scolaire, pré-lien école/prof, métier cible.
    - **Si `adult_learner = true` (adulte) :** domaine professionnel, type d'objectif (certification, bac adulte, montée en compétences, reconversion). Pas de champ scolaire. Pas de module parent.
    - Question "Comment vous nous avez connus ?" et explication adaptation IA.
    - Pré-alimentation casier (upload fichiers).
    - Redirection vers tutoriel après validation.
  - Infos Design : UX gamifiée (animations fluides, Fracto comme guide) ; Branchement conditionnel sur `adult_learner` dès l'écran 1 ; Pour UML : classe 'UserProfile' avec attrs `adult_learner: bool`, `handicap`, `objectifs`. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux une authentification standard afin de sécuriser mon compte facilement.
  - Critères d'Acceptation :
    - **Flux B2C (standard) :** email/mot de passe, OAuth (Google/Apple), 2FA, récupération de compte par email/SMS.
    - **Flux GAR (ENT) :** connexion via SSO transmis par l'ENT. L'identifiant opaque GAR (ex: `P09xxxxxx`) est traité comme un *credential secondaire*, jamais comme identité primaire. À la première connexion GAR, l'élève est **obligatoirement** invité à créer ou lier un compte B2C (email Gmail/Apple/etc.) pour garantir la portabilité de ses données hors du contexte scolaire.
    - Auto-login après onboarding. Si l'élève arrive par le GAR avec un email connu, l'Account Linking est proposé automatiquement.
    - Message RGPD sur data (casier, historique). L'email B2C reste l'identité principale — l'ID GAR est un credential de connexion additionnel.
  - Infos Design : Mobile-first, boutons sociaux + bouton ENT ; 2 flows distincts (B2C vs GAR) avec fallback B2C obligatoire ; Seq Diagram : flow GAR → detect existing email → link or create B2C. ==Priorité : Haute.==

- **User Story** : En tant qu'élève arrivant via le GAR (ENT), je veux lier mon identifiant GAR à mon compte B2C (email/Google) ou en créer un immédiatement afin que mon parcours soit portable hors du contexte scolaire.
  - Critères d'Acceptation :
    - **Déclenchement :** à chaque première session GAR (ou si l'élève n'a pas encore de compte B2C lié).
    - **Détection automatique :** si le profil GAR contient un email correspondant à un `User` existant → proposition de fusion en 1 clic (OTP de confirmation).
    - **Création :** si aucun compte B2C connu → flow rapide : choisir Gmail/Apple ou créer email/mdp. Durée cible < 60 secondes.
    - **Post-Account Linking :** l'ID GAR et le compte B2C pointent vers le même `User`. L'élève peut se connecter par les deux voies indifféremment.
    - **En cas de refus temporaire :** reminder à chaque connexion GAR (non-bloquant, mais fortement encouragé).
    - Aucun doublon `User` ne peut exister une fois le lien établi.
  - Infos Design : Modal post-login ENT, UX simple (Duolingo-like) ; Backend : merge des `Membership` vers l'`User` principal ; RGPD : transparence sur ce qui est conservé. ==Priorité : Haute (critique anti-doublons).==

Module : Tutoriel

- **User Story** : En tant qu'élève, je veux un tutoriel user-led présenté par Fracto afin de découvrir les éléments principaux sans friction.
  - Critères d'Acceptation :
    - Overlay sombre transparent highlightant boucle gameplay (home, arbre, cours).
    - Activation seulement à première entrée dans un onglet.
    - Explications courtes via animations Fracto.
    - Skip possible, reprise si quitté.
  - Infos Design : Gamifié (Duolingo-style) ; Pas de blocage UX ; Pour Figma : composants overlay réutilisables. ==Priorité : Haute.==

#### Interface : Barre de Navigation

Module : Navigation Globale

- **User Story** : En tant qu'élève, je veux une barre de navigation avec 3 icônes afin d'accéder rapidement aux vues principales.
  - Critères d'Acceptation :
    - Droite : Home (icône remplie quand active).
    - Milieu : Centre de connaissances (icone arbre de pythagore, courbe conteneur, illuminé/agrandi quand active).
    - Gauche : Cours (livres animés/personnages en attente quand active).
    - Swipe gestures pour transitions fluides.
  - Infos Design : Bottom bar mobile ; Animations Lottie ; Pour C4 : container 'NavBar' lié à backend progress. ==Priorité : Haute.==

#### Interface : Page d'Accueil (Home)

Module : Contenu Personnalisé

- **User Story** : En tant qu'élève, je veux un commentaire Fracto adapté à l'heure afin de me sentir accueilli et motivé.
  - Critères d'Acceptation :
    - "Bonjour [prénom]" matin, "Bonsoir" soir, sinon "Le saviez-vous ?" ou fun fact adapté (liens compétences, value learning).
    - Basé sur profil (âge, intérêts, historique).
  - Infos Design : UX gamifiée (Fracto animé) ; IA pour génération (LangChain, no hallucinations) ; JSON pour facts. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux des Fract Facts dans home afin d'apprendre des anecdotes motivantes.
  - Critères d'Acceptation :
    - Anecdotes connexes à cours récents, tips app.
    - Adaptés profil/casier.
    - Max 1-2 par session.
  - Infos Design : Cards swipeables ; IA génération ; JSON Markdown. Priorité : Moyenne.

- **User Story** : En tant qu'élève, je veux accéder aux derniers cours afin de reprendre rapidement.
  - Critères d'Acceptation :
    - Liste expandable vers capsules.
    - Miniatures illustrées.
    - Reprise si quitté mid-capsule.
  - Infos Design : Scroll infini-like ; Lien backend historique ; Pour UML : assoc 'User' à 'RecentLessons'. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux un bouton streak avec insights afin de tracker ma motivation.
  - Critères d'Acceptation :
    - Icône éclair + chiffre streak.
    - Pop-up : stats activité, comparisons (classe, lycée, monde) comme "Plus long streak de ton lycée".Fract stats pour engagement.
  - Infos Design : Gamification (badges) ; Data from backend analytics ; Seq Diagram pour fetch stats. Priorité : Moyenne.

- **User Story** : En tant qu'élève, je veux accéder à un menu Paramètres structuré afin de gérer tous les aspects de mon compte et de mes préférences en un seul endroit.
  - Critères d'Acceptation :
    - Sections accessibles depuis l'icône paramètres (haut droite) :
      - **Profil & Identité** : prénom, objectifs, métier cible. Inclut la gestion du compte GAR lié (voir l'identifiant ENT associé, possibilité de délier).
      - **Mon Organisation** *(label dynamique selon le type d'`Organization` : "Mon École", "Mon Centre", "Mon Organisme", "Mon Académie"...)* : voir l'affiliation active (via School Code ou GAR), date d'expiration Premium. Raccourci vers le module School Code si non configuré.
      - **Connexions** : raccourci vers la liste des superviseurs connectés. Si `adult_learner = false` : inclut aussi les parents.
      - **Accessibilité** : toggle dyslexie, mode autisme/sensibilité sensorielle — persistants cross-session.
      - **RGPD & Données** : options casier (export, suppression), historique accès, demande de suppression du compte.
      - **Déconnexion** : logout avec confirmation.
    - Navigation par sections claires avec chevrons (pas tout sur une page).
  - Infos Design : Bottom sheet ou page dédiée ; Label de la section "Mon Organisation" résolu depuis `Organization.label_type` (DB) ; Accessibilité mise en avant si profil handicap actif. ==Priorité : Haute.==

Module : Fract Facts et Stats

- **User Story** : En tant qu'élève, je veux des Fract Stats pour comparer mes perfs afin de me challenger.
  - Critères d'Acceptation :
    - Stats : exo réussite, connexion, croissance.
    - Pools : classe, lycée, monde (basé connexions).
    - Privacy toggle.
    - Contexte : Streak modal, Validation/Flop bloc question
  - Infos Design : Backend vector store pour rankings ; Priorité : Moyenne.

#### Interface : Vue Cours

Module : Liste et Catégories

- **User Story** : En tant qu'élève, je veux une liste de cours avec miniatures afin de choisir facilement.
  - Critères d'Acceptation :
    - Onglet cours : liste scrollable, catégories dynamiques au scroll.
    - Miniatures belles/illustratives est qui suivent le code couleur matiere et l'iconographie
  - Infos Design : Mobile scroll ; Images SVG/PNG ; Pour Figma : composants card. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux un chemin de capsules par cours afin de progresser séquentiellement.
  - Critères d'Acceptation :
    - Vue chemin : points capsules, groupées par chapitres (sticky titre chapitre au scroll).
    - Sauter capsules avec avertissement (sauf contrôles).
    - Capsule actuelle en surbrillance, futures grises.
  - Infos Design : Gamifié (arbre-like) ; Animations transition ; Seq Diagram pour progress sync. Pour UML : classe `Chapter` est une entité DB explicite avec `id` propre (généré par Pipeline 1), pas un simple label de groupement — API `GET /courses/{id}/chapters` retourne la hiérarchie complète. ==Priorité : Haute.==

Module : Types de Capsules

- **User Story** : En tant qu'élève, je veux des capsules leçons pour apprendre concepts afin de maîtriser bases.
  - Critères d'Acceptation :
    - Sections avec blocs : texte (Markdown), image, animation (Lottie), interactive (custom renderer JSON code).
    - Adaptations : définitions/why/hints via profil/casier/compétences.
    - Inputs libres avec réponses IA.
  - Infos Design : Formes distinctes (leçon=forme1) ; IA RAG pour no hallucinations ; Pour UML : hiérarchie 'Capsule' > 'Section' > 'Block'. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux des capsules training pour pratiquer afin de consolider compétences.
  - Critères d'Acceptation :
    - 5 problèmes : 3 non-adaptés (input/QCO/QCM/interactive_pb), 2 adaptés (i-Input_problem élaborés, scan exo).
    - Alternance dès non-adapté.
    - Hints/why comme sous-sections (multi-blocs).
  - Infos Design : Difficulté croissante ; Ergonomie input (texte/micro/photo/scan) ; IA vérif raisonabilité. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux des capsules contrôle pour évaluer afin de valider chapitre.
  - Critères d'Acceptation :
    - Remix adaptés trainings chapitre (plus difficile redescendue).
    - Online-only, non-obligatoire/sautable.
    - Feedback personnalisé post-contrôle (rapport prof-like).
    - Max 1.5x longueur moyenne.
  - Infos Design : Forme distincte (fin chapitre) ; Gamifié non-effrayant ; Backend pour remix IA. ==Priorité : Haute.==

Module : Blocs et Interactions

- **User Story** : En tant qu'élève, je veux des blocs variés dans sections afin d'interagir diversement.
  - Critères d'Acceptation :
    - Types : texte (math formalisme), definition (cadre/police spéciale), QCO/QCM (options variables), Input (algo vérif), i-Input (IA vérif/génération).
    - Question texte au-dessus, hint/why post-validation.
    - Énoncés images pour hook.
  - Infos Design : Notion-like composable ; Custom renderer pour interactive ; Markdown/JSON delivery. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux fin capsule avec félicitations afin de me motiver.
  - Critères d'Acceptation :
    - Écran succès, redirection prochaine.
    - Animation extra si nouvelles compétences.
    - Redirigé vers remarques Fracto (si nouvelles).
  - Infos Design : Gamification (Duolingo) ; Lien arbre update ; Priorité : Moyenne.

Module : Progression et Reprise

- **User Story** : En tant qu'élève, je veux reprendre une capsule exactement où je l'ai quittée afin de ne pas perdre mon avancement.
  - Critères d'Acceptation :
    - Sauvegarde auto position (section/bloc actuel).
    - Reprise fluide à l'ouverture (animation smooth).
    - Sync backend online-only MVP.
    - Notification push si inactivité longue.
  - Infos Design : Gamifié (pas de perte) ; Pour seq diagram : flow resume avec backend progress endpoint. ==Priorité : Haute.==

Module : Feedback et Succès

- **User Story** : En tant qu'élève, je veux un feedback personnalisé après un contrôle afin de comprendre mes forces/faiblesses.
  - Critères d'Acceptation :
    - Rapport style prof : synthèse chapitre, compétences évaluées, conseils adaptés (profil/ton).
    - Liens vers capsules à revoir.
    - Animation non-effrayante (positif-focused).
    - Stockage historique pour arbre update.
  - Infos Design : IA LangChain + RAG ; Markdown pour rapport ; Redirection vers centre connaissance. ==Priorité : Haute.==

Module : Partage de Contenu

- **User Story** : En tant qu'élève, je veux partager une capsule leçon que j'aime bien via un lien afin que mon camarade puisse la découvrir ou la faire rapidement.
  - Critères d'Acceptation :
    - Bouton "Partager" sur capsule leçon terminée ou en cours (icône share standard mobile).
    - Génère lien unique/deep link (ex: app.fractis.fr/lesson/[id]?share=[token]).
    - Ouverture : si app installée → ouvre directement la capsule dans l'app (sync progress si déjà commencé).
    - Si pas installée (browser) → affiche preview capsule (contenu statique ou interactif limité) + pop-up "Installe l'app pour une expérience complète" avec boutons App Store/Play Store.
    - Tracking anonyme du partage (analytics PostHog).
  - Infos Design : Gamifié (motivation sociale) ; Deep linking Flutter (uni_links ou app_links package) ; Deferred deep link pour install puis redirect ; Pour seq diagram : flow share → backend token → browser fallback → install prompt. Priorité : Moyenne (post-MVP viralité).

- **User Story** : En tant qu'élève receveur d'un lien partagé, je veux accéder à la capsule depuis mon browser afin de tester sans installer immédiatement.
  - Critères d'Acceptation :
    - Page web responsive (PWA-like) : affiche chemin capsule simplifié (blocs texte/image/animation basiques, pas full interactive si lourd).
    - Pop-up overlay après chargement (ou auto) : "Ouvre dans l'app Fractis pour animations interactives, adaptation IA et suivi progression" → boutons "Ouvrir app" (deep link) ou "Installer maintenant".
    - Si install + deep link cliqué → switch seamless vers app.
    - Fallback graceful si offline (contenu cached si PWA).
  - Infos Design : Utilise Flutter Web pour preview (grow-builder repo) ; Service Worker pour offline preview ; UX Duolingo-like (prompt install non-intrusif). Priorité : Moyenne.

#### Interface : Vue Centrale (Centre de Connaissance)

Module : Feedback Principal

- **User Story** : En tant qu'élève, je veux vue centrale avec dernier feedback Fracto afin de voir progrès.
  - Critères d'Acceptation :
    - Gros plan : rapport prof-like sur compétences/événements.
    - Swipe gauche : casier ; droite : cerveau Fracto.
    - Swipe bas : arbre compétences.
  - Infos Design : Animations swipe ; IA génération feedback ; ==Priorité : Haute.==

Module : Arbre de Compétences

- **User Story** : En tant qu'élève, je veux un arbre fractal Pythagore afin de visualiser progression.
  - Critères d'Acceptation :
    - Croissance additive (carré/triangle/forme par compétence).
    - Animation ajout/opacité update.
    - Navigation zoom/clic pour détails/redirection liste.
    - Boutons : partager, comparer (classe/collègue/objectifs comme bac).
  - Infos Design : Interactif map-like ; Backend compétences eval ; Pour Figma : Lottie croissance.==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux liste compétences afin de détails niveaux.
  - Critères d'Acceptation :
    - Validées/non-validées, refs/infos.
    - Animation highlight fraîches.
    - Lien historique interactions.
  - Infos Design : Liste scrollable ; Animations sur updates ; Priorité : Moyenne.

Module : Cerveau de Fracto

- **User Story** : En tant qu'élève, je veux vue cerveau Fracto afin de corriger mon profil mental.
  - Critères d'Acceptation :
    - Affichage : intérêts, ton, résumé pédagogique, remarques prof.
    - Éditable pour corrections.
    - Animation Fracto "plug".
  - Infos Design : UX corrective ; IA déduction historique ; RGPD edit. Priorité : Moyenne.

Module : Casier de Fracto

- **User Story** : En tant qu'élève, je veux vue casier afin de gérer données non-structurées.
  - Critères d'Acceptation :
    - Liste fichiers (PNG/PDF/TXT), toggle activation.
    - Section partagée (superviseurs, notification → actif par défaut après 48h).
    - Animation Fracto "plug".
  - Infos Design : Privacy-focused ; Backend vector store ; Pour seq : flow activation IA. Priorité : Moyenne.

#### Interface : Adaptation Globale et Handicap

Module : Adaptation IA (Profil + Casier)

- **User Story** : En tant qu'élève, je veux que les contenus s'adaptent en temps réel à mon profil et casier afin d'avoir une expérience "Intuitive Math" personnalisée.
  - Critères d'Acceptation :
    - Priorité : casier actif > profil mental (intérêts, ton, résumé pédagogique, remarques prof).
    - Appliqué à : définitions (version simplifiée), why/hint (explications reformulées), inputs libres (réponses IA contextuelles).
    - Historique interactions/nav + dernières capsules pour ajustements.
    - Compétences évaluées influencent difficulté (ex: training 2 adaptés plus élaborés).
  - Infos Design : Backend pgvector pour RAG ; No hallucinations (contenu vérifié) ; Pour UML : 'AdaptationService' lié à 'UserProfile' et 'Casier'. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux activer/désactiver mon casier et sources partagées afin de contrôler ce que l'IA utilise.
  - Critères d'Acceptation :
    - Toggle global/per-fichier pour ses propres documents (PNG/JPG/PDF/TXT).
    - **Ressources superviseurs :** lorsqu'un superviseur dépose une ressource dans le casier partagé, l'élève reçoit une notification actionnable : "Prof X a partagé [fichier] — actif par défaut pour personnaliser tes cours." → bouton "Désactiver" intégré à la notification.
    - Si aucun choix fait dans les 48h → ressource active par défaut.
    - Toggle per-ressource superviseur disponible en permanence dans la vue Casier.
    - RGPD transparence : indicateur "utilisé par l'IA" visible par fichier, avec info sur qui a déposé.
  - Infos Design : Vue casier avec cards toggle ; Notif actionnable (deep link vers casier) ; Seq pour sync IA retrieval. Priorité : Moyenne.

Module : Prise en Charge Handicap

- **User Story** : En tant qu'élève avec dyslexie, je veux des adaptations spécifiques afin de lire et interagir confortablement.
  - Critères d'Acceptation :
    - Font dyslexie-friendly (OpenDyslexic-like), espacement augmenté, fond contrasté.
    - Text-to-speech option sur blocs texte/définitions (via device ou intégré).
    - Moins d'animations rapides, couleurs calmes.
    - Toggle onboarding + paramètres persistants.
  - Infos Design : WCAG-compliant ; Intégration device accessibility ; Pour Figma : variants composants (dyslexic mode). ==Priorité : Haute.==

- **User Story** : En tant qu'élève avec autisme ou troubles similaires, je veux un mode adapté afin de réduire surcharge sensorielle.
  - Critères d'Acceptation :
    - Ton neutre/calme pour Fracto (pas trop enthousiaste).
    - Réduction animations/flashs, sons optionnels.
    - Navigation prévisible, pas de pop-ups surprises.
    - Inputs simplifiés (moins choix simultanés).
  - Infos Design : Profil mental toggle ; UX minimaliste option ; Priorité : Moyenne.

#### Interface : Centre de Connaissance (suite approfondie)

Module : Interactions Swipe et Arbre

- **User Story** : En tant qu'élève, je veux swipe pour naviguer entre sous-vues afin d'explorer mon profil Fracto intuitivement.
  - Critères d'Acceptation :
    - Swipe gauche → Casier ; droite → Cerveau ; bas → Arbre (enroule feedback principal).
    - Animations fluides, feedback haptic.
    - Feedback principal toujours visible au centre (dernier rapport).
  - Infos Design : Gesture-based mobile ; Pour C4 : component 'KnowledgeCenter' avec sub-containers. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux comparer mon arbre à d'autres afin de me motiver via benchmark.
  - Critères d'Acceptation :
    - Bouton "Comparer" : arbres classe/collègue (via add ami), objectifs (bac, contrôle).
    - Mini-vue overlay, pas full immersion.
    - Privacy : consent explicite pour partage.
  - Infos Design : Gamifié (social light) ; Backend pour shared trees ; Animations croissance comparative. Priorité : Moyenne.

Module : Cerveau et Casier (animations Fracto)

- **User Story** : En tant qu'élève, je veux voir Fracto "se plugger" dans les vues Cerveau/Casier afin de comprendre visuellement le but.
  - Critères d'Acceptation :
    - Animation Lottie : Fracto arrive et se connecte à un port/emplacement thématique.
    - Texte explicatif court + tooltip.
    - Une fois vu, option skip future.
  - Infos Design : Mascot gamifié (Duolingo-like) ; JSON pour animations ; Priorité : Moyenne.

#### Interface : Globale (Offline Support)

Module : Expérience Offline-First

- **User Story** : En tant qu'élève, je veux accéder à la plupart des contenus sans connexion afin de continuer à apprendre n'importe où (transport, avion, zone blanche).
  - Critères d'Acceptation :
    - Cache auto des capsules récentes/dernier cours (leçons, training non-adaptés basiques).
    - Accès offline : home (derniers cours), arbre compétences (vue statique), liste capsules chemin (progress local), sections/blocs cached (texte, image, Lottie, interactive simple si JSON local).
    - Reprise mid-capsule offline.
    - Sync auto dès reconnexion (progress, nouvelles adaptations, IA feedback).
    - Limitations claires : pas d'adaptations IA temps réel (fallback profil last-known), pas de contrôles (online-only), pas de nouveaux cours download auto.
  - Infos Design : Offline-first architecture (Flutter + Hive/Isar pour local DB, ou shared_preferences + assets cache) ; Service Worker si PWA hybrid ; Évolutif depuis online-only MVP. ==Priorité : Haute (ton overview mentionne évolution offline-first)==.

- **User Story** : En tant qu'élève offline, je veux un warning clair afin de comprendre pourquoi mon expérience est bridée.
  - Critères d'Acceptation :
    - Banner/popup discret au lancement offline : "Tu es hors ligne – expérience limitée : pas d'IA adaptative, pas de contrôles, pas de nouveaux contenus. Reconnecte-toi pour tout débloquer !"
    - Icône offline visible (bar nav ou header).
    - Explications par feature : ex. dans training "Problèmes adaptés indisponibles offline", dans arbre "Mises à jour compétences en attente sync".
    - Option "Continuer quand même" ou dismiss permanent par session.
    - Pas bloquant (accès graceful aux cached).
  - Infos Design : UX non-punitif (positif : "Apprends même sans réseau !") ; Animations légères pour warning ; Intégration connectivity listener (Flutter connectivity_plus) ; Pour Figma : composants OfflineBanner réutilisable. ==Priorité : Haute.==

#### Interface : Paramètres et Connexions

> **Lexique** : *Connexion* = lien consent-based superviseur ↔ élève, visible dans le dashboard prof. *Membership* = affiliation silencieuse à une `Organization` ou `Workspace` (Premium uniquement, non visible du prof sauf Workspace lié).

Module : Mon Établissement

- **User Story** : En tant qu'élève B2C, je veux entrer un "School Code" dans mes paramètres afin de bénéficier du Premium de mon établissement partenaire, même sans être rattaché à un Workspace actif.
  - Critères d'Acceptation :
    - Accès depuis Paramètres → "Mon Établissement" → champ "Code École".
    - Vérification de validité du code (existe, licence non-expirée, quota disponible).
    - Si valide : Premium activé. L'élève n'apparaît dans aucun dashboard de prof (vie privée).
    - Une licence est consommée sur le pool de l'`Organization`. Comptage visible dans le dashboard Admin.
    - Message clair : "Tu bénéficies du Premium de [Lycée X] jusqu'au [date expiration]."
    - En cas de quota atteint ou code invalide : message d'erreur explicite.
    - À distinguer d'une *Connexion* superviseur : le School Code n'implique aucune visibilité du prof sur les données de l'élève.
  - Infos Design : Champ dans section Paramètres → Mon Établissement ; Vérification backend synchrone ; Pour UML : création d'un `Membership(User, Organization)` de type 'premium_solo'. ==Priorité : Haute.==

Module : Gestion des Connexions

- **User Story** : En tant qu'élève, je veux recevoir et gérer des demandes de connexion d'un superviseur afin de partager des données ciblées pour un meilleur soutien.
  - Critères d'Acceptation :
    - Notification push/in-app pour demande (ex: "Prof X veut se connecter pour t'aider").
    - Pop-up consentement : explication non-flicage ("Seulement infos utiles pour aide efficace"), détail transmis (compétences, forces/faiblesses, arbres objectifs, casier partagé), intérêt (meilleur guidage cursus).
    - Options : accepter (avec durée déterminée), refuser.
    - Si accepté : superviseur peut envoyer arbres objectifs, contenus casier, voir analytics forces/faiblesses.
    - Renouvellement pop-up à fin durée (ex: 3 mois, configurable).
  - Infos Design : RGPD-compliant (granularité fine) ; UX bienveillante (texte positif) ; Backend OAuth-inspired handshake ; Seq Diagram pour flow demande-accept. ==Priorité : Haute.==

- **User Story** : En tant qu'élève dans un contexte "edu" (école), je veux une connexion automatique avec mon prof afin d'accéder au Premium sans refus possible.
  - Critères d'Acceptation :
    - **Hors-GAR :** auto-activation si l'élève a rejoint un `Workspace` rattaché à une `Organization` sous licence. Pop-up info : "Connexion école imposée pour soutien intégré".
    - **Via GAR :** le simple accès à l'app depuis l'ENT valide automatiquement l'appartenance Premium Partenaire. Le `Workspace` est créé/injecté depuis les métadonnées de classe GAR.
    - Détail transmis (forces/faiblesses, etc.) non-refusable en contexte edu.
    - Fin de connexion si l'élève quitte l'école ou si la licence expire → switch automatique vers Freemium (sauf abonnement B2C perso actif).
    - L'Account Linking B2C est rappelé si non effectué : l'élève peut emporter ses données hors de l'ENT.
  - Infos Design : Intégration SSO GAR + flux Workspace auto ; Pour UML : classe 'Membership' avec type 'edu', lié à 'Organization' via 'Workspace'. ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux consulter et gérer mes connexions en cours afin de contrôler mes partages.
  - Critères d'Acceptation :
    - Vue dans paramètres : liste *Connexions* actives (superviseur, durée restante, détail transmis).
    - Options : renouveler, terminer (sauf "edu").
    - Historique des *Connexions* expirées.
  - Infos Design : Liste simple scrollable ; Boutons action clairs ; Sync backend permissions. Priorité : Moyenne.

Module : QR Code Scanner

- **User Story** : En tant qu'élève, je veux scanner un QR code pour recevoir du contenu partagé afin d'accéder à des ressources sans connexion superviseur.
  - Critères d'Acceptation :
    - Accès via paramètres : scanner intégré (device camera).
    - Contenu reçu : arbres objectifs, casier items (PDF/exos), sans lien permanent.
    - Utilisable pour activités groupe (ex: session collaborative).
    - Warning si offline (bridé).
  - Infos Design : Flutter camera plugin ; UX rapide (scan → import auto) ; Pour seq : flow scan → backend validate → local import. Priorité : Moyenne.

- **User Story** : En tant qu'élève, je veux participer à des activités de groupe via QR/link afin de collaborer sans setup complexe.
  - Critères d'Acceptation :
    - Scan/import link → join session temporaire (ex: exo partagé, arbre groupe).
    - Pas de connexion persistante.
    - Feedback Fracto adapté groupe.
  - Infos Design : Gamifié (multiplayer light) ; Temp data only ; Intégration avec workspaces superviseur (côté dashboard). Priorité : Moyenne.

**User Stories pour les Parents (Intégration Connexions et Updates)**

> **Note persona :** Le parent est un superviseur de type `parent`. Il **n'a pas de Dashboard dédié** — son interaction avec la plateforme se limite à recevoir des emails de notification et à gérer sa *Connexion* via un lien email. L'invitation et le consentement sont toujours initiés par l'élève.

Module : Gestion des Connexions (Ajout Parent)

- **User Story** : En tant qu'élève (mineur, `adult_learner = false`), je veux ajouter une connexion à mon parent via l'app afin de partager mes avancées pour un soutien familial sans friction.
  - Critères d'Acceptation :
    - **Visible uniquement si `adult_learner = false`.** Masqué et non-proposé pour les adultes en formation continue.
    - Dans paramètres ou vue connexions : bouton "Ajouter superviseur (sous type : parent)" (email invite).
    - Pop-up consent : explication non-flicage ("Seulement infos utiles pour encouragements"), détail transmis (avancées significatives comme compétences validées), intérêt (motivation familiale).
    - Durée limitée (ex: 6 mois, renouvelable).
    - Refus possible (sauf si "edu" via école).
    - Sync immédiat backend (handshake OAuth-inspired).
  - Infos Design : UX simple (Duolingo-like flow) ; RGPD granularité ; Pour seq diagram : flow invite → consent → connexion active. Conditionné par `UserProfile.adult_learner` (backend + frontend). ==Priorité : Haute.==

- **User Story** : En tant qu'élève, je veux gérer mes connexions parentales afin de contrôler les updates envoyés.
  - Critères d'Acceptation :
    - Vue liste connexions : inclut parents (statut, durée, toggle updates emails).
    - Options : renouveler, terminer (avec confirmation).
    - Notification si renouvellement approchant.
  - Infos Design : Liste scrollable ; Privacy-focused toggles. Priorité : Moyenne.

Module : Déclenchement des Updates

- **User Story** : En tant qu'élève connecté à un parent, je veux que des avancées significatives déclenchent des updates automatiques afin de partager mes progrès positivement.
  - Critères d'Acceptation :
    - Triggers : compétence validée, chapitre fini, streak milestone, contrôle réussi (configurable par élève).
    - Pas d'envoi si offline (queue pour sync).
    - Consent vérifié avant tout envoi.
  - Infos Design : Backend auto (event-based via DragonflyDB) ; Pas visible élève sauf opt-in notif. ==Priorité : Haute.==

Module : Réception des Updates (côté Parent)

- **User Story** : En tant que parent connecté (superviseur sans dashboard), je reçois des emails de notification des avancées de mon enfant afin de le soutenir positivement sans avoir à me connecter à l'application.
  - Critères d'Acceptation :
    - Email de notification déclenché par les triggers configurés par l'élève (compétence validée, chapitre fini, streak milestone, contrôle réussi).
    - Contenu email : résumé de l'avancée, chiffre clé (ex: "Lucas a validé sa 5e compétence en Algèbre !"), ton encourageant (Fracto-style).
    - Lien "Voir le détail" → page web statique légère (token temporaire, pas de login app requis).
    - Option "Se désabonner des emails" dans chaque email (RGPD) sans rompre la *Connexion*.
    - Lien "Gérer ma connexion" → interface minimale web (voir durée, accepter renouvellement, terminer la connexion).
  - Infos Design : Email transactionnel (template HTML, Fracto branding) ; Backend DragonflyDB pour queues ; Page web statique légère (pas Flutter) ; Log consent email (RGPD). ==Priorité : Haute.==

# User Stories pour le Dashboard Superviseur

Personas : Superviseur (générique pour Prof/Parent/Tuteur), avec précision si "edu" (Prof école B2B).

#### Interface : Onboarding et Inscription

Module : Inscription et Profil Initial

- **User Story** : En tant que superviseur, je veux un onboarding personnalisé afin de configurer rapidement mon profil et démarrer la supervision.
  - Critères d'Acceptation :
    - Écrans séquentiels : infos connexion (SSO/OAuth, email/mdp), nom/prénom/rôle/établissement/travail.
    - **Étape optionnelle (fortement suggérée) :** "Êtes-vous rattaché à un établissement partenaire ?" → champ Master School Code. Si valide : rattachement immédiat à l'`Organization` + rôle `Supervisor` activé. Peut être complété ultérieurement depuis Paramètres → Mes Organisations.
    - Questions : "Comment connu plateforme ?" et "Comment l'utiliser ?" (suggestions workspaces basées sur réponses).
    - Option ajout élèves immédiate (demandes *Connexion* via QR/link/email).
    - Explication RGPD : transparence data accès (consent élève, sauf "edu").
    - Redirection : création premier workspace + tutoriel Notion-style.
  - Infos Design : UX fluide (stepper wizard) ; Validation live synchrone du MSC ; Intégration backend pour profil ; Pour Figma : composants form réutilisables. ==Priorité : Haute.==

- **User Story** : En tant que superviseur prof "edu", je veux une inscription via SSO GAR (ENT) afin d'être automatiquement rattaché à mon établissement et activer les connexions élèves.
  - Critères d'Acceptation :
    - **Via GAR :** le SSO transmet le profil prof (UAI établissement inclus). Le SI recherche l'`Organization` via l'UAI (clé primaire). Si trouvée → rattachement automatique du compte au rôle `Supervisor`. Si non trouvée → alerte Admin (établissement non-provisionné).
    - Si le prof a déjà un compte B2C (email reconnu) → Account Linking automatique (même principe que côté élève).
    - Les Workspaces peuvent être créés automatiquement depuis les métadonnées de classe GAR (ex: "Terminale Maths - M. Dupont").
    - Flag `edu` activé automatiquement : les données du Workspace sont propriété de l'école.
    - Pop-up RGPD adapté : "Connexion imposée pour élèves pendant durée de la licence établissement."
  - Infos Design : B2B-focused ; Seq Diagram : GAR SSO → UAI lookup → Organization match → Supervisor role + Workspace auto-create. ==Priorité : Haute==.

- **User Story** : En tant que superviseur (prof hors-GAR ou indépendant), je veux entrer un "Master School Code" lors de l'onboarding afin d'être rattaché à mon établissement et accéder à mes droits de Superviseur.
  - Critères d'Acceptation :
    - Champ "Code Établissement" à l'étape onboarding (ou ajout ultérieur depuis Paramètres).
    - Vérification du code → liaison du compte `User` à l'`Organization` correspondante.
    - Rôle mis à jour : `User` → `Supervisor` dans cette `Organization`.
    - Confirmation : "Tu es maintenant superviseur au sein de [Lycée X]."
    - Le superviseur peut créer des Workspaces rattachés à cette `Organization` ; les élèves membres héritent du Premium.
    - Un superviseur peut avoir plusieurs Master School Code (peuvent changer si mutation).
  - Infos Design : Stepper onboarding avec champ optionnel mais fortement suggéré ; Vérification synchrone backend ; Pour UML : création d'un `Membership(User, Organization)` de type 'supervisor'. ==Priorité : Haute==.

Module : Tutoriel Initial

- **User Story** : En tant que superviseur nouveau, je veux un tutoriel rapide afin de découvrir les features sans friction.
  - Critères d'Acceptation :
    - Guide interactif post-onboarding (highlight workspaces, connexions).
    - Skip possible, reprise si besoin.
    - Notion-style (drag/drop exemples).
  - Infos Design : Overlay tours ; Pour C4 : component 'TutorialOverlay'. Priorité : Moyenne.

#### Interface : Workspaces Contextuels

Module : Création et Gestion

- **User Story** : En tant que superviseur, je veux créer un workspace contextuel afin d'organiser ma supervision par groupe ou individu.
  - Critères d'Acceptation :
    - Formulaire : nom propre, icône (emoji/upload).
    - **Statut du Workspace :**
      - `free` (par défaut) : Workspace sans licence, fonctionnalités limitées (pas d'analytics avancés, quota IA réduit). Utilisable sans être rattaché à une `Organization` — c'est le levier PLG.
      - `licensed` : Workspace rattaché à une `Organization` sous licence. Les élèves membres héritent automatiquement du Premium de l'école.
    - Si le superviseur est lié à une `Organization` valide → option de rattacher le Workspace à l'`Organization` (passage automatique en `licensed`).
    - **Transition Free → Licensed :** se fait sans recréation de compte ni de Workspace ; seul le statut change.
    - Ajout élèves via demandes connexion (QR/link, ou auto-injection GAR).
    - Limite de Workspaces par tier SaaS (essai gratuit : 1 Workspace Free).
    - Archivage/partage entre superviseurs (optionnel).
  - Infos Design : Notion-like (pages flexibles) ; Pour UML : classe 'Workspace' avec attrs `status: free|licensed`, `organization_id: nullable`, `is_edu: bool`. ==Priorité : Haute==.

- **User Story** : En tant que superviseur, je veux une overview des élèves dans un workspace afin de voir l'état global rapidement.
  - Critères d'Acceptation :
    - Liste élèves connectés (CRUD : add/remove via connexions).
    - Indicateurs basiques (progress moyen, alertes).
    - Modules activables (ex: analytics Pro-only).
  - Infos Design : Dashboard cards ; Sync backend app élève data. ==Priorité : Haute==.

- **User Story** : En tant que superviseur, je veux un arbre de connaissance moyen par workspace afin d'identifier gaps communs.
  - Critères d'Acceptation :
    - Agrégat visuel (fractal Pythagore moyen des élèves).
    - Highlight forces/faiblesses groupe.
    - Comparaison avec arbres objectifs.
  - Infos Design : Interactif zoomable ; IA pour agrégat ; Pour Figma : composants TreeAggregate. ==Priorité : Haute==.

#### Interface : Fonctions Principales (par Workspace)

Module : Connexions et Demandes

- **User Story** : En tant que superviseur, je veux faire une demande de connexion à un élève afin d'accéder à ses données pour un soutien ciblé.
  - Critères d'Acceptation :
    - Méthodes : email, QR/link, invite direct.
    - Vue status : en attente, acceptée, expirée (renouvellement auto).
    - Détail data accès : compétences, forces/faiblesses (transmis post-consent).
    - "Edu" : auto-connexion sans refus.
  - Infos Design : Boutons action (send request) ; RGPD pop-ups ; Seq pour handshake backend. ==Priorité : Haute==.

Module : Analytics et Visualisation

- **User Story** : En tant que superviseur, je veux une vue précise des forces/faiblesses d'un élève ou groupe afin d'analyser progressions réelles.
  - Critères d'Acceptation :
    - Dashboards : par élève (historiques app), groupe (moyennes).
    - Basé sur data app (compétences évaluées).
    - Export reports (PDF/Excel).
  - Infos Design : Graphs interactifs ; Backend analytics (PostHog intégré) ; ==Priorité : Haute==.

- **User Story** : En tant que superviseur, je veux visualiser et comparer arbres objectifs/élèves afin de guider le cursus.
  - Critères d'Acceptation :
    - Vue side-by-side : arbre élève vs objectif.
    - Highlight gaps pour interventions.
  - Infos Design : Fractal Pythagore réutilisable ; Pour UML : assoc 'TreeViewer'. ==Priorité : Haute==.

- **User Story** : En tant que superviseur, je veux des commentaires Fracto générés IA afin d'avoir des insights bienveillants.
  - Critères d'Acceptation :
    - Génération : encouragements, conseils pédagogiques ciblés (basé forces/faiblesses).
    - Éditable avant envoi.
    - Framing positif.
  - Infos Design : IA LangChain ; UX cards éditable ; No hallucinations (RAG vérifié). Priorité : Moyenne.

Module : Contenu et Recommandations

- **User Story** : En tant que superviseur, je veux explorer contenus plateforme via browser afin de preview avant recommandation.
  - Critères d'Acceptation :
    - Recherche/filtre : leçons, capsules.
    - Preview interactif (blocs texte/image).
  - Infos Design : Notion-like explorer ; Backend content repo (JSON/Markdown). ==Priorité : Haute.==

- **User Story** : En tant que superviseur, je veux recommander contenus aux élèves afin de coller au programme scolaire.
  - Critères d'Acceptation :
    - Sélection : leçons/capsules, push via app (notif élève).
    - Personnalisé par élève/groupe.
  - Infos Design : Boutons recommend ; Sync backend push. ==Priorité : Haute==.

- **User Story** : En tant que superviseur, je veux générer QR/links pour recommandations ou activités afin de partager facilement.
  - Critères d'Acceptation :
    - Génération : QR downloadable, links copiables (projection classe).
    - Lien vers contenus ou activités groupe.
  - Infos Design : QR scanner compatible app élève ; Pour seq : generate → share flow. Priorité : Moyenne.

- **User Story** : En tant que superviseur, je veux déposer des ressources dans le casier partagé afin qu'elles enrichissent l'adaptation IA de mes élèves.
  - Critères d'Acceptation :
    - Upload PDF/exos → conversion IA RAG (pgvector embeddings).
    - À chaque upload : l'élève reçoit une notification actionnable "Prof X a partagé [fichier]" avec bouton "Désactiver". Si pas de choix sous 48h → ressource active par défaut.
    - Le superviseur voit le statut par élève dans l'overview du Workspace : actif / désactivé par l'élève.
    - Limite volume par tier SaaS.
  - Infos Design : Drag/drop uploader ; Sync notification backend (DragonflyDB) ; Statut affiché par élève dans le dashboard Workspace. ==Priorité : Haute==.

Module : Outils Créatifs

- **User Story** : En tant que superviseur, je veux générer arbres objectifs personnalisés afin de guider élèves vers contrôles/exos.
  - Critères d'Acceptation :
    - Création : fractal Pythagore, nodes compétences/objectifs.
    - Envoi via connexion (guide pour contrôles/prépa).
    - Éditable, versions multiples.
  - Infos Design : Builder interactif ; IA suggestions ; Pour Figma : TreeGenerator composants. ==Priorité : Haute==.

- **User Story** : En tant que superviseur, je veux créer activités groupe afin de setup collaborations.
  - Critères d'Acceptation :
    - Setup : exo partagé, challenges via QR/links.
    - Tracking participation (analytics basiques).
    - Intégration arbres objectifs.
  - Infos Design : Wizard création ; Gamifié pour élèves ; Priorité : Moyenne.

#### Interface : Autres Fonctionnalités Globales

Module : Gestion Compte et Infos

- **User Story** : En tant que superviseur, je veux une vue paramètres pour gérer mon compte, mes affiliations et mon abonnement afin de tout maintenir à jour.
  - Critères d'Acceptation :
    - **Profil** : update nom/rôle/email.
    - **Mes Organisations** : liste de toutes les `Organization` auxquelles je suis affilié (ex: Lycée 1, Lycée 2, cours particuliers privé) avec rôle, statut de la licence et Workspaces associés. Actions disponibles :
      - Rejoindre une nouvelle Organisation (saisir un nouveau MSC).
      - Quitter une Organisation (les Workspaces liés sont archivés ou transférés).
    - **Abonnement SaaS** : tier actuel (essai → fondation → pro → illimité), upgrade depuis l'app, billing Stripe.
    - Downgrade/logout.
  - Infos Design : Page paramètres avec sections ; Liste Organisations avec badge statut (licence active / expirée) ; Intégration Stripe-like pour billing. ==Priorité : Haute.==

Module : Notifications et Alerts

- **User Story** : En tant que superviseur, je veux des notifications pour événements clés afin de rester informé en temps réel.
  - Critères d'Acceptation :
    - Push/email : réponses connexions, progress élèves, expirations.
    - Customisable (fréquence).
  - Infos Design : In-app bell + email ; Backend DragonflyDB pour queues. Priorité : Moyenne.

Module : Sécurité et RGPD

- **User Story** : En tant que superviseur, je veux des outils RGPD pour auditer et exporter data afin de respecter conformité.
  - Critères d'Acceptation :
    - Audit logs accès data.
    - Export data élèves sur demande (CSV/PDF).
    - Pop-ups transparence par action.
  - Infos Design : Admin-like logs ; Backend Sentry pour tracking. ==Priorité : Haute==.

Module : Analytics Globaux

- **User Story** : En tant que superviseur, je veux une vue analytics cross-workspaces afin de voir patterns généraux.
  - Critères d'Acceptation :
    - Agrégats : progress global, trends forces/faiblesses.
    - Filtres par rôle/tier.
  - Infos Design : High-level dashboards ; IA insights. Priorité : Moyenne.

Module : Tutoriel et Support

- **User Story** : En tant que superviseur, je veux un help center intégré afin d'obtenir support rapidement.
  - Critères d'Acceptation :
    - Chat/guide interactif.
    - Liens FAQ/RGPD.
  - Infos Design : Embedded chat (ex: Intercom) ; Priorité : Moyenne.

# User stories détaillées pour l'**Admin Panel** (outil interne)

### Interface : Dashboard Accueil (Overview)

- **User Story** : En tant qu'admin, je veux un dashboard d'accueil avec KPI temps réel afin de surveiller la santé globale de la plateforme en un coup d’œil.
  - Critères d'Acceptation :
    - Affichage : DAU/MAU total + par segment (B2C élèves, superviseurs SaaS, élèves "edu" B2B).
    - Métriques monétisation : MRR/ARR, breakdown B2C vs SaaS vs B2B, churn rate.
    - IA : nombre requêtes RAG/LangChain, taux hallucinations (Langfuse/Ragas), coût LLM estimé.
    - Ops : uptime, erreurs 5xx, latence API moyenne (Grafana).
    - Alertes live : top 5 incidents Sentry, pics connexions refusées.
    - Quick search : barre pour trouver user/élève/superviseur/workspace instantanément.
  - Infos Design : Vue full-screen responsive ; Grafana embedded ou custom Vue components ; Refresh auto 30s ; Rouge/vert pour alertes. ==Priorité : Haute.==

- **User Story** : En tant qu'admin, je veux impersonate un utilisateur afin de reproduire et debugger un bug signalé.
  - Critères d'Acceptation :
    - Recherche user → bouton "Impersonate" (ouvre nouvelle tab en mode simulé).
    - Logs action impersonate (qui, quand, user cible).
    - Limite : seulement admins + audit trail permanent.
    - Auto-logout après 30 min inactivité.
  - Infos Design : Secure token temporaire ; Pas d’accès billing sensible en mode impersonate. ==Priorité : Haute.==

### Interface : Gestion Utilisateurs & Rôles

- **User Story** : En tant qu'admin, je veux une liste paginée et filtrable des utilisateurs afin de gérer support, abuse et analytics.
  - Critères d'Acceptation :
    - Filtres : rôle (élève/superviseur/admin), tier (freemium/premium/edu/etc.), pays, dernière activité, handicap activé.
    - Colonnes : ID, email, prénom, rôle, tier, date inscription, établissements/classes liés.
    - Actions bulk : suspendre, ban, reset password, export CSV/JSON.
    - Merge comptes duplicata (manuel validation).
  - Infos Design : Table ag-grid-like ou TanStack ; Export avec filtres appliqués. ==Priorité : Haute==.

- **User Story** : En tant qu'admin, je veux gérer les rôles et permissions RBAC afin de contrôler accès interne.
  - Critères d'Acceptation :
    - Liste admins/support/dev avec niveaux (full/read-only/debug).
    - Ajout/suppression admins.
    - Logs changements rôles.
  - Infos Design : Simple CRUD form ; Backend FastAPI permissions. ==Priorité : Haute==.

### Interface : Connexions Superviseur-Élève (RGPD)

- **User Story** : En tant qu'admin, je veux auditer toutes les connexions superviseur-élève afin de vérifier conformité RGPD et détecter anomalies.
  - Critères d'Acceptation :
    - Liste : superviseur → élève(s), type (normal/edu), statut, durée restante, date accept/renouvellement/refus.
    - Détail transmis : compétences partagées, casier items, arbres objectifs envoyés.
    - Filtre : refus massifs, expirations non-renouvelées, connexions "edu" actives.
    - Export logs consent (version pop-up, timestamp).
  - Infos Design : Timeline view par élève ; Alertes auto sur refus >10% par superviseur. ==Priorité : Haute==.

### Interface : Affiliations & Memberships

- **User Story** : En tant qu'admin, je veux voir et gérer les `Membership` individuelles afin d'auditer les affiliations, résoudre les litiges et assurer la conformité RGPD.
  - Critères d'Acceptation :
    - Vue filtrée par type : `premium_solo` (élève ayant saisi un School Code), `edu` (élève rattaché via Workspace ou GAR), `supervisor` (prof rattaché à une Organization).
    - **Par utilisateur :** liste de toutes ses affiliations actives (Organization, type, date d'entrée, date expiration, méthode — GAR / School Code / Workspace).
    - **Par Organization :** liste de tous les `User` affiliés avec leur type de Membership.
    - Actions support : révoquer manuellement un Membership (fraude, quota dépassé, mauvais rattachement).
    - Export CSV des Memberships pour audit externe (RGPD, réglement litige école).
  - Infos Design : Table filtrable (TanStack) ; Drill-down User ↔ Organization ; Actions audit logées. ==Priorité : Haute==.

### Interface : Contenu & Qualité Pédagogique

- **User Story** : En tant qu'admin, je veux explorer et éditer le contenu pédagogique afin de corriger erreurs mathématiques ou bugs UX.
  - Critères d'Acceptation :
    - Arborescence : `cours → chapitres → capsules → sections → blocs` (texte Markdown, interactive JSON, etc.) — les chapitres sont générés par Pipeline 1 et stockés en DB comme entités propres.
    - Preview full (comme dans app élève).
    - Édition manuelle du `sections_json` d'une capsule via Monaco editor (rare, post-génération Pipeline 2) + comparaison avant/après (versionning capsule).
    - Flag contenu problématique (raison, priorité fix).
  - Infos Design : Tree view + editor Monaco-like pour JSON/Markdown ; Preview iframe. ==Priorité : Haute==.

- **User Story** : En tant qu'admin, je veux monitorer la qualité des réponses IA afin d'améliorer l’adaptation pédagogique.
  - Critères d'Acceptation :
    - Dashboard Langfuse/Ragas : taux hallucinations, pertinence score, feedback élève agrégé.
    - Top 10 réponses flagged (low score ou manual report).
    - **Re-embedding casier** : forcer re-chunking des PDF/fichiers superviseurs uploadés (pgvector) — indépendant du pipeline.
    - **Régénération capsule** : relancer Pipeline 2 pour une capsule spécifique (crée un nouveau `job` en table `jobs`, écrase `sections_json` si succès).
    - Alertes : >5% hallucinations sur 24h.
  - Infos Design : Graphs temporels ; Lien direct vers logs Langfuse. ==Priorité : Haute==.

### Interface : Monitoring & Observabilité

- **User Story** : En tant qu'admin, je veux accéder aux logs et métriques ops afin de diagnostiquer incidents rapidement.
  - Critères d'Acceptation :
    - Intégration Loki/Grafana/Tempo : logs API, traces séquences, métriques VPS/Coolify.
    - Sentry : erreurs groupées + breadcrumbs user.
    - DragonflyDB/pgvector : cache hit rate, slow queries.
    - **Vue jobs pipeline** : liste des jobs Pipeline 1 & 2 depuis la table `jobs` (statut pending/running/completed/failed, durée d'exécution, coût LLM estimé via Langfuse, capsule associée).
    - Alertes configurables (Slack/Email).
  - Infos Design : Embedded Grafana dashboards ; Search logs par user ID ou endpoint. ==Priorité : Haute==.

### Interface : Monétisation & Billing

- **User Story** : En tant qu'admin, je veux gérer les abonnements et licences afin de suivre revenus et churn selon le modèle de chaque type d'Organisation.
  - Critères d'Acceptation :
    - Liste SaaS superviseurs : essai → fondation → pro → illimité (churn reasons si dispo).
    - **B2B Organisations — deux modèles de licence :**
      - `quota_fixe` (écoles, lycées) : quota sièges annuel, date expiration. Alerte si > 100% sièges. Vue : utilisés / max.
      - `per_active_student` (cours du soir, soutien scolaire, organismes privés) : facturation mensuelle basée sur le nb d'élèves Premium actifs dans le mois (Membership active dans la période). Pas de quota plafond — montant variable. Vue : nb actifs ce mois / montant dû.
    - Fin de licence (quota_fixe expiré ou impayé) → switch automatique : élèves repassent en Freemium (sauf B2C perso actif).
    - **B2C :** tracking quotas IA freemium, taux upsell Premium.
    - Actions : refund manuel, upgrade forcé (support), révocation/rotation du Master School Code.
  - Infos Design : Stripe/Paddle dashboard intégré ; Vue `Organization` drill-down : modèle de licence → Workspaces → élèves actifs → montant ; Graphs MRR + ARR différenciés par modèle. ==Priorité : Haute==.

- **User Story** : En tant qu'admin, je veux provisionner une Organisation partenaire (Hors-GAR) afin de configurer sa licence, son Master School Code et adapter l'interface au type de structure.
  - Critères d'Acceptation :
    - **Formulaire — champs clés :**
      - Nom de la structure.
      - Type : `lycée` | `collège` | `privé_scolaire` | `cours_du_soir` | `soutien_scolaire` | `prépa` | `organisme_formation` | `autre`.
      - **Modèle de licence :** `quota_fixe` (nb sièges + date expiration) ou `per_active_student` (facturation mensuelle par élève actif — recommandé pour structures à inscription glissante).
      - **Label UX :** libellé affiché aux utilisateurs pour "Mon École" → configurable : `Mon École` | `Mon Centre` | `Mon Organisme` | `Mon Académie` | `Ma Prépa` | personnalisé.
    - Génération automatique d'un Master School Code unique et mémorable, associé à l'`Organization`.
    - Option révocation/rotation du code.
    - Vue quota (si `quota_fixe`) ou comptage actifs (si `per_active_student`) en temps réel.
    - Possibilité d'associer un domaine email comme validation alternative.
    - **Via GAR :** création automatique dès réception de la commande GAR (UAI = clé primaire, type auto-défini = `lycée` ou `collège`, modèle = `quota_fixe`). L'admin peut ajuster post-création.
  - Infos Design : Formulaire admin CRUD ; `Organization.label_type` et `Organization.licence_model` en DB ; UAI unique constraint ; Audit log rotations de code. ==Priorité : Haute==.

### Interface : Sécurité & RGPD

- **User Story** : En tant qu'admin, je veux traiter les demandes RGPD (export/suppression) afin d’être conforme légalement.
  - Critères d'Acceptation :
    - Workflow : ticket-like (demande user → validation → export JSON/CSV ou delete).
    - Logs toutes suppressions (audit-proof).
    - Scan auto PII leaks (weekly report).
  - Infos Design : Secure download links (expirent 7j) ; ==Priorité : Haute==.

### Interface : Outils Support & Opérationnels

- **User Story** : En tant qu'admin support, je veux voir et répondre aux tickets élèves/superviseurs afin de résoudre problèmes rapidement.
  - Critères d'Acceptation :
    - Liste tickets (intégration Intercom/Zendesk-like).
    - Vue contexte : profil user, dernières capsules, connexions actives.
    - Réponses templates + pièces jointes.
  - Infos Design : Inbox-style ; Priorité : Moyenne.

- **User Story** : En tant qu'admin dev, je veux gérer feature flags afin de rollout progressif ou hotfix.
  - Critères d'Acceptation :
    - Liste flags (offline mode, new IA model, etc.).
    - Pourcentage rollout, A/B stats.
    - Activation/désactivation instantanée.
  - Infos Design : Toggle UI simple ; Backend Redis-like pour flags. Priorité : Moyenne.
