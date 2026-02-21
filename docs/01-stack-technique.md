# Stack Technique — FRACTIS

> **Contexte** : Équipe de 4 juniors, budget étudiants, première app.
> **Contraintes directrices** : Budget limité · Pertinence · Scalabilité · Résilience · Privacy max · Souveraineté data (France/EU) · Anti dette technique · Pen-test ready.

---

## Infrastructure

### Répartition sur 2 VPS

| VPS | Rôle | Services |
|-----|------|----------|
| **VPS Principal** (Contabo Cloud VPS 20 — 6 vCPU, 12 GB RAM, 100 GB NVMe) | Production critique | PostgreSQL, DragonflyDB, MinIO, FastAPI, Celery, Coolify |
| **VPS Secondaire** (perso) | Observabilité & outils internes | Langfuse, LGTM stack, GlitchTip, PostHog |

> [!IMPORTANT]
> **Logique de séparation** : Les outils d'observabilité sont des consommateurs passifs — ils reçoivent des données en HTTP/push. Si le VPS secondaire tombe, l'app continue de fonctionner, on perd juste le monitoring temporairement.
>
> **Liaison** : Tunnel WireGuard entre les deux VPS (chiffré, réseau privé).

### Contabo VPS (Germany) — Souveraineté EU

- **Pourquoi** : Meilleur rapport prix/performance pour un budget étudiant. Datacenter EU = conformité RGPD.
- **Alternative rejetée** : Hetzner (plus cher à specs équivalentes).

### Coolify — PaaS Self-hosted

- **Pourquoi** : Déploiement simplifié (équivalent Heroku/Vercel self-hosted), gestion Docker, SSL auto, reverse proxy intégré. Zéro vendor lock-in.
- **Alternative rejetée** : CapRover (moins maintenu), Dokku (moins de fonctionnalités).

### ScaleWay — Cloud Bursting + Backups S3

- **Pourquoi** : Cloud français (souveraineté), pricing étudiant-friendly. Utilisé pour :
  - **Cloud Bursting** : absorber les pics (rentrée scolaire, examens).
  - **Object Storage S3** : destination backups PostgreSQL quotidiens (`pg_dump` → ScaleWay S3). Coût : ~€0.01/GB/mois.

---

## Data

### PostgreSQL + pgvector + pg_cron

- **Pourquoi** : DB relationnelle mature + recherche vectorielle (RAG pour casier/adaptation IA) en une seule base. `pg_cron` pour les tâches planifiées (expiration licences, timer 48h casier partagé).
- **Alternative rejetée** : MongoDB (perte de l'intégrité relationnelle nécessaire pour memberships, connexions, RGPD).

### DragonflyDB — Cache + Celery Broker

- **Pourquoi** : Drop-in Redis compatible, plus performant, consomme moins de RAM. Sert de broker pour Celery, cache sessions, feature flags, pub/sub pour notifications.
- **Alternative rejetée** : Redis (plus gourmand en RAM pour les mêmes fonctionnalités).

### MinIO — Stockage Objet S3-compatible + Serveur d'Assets

- **Pourquoi** : Self-hosted, souveraineté data. Stocke les fichiers casier (PDF, images), assets cours, exports RGPD. Sert aussi directement les assets statiques via presigned URLs ou bucket public (reverse proxy Coolify/Caddy devant avec cache headers).
- **Flow casier** : Upload → MinIO (stockage brut) → Celery worker (chunking) → pgvector (embeddings).
- **[FUTUR] CDN** : Si la bande passante VPS sature (milliers d'utilisateurs simultanés) ou internationalisation hors France, il suffira de placer un CDN (ex: Bunny.net, Cloudflare) devant MinIO. Changement trivial (URL de base des assets), zéro modification de code.

---

## Backend

### FastAPI

- **Pourquoi** : Async natif, typing Python fort, documentation OpenAPI auto-générée, courbe d'apprentissage douce pour juniors. Écosystème Python = accès direct aux libs ML/IA.
- **Alternative rejetée** : Django REST Framework (plus lourd, moins performant async), Express.js (perte de l'écosystème Python ML).

### SQLModel + Alembic

- **Pourquoi** : SQLModel unifie ORM SQLAlchemy et schéma Pydantic (un seul modèle pour DB + API validation). Alembic pour les migrations de schéma robustes et versionnées.

### Celery — Workers Async

- **Pourquoi** : Tâches asynchrones lourdes : pipeline IA, embedding casier, emails parents, batch expiration licences, génération exports RGPD. Broker = DragonflyDB.

### slowapi — Rate Limiting

- **Pourquoi** : Rate limiting par user/tier (freemium vs premium vs edu) et throttling des appels LLM (protection budget Groq). Léger, s'intègre nativement avec FastAPI, utilise DragonflyDB comme backend.

### WebSocket (FastAPI natif)

- **Pourquoi** : Temps réel nécessaire pour : état de génération feedback ("Fracto analyse ton travail..."), notifications in-app, statut pipeline jobs admin. FastAPI supporte nativement les WebSockets, DragonflyDB sert de pub/sub.

---

## Auth

### Ory Kratos — Identité

- **Pourquoi** : Open-source, self-hosted, léger (~200 MB RAM). Permet de construire ses propres UIs d'authentification (custom frontend Flutter). Gère les flows : email/mdp, OAuth (Google/Apple), 2FA, récupération de compte, Account Linking.
- **Alternative rejetée** : Keycloak (plus lourd ~1 GB RAM, impose ses propres UIs, over-engineered pour notre cas).

### RBAC maison dans FastAPI — Autorisation

- **Pourquoi** : Le RBAC de FRACTIS est très spécifique (élève/superviseur/admin + contexte edu/B2C + Membership + connexions consent-based). Un RBAC maison dans les dépendances FastAPI est plus simple et adapté qu'une solution générique.

### [FUTUR] Bridge SAML→OIDC pour GAR

- **Quand** : Dès signature du premier partenariat GAR (Éducation Nationale).
- **Solution envisagée** : `satosa` (Python, open-source) — reçoit du SAML côté GAR, expose un OIDC provider côté Kratos. Léger (~200 MB RAM), peut tourner sur le VPS secondaire.
- **Pourquoi pas maintenant** : Les établissements partenaires initiaux sont hors-GAR.

---

## LLM / IA

### LangChain + Groq SDK — Appels LLM

- **Pourquoi** : Groq = inférence ultra-rapide (critique pour adaptation blocs en temps réel). LangChain comme couche d'abstraction au-dessus du SDK Groq apporte :
  - Intégration native Langfuse (tracing automatique via `CallbackHandler`).
  - Possibilité de switch de provider LLM sans réécrire le code.
  - Templates de prompts structurés.
- **Usage** : Adaptation de blocs, hints, why, définitions, commentaires Fracto, feedback post-contrôle.

### LangGraph — Pipelines de Création de Contenu

- **Pourquoi** : Workflows multi-étapes (Pipeline 1 & 2) avec branchements conditionnels, retry, état partagé entre nœuds. LangGraph gère le graphe d'exécution nativement.
- **Usage** : Génération de cours (Pipeline 1 : structure) et capsules (Pipeline 2 : contenu).

### Langfuse self-hosted — LLM Ops

- **Pourquoi** : Tracing complet des appels LLM (latence, tokens, coût), scoring hallucinations, quality monitoring. Self-hosted = souveraineté data IA. Hébergé sur VPS secondaire.

---

## Observabilité (VPS Secondaire)

### LGTM Stack self-hosted — Infra Monitoring

- **Composants** : Grafana (dashboards) + Loki (logs) + Tempo (traces) + Mimir (métriques).
- **Pourquoi** : Couverture complète open-source. Collecte via Prometheus scrape et Loki push depuis le VPS principal.

### GlitchTip self-hosted — Error Tracking

- **Pourquoi** : Alternative Sentry open-source, self-hosted. Cohérent avec la souveraineté data.
- **Alternative rejetée** : Sentry cloud (données hors EU, coût).

### PostHog self-hosted — Product Analytics

- **Pourquoi** : Analytics produit (DAU/MAU, funnels, engagement) + feature flags intégrés pour rollout progressif. Self-hosted = RGPD compliant.

---

## Frontends

### Flutter — App Élève (iOS/Android)

- **Pourquoi** : Cross-platform natif, performances GPU pour animations Lottie/interactives, support offline robuste (Hive/Isar pour local DB), un seul codebase pour iOS + Android.

### Flutter Web — Dashboard Superviseur

- **Pourquoi** : Réutilisation du **moteur de rendu de capsules Flutter** pour la preview de cours dans le dashboard. Évite de maintenir un renderer dupliqué. C'est une webapp de travail, pas une landing : le temps de chargement initial de Flutter Web n'est pas un problème.

### Flutter Web — Admin Panel

- **Pourquoi** : Même argument : le moteur de rendu Flutter est nécessaire pour visualiser, vérifier et manager les cours/capsules. Outil interne, pas de contrainte SEO.

### Nuxt — Landing Page + Page Preview Partage

- **Pourquoi** : SEO, SSR, performance pour la vitrine publique. Maîtrise de l'équipe sur ce framework.
- **Page preview partage** : Quand un élève partage un lien de capsule, la page Nuxt sert de shell (OG meta tags pour preview social, boutons stores, deep link). Le rendu de la capsule elle-même est affiché via un **iframe Flutter Web** (build allégé du renderer, hébergé sur un sous-domaine `preview.fractis.fr`).

### Deep Linking — Universal Links / App Links natifs

- **Pourquoi** : Solution la plus simple, gratuite, sans dépendance à un service tiers. Deux fichiers JSON hébergés sur le domaine Nuxt (`.well-known/apple-app-site-association` + `.well-known/assetlinks.json`) + package Flutter `app_links`.
- **Alternative rejetée** : Branch.io, Firebase Dynamic Links (dépendance externe, Firebase DL deprecated).

---

## Services Externes (pragmatisme)

### Brevo — Email Transactionnel

- **Pourquoi** : Entreprise française, RGPD-native, pricing adapté startups. Utilisé pour : updates parents, récupération compte, notifications RGPD.

### Stripe + Stripe Tax — Paiement

- **Pourquoi** : Standard industrie, gère les deux modèles de licence (`quota_fixe` + `per_active_student`), webhooks robustes, Stripe Tax pour la TVA automatique.

### FCM / APNs — Push Notifications

- **Pourquoi** : Inévitable pour le push mobile. Pas d'alternative viable pour iOS (APNs obligatoire) ni Android (FCM standard de facto).

---

## Backups

### pg_dump → ScaleWay S3

- **Fréquence** : Quotidien (cron via `pg_cron` ou Coolify).
- **Rétention** : 30 jours glissants.
- **Coût** : < €1/mois pour quelques GB.
- **Restauration** : `pg_restore` depuis le dump S3.
