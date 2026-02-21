workspace "Projet FRACTIS" "Architecture et conception du projet FRACTIS — Plateforme éducative IA" {

    !docs docs

    model {

        // ══════════════════════════════════════════════════════
        // PERSONAS
        // ══════════════════════════════════════════════════════
        eleve = person "Élève" "Apprend les mathématiques via l'app mobile. Mineur ou adulte en formation."
        superviseur = person "Superviseur" "Prof, tuteur ou indépendant. Gère workspaces et suit la progression des élèves."
        parent = person "Parent" "Reçoit des emails de notification sur les avancées de son enfant."
        admin = person "Administrateur" "Opère la plateforme : monitoring, RGPD, billing, qualité IA."
        visiteur = person "Visiteur" "Découvre FRACTIS via le site vitrine ou un lien de capsule partagé."

        // ══════════════════════════════════════════════════════
        // SYSTÈME PRINCIPAL — FRACTIS (avec Containers et Components)
        // ══════════════════════════════════════════════════════
        fractis = softwareSystem "FRACTIS" "Plateforme éducative IA adaptative pour les mathématiques." {

            // ──────────────────────────────────────────────────
            // Container : App Élève (Flutter)
            // ──────────────────────────────────────────────────
            appMobile = container "App Élève" "Application mobile Flutter pour l'apprentissage adaptatif." "Flutter (iOS/Android)" {
                appOnboarding = component "Onboarding Module" "Écrans séquentiels de configuration du profil élève (adult_learner, handicap, objectifs)." "Flutter Widget"
                appAuth = component "Auth Module" "Écrans login B2C (email/OAuth) et GAR SSO, Account Linking." "Flutter Widget"
                appNavBar = component "Navigation Bar" "Barre de navigation 3 icônes (Home, Centre Connaissance, Cours) avec swipe gestures." "Flutter Widget"
                appHome = component "Home Screen" "Commentaire Fracto adapté, derniers cours, bouton streak, accès paramètres." "Flutter Widget"
                appCourseList = component "Course List" "Liste scrollable de cours avec miniatures et catégories dynamiques." "Flutter Widget"
                appCapsulePath = component "Capsule Path" "Chemin de capsules par cours, groupées par chapitres, progression visuelle." "Flutter Widget"
                appCapsuleRunner = component "Capsule Runner" "Moteur de rendu des capsules (leçon/training/contrôle) : sections, blocs, inputs." "Flutter Widget"
                appBlockRenderer = component "Block Renderer" "Rendu des blocs variés (texte, définition, QCO/QCM, Input, i-Input, Lottie, interactive)." "Flutter Widget"
                appKnowledgeCenter = component "Knowledge Center" "Vue centrale : feedback Fracto, arbre compétences, swipe casier/cerveau." "Flutter Widget"
                appCompetenceTree = component "Competence Tree View" "Visualisation de l'arbre fractal Pythagore interactif (zoom, clic, partage)." "Flutter Widget"
                appSettings = component "Settings Screen" "Paramètres : profil, mon établissement, connexions, accessibilité, RGPD, déconnexion." "Flutter Widget"
                appConnections = component "Connections Manager" "Gestion des connexions superviseurs et parents (accept/refus/renouvellement)." "Flutter Widget"
                appOfflineManager = component "Offline Manager" "Cache capsules récentes, gestion hors-ligne, sync à la reconnexion, warnings." "Flutter Widget"
                appAccessibility = component "Accessibility Engine" "Adaptations dyslexie (font, espacement, TTS) et autisme (ton calme, animations réduites)." "Flutter Widget"
                appLocalStore = component "Local Storage" "Stockage local (Hive/Isar) pour cache offline, progression, préférences." "Hive / Isar"
                appApiClient = component "API Client" "Client HTTP pour communiquer avec l'API Backend." "Dio / HTTP"
            }

            // ──────────────────────────────────────────────────
            // Container : Dashboard Superviseur (Flutter Web)
            // ──────────────────────────────────────────────────
            dashboardWeb = container "Dashboard Superviseur" "Application web pour supervision, analytics et recommandations. Réutilise le moteur de rendu Flutter pour la preview des cours." "Flutter Web" {
                dashOnboarding = component "Supervisor Onboarding" "Inscription, profil, saisie Master School Code, tutoriel." "Flutter Widget"
                dashWorkspaceManager = component "Workspace Manager" "Création, gestion et archivage de workspaces (free/licensed)." "Flutter Widget"
                dashStudentOverview = component "Student Overview" "Vue d'ensemble des élèves d'un workspace : indicateurs, alertes, progression." "Flutter Widget"
                dashAnalytics = component "Analytics Dashboard" "Forces/faiblesses par élève ou groupe, export PDF/Excel." "Flutter Widget"
                dashTreeViewer = component "Tree Viewer" "Visualisation arbres compétences (élève, objectif, moyen workspace), comparaison side-by-side." "Flutter Widget"
                dashTreeBuilder = component "Objective Tree Builder" "Création d'arbres objectifs personnalisés pour guider les élèves." "Flutter Widget"
                dashContentBrowser = component "Content Browser" "Exploration et preview des cours/capsules via le moteur de rendu Flutter partagé." "Flutter Widget"
                dashRecommender = component "Content Recommender" "Sélection et push de contenus recommandés aux élèves/groupes." "Flutter Widget"
                dashCasierUploader = component "Shared Casier Uploader" "Dépôt de ressources (PDF/exos) dans le casier partagé des élèves." "Flutter Widget"
                dashConnectionManager = component "Connection Manager" "Demandes de connexion élèves (QR/link/email), statuts, renouvellements." "Flutter Widget"
                dashSettingsAccount = component "Account Settings" "Gestion profil, organisations, abonnement SaaS (Stripe), déconnexion." "Flutter Widget"
                dashRGPD = component "RGPD Tools" "Audit logs accès, export données élèves, transparence conformité." "Flutter Widget"
                dashApiClient = component "API Client" "Client HTTP pour communiquer avec l'API Backend." "Dio / HTTP"
            }

            // ──────────────────────────────────────────────────
            // Container : Admin Panel (Flutter Web)
            // ──────────────────────────────────────────────────
            adminPanel = container "Admin Panel" "Outil interne pour monitoring, billing, RGPD et gestion contenu. Réutilise le moteur de rendu Flutter pour vérification des capsules." "Flutter Web" {
                admDashboard = component "KPI Dashboard" "DAU/MAU, MRR/ARR, métriques IA, ops, alertes live, quick search." "Flutter Widget"
                admUserManager = component "User Manager" "Liste paginée/filtrable utilisateurs, actions bulk (suspend/ban/reset/export)." "Flutter Widget"
                admRBAC = component "RBAC Manager" "Gestion rôles et permissions admin (full/read-only/debug/support)." "Flutter Widget"
                admImpersonate = component "Impersonate Tool" "Simulation de session utilisateur pour debug (token temporaire, audit trail)." "Flutter Widget"
                admConnectionAudit = component "Connection Auditor" "Audit des connexions superviseur-élève, conformité RGPD, timeline." "Flutter Widget"
                admMembershipViewer = component "Membership Viewer" "Vue et gestion des affiliations (premium_solo/edu/supervisor), drill-down User-Org." "Flutter Widget"
                admContentEditor = component "Content Editor" "Arborescence cours, preview via moteur Flutter, édition JSON/Markdown, flag contenu." "Flutter Widget"
                admAIQuality = component "AI Quality Monitor" "Dashboard Langfuse, hallucinations, re-embedding, régénération capsule." "Flutter Widget"
                admMonitoring = component "Ops Monitoring" "Logs Grafana/Loki/Tempo, GlitchTip erreurs, jobs pipeline (statut, coût LLM)." "Flutter Widget"
                admBilling = component "Billing Manager" "Abonnements SaaS, licences B2B (quota_fixe/per_active_student), refunds." "Flutter Widget"
                admOrgProvisioner = component "Organization Provisioner" "Création Organisations (type, licence, label UX, Master School Code, UAI)." "Flutter Widget"
                admRGPD = component "RGPD Handler" "Workflow demandes export/suppression, scan PII, audit logs." "Flutter Widget"
                admApiClient = component "API Client" "Client HTTP pour communiquer avec l'API Backend." "Dio / HTTP"
            }

            // ──────────────────────────────────────────────────
            // Container : Site Web Public (Nuxt)
            // ──────────────────────────────────────────────────
            siteWeb = container "Site Web Public" "Landing page vitrine et page de preview capsules partagées (avec iframe Flutter Web pour le rendu)." "Nuxt (SSR)" "Web Browser"

            // ──────────────────────────────────────────────────
            // Container : Preview Renderer (Flutter Web)
            // ──────────────────────────────────────────────────
            previewRenderer = container "Preview Renderer" "Build allégé du moteur de rendu Flutter (read-only) pour preview capsules partagées, intégré en iframe dans le site Nuxt." "Flutter Web"

            // ──────────────────────────────────────────────────
            // Container : API Backend (FastAPI)
            // ──────────────────────────────────────────────────
            apiBackend = container "API Backend" "Logique métier, authentification, progression, connexions, adaptation IA. Inclut rate limiting (slowapi) et WebSocket." "FastAPI (Python)" {
                apiAuthController = component "Auth Controller" "Endpoints authentification : login email/OAuth, GAR SSO, Account Linking, 2FA, tokens." "FastAPI Router"
                apiOnboardingController = component "Onboarding Controller" "Endpoints configuration profil (élève et superviseur), étapes séquentielles." "FastAPI Router"
                apiCourseController = component "Course Controller" "Endpoints cours, chapitres, capsules, sections, blocs (CRUD + lecture hiérarchique)." "FastAPI Router"
                apiProgressController = component "Progress Controller" "Endpoints progression : sauvegarde position, reprise, derniers cours, sessions." "FastAPI Router"
                apiCompetenceController = component "Competence Controller" "Endpoints arbres compétences : génération, comparaison, partage, agrégat workspace." "FastAPI Router"
                apiConnectionController = component "Connection Controller" "Endpoints connexions : demande, accept/refus, renouvellement, list, connexions edu auto." "FastAPI Router"
                apiWorkspaceController = component "Workspace Controller" "Endpoints workspaces : CRUD, rattachement org, overview élèves, arbre moyen." "FastAPI Router"
                apiMembershipController = component "Membership Controller" "Endpoints affiliations : School Code, Master School Code, GAR auto, révocation." "FastAPI Router"
                apiCasierController = component "Casier Controller" "Endpoints casier : upload fichiers, toggle activation, ressources superviseurs partagées." "FastAPI Router"
                apiRecommendController = component "Recommendation Controller" "Endpoints recommandations : push contenus, QR/links, notifications élèves." "FastAPI Router"
                apiAnalyticsController = component "Analytics Controller" "Endpoints analytics : forces/faiblesses, reports, export PDF/Excel." "FastAPI Router"
                apiAdminController = component "Admin Controller" "Endpoints admin : users CRUD, RBAC, impersonate, billing, RGPD, orgs provisioning." "FastAPI Router"
                apiNotifController = component "Notification Controller" "Endpoints notifications : in-app, push, emails parents, warnings offline. WebSocket pour temps réel." "FastAPI Router"
                apiAdaptationService = component "Adaptation Service" "Service IA : adaptation contenu (profil + casier), hints, why, définitions, feedback contrôle." "Python Service"
                apiFractoService = component "Fracto Comment Service" "Service IA : génération commentaires Fracto adaptés (heure, profil, historique)." "Python Service"
                apiParentUpdateService = component "Parent Update Service" "Service événementiel : triggers (compétence, chapitre, streak) vers emails parents." "Python Service"
                apiOfflineSyncService = component "Offline Sync Service" "Service de synchronisation : merge progression offline, résolution conflits." "Python Service"
                apiAuthService = component "Auth Service" "Logique auth : validation credentials, GAR SSO, Account Linking, token management." "Python Service"
                apiOrgService = component "Organization Service" "Logique organisations : provisioning, licences, quotas, School Codes, UAI lookup." "Python Service"
                apiBillingService = component "Billing Service" "Logique billing : Stripe webhooks, tiers SaaS, facturation B2B, switch freemium." "Python Service"
                apiRGPDService = component "RGPD Service" "Logique RGPD : export data, suppression, audit logs, scan PII." "Python Service"
                apiJobRunner = component "Pipeline Job Runner" "Exécution et suivi des jobs Pipeline 1 et 2 (statut, coût LLM, régénération)." "Python Service"
            }

            // ──────────────────────────────────────────────────
            // Container : Celery Workers
            // ──────────────────────────────────────────────────
            celeryWorkers = container "Celery Workers" "Workers asynchrones pour tâches lourdes : pipelines IA, embedding casier, emails, batch licence." "Celery (Python)"

            // ──────────────────────────────────────────────────
            // Containers : Datastores
            // ──────────────────────────────────────────────────
            dbPostgres = container "Base de Données" "Stocke utilisateurs, profils, cours, progression, connexions, memberships, organisations. pgvector pour embeddings RAG." "PostgreSQL + pgvector + pg_cron" "Database"
            cacheQueue = container "Cache & Queues" "Cache sessions, broker Celery, pub/sub notifications, feature flags." "DragonflyDB" "Database"
            objectStore = container "Stockage Objet" "Fichiers casier (PDF, images), assets cours, exports RGPD. Sert aussi directement les assets statiques via presigned URLs (reverse proxy Coolify avec cache headers)." "MinIO (S3-compatible)" "Database"

            // ──────────────────────────────────────────────────
            // Container : Identity Provider
            // ──────────────────────────────────────────────────
            identityProvider = container "Identity Provider" "Gestion identité self-hosted : flows login, OAuth, 2FA, recovery, Account Linking. Custom UIs Flutter." "Ory Kratos"
        }

        // ══════════════════════════════════════════════════════
        // SYSTÈMES EXTERNES
        // ══════════════════════════════════════════════════════
        gar = softwareSystem "GAR / ENT" "SSO Éducation Nationale, métadonnées classes/établissements." "Existing System"
        oauthProviders = softwareSystem "OAuth Providers" "Google, Apple — authentification B2C." "Existing System"
        llmService = softwareSystem "Groq (LLM)" "Inférence LLM ultra-rapide via LangChain/LangGraph pour adaptation pédagogique et génération contenu." "Existing System"
        stripeBilling = softwareSystem "Stripe" "Abonnements SaaS, facturation B2B et Stripe Tax (TVA auto)." "Existing System"
        emailService = softwareSystem "Brevo" "Emails transactionnels (updates parents, RGPD, récupération). Entreprise française, RGPD-native." "Existing System"
        pushService = softwareSystem "FCM / APNs" "Notifications push mobile." "Existing System"
        langfuse = softwareSystem "Langfuse" "Observabilité IA self-hosted : tracing LLM, hallucinations, scores, coût. Hébergé VPS secondaire." "Existing System"
        posthog = softwareSystem "PostHog" "Analytics produit self-hosted : DAU/MAU, funnels, feature flags. Hébergé VPS secondaire." "Existing System"
        glitchtip = softwareSystem "GlitchTip" "Error tracking self-hosted (alternative Sentry). Hébergé VPS secondaire." "Existing System"
        grafanaStack = softwareSystem "LGTM Stack" "Monitoring ops self-hosted : Grafana + Loki + Tempo + Mimir. Hébergé VPS secondaire." "Existing System"
        scalewayS3 = softwareSystem "ScaleWay S3" "Object Storage pour backups PostgreSQL quotidiens et cloud bursting." "Existing System"


        // ══════════════════════════════════════════════════════
        // RELATIONS — LEVEL 1 (System Context)
        // ══════════════════════════════════════════════════════
        eleve -> fractis "Apprend, progresse, gère profil et casier" "HTTPS"
        superviseur -> fractis "Supervise élèves, workspaces, recommandations" "HTTPS"
        admin -> fractis "Monitore, billing, RGPD, qualité IA" "HTTPS"
        visiteur -> fractis "Découvre FRACTIS, preview capsules partagées" "HTTPS"
        fractis -> gar "Auth SSO ENT, métadonnées UAI" "SAML / OAuth2"
        fractis -> oauthProviders "Auth B2C" "OAuth2 / OIDC"
        fractis -> llmService "Adaptation IA, feedback, génération contenu" "API REST"
        fractis -> stripeBilling "Billing SaaS et B2B" "Stripe API"
        fractis -> emailService "Emails transactionnels" "SMTP / API"
        fractis -> pushService "Notifications push" "FCM / APNs"
        fractis -> langfuse "Traces et scoring IA" "API REST"
        fractis -> posthog "Événements analytics" "API REST"
        fractis -> glitchtip "Erreurs applicatives" "SDK"
        fractis -> grafanaStack "Métriques ops et logs" "Prometheus / Loki"
        fractis -> scalewayS3 "Backups PostgreSQL quotidiens" "S3 API"

        fractis -> parent "Emails avancées enfant" "Email"

        // ══════════════════════════════════════════════════════
        // RELATIONS — LEVEL 2 (Containers)
        // ══════════════════════════════════════════════════════

        // Personas → Containers
        eleve -> appMobile "Utilise l'app mobile" "HTTPS"
        superviseur -> dashboardWeb "Utilise le dashboard web" "HTTPS"
        admin -> adminPanel "Utilise l'admin panel" "HTTPS"
        visiteur -> siteWeb "Découvre FRACTIS, preview capsule partagée" "HTTPS"

        // Site Web → Preview
        siteWeb -> previewRenderer "Intègre le renderer en iframe pour preview capsules" "iframe HTTPS"
        siteWeb -> apiBackend "Fetch métadonnées capsule (OG tags SSR)" "JSON/HTTPS"
        previewRenderer -> apiBackend "Fetch contenu capsule pour rendu" "JSON/HTTPS"

        // Frontend → API
        appMobile -> apiBackend "Requêtes API" "JSON/HTTPS"
        dashboardWeb -> apiBackend "Requêtes API" "JSON/HTTPS"
        adminPanel -> apiBackend "Requêtes API" "JSON/HTTPS"

        // Frontend → Identity Provider
        appMobile -> identityProvider "Flows auth (login, register, recovery)" "HTTPS"
        dashboardWeb -> identityProvider "Flows auth superviseur" "HTTPS"
        adminPanel -> identityProvider "Flows auth admin" "HTTPS"

        // API → Identity Provider
        apiBackend -> identityProvider "Validation sessions et tokens" "HTTPS"

        // API → Datastores
        apiBackend -> dbPostgres "Lit et écrit données" "SQL/TCP"
        apiBackend -> cacheQueue "Cache, pub/sub, broker Celery" "TCP"
        apiBackend -> objectStore "Upload/download fichiers casier et assets" "S3 API"

        // Celery Workers
        apiBackend -> celeryWorkers "Dispatch tâches asynchrones" "DragonflyDB"
        celeryWorkers -> cacheQueue "Consomme tâches depuis le broker" "TCP"
        celeryWorkers -> dbPostgres "Lit et écrit données (pipelines, embeddings)" "SQL/TCP"
        celeryWorkers -> objectStore "Lit fichiers pour chunking/embedding" "S3 API"
        celeryWorkers -> llmService "Appels LLM (LangChain/LangGraph)" "API REST"
        celeryWorkers -> langfuse "Log traces et coûts LLM" "API REST"
        celeryWorkers -> emailService "Envoi emails (updates parents, RGPD)" "SMTP / API"

        // API → Systèmes Externes
        apiBackend -> gar "SSO ENT, UAI lookup" "SAML / OAuth2"
        apiBackend -> oauthProviders "Auth sociale" "OAuth2 / OIDC"
        apiBackend -> llmService "Adaptation IA temps réel (LangChain + Groq)" "API REST"
        apiBackend -> stripeBilling "Billing et webhooks" "Stripe API"
        apiBackend -> langfuse "Traces IA" "API REST"
        apiBackend -> posthog "Analytics" "API REST"
        apiBackend -> glitchtip "Erreurs" "SDK"
        apiBackend -> grafanaStack "Métriques" "Prometheus"
        apiBackend -> pushService "Push notifications" "FCM / APNs"

        // Backups
        dbPostgres -> scalewayS3 "Backup quotidien pg_dump" "S3 API"

        // Assets (servis directement par MinIO via reverse proxy Coolify)
        siteWeb -> objectStore "Assets statiques" "S3 API / HTTPS"
        appMobile -> objectStore "Assets cours (images, Lottie)" "S3 API / HTTPS"
        previewRenderer -> objectStore "Assets preview" "S3 API / HTTPS"

        // ══════════════════════════════════════════════════════
        // RELATIONS — LEVEL 3 (Components)
        // ══════════════════════════════════════════════════════

        // --- App Élève : composants internes ---
        appOnboarding -> appApiClient "Envoie profil" ""
        appAuth -> appApiClient "Login / OAuth / GAR" ""
        appHome -> appApiClient "Fetch derniers cours, Fracto comment" ""
        appCourseList -> appApiClient "Fetch liste cours" ""
        appCapsulePath -> appApiClient "Fetch chapitres et progression" ""
        appCapsuleRunner -> appBlockRenderer "Rend les blocs de chaque section" ""
        appCapsuleRunner -> appApiClient "Sauvegarde progression, fetch contenu" ""
        appKnowledgeCenter -> appApiClient "Fetch feedback, arbre, casier" ""
        appCompetenceTree -> appApiClient "Fetch arbre compétences" ""
        appSettings -> appApiClient "Update profil, School Code" ""
        appConnections -> appApiClient "Gestion connexions" ""
        appOfflineManager -> appLocalStore "Cache capsules et progression locale" ""
        appOfflineManager -> appApiClient "Sync à la reconnexion" ""
        appAccessibility -> appLocalStore "Persistance préférences accessibilité" ""
        appApiClient -> apiBackend "Requêtes HTTP" "JSON/HTTPS"

        // --- Dashboard : composants internes ---
        dashOnboarding -> dashApiClient "Envoie profil superviseur, MSC" ""
        dashWorkspaceManager -> dashApiClient "CRUD workspaces" ""
        dashStudentOverview -> dashApiClient "Fetch élèves et indicateurs" ""
        dashAnalytics -> dashApiClient "Fetch analytics" ""
        dashTreeViewer -> dashApiClient "Fetch arbres compétences" ""
        dashTreeBuilder -> dashApiClient "Crée arbres objectifs" ""
        dashContentBrowser -> dashApiClient "Search et preview contenus" ""
        dashRecommender -> dashApiClient "Push recommandations" ""
        dashCasierUploader -> dashApiClient "Upload ressources casier" ""
        dashConnectionManager -> dashApiClient "Demandes connexion" ""
        dashSettingsAccount -> dashApiClient "Update compte, orgs, billing" ""
        dashRGPD -> dashApiClient "Audit et export données" ""
        dashApiClient -> apiBackend "Requêtes HTTP" "JSON/HTTPS"

        // --- Admin Panel : composants internes ---
        admDashboard -> admApiClient "Fetch KPI et alertes" ""
        admUserManager -> admApiClient "CRUD utilisateurs" ""
        admRBAC -> admApiClient "Gestion rôles" ""
        admImpersonate -> admApiClient "Impersonate user" ""
        admConnectionAudit -> admApiClient "Audit connexions" ""
        admMembershipViewer -> admApiClient "Vue affiliations" ""
        admContentEditor -> admApiClient "Édition contenu" ""
        admAIQuality -> admApiClient "Monitoring IA" ""
        admMonitoring -> admApiClient "Logs et jobs" ""
        admBilling -> admApiClient "Billing et licences" ""
        admOrgProvisioner -> admApiClient "Provisioning orgs" ""
        admRGPD -> admApiClient "RGPD workflow" ""
        admApiClient -> apiBackend "Requêtes HTTP" "JSON/HTTPS"

        // --- API Backend : composants internes ---
        // Controllers → Services
        apiAuthController -> apiAuthService "Délègue logique auth" ""
        apiOnboardingController -> apiAuthService "Création profil" ""
        apiCourseController -> dbPostgres "Requêtes cours/chapitres/capsules" "SQL"
        apiProgressController -> dbPostgres "Sauvegarde/lecture progression" "SQL"
        apiCompetenceController -> dbPostgres "Requêtes compétences et arbres" "SQL"
        apiConnectionController -> dbPostgres "CRUD connexions" "SQL"
        apiConnectionController -> cacheQueue "Publie notifs connexion" ""
        apiWorkspaceController -> dbPostgres "CRUD workspaces" "SQL"
        apiWorkspaceController -> apiOrgService "Rattachement organisation" ""
        apiMembershipController -> apiOrgService "Gestion affiliations" ""
        apiCasierController -> dbPostgres "CRUD casier items" "SQL"
        apiCasierController -> objectStore "Upload/download fichiers" "S3 API"
        apiRecommendController -> cacheQueue "Push notifs recommandation" ""
        apiAnalyticsController -> dbPostgres "Requêtes analytics" "SQL"
        apiAdminController -> apiOrgService "Provisioning, RBAC" ""
        apiAdminController -> apiRGPDService "Workflow RGPD" ""
        apiAdminController -> apiBillingService "Gestion billing" ""
        apiNotifController -> cacheQueue "Publie notifications" ""

        // Services → Externes
        apiAuthService -> identityProvider "Gestion sessions Kratos" "HTTPS"
        apiAuthService -> gar "SSO GAR" "SAML"
        apiAuthService -> oauthProviders "OAuth B2C" "OAuth2"
        apiAuthService -> dbPostgres "Credentials et tokens" "SQL"
        apiAdaptationService -> llmService "Appels LLM (LangChain + Groq)" "API REST"
        apiAdaptationService -> dbPostgres "Lecture profil et casier" "SQL"
        apiAdaptationService -> langfuse "Log traces adaptation" "API REST"
        apiFractoService -> llmService "Génération commentaires Fracto (LangChain + Groq)" "API REST"
        apiParentUpdateService -> cacheQueue "Queue emails parents" ""
        apiOfflineSyncService -> dbPostgres "Merge progression" "SQL"
        apiOrgService -> dbPostgres "Orgs, licences, School Codes" "SQL"
        apiBillingService -> stripeBilling "Stripe API" "HTTPS"
        apiBillingService -> dbPostgres "Abonnements et tiers" "SQL"
        apiRGPDService -> dbPostgres "Export et suppression data" "SQL"
        apiRGPDService -> objectStore "Purge fichiers casier" "S3 API"
        apiJobRunner -> celeryWorkers "Dispatch pipelines IA (LangGraph)" "DragonflyDB"
        apiJobRunner -> dbPostgres "Statut et résultats jobs" "SQL"
        apiJobRunner -> langfuse "Log traces et coûts" "API REST"

        // Services → Adaptation pour capsules
        apiCourseController -> apiAdaptationService "Adapte blocs au profil" ""
        apiProgressController -> apiAdaptationService "Feedback contrôle" ""
    }

    views {
        properties {
            "plantuml.url" "http://localhost:8888"
            "plantuml.format" "svg"
        }

        // ══════════════════════════════════════════════════════
        // C4 Level 1 — System Context
        // ══════════════════════════════════════════════════════
        systemContext fractis "SystemContext" "Diagramme de contexte : FRACTIS, personas et systèmes externes" {
            include *
            autoLayout
        }

        // ══════════════════════════════════════════════════════
        // C4 Level 2 — Containers
        // ══════════════════════════════════════════════════════
        container fractis "Containers" "Vue conteneurs de FRACTIS" {
            include *
            autoLayout
        }

        // ══════════════════════════════════════════════════════
        // C4 Level 3 — Components (un par container)
        // ══════════════════════════════════════════════════════

        // Level 3 : App Élève
        component appMobile "Components_AppEleve" "Composants de l'App Élève Flutter" {
            include *
            autoLayout
        }

        // Level 3 : Dashboard Superviseur
        component dashboardWeb "Components_Dashboard" "Composants du Dashboard Superviseur (Flutter Web)" {
            include *
            autoLayout
        }

        // Level 3 : Admin Panel
        component adminPanel "Components_AdminPanel" "Composants de l'Admin Panel (Flutter Web)" {
            include *
            autoLayout
        }

        // Level 3 : API Backend
        component apiBackend "Components_APIBackend" "Composants de l'API Backend FastAPI" {
            include *
            autoLayout
        }

        // ══════════════════════════════════════════════════════
        // C4 Level 4 — Diagrammes de Classes (PlantUML)
        // ══════════════════════════════════════════════════════

        // Vue d'ensemble (toutes les classes)
        image fractis "L4_Overview" {
            plantuml docs/diagrams/classes-app.puml
            title "[L4] Vue d'Ensemble — Toutes les Classes"
        }

        // Détail par domaine
        image fractis "L4_Identity" {
            plantuml docs/diagrams/classes-identity.puml
            title "[L4] Identité & Authentification"
        }

        image fractis "L4_Organization" {
            plantuml docs/diagrams/classes-organization.puml
            title "[L4] Organisation & Affiliation"
        }

        image fractis "L4_Content" {
            plantuml docs/diagrams/classes-content.puml
            title "[L4] Contenu Pédagogique"
        }

        image fractis "L4_Progress" {
            plantuml docs/diagrams/classes-progress.puml
            title "[L4] Progression & Évaluation"
        }

        image fractis "L4_Connections" {
            plantuml docs/diagrams/classes-connections.puml
            title "[L4] Connexions & Supervision"
        }

        image fractis "L4_Services" {
            plantuml docs/diagrams/classes-services.puml
            title "[L4] Adaptation & Services"
        }

        theme default
    }
}
