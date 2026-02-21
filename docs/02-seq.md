
# Diagrammes de Séquence Prioritaires — Phase Commando

> **Objectif** : Identifier les processus suffisamment piégeux ou multi-acteurs pour justifier un diagramme de séquence **avant** de coder, même en mode développement rapide.
>
> **Critères de sélection** : chaque processus ci-dessous cumule au moins 2 de ces risques :
>
> - 🔀 **Multi-chemins** : branchements conditionnels qui multiplient les cas d'erreur
> - 🤝 **Multi-acteurs** : coordination entre ≥3 composants/systèmes
> - ⏱️ **Asynchrone** : queues, callbacks, webhooks, timers
> - 🔒 **RGPD / Sécurité** : consentement, audit trail, données sensibles
> - 💥 **Irréversible** : merge de comptes, suppression de données, activation de licences

---

## 1. 🔑 Auth GAR + Account Linking B2C

**Flux** : Élève arrive via ENT → SSO GAR → détection email existant → fusion ou création compte B2C → anti-doublons.

**Pourquoi c'est piégeux :**

- **3 chemins distincts** : (a) email GAR matche un User existant → fusion OTP, (b) aucun match → création rapide B2C, (c) refus temporaire → rappel à chaque connexion GAR.
- **Irréversibilité** : une fusion de comptes mal faite crée un doublon **impossible** à corriger proprement en prod (Memberships, progression, connexions à réconcilier).
- **Multi-systèmes** : GAR SSO (SAML) + OAuth Providers + base interne + système de tokens OTP.
- **Race condition** : si l'élève se connecte simultanément via GAR et via B2C avant la liaison, risque de doublon.

**Acteurs** : Élève, App Mobile, API Backend, GAR/ENT, OAuth Provider, DB.

**Sans ce diagramme** : on code le happy path, on oublie le cas "refus temporaire + rappel", et on se retrouve avec des comptes orphelins en prod.

---

## 2. 🤝 Handshake Connexion Superviseur ↔ Élève

**Flux** : Superviseur envoie demande (QR/email/lien) → notification élève → pop-up consent → accept/refus → données partagées → renouvellement/expiration.

**Pourquoi c'est piégeux :**

- **2 flux parallèles** : connexion normale (consent-based, refusable) vs connexion "edu" (auto-imposée, non-refusable).
- **Lifecycle complet** : `EN_ATTENTE → ACTIVE → EXPIREE → RENOUVELLEMENT_EN_ATTENTE → ACTIVE` — chaque transition a des side-effects (notifs, accès data, audit RGPD).
- **RGPD critique** : le consent doit être versionné, timestampé, et auditable. Un bug ici = non-conformité légale.
- **Multi-méthodes** : QR code, lien direct, email, auto-GAR, auto-Workspace — chacune avec son propre flow de validation du token.

**Acteurs** : Superviseur, Dashboard Web, API Backend, DB, Cache/Queue, Push Service, Élève, App Mobile.

**Sans ce diagramme** : on oublie le renouvellement automatique, l'audit trail RGPD, ou le fallback quand le token QR expire.

---

## 3. 🔄 Sync Offline → Online (Progression)

**Flux** : Élève travaille offline → sauvegarde locale → reconnexion → merge progression → résolution conflits → nouvelles adaptations IA.

**Pourquoi c'est piégeux :**

- **Conflits de données** : l'élève a progressé offline pendant que le serveur a reçu des mises à jour (contenu régénéré, compétences recalculées par un contrôle précédent syncé par un autre device).
- **Ordre des opérations critique** : sync progression → PUIS recalcul compétences → PUIS adaptation IA. Si l'ordre est inversé, l'adaptation se base sur des données obsolètes.
- **Cas limites** : capsule commencée offline mais supprimée côté serveur, ou capsule régénérée (nouvelle version du `sections_json`).
- **Pas de rollback facile** : une fois la progression mergée et les compétences recalculées, il est très coûteux de revenir en arrière.

**Acteurs** : App Mobile (Offline Manager, Local Store), API Backend (Offline Sync Service), DB, Adaptation Service.

**Sans ce diagramme** : on implémente un sync naïf "last write wins" qui écrase la progression serveur ou perd le travail offline de l'élève.

---

## 4. 📧 Pipeline Updates Parents

**Flux** : Événement (compétence validée, chapitre fini, streak) → vérification consent → vérification config triggers → queue → génération email → envoi → lien sécurisé avec token temporaire.

**Pourquoi c'est piégeux :**

- **Chaîne asynchrone longue** : événement → check consent → check config → queue DragonflyDB → worker email → SMTP → callback delivery.
- **Conditions multiples à vérifier** : `adult_learner = false` ET connexion parent active ET trigger activé dans config ET consent vérifié ET pas offline (sinon queue pour sync).
- **Sécurité des liens** : le lien "Voir le détail" utilise un token temporaire — expiration, rotation, protection contre le replay.
- **RGPD** : le parent peut se désabonner des emails **sans** rompre la connexion — deux états indépendants à gérer.

**Acteurs** : App Élève (trigger), API Backend (Parent Update Service), Cache/Queue (DragonflyDB), Email Service, Parent (récepteur).

**Sans ce diagramme** : on envoie des emails à des parents dont le consentement a expiré, ou on oublie le cas "offline → queue → sync → envoi différé".

---

## 5. 🏫 School Code / MSC → Membership + Premium

**Flux** : Élève saisit School Code (ou Superviseur saisit Master School Code) → vérification → création Membership → activation Premium → consommation siège licence.

**Pourquoi c'est piégeux :**

- **3 chemins d'entrée** avec des conséquences différentes : (a) School Code élève → `premium_solo` (pas visible du prof), (b) MSC superviseur → rôle `supervisor` + capacité de créer des workspaces licensed, (c) GAR auto → `edu` + workspace auto-créé.
- **Gestion de quota temps réel** : vérifier quota disponible → consommer atomiquement un siège → gérer le cas "quota atteint pendant la validation" (race condition classique).
- **Licence dual-model** : `quota_fixe` (vérifier nb sièges) vs `per_active_student` (pas de quota, comptage mensuel) — logique complètement différente.
- **Cascade d'effets** : un Membership `edu` via workspace → héritage Premium → mais si l'élève a déjà un abonnement B2C personnel, il ne doit pas perdre ses avantages si la licence école expire.

**Acteurs** : Élève/Superviseur, App/Dashboard, API Backend (Membership Controller, Org Service), DB, Stripe (si upgrade).

**Sans ce diagramme** : on oublie la race condition sur le quota, ou on crée des Memberships en double quand un élève a déjà un `premium_solo` et rejoint un Workspace `edu`.

---

## 6. 🧠 Adaptation IA d'un Bloc (Capsule Runner)

**Flux** : Élève ouvre un bloc → API vérifie type → si adaptatif : chargement contexte (profil + casier actif + compétences + historique) → appel LLM → vérification hallucinations → rendu adapté.

**Pourquoi c'est piégeux :**

- **Logique de priorité** : casier actif > profil mental > historique. Si un fichier superviseur est actif dans le casier, il **prime** sur le profil — mais si le même fichier est désactivé par l'élève, il faut l'exclure du contexte RAG.
- **Latence critique** : l'appel LLM est bloquant pour l'affichage du bloc. Il faut un fallback si timeout (contenu non-adapté, cache last-known).
- **Hallucinations** : chaque réponse IA doit être vérifiée (RAG + scoring Langfuse). Si le score est trop bas, fallback sur contenu statique.
- **6 sous-cas** : définition adaptée, hint post-validation, why explicatif, input libre vérifié IA, i-Input IA élaboré, commentaire Fracto — chacun avec sa propre logique de contexte.

**Acteurs** : App Mobile (Capsule Runner, Block Renderer), API Backend (Adaptation Service), DB (profil, casier), LLM Service, Langfuse.

**Sans ce diagramme** : on implémente un appel LLM naïf sans fallback, et le premier timeout en prod bloque l'expérience élève pendant 30 secondes.

---

## 7. 🔐 GAR SSO Superviseur + Auto-création Workspaces

**Flux** : Prof se connecte via ENT → SSO GAR → UAI lookup → match Organization → rôle Supervisor → Account Linking B2C → auto-création Workspaces depuis métadonnées classes GAR.

**Pourquoi c'est piégeux :**

- **Dépendance externe fragile** : les métadonnées GAR (classes, UAI) peuvent être incomplètes, mal formatées, ou arriver en retard par rapport à la rentrée scolaire.
- **Cas "Organization non-provisionnée"** : si l'UAI transmise ne correspond à aucune Organization en base → alerte Admin → mais le prof est déjà connecté et attend de voir ses classes.
- **Account Linking bidirectionnel** : le même flow que côté élève, mais avec des conséquences différentes (rôle Supervisor au lieu d'Eleve, Workspaces au lieu de progression).
- **Idempotence** : le prof se reconnecte chaque jour via GAR — les Workspaces ne doivent pas être re-créés. Il faut un mécanisme de "déjà vu" basé sur les métadonnées de classe.

**Acteurs** : Superviseur, Browser, GAR/ENT, API Backend (Auth Service, Org Service, Workspace Controller), DB.

**Sans ce diagramme** : on crée des workspaces en doublon à chaque connexion GAR, ou on bloque le prof quand son école n'est pas encore provisionnée.

---

## 8. 📦 Dépôt Casier Partagé (Superviseur → Élève)

**Flux** : Superviseur upload fichier → chunking + embedding pgvector → notification actionnable élève → 48h timer auto-activation → toggle per-ressource → statut visible dashboard superviseur.

**Pourquoi c'est piégeux :**

- **Pipeline asynchrone** : upload → conversion → chunking → embedding → stockage vectors. Chaque étape peut fail indépendamment (fichier corrompu, embedding timeout, pgvector full).
- **Timer 48h** : mécanisme de "silence = consentement" — nécessite un scheduler fiable (cron job ou queue delayed). Si le timer se déclenche pendant que l'élève est offline, il faut gérer le cas.
- **Statut bidirectionnel** : le superviseur voit "actif/désactivé" par élève, l'élève voit "utilisé par l'IA = oui/non" par fichier. Les deux vues doivent être cohérentes en temps réel.
- **RGPD** : indicateur visible de "qui a déposé" et "utilisé par l'IA" — transparence obligatoire.

**Acteurs** : Superviseur, Dashboard, API Backend (Casier Controller), DB + pgvector, Cache/Queue (timer 48h), Push Service, Élève, App Mobile.

**Sans ce diagramme** : on oublie le timer 48h, ou le statut du dashboard superviseur n'est pas syncé avec le toggle de l'élève.

---

## 9. 💳 Expiration Licence → Switch Freemium

**Flux** : Licence Organization expire → détection (cron/webhook) → identification tous Memberships liés → switch chaque élève `edu` vers Freemium → SAUF si abonnement B2C perso actif → notification → archivage Workspaces.

**Pourquoi c'est piégeux :**

- **Cascade massive** : une licence qui expire peut affecter **des centaines d'élèves** simultanément. Il faut un batch fiable, pas un traitement séquentiel qui timeout.
- **Exception B2C** : un élève qui a son propre abonnement Premium ne doit PAS être rétrogradé. Il faut vérifier `Abonnement` personnel avant de toucher au statut.
- **Deux modèles** : `quota_fixe` (date expiration) vs `per_active_student` (impayé → suspension). La détection et le traitement sont différents.
- **Communication** : chaque élève affecté doit recevoir une notification claire et non-anxiogène. Le superviseur doit aussi être prévenu.
- **Rollback** : si la licence est renouvelée dans les 24h suivant l'expiration, il faut pouvoir restaurer les Memberships sans perte.

**Acteurs** : Scheduler (cron), API Backend (Billing Service, Org Service), DB, Stripe, Cache/Queue (notifications batch), Push/Email Services.

**Sans ce diagramme** : on rétrograde par erreur des élèves qui ont un abo perso, ou on oublie de notifier le superviseur.

---

## 10. 📝 Feedback Post-Contrôle + Update Arbre

**Flux** : Élève termine capsule contrôle → calcul scores par compétence → appel LLM pour synthèse prof-like → génération rapport → update niveaux compétences → mise à jour arbre Pythagore → redirection centre connaissance.

**Pourquoi c'est piégeux :**

- **Chaîne de dépendances stricte** : score brut → scoring par compétence → appel LLM (avec contexte compétences) → sauvegarde feedback → update `UserCompetence` → regeneration `CompetenceTree` → push notification. **Chaque étape dépend de la précédente.**
- **LLM non-déterministe** : le feedback généré doit être "prof-like", positif, et pertinent. Mais le LLM peut halluciner des conseils incorrects — nécessite scoring Langfuse avant affichage.
- **Concurrence** : si l'élève commence une autre capsule pendant que le feedback est en cours de génération, les compétences ne sont pas encore à jour pour l'adaptation.
- **Affichage** : le feedback doit être prêt quand l'écran de fin s'affiche. Si le LLM est lent, il faut un état intermédiaire "Fracto analyse ton travail..." avec polling ou WebSocket.

**Acteurs** : App Mobile (Capsule Runner), API Backend (Progress Controller, Adaptation Service), LLM Service, Langfuse, DB, App Mobile (Knowledge Center).

**Sans ce diagramme** : on affiche un écran de fin vide pendant 10 secondes en attendant le LLM, ou on met à jour l'arbre avant que le feedback soit vérifié.

---

## 11. 🗑️ RGPD : Export et Suppression de Compte

**Flux** : Élève demande export/suppression → création ticket → validation admin → collecte données transversales → génération archive ou suppression cascade → lien sécurisé temporaire → audit log.

**Pourquoi c'est piégeux :**

- **Portée transversale** : un `User` est lié à des dizaines de tables (progression, sessions, compétences, casier, connexions, memberships, notifications, audit logs). L'export doit être exhaustif et la suppression complète.
- **Délai légal** : RGPD impose un traitement sous 30 jours. Il faut un workflow ticket-like avec suivi et alertes si deadline approche.
- **Données partagées** : les `Connection` impliquent deux User. Supprimer un élève ne doit pas supprimer les données du superviseur. Le casier partagé contient des fichiers déposés par le superviseur.
- **Irréversibilité** : une suppression de compte est définitive. Le lien de téléchargement de l'export expire. Il faut des confirmations et des logs audit-proof.
- **pgvector** : les embeddings du casier doivent aussi être purgés, sinon les données persistent dans l'espace vectoriel.

**Acteurs** : Élève, App Mobile, API Backend (RGPD Service), DB, pgvector, Admin (validation), Email Service (lien export).

**Sans ce diagramme** : on oublie de purger les vectors pgvector, ou on supprime les données superviseur en cascade.

---

## Récapitulatif et Priorisation

| # | Processus | Risques | Priorité Seq |
|---|---|---|---|
| 1 | Auth GAR + Account Linking | 🔀🤝💥 Multi-chemins, irréversible | **P0** |
| 2 | Handshake Connexion | 🔀🤝🔒⏱️ RGPD, lifecycle complet | **P0** |
| 3 | Sync Offline → Online | 🔀💥⏱️ Conflits, irréversible | **P0** |
| 4 | Pipeline Updates Parents | ⏱️🔒🤝 Async, consent, multi-conditions | **P1** |
| 5 | School Code / MSC → Premium | 🔀💥🤝 Race conditions, cascade | **P1** |
| 6 | Adaptation IA Bloc | 🤝⏱️🔀 Latence, fallback, 6 sous-cas | **P1** |
| 7 | GAR SSO Superviseur | 🔀🤝💥 Externe fragile, idempotence | **P1** |
| 8 | Dépôt Casier Partagé | ⏱️🤝🔒 Timer 48h, pipeline async | **P2** |
| 9 | Expiration Licence → Freemium | 💥⏱️🤝 Cascade massive, exception B2C | **P2** |
| 10 | Feedback Contrôle + Arbre | ⏱️🤝🔀 Chaîne dépendances, LLM lent | **P2** |
| 11 | RGPD Export/Suppression | 🔒💥🤝 Irréversible, transversal | **P2** |

> **P0** = à diagrammer **avant** de poser la première ligne de code.
> **P1** = à diagrammer dès que le squelette du P0 est en place.
> **P2** = peut être codé en mode commando, mais le diagramme évitera un refacto coûteux.
