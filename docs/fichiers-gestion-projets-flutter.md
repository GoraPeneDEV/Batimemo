# Fichiers Flutter — Module Gestion de Projets

> Tous les fichiers Dart impliqués dans le module **Gestion de Projets** de l'application mobile.
> Organisés par couche (écrans, stores, API, modèles, widgets).

---

## Écrans (`lib/screens/Project/`)

| Fichier | Rôle |
|---|---|
| `ProjectScreen.dart` | Point d'entrée du module (ancienne version — remplacé par `project_dashboard_screen.dart`) |
| `project_dashboard_screen.dart` | **Écran principal** — tableau de bord du module, liste les projets récents, statistiques, accès rapide aux feuilles de temps |
| `project_list_screen.dart` | Liste paginée de tous les projets avec filtres (statut, type, recherche) |
| `project_create_screen.dart` | Formulaire de création d'un nouveau projet (nom, type, priorité, dates, budget, facturation) |
| `project_detail_screen.dart` | Détails complets d'un projet : membres, avancement, finances, onglet tâches |
| `project_statistics_screen.dart` | Statistiques globales des projets (graphiques, KPIs) |

### Sous-dossier `tasks/`

| Fichier | Rôle |
|---|---|
| `tasks/project_tasks_screen.dart` | Liste des tâches d'un projet (si module TaskSystem actif), avec filtres |
| `tasks/project_task_create_screen.dart` | Formulaire de création / modification d'une tâche |

### Sous-dossier `timesheets/`

| Fichier | Rôle |
|---|---|
| `timesheets/timesheet_list_screen.dart` | Liste paginée des feuilles de temps (mes entrées de temps) |
| `timesheets/timesheet_form_screen.dart` | Formulaire de création / modification d'une entrée de temps |
| `timesheets/timesheet_detail_screen.dart` | Détails d'une feuille de temps avec statut d'approbation |

### Sous-dossier `Widget/`

| Fichier | Rôle |
|---|---|
| `Widget/project_item_widget.dart` | Carte affichée dans la liste des projets (nom, statut, progression, badge priorité) |
| `Widget/project_status_badge.dart` | Badge coloré selon le statut du projet (planning, in_progress, on_hold, etc.) |
| `Widget/task_item_widget.dart` | Carte d'une tâche dans la liste des tâches |
| `Widget/timesheet_item_widget.dart` | Ligne d'une feuille de temps dans la liste |

---

## Stores MobX (`lib/stores/Project/`)

> Ces stores gèrent l'état réactif de chaque sous-module via MobX.

| Fichier | Rôle |
|---|---|
| `ProjectStore.dart` | Store principal — liste des projets, détail, création, archivage, feuilles de temps, statistiques |
| `ProjectStore.g.dart` | Code généré par `build_runner` pour `ProjectStore` (ne pas modifier manuellement) |
| `TaskStore.dart` | Store pour les tâches — liste, création, complétion, démarrage/arrêt du chronomètre |
| `TaskStore.g.dart` | Code généré pour `TaskStore` |
| `TimesheetStore.dart` | Store pour les feuilles de temps — liste, création, modification, soumission, suppression |
| `TimesheetStore.g.dart` | Code généré pour `TimesheetStore` |

### Ancien store (couche inférieure)

| Fichier | Rôle |
|---|---|
| `lib/stores/project_store.dart` | Store alternatif (ancien) utilisant `ProjectRepository` — gère projets + feuilles de temps |
| `lib/stores/project_store.g.dart` | Code généré pour l'ancien store |

---

## API (`lib/api/`)

| Fichier | Rôle |
|---|---|
| `api/project_api.dart` | Client API principal — toutes les opérations REST : projets, tâches, membres, feuilles de temps |
| `api/api_routes.dart` | Constantes des routes API (`projects`, `projects/statistics`, `projects/timesheets`) |

### Repository Dio (`lib/api/dio_api/repositories/`)

| Fichier | Rôle |
|---|---|
| `repositories/project_repository.dart` | Repository Dio pour les projets et feuilles de temps — utilisé par `lib/stores/project_store.dart` |

---

## Modèles (`lib/models/project/`)

| Fichier | Rôle |
|---|---|
| `project/project.dart` | Classes `Project` et `ProjectSimpleUser` — modèle principal avec tous les champs (statut, priorité, finances, membres) |
| `project/project_model.dart` | Variante `ProjectModel` (nullable) + `ProjectListResponse` pour la pagination |
| `project/project_member_model.dart` | Modèle `ProjectMemberModel` — membre d'équipe (rôle, allocation %, taux horaire) |
| `project/project_statistics.dart` | Modèle `ProjectStatistics` — KPIs globaux (total projets, heures, budget, etc.) |
| `project/task_model.dart` | Modèle `TaskModel` + `TaskListResponse` — tâche avec statut, priorité, heures estimées/réelles, chronomètre |
| `project/task_meta_model.dart` | Métadonnées pour les tâches (listes de statuts et priorités disponibles depuis l'API) |
| `project/timesheet.dart` | Classe `Timesheet` — feuille de temps avec montants facturables, coûts, approbation |
| `project/timesheet_model.dart` | Variante `TimesheetModel` (nullable) + `TimesheetListResponse` pour la pagination |

---

## Intégration dans l'application

| Fichier | Rôle |
|---|---|
| `lib/screens/navigation_screen.dart` | Vérifie `isProjectModuleEnabled()` et ajoute `ProjectDashboardScreen` à la navigation principale |
| `lib/service/module_service.dart` | Méthode `isProjectModuleEnabled()` — active/désactive le module selon la config serveur |

---

## Résumé par couche

```
Écrans (11 fichiers)
  screens/Project/
  ├── project_dashboard_screen.dart     ← point d'entrée principal
  ├── project_list_screen.dart
  ├── project_create_screen.dart
  ├── project_detail_screen.dart
  ├── project_statistics_screen.dart
  ├── ProjectScreen.dart                ← ancienne version
  ├── tasks/
  │   ├── project_tasks_screen.dart
  │   └── project_task_create_screen.dart
  └── timesheets/
      ├── timesheet_list_screen.dart
      ├── timesheet_form_screen.dart
      └── timesheet_detail_screen.dart

Widgets (4 fichiers)
  screens/Project/Widget/
  ├── project_item_widget.dart
  ├── project_status_badge.dart
  ├── task_item_widget.dart
  └── timesheet_item_widget.dart

Stores MobX (8 fichiers dont 3 générés)
  stores/Project/
  ├── ProjectStore.dart + .g.dart
  ├── TaskStore.dart + .g.dart
  └── TimesheetStore.dart + .g.dart
  stores/
  ├── project_store.dart + .g.dart      ← ancien store

API (3 fichiers)
  api/
  ├── project_api.dart
  ├── api_routes.dart
  └── dio_api/repositories/project_repository.dart

Modèles (8 fichiers)
  models/project/
  ├── project.dart
  ├── project_model.dart
  ├── project_member_model.dart
  ├── project_statistics.dart
  ├── task_model.dart
  ├── task_meta_model.dart
  ├── timesheet.dart
  └── timesheet_model.dart
```

---

## Documentation associée

| Fichier | Contenu |
|---|---|
| `docs/project-management.md` | Architecture backend Laravel/PMCore (base de données, routes web, API REST) |
| `docs/projet-management-mobile.md` | Documentation détaillée du module mobile (modèles Dart, MobX, Dio, pagination, traductions) |
