# FRACTIS — Architecture (Structurizr + PlantUML)

Modèle C4 + diagrammes UML du projet FRACTIS.

## Structure

```
├── workspace.dsl              # Modèle C4 (contexte, conteneurs, vues image PlantUML)
├── docker-compose.yml         # Structurizr Lite + serveur PlantUML local
└── docs/
    ├── 01-classes.md          # Documentation Markdown
    └── diagrams/
        ├── classes-app.puml   # Diagramme de classes UML (L4)
        └── sequence-auth.puml # Séquence Superviseur-Élève
```

## Lancer en local

```bash
docker compose up -d
```

→ [http://localhost:8080](http://localhost:8080)

Structurizr se recharge automatiquement à chaque sauvegarde de fichier.

**Note :** Vous pouvez également consulter la documentation complète du projet (fichiers Markdown) directement depuis l'interface web de Structurizr sous l'onglet "Documentation".

## Vues disponibles

| Vue | Type | Description |
|---|---|---|
| `SystemContext` | C4 L1 | Contexte système |
| `Containers` | C4 L2 | Conteneurs (React, Node.js, PostgreSQL) |
| `Sequence_Login` | C4 Dynamic | Flux de connexion |
| `AppClasses` | Image / PlantUML | Diagramme de classes FRACTIS |
| `AuthSequence` | Image / PlantUML | Séquence Superviseur-Élève |
