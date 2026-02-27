# Fonctionnalité Gestion de Projets — Module Mobile (PMCore)

## Vue d'ensemble

Le module de gestion de projets permet aux employés de **créer des projets**, de **consulter la liste** de leurs projets, de **suivre l'avancement** (statut, progression, budget), de **voir les membres de l'équipe**, de **saisir des feuilles de temps** et de **gérer les tâches** (si le module TaskSystem est actif).

> **Architecture API** : Ce module utilise le **client Dio moderne** (`DioApiClient`) avec `AuthInterceptor` et `ErrorInterceptor` — identique au module Leave.
> **Pagination** : Ce module utilise `skip`/`take` (offset), comme Expense — contrairement à Leave qui utilise `page`/`perPage`.

---

## Architecture Flutter (App Mobile)

```
lib/
├── screens/
│   └── Project/
│       ├── ProjectScreen.dart                  # Liste paginée des projets (avec filtres)
│       ├── project_create_screen.dart          # Formulaire de création d'un projet
│       ├── project_detail_screen.dart          # Détails d'un projet (membres, avancement, finances)
│       ├── project_timesheets_screen.dart      # Liste des feuilles de temps (paginée)
│       ├── project_timesheet_create_screen.dart # Formulaire de saisie d'heures
│       ├── project_tasks_screen.dart           # Liste des tâches (si TaskSystem actif)
│       ├── project_task_create_screen.dart     # Formulaire de création de tâche
│       └── Widget/
│           ├── project_item_widget.dart        # Carte d'un projet (liste)
│           ├── project_status_badge.dart       # Badge coloré de statut
│           ├── project_progress_widget.dart    # Barre de progression + indicateur retard
│           ├── project_member_item.dart        # Ligne membre (nom + badge rôle)
│           ├── timesheet_item_widget.dart      # Carte d'une feuille de temps
│           └── task_item_widget.dart           # Carte d'une tâche
│
├── models/
│   └── Project/
│       ├── project_model.dart                  # Modèle projet + réponse paginée
│       ├── project_member_model.dart           # Modèle membre d'un projet
│       ├── timesheet_model.dart                # Modèle feuille de temps + réponse paginée
│       ├── task_model.dart                     # Modèle tâche + réponse paginée
│       └── task_meta_model.dart                # Statuts, priorités, membres (dropdowns)
│
├── api/
│   ├── project_api.dart                        # ✅ Méthodes API Project (DioApiClient)
│   └── api_routes.dart                         # Constantes des URLs
│
└── stores/
    └── Project/
        ├── ProjectStore.dart                   # MobX Store — projets + formulaire création
        ├── ProjectStore.g.dart                 # Fichier généré (build_runner)
        ├── TimesheetStore.dart                 # MobX Store — feuilles de temps
        ├── TimesheetStore.g.dart
        ├── TaskStore.dart                      # MobX Store — tâches (si TaskSystem)
        └── TaskStore.g.dart
```

---

## Base de données (côté Backend)

Référence complète : voir `project-management.md`.

Colonnes clés exposées à l'API mobile (table `projects`) :

| Colonne | Type | Description |
|---|---|---|
| `id` | bigint | Clé primaire |
| `name` | varchar(255) | Nom du projet |
| `code` | varchar(50) | Code auto-généré (ex: PRJ-001) |
| `description` | longtext | Description |
| `status` | enum | `planning` / `in_progress` / `on_hold` / `completed` / `cancelled` |
| `type` | enum | `internal` / `client` / `maintenance` / `development` |
| `priority` | enum | `low` / `medium` / `high` / `urgent` |
| `start_date` | date | Date de début |
| `end_date` | date | Date de fin |
| `budget` | decimal(15,2) | Budget alloué |
| `actual_cost` | decimal(15,2) | Coût réel (calculé depuis timesheets) |
| `completion_percentage` | int | Pourcentage d'avancement (0–100) |
| `is_billable` | boolean | Projet facturable |
| `hourly_rate` | decimal(8,2) | Taux horaire |
| `color_code` | varchar(7) | Couleur hex (ex: `#d4820a`) |
| `is_archived` | boolean | Archivé |

---

## Modèles Dart

### `ProjectModel`

```dart
class ProjectModel {
  int? id;
  String? name;
  String? code;                   // Ex: "PRJ-001", auto-généré
  String? description;            // Présent uniquement dans la vue détail
  String? status;                 // planning | in_progress | on_hold | completed | cancelled
  String? statusLabel;
  String? type;                   // internal | client | maintenance | development
  String? typeLabel;
  String? priority;               // low | medium | high | urgent
  String? priorityLabel;
  String? colorCode;              // Ex: "#3B82F6"
  bool? isBillable;
  bool? isArchived;
  bool? isOverdue;
  int? completionPercentage;      // 0 à 100
  String? startDate;              // Format: "yyyy-MM-dd" (défini par Constants.DateFormat)
  String? endDate;
  int? daysUntilDeadline;         // Positif = jours restants, négatif = en retard
  Map<String, dynamic>? projectManager; // { "id": 1, "name": "Jean Dupont" }
  String? myRole;                 // Rôle de l'utilisateur connecté sur ce projet
  int? memberCount;
  String? createdAt;              // Format: "yyyy-MM-dd HH:mm:ss"

  // Champs présents uniquement dans la réponse détail (getProject)
  num? budget;
  num? actualCost;
  num? actualRevenue;
  num? hourlyRate;
  num? budgetVariance;
  num? budgetVariancePercentage;
  num? profitMargin;
  num? profitMarginPercentage;
  bool? isOverBudget;
  num? totalHours;
  num? billableHours;
  String? completedAt;
  String? updatedAt;
  Map<String, dynamic>? client;   // { "id": 5, "name": "Famille Dubois" }
  List<ProjectMemberModel>? members; // Uniquement dans le détail
}
```

### `ProjectListResponse`

```dart
class ProjectListResponse {
  int totalCount;
  List<ProjectModel> values;
}
```

### `ProjectMemberModel`

```dart
class ProjectMemberModel {
  int? id;
  int? userId;
  String? name;
  String? email;
  String? role;                   // manager | lead | coordinator | member | viewer | client
  String? roleLabel;
  num? hourlyRate;
  num? effectiveHourlyRate;
  int? allocationPercentage;
  num? weeklyCapacityHours;
  String? joinedAt;
}
```

### `TimesheetModel`

```dart
class TimesheetModel {
  int? id;
  int? projectId;
  String? projectName;
  String? projectCode;
  String? date;                   // Format: "yyyy-MM-dd"
  num? hours;
  String? formattedHours;         // Ex: "6h 30m"
  String? status;                 // draft | submitted | approved | rejected | invoiced
  String? statusLabel;
  bool? isBillable;
  num? billableAmount;
  String? createdAt;

  // Champs présents uniquement dans la réponse détail
  String? description;
  int? taskId;
  num? billingRate;
  num? costRate;
  num? costAmount;
  num? totalAmount;
  Map<String, dynamic>? approvedBy; // { "id": 1, "name": "..." }
  String? approvedAt;
  String? updatedAt;
  bool? canEdit;
  bool? canSubmit;
  bool? canDelete;
}
```

### `TimesheetListResponse`

```dart
class TimesheetListResponse {
  int totalCount;
  num totalHours;
  num totalBillableHours;
  List<TimesheetModel> values;
}
```

### `TaskModel`

```dart
class TaskModel {
  int? id;
  String? title;
  String? description;            // Présent uniquement dans la vue détail
  int? statusId;
  String? statusName;
  String? statusColor;
  int? priorityId;
  String? priorityName;
  String? priorityColor;
  int? assignedToUserId;
  String? assignedToName;
  String? dueDate;                // Format: "yyyy-MM-dd"
  num? estimatedHours;
  num? actualHours;
  bool? isMilestone;
  bool? isCompleted;
  bool? isRunning;
  String? completedAt;
  int? taskOrder;
  String? createdAt;

  // Champs présents uniquement dans la réponse détail
  int? parentTaskId;
  String? timeStartedAt;
  String? updatedAt;
}
```

### `TaskMetaModel` (pour les dropdowns du formulaire)

```dart
class TaskMetaModel {
  List<TaskStatusOption> statuses;
  List<TaskPriorityOption> priorities;
  List<TaskMemberOption> members;
}

class TaskStatusOption   { int id; String name; String? color; }
class TaskPriorityOption { int id; String name; String? color; }
class TaskMemberOption   { int userId; String name; }
```

---

## API REST

### Base URL

```
https://batimemo.com/api/V1/
```

### Authentification

Tous les endpoints nécessitent le header JWT :

```
Authorization: Bearer <token>
```

Injecté automatiquement par `AuthInterceptor` du `DioApiClient`.
En mode **SaaS multi-tenant**, l'header `X-Tenant-ID` est aussi ajouté automatiquement.

---

### Endpoints Projects ✅

#### `GET /projects`

Liste paginée des projets accessibles à l'utilisateur connecté (manager ou membre actif).

**Paramètres de requête** :

| Paramètre | Type | Défaut | Description |
|---|---|---|---|
| `skip` | int | `0` | Offset de pagination |
| `take` | int | `20` | Nombre de résultats |
| `status` | string | — | Filtre: `planning` / `in_progress` / `on_hold` / `completed` / `cancelled` |
| `type` | string | — | Filtre: `internal` / `client` / `maintenance` / `development` |
| `priority` | string | — | Filtre: `low` / `medium` / `high` / `urgent` |
| `archived` | string | `false` | `true` pour voir les projets archivés |
| `search` | string | — | Recherche dans `name`, `code`, `description` |

**Réponse** :
```json
{
  "statusCode": 200,
  "status": "success",
  "data": {
    "totalCount": 12,
    "values": [
      {
        "id": 3,
        "name": "Réno cuisine Dubois",
        "code": "REN-001",
        "status": "in_progress",
        "statusLabel": "In Progress",
        "type": "client",
        "typeLabel": "Client",
        "priority": "high",
        "priorityLabel": "High",
        "colorCode": "#d4820a",
        "isBillable": true,
        "isArchived": false,
        "isOverdue": false,
        "completionPercentage": 25,
        "startDate": "2026-03-01",
        "endDate": "2026-05-31",
        "daysUntilDeadline": 96,
        "projectManager": { "id": 5, "name": "Jean Tremblay" },
        "myRole": "manager",
        "memberCount": 4,
        "createdAt": "2026-02-10 09:00:00"
      }
    ]
  }
}
```

---

#### `POST /projects`

Crée un nouveau projet. Le créateur est automatiquement ajouté comme `manager`.

**Payload** :
```json
{
  "name": "Réno cuisine Dubois",
  "description": "Rénovation complète de la cuisine",
  "type": "client",
  "priority": "high",
  "startDate": "2026-03-01",
  "endDate": "2026-05-31",
  "budget": 45000.00,
  "isBillable": true,
  "hourlyRate": 95.00,
  "colorCode": "#d4820a",
  "clientId": 12,
  "projectManagerId": 5
}
```

> Seul `name` est obligatoire. Le `status` est automatiquement `planning`. Le `code` est auto-généré.

**Réponse** (HTTP 201) :
```json
{
  "statusCode": 201,
  "status": "success",
  "data": {
    "message": "Project created successfully",
    "projectId": 3,
    "project": { ...détails complets... }
  }
}
```

---

#### `GET /projects/{id}`

Détails complets d'un projet (avec membres, finances, heures).

> L'utilisateur doit être manager ou membre actif. Retourne 404 sinon.

**Réponse** :
```json
{
  "statusCode": 200,
  "status": "success",
  "data": {
    "id": 3,
    "name": "Réno cuisine Dubois",
    ...tous les champs de la liste...,
    "description": "Rénovation complète de la cuisine",
    "budget": "45000.00",
    "actualCost": "12500.00",
    "actualRevenue": "14250.00",
    "hourlyRate": "95.00",
    "budgetVariance": "32500.00",
    "budgetVariancePercentage": "72.22",
    "profitMargin": "1750.00",
    "profitMarginPercentage": "12.28",
    "isOverBudget": false,
    "totalHours": 150.0,
    "billableHours": 132.5,
    "completedAt": null,
    "updatedAt": "2026-02-20 14:30:00",
    "client": { "id": 12, "name": "Famille Dubois" },
    "members": [
      {
        "id": 1,
        "userId": 8,
        "name": "Marie Gagnon",
        "email": "marie@example.com",
        "role": "lead",
        "roleLabel": "Lead",
        "hourlyRate": "85.00",
        "effectiveHourlyRate": "85.00",
        "allocationPercentage": 75,
        "weeklyCapacityHours": 30.0,
        "joinedAt": "2026-02-10 09:00:00"
      }
    ]
  }
}
```

---

#### `PUT /projects/{id}`

Met à jour un projet existant (tous les champs sont optionnels).

**Payload** (tous optionnels) :
```json
{
  "name": "Nouveau nom",
  "status": "in_progress",
  "completionPercentage": 35,
  "endDate": "2026-06-30"
}
```

> Quand `status` passe à `completed`, `completedAt` et `completionPercentage = 100` sont auto-définis.

---

#### `DELETE /projects/{id}`

Supprime un projet (soft delete).

---

#### `POST /projects/{id}/archive`

Archive ou désarchive un projet.

**Payload** :
```json
{ "archive": true }
```

---

#### `GET /projects/statistics`

Statistiques globales pour le tableau de bord mobile.

**Réponse** :
```json
{
  "statusCode": 200,
  "status": "success",
  "data": {
    "overview": {
      "total": 12,
      "active": 8,
      "completed": 3,
      "onHold": 1,
      "overdue": 2
    },
    "myTime": {
      "hoursThisWeek": 32.5,
      "billableHoursThisWeek": 28.0,
      "pendingTimesheets": 3
    },
    "recentProjects": [...5 projets récents...],
    "overdueProjects": [...projets en retard...]
  }
}
```

---

### Endpoints Members ✅

#### `GET /projects/{id}/members`

Liste des membres actifs d'un projet.

**Réponse** :
```json
{
  "data": {
    "totalCount": 4,
    "members": [ ...liste formatMember... ]
  }
}
```

#### `POST /projects/{id}/members`

Ajoute un membre au projet.

**Payload** :
```json
{
  "userId": 8,
  "role": "lead",
  "hourlyRate": 85.00,
  "allocationPercentage": 75
}
```

#### `PUT /projects/{id}/members/{memberId}`

Modifie le rôle ou l'allocation d'un membre.

#### `DELETE /projects/{id}/members/{memberId}`

Retire un membre du projet (soft remove via `left_at`).

> Impossible de retirer le seul manager du projet.

---

### Endpoints Timesheets ✅

#### `GET /projects/timesheets`

Liste paginée des feuilles de temps de l'utilisateur connecté.

**Paramètres de requête** :

| Paramètre | Type | Description |
|---|---|---|
| `skip` | int | Offset (défaut: 0) |
| `take` | int | Nombre de résultats (défaut: 20) |
| `status` | string | `draft` / `submitted` / `approved` / `rejected` / `invoiced` |
| `projectId` | int | Filtrer par projet |
| `startDate` | string | Date début (format `yyyy-MM-dd`) |
| `endDate` | string | Date fin (format `yyyy-MM-dd`) |
| `billable` | bool | `true` / `false` |

**Réponse** :
```json
{
  "data": {
    "totalCount": 25,
    "totalHours": 187.5,
    "totalBillableHours": 162.0,
    "values": [ ...liste de timesheets... ]
  }
}
```

#### `POST /projects/timesheets`

Crée une feuille de temps (statut initial: `draft`).

**Payload** :
```json
{
  "projectId": 3,
  "date": "2026-02-21",
  "hours": 6.5,
  "description": "Installation des armoires — côté ouest",
  "isBillable": true,
  "billingRate": 95.00,
  "costRate": 65.00,
  "taskId": null
}
```

> `billingRate` et `costRate` sont optionnels — auto-résolus depuis le taux membre → taux projet.

#### `GET /projects/timesheets/{id}` — détails d'une feuille de temps

#### `PUT /projects/timesheets/{id}` — modification (uniquement si `draft`)

#### `POST /projects/timesheets/{id}/submit` — soumission pour approbation

#### `DELETE /projects/timesheets/{id}` — suppression (uniquement si `draft`)

---

### Endpoints Tasks ✅ (si module TaskSystem actif)

> Si le module TaskSystem n'est pas actif, tous les endpoints retournent **404** automatiquement.

#### `GET /projects/{projectId}/tasks/meta`

Récupère les statuts, priorités et membres disponibles pour les dropdowns du formulaire.

**Réponse** :
```json
{
  "data": {
    "statuses": [
      { "id": 1, "name": "Todo",        "color": "#6B7280" },
      { "id": 2, "name": "In Progress", "color": "#3B82F6" },
      { "id": 3, "name": "Review",      "color": "#F59E0B" },
      { "id": 4, "name": "Completed",   "color": "#10B981" }
    ],
    "priorities": [
      { "id": 1, "name": "Low",      "color": "#6B7280" },
      { "id": 2, "name": "Medium",   "color": "#3B82F6" },
      { "id": 3, "name": "High",     "color": "#F59E0B" },
      { "id": 4, "name": "Critical", "color": "#EF4444" }
    ],
    "members": [
      { "userId": 8, "name": "Marie Gagnon" },
      { "userId": 5, "name": "Jean Tremblay" }
    ]
  }
}
```

---

#### `GET /projects/{projectId}/tasks`

Liste paginée des tâches d'un projet.

**Paramètres de requête** :

| Paramètre | Type | Description |
|---|---|---|
| `skip` | int | Offset (défaut: 0) |
| `take` | int | Nombre de résultats (défaut: 20) |
| `statusId` | int | Filtrer par ID de statut |
| `priorityId` | int | Filtrer par ID de priorité |
| `assignedTo` | int | Filtrer par ID d'utilisateur assigné |
| `completed` | bool | `true` = tâches terminées uniquement |
| `search` | string | Recherche dans `title` |

**Réponse** :
```json
{
  "data": {
    "totalCount": 18,
    "values": [
      {
        "id": 12,
        "title": "Poser les armoires supérieures",
        "statusId": 2,
        "statusName": "In Progress",
        "statusColor": "#3B82F6",
        "priorityId": 3,
        "priorityName": "High",
        "priorityColor": "#F59E0B",
        "assignedToUserId": 8,
        "assignedToName": "Marie Gagnon",
        "dueDate": "2026-03-15",
        "estimatedHours": 8.0,
        "actualHours": null,
        "isMilestone": false,
        "isCompleted": false,
        "isRunning": false,
        "completedAt": null,
        "taskOrder": 0,
        "createdAt": "2026-02-15 10:00:00"
      }
    ]
  }
}
```

---

#### `POST /projects/{projectId}/tasks`

Crée une nouvelle tâche dans le projet.

**Payload** :
```json
{
  "title": "Poser les armoires supérieures",
  "description": "Commencer par le côté fenêtre",
  "statusId": 1,
  "priorityId": 3,
  "assignedToUserId": 8,
  "dueDate": "2026-03-15",
  "estimatedHours": 8.0,
  "isMilestone": false,
  "taskOrder": 0
}
```

> L'utilisateur assigné (`assignedToUserId`) doit être membre du projet.

**Réponse** (HTTP 201) :
```json
{ "data": { "message": "Task created successfully", "task": { ...détails... } } }
```

---

#### `GET /projects/{projectId}/tasks/{taskId}` — détail d'une tâche

Inclut `description`, `parentTaskId`, `timeStartedAt`, `updatedAt` en plus des champs de la liste.

---

#### `PUT /projects/{projectId}/tasks/{taskId}` — modification d'une tâche

Tous les champs sont optionnels.

---

#### `DELETE /projects/{projectId}/tasks/{taskId}` — suppression d'une tâche

---

#### `POST /projects/{projectId}/tasks/{taskId}/complete`

Marque la tâche comme terminée (met le statut à "Completed", enregistre `completed_at`).

**Réponse** :
```json
{ "data": { "message": "Task completed successfully", "task": { ...avec isCompleted: true... } } }
```

---

#### `POST /projects/{projectId}/tasks/{taskId}/start`

Démarre le chronomètre de la tâche (`time_started_at = now()`).

**Réponse** :
```json
{ "data": { "message": "Task timer started", "task": { ...avec isRunning: true... } } }
```

---

#### `POST /projects/{projectId}/tasks/{taskId}/stop`

Arrête le chronomètre et enregistre les heures écoulées dans `actual_hours`.

**Réponse** :
```json
{
  "data": {
    "message": "Task timer stopped",
    "elapsedHours": 2.5,
    "task": { ...avec isRunning: false, actualHours: 2.5... }
  }
}
```

---

## Flux complet depuis le mobile

```
Employé ouvre "Projets"
        ↓
  ProjectScreen → GET /projects?skip=0&take=20
        ↓
  Filtres optionnels: status / type / search (→ refresh liste)
        ↓
  Tap sur un projet → ProjectDetailScreen
        └── GET /projects/{id}
              → Affiche membres, avancement, finances
                    ↓
  Onglet "Tasks" → ProjectTasksScreen
        └── GET /projects/{id}/tasks
              → Liste des tâches + filtres statut
                    ↓
  Onglet "Timesheets" → ProjectTimesheetsScreen
        └── GET /projects/timesheets?projectId={id}
              → Liste des feuilles de temps personnelles

  Bouton "+" (ProjectScreen) → ProjectCreateScreen
        └── POST /projects → retour liste + refresh

  Bouton "+" (TasksScreen) →
        ├── GET /projects/{id}/tasks/meta (statuts, priorités, membres)
        └── ProjectTaskCreateScreen → POST /projects/{id}/tasks

  Bouton "+" (TimesheetsScreen) → ProjectTimesheetCreateScreen
        └── POST /projects/timesheets
```

---

## Gestion d'état — `ProjectStore` (MobX)

### Observables

| Propriété | Type | Description |
|---|---|---|
| `pagingController` | `PagingController<int, ProjectModel>` | Pagination infinie (liste projets) |
| `isLoading` | `bool` | Chargement en cours (création / stats) |
| `selectedProject` | `ProjectModel?` | Projet affiché dans le détail |
| `statistics` | `Map?` | Données du tableau de bord |
| `selectedStatus` | `String?` | Filtre statut actif |
| `selectedType` | `String?` | Filtre type actif |
| `searchQuery` | `String` | Texte de recherche |
| `nameController` | `TextEditingController` | Nom (formulaire) |
| `descriptionController` | `TextEditingController` | Description (formulaire) |
| `selectedProjectType` | `String` | Type (défaut: `client`) |
| `selectedPriority` | `String` | Priorité (défaut: `medium`) |
| `startDate` | `DateTime?` | Date de début |
| `endDate` | `DateTime?` | Date de fin |
| `budgetController` | `TextEditingController` | Budget (formulaire) |
| `isBillable` | `bool` | Toggle facturable (défaut: `true`) |
| `hourlyRateController` | `TextEditingController` | Taux horaire (formulaire) |
| `selectedColor` | `String` | Couleur hex (défaut: `#007bff`) |

### Actions

| Action | Description |
|---|---|
| `fetchProjects(pageKey)` | Charge une page de projets (skip/take) |
| `loadProjectDetail(id)` | Charge le détail complet + membres |
| `loadStatistics()` | Charge les statistiques du tableau de bord |
| `createProject()` | Valide + soumet le formulaire de création |
| `applyFilters()` | Applique les filtres → refresh liste |
| `resetFilters()` | Réinitialise les filtres → refresh liste |
| `resetForm()` | Vide le formulaire de création |

---

## Flux de données détaillé

### Affichage de la liste

```
ProjectScreen.initState()
  └── pagingController.addPageRequestListener(fetchProjects)
        └── ProjectStore.fetchProjects(pageKey)           // pageKey = offset (0, 20, 40...)
              └── ProjectApi.getProjects(skip: pageKey, take: 20, ...)
                    └── DioApiClient.get('/projects', queryParameters: {...})
                          └── GET /api/V1/projects?skip=0&take=20
                                └── { totalCount: 12, values: [...] }
                                      └── isLastPage = (pageKey + result.values.length) >= result.totalCount
                                            └── pagingController.appendPage(values, pageKey + values.length)
```

### Création d'un projet

```
ProjectCreateScreen → tap "Créer le projet"
  └── ProjectStore.createProject()
        ├── Validation: name non vide / endDate >= startDate
        └── ProjectApi.createProject({
              "name": ..., "type": ..., "priority": ...,
              "startDate": ..., "endDate": ..., "budget": ...,
              "isBillable": ..., "colorCode": ...
            })
              └── DioApiClient.post('/projects', data: payload)
                    └── HTTP 201 → toast succès → pop → pagingController.refresh()
```

### Création d'une tâche

```
ProjectTaskCreateScreen.initState()
  └── TaskStore.loadMeta(projectId)
        └── GET /projects/{id}/tasks/meta
              → Peuple les dropdowns (statuts, priorités, membres)

ProjectTaskCreateScreen → tap "Créer"
  └── TaskStore.createTask(projectId, payload)
        └── POST /projects/{id}/tasks
              → HTTP 201 → toast succès → pagingController.refresh()
```

---

## Client HTTP — `DioApiClient`

```dart
// project_api.dart
class ProjectApi {
  final DioApiClient _client;
  ProjectApi(this._client);

  // GET /projects (liste paginée)
  Future<ProjectListResponse> getProjects({
    int skip = 0,
    int take = 20,
    String? status,
    String? type,
    String? priority,
    String? search,
    bool archived = false,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'take': take,
      'archived': archived ? 'true' : 'false',
    };
    if (status   != null) params['status']   = status;
    if (type     != null) params['type']     = type;
    if (priority != null) params['priority'] = priority;
    if (search   != null && search.isNotEmpty) params['search'] = search;

    final response = await _client.get('/projects', queryParameters: params);
    return ProjectListResponse.fromJson(response.data['data']);
  }

  // GET /projects/{id}
  Future<ProjectModel> getProject(int id) async {
    final response = await _client.get('/projects/$id');
    return ProjectModel.fromJson(response.data['data']);
  }

  // POST /projects
  Future<Map<String, dynamic>> createProject(Map<String, dynamic> payload) async {
    final response = await _client.post('/projects', data: payload);
    return response.data['data'] as Map<String, dynamic>;
  }

  // PUT /projects/{id}
  Future<ProjectModel> updateProject(int id, Map<String, dynamic> payload) async {
    final response = await _client.put('/projects/$id', data: payload);
    return ProjectModel.fromJson(response.data['data']['project']);
  }

  // GET /projects/statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final response = await _client.get('/projects/statistics');
    return response.data['data'] as Map<String, dynamic>;
  }

  // GET /projects/timesheets
  Future<TimesheetListResponse> getTimesheets({
    int skip = 0,
    int take = 20,
    String? status,
    int? projectId,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, dynamic>{'skip': skip, 'take': take};
    if (status    != null) params['status']    = status;
    if (projectId != null) params['projectId'] = projectId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate   != null) params['endDate']   = endDate;

    final response = await _client.get('/projects/timesheets', queryParameters: params);
    return TimesheetListResponse.fromJson(response.data['data']);
  }

  // POST /projects/timesheets
  Future<TimesheetModel> createTimesheet(Map<String, dynamic> payload) async {
    final response = await _client.post('/projects/timesheets', data: payload);
    return TimesheetModel.fromJson(response.data['data']['timesheet']);
  }

  // POST /projects/timesheets/{id}/submit
  Future<void> submitTimesheet(int id) async {
    await _client.post('/projects/timesheets/$id/submit');
  }

  // GET /projects/{projectId}/tasks/meta
  Future<TaskMetaModel> getTaskMeta(int projectId) async {
    final response = await _client.get('/projects/$projectId/tasks/meta');
    return TaskMetaModel.fromJson(response.data['data']);
  }

  // GET /projects/{projectId}/tasks
  Future<TaskListResponse> getTasks(int projectId, {
    int skip = 0,
    int take = 20,
    int? statusId,
    bool? completed,
    String? search,
  }) async {
    final params = <String, dynamic>{'skip': skip, 'take': take};
    if (statusId  != null) params['statusId']  = statusId;
    if (completed != null) params['completed'] = completed;
    if (search    != null && search.isNotEmpty) params['search'] = search;

    final response = await _client.get('/projects/$projectId/tasks', queryParameters: params);
    return TaskListResponse.fromJson(response.data['data']);
  }

  // POST /projects/{projectId}/tasks
  Future<TaskModel> createTask(int projectId, Map<String, dynamic> payload) async {
    final response = await _client.post('/projects/$projectId/tasks', data: payload);
    return TaskModel.fromJson(response.data['data']['task']);
  }

  // POST /projects/{projectId}/tasks/{taskId}/complete
  Future<TaskModel> completeTask(int projectId, int taskId) async {
    final response = await _client.post('/projects/$projectId/tasks/$taskId/complete');
    return TaskModel.fromJson(response.data['data']['task']);
  }

  // POST /projects/{projectId}/tasks/{taskId}/start
  Future<TaskModel> startTask(int projectId, int taskId) async {
    final response = await _client.post('/projects/$projectId/tasks/$taskId/start');
    return TaskModel.fromJson(response.data['data']['task']);
  }

  // POST /projects/{projectId}/tasks/{taskId}/stop
  Future<Map<String, dynamic>> stopTask(int projectId, int taskId) async {
    final response = await _client.post('/projects/$projectId/tasks/$taskId/stop');
    return response.data['data'] as Map<String, dynamic>; // { elapsedHours, task }
  }
}
```

---

## Pagination infinie

**Important** : Ce module utilise `skip`/`take` (offset), comme Expense — **pas** `page`/`perPage`.

```dart
// firstPageKey = 0 (offset de départ)
PagingController<int, ProjectModel> pagingController =
  PagingController(firstPageKey: 0);

Future<void> fetchProjects(int pageKey) async {
  final result = await projectApi.getProjects(skip: pageKey, take: 20);
  final isLastPage = (pageKey + result.values.length) >= result.totalCount;

  if (isLastPage) {
    pagingController.appendLastPage(result.values);
  } else {
    pagingController.appendPage(result.values, pageKey + result.values.length);
  }
}
```

> Même logique pour les tâches (`getTasks`) et les feuilles de temps (`getTimesheets`).

---

## Localisation (Traductions)

### Clés à ajouter dans `language_en.dart` (et équivalents FR/ES/DE/AR)

#### Projets

| Clé | Valeur (EN) |
|---|---|
| `lblProjects` | "Projects" |
| `lblProject` | "Project" |
| `lblCreateProject` | "Create Project" |
| `lblNewProject` | "New Project" |
| `lblProjectName` | "Project Name" |
| `lblEnterProjectName` | "Enter project name" |
| `lblPleaseEnterProjectName` | "Please enter a project name" |
| `lblProjectDescription` | "Description" |
| `lblProjectType` | "Project Type" |
| `lblSelectProjectType` | "Select project type" |
| `lblProjectPriority` | "Priority" |
| `lblSelectPriority` | "Select priority" |
| `lblStartDate` | "Start Date" |
| `lblEndDate` | "End Date" |
| `lblEndDateError` | "End date must be after start date" |
| `lblBudget` | "Budget" |
| `lblEnterBudget` | "Enter budget amount" |
| `lblIsBillable` | "Billable Project" |
| `lblHourlyRate` | "Hourly Rate" |
| `lblProjectColor` | "Project Color" |
| `lblProjectCode` | "Code" |
| `lblProjectManager` | "Project Manager" |
| `lblTeamMembers` | "Team Members" |
| `lblMembersCount` | "members" |
| `lblCompletion` | "Completion" |
| `lblBudgetUsed` | "Budget Used" |
| `lblActualCost` | "Actual Cost" |
| `lblOverdue` | "Overdue" |
| `lblDaysLeft` | "days left" |
| `lblProjectDetails` | "Project Details" |
| `lblFinancials` | "Financials" |
| `lblTimeline` | "Timeline" |
| `lblSubmitProject` | "Create Project" |
| `lblProjectCreatedSuccessfully` | "Project created successfully" |
| `lblYourProjectsWillAppearHere` | "Your projects will appear here" |
| `lblNoProjects` | "No Projects" |
| `lblSearchProjects` | "Search projects..." |
| `lblMyRole` | "My Role" |
| `lblClientName` | "Client" |
| `lblNoClientAssigned` | "No client assigned" |

#### Types de projets

| Clé | Valeur (EN) |
|---|---|
| `lblTypeInternal` | "Internal" |
| `lblTypeClient` | "Client" |
| `lblTypeMaintenance` | "Maintenance" |
| `lblTypeDevelopment` | "Development" |

#### Priorités

| Clé | Valeur (EN) |
|---|---|
| `lblPriorityLow` | "Low" |
| `lblPriorityMedium` | "Medium" |
| `lblPriorityHigh` | "High" |
| `lblPriorityUrgent` | "Urgent" |

#### Feuilles de temps

| Clé | Valeur (EN) |
|---|---|
| `lblTimesheets` | "Timesheets" |
| `lblNewTimesheet` | "Log Time" |
| `lblLogHours` | "Log Hours" |
| `lblHours` | "Hours" |
| `lblEnterHours` | "Enter hours (e.g. 6.5)" |
| `lblDescription` | "Description" |
| `lblEnterWorkDescription` | "Describe the work done" |
| `lblWorkDate` | "Work Date" |
| `lblTotalHours` | "Total Hours" |
| `lblBillableHours` | "Billable Hours" |
| `lblTimesheetSubmitted` | "Timesheet submitted for approval" |
| `lblTimesheetCreated` | "Timesheet entry created" |
| `lblTimesheetStatusDraft` | "Draft" |
| `lblTimesheetStatusSubmitted` | "Submitted" |
| `lblTimesheetStatusApproved` | "Approved" |
| `lblTimesheetStatusRejected` | "Rejected" |
| `lblTimesheetStatusInvoiced` | "Invoiced" |
| `lblCannotEditTimesheet` | "Only draft timesheets can be edited" |
| `lblCannotDeleteTimesheet` | "Only draft timesheets can be deleted" |

#### Tâches

| Clé | Valeur (EN) |
|---|---|
| `lblTasks` | "Tasks" |
| `lblTask` | "Task" |
| `lblNewTask` | "New Task" |
| `lblCreateTask` | "Create Task" |
| `lblTaskTitle` | "Task Title" |
| `lblEnterTaskTitle` | "Enter task title" |
| `lblPleaseEnterTaskTitle` | "Please enter a task title" |
| `lblTaskStatus` | "Status" |
| `lblSelectTaskStatus` | "Select status" |
| `lblTaskPriority` | "Priority" |
| `lblAssignTo` | "Assign To" |
| `lblSelectMember` | "Select a member" |
| `lblDueDate` | "Due Date" |
| `lblEstimatedHours` | "Estimated Hours" |
| `lblIsMilestone` | "Mark as Milestone" |
| `lblTaskCreated` | "Task created successfully" |
| `lblTaskUpdated` | "Task updated successfully" |
| `lblTaskCompleted` | "Task completed" |
| `lblTaskStarted` | "Timer started" |
| `lblTaskStopped` | "Timer stopped" |
| `lblElapsedHours` | "Elapsed" |
| `lblCompleteTask` | "Mark Complete" |
| `lblStartTimer` | "Start Timer" |
| `lblStopTimer` | "Stop Timer" |
| `lblTaskAlreadyCompleted` | "Task is already completed" |
| `lblTaskAlreadyRunning` | "Task is already running" |
| `lblNoTasks` | "No Tasks" |
| `lblNoTasksYet` | "No tasks in this project yet" |
| `lblRoleBadge` | Voir `lblRoleManager`, `lblRoleLead`, etc. |
| `lblRoleManager` | "Manager" |
| `lblRoleLead` | "Lead" |
| `lblRoleCoordinator` | "Coordinator" |
| `lblRoleMember` | "Member" |
| `lblRoleViewer` | "Viewer" |
| `lblTaskSystemNotAvailable` | "Task management is not available" |

---

## Intégration dans la Navigation

```dart
// navigation_screen.dart
if (moduleService.isProjectModuleEnabled()) {
  pages.add(const ProjectScreen());
  navItems.add(_modernNavItem(
    icon: Iconsax.briefcase,
    activeIcon: Iconsax.briefcase5,
    label: language.lblProjects,
  ));
}
```

---

## Gestion des erreurs

### Vérifications côté app

| Condition | Erreur affichée |
|---|---|
| Nom de projet vide | `lblPleaseEnterProjectName` |
| `endDate` avant `startDate` | `lblEndDateError` |
| Titre de tâche vide | `lblPleaseEnterTaskTitle` |
| Statut de tâche non sélectionné | Validation formulaire |
| Utilisateur assigné non membre | Message serveur (422) |
| Tâche déjà complétée | `lblTaskAlreadyCompleted` |
| Tâche déjà en cours | `lblTaskAlreadyRunning` |
| TaskSystem non disponible | 404 → afficher `lblTaskSystemNotAvailable` |
| Pas de connexion Internet | `noInternetMsg` |
| Erreur 401 | Déconnexion automatique (`logoutAlt()`) |
| Erreur 422 | Message de validation du serveur |

### Exceptions Dio

```
ApiException
├── NetworkException          (pas de réseau)
├── TimeoutException          (dépassement délai)
├── UnauthorizedException     (401 → auto logout)
├── NotFoundException         (404 — projet / tâche introuvable, ou TaskSystem désactivé)
├── ValidationException       (422 → afficher message serveur)
├── ServerException           (500)
└── ForbiddenException        (403)
```

---

## Statuts des projets

| Valeur | Label (FR) | Couleur | Icône suggérée |
|---|---|---|---|
| `planning` | En planification | Bleu (`#3B82F6`) | `Iconsax.timer` |
| `in_progress` | En cours | Vert (`#10B981`) | `Iconsax.play_circle` |
| `on_hold` | En pause | Orange (`#F59E0B`) | `Iconsax.pause_circle` |
| `completed` | Terminé | Gris (`#6B7280`) | `Iconsax.tick_circle` |
| `cancelled` | Annulé | Rouge (`#EF4444`) | `Iconsax.close_circle` |

---

## Statuts des feuilles de temps

| Valeur | Label (FR) | Couleur | Actions possibles |
|---|---|---|---|
| `draft` | Brouillon | Gris | Modifier, Soumettre, Supprimer |
| `submitted` | Soumis | Bleu | Lecture seule |
| `approved` | Approuvé | Vert | Lecture seule |
| `rejected` | Rejeté | Rouge | Lecture seule |
| `invoiced` | Facturé | Violet | Lecture seule |

---

## Notes d'implémentation importantes

1. **Pagination `skip`/`take`** : Ce module utilise `skip`/`take` (comme Expense), pas `page`/`perPage`. Le `firstPageKey` du `PagingController` est `0`. Le `nextPageKey` est `pageKey + result.values.length`.

2. **`statistics` avant `{id}`** : La route `GET /projects/statistics` est définie avant `GET /projects/{id}` dans `routes/api.php` pour éviter les conflits de routage.

3. **`timesheets` avant `{id}`** : Même logique — `GET /projects/timesheets` est un préfixe statique, défini avant les routes dynamiques.

4. **TaskSystem conditionnel** : Si `moduleExists('TaskSystem')` est `false`, tous les endpoints `/tasks` retournent 404. Le mobile doit gérer ce cas avec `lblTaskSystemNotAvailable`.

5. **Couleur hex** : Convertir avec `Color(int.parse(colorCode.replaceAll('#', '0xFF')))`.

6. **`myRole`** : Le champ `myRole` dans la réponse projet indique le rôle de l'utilisateur connecté sur ce projet. Utile pour afficher/masquer les actions (ex: seuls les managers voient "Ajouter un membre").

7. **Membres** : Le champ `members` est présent uniquement dans la réponse de `GET /projects/{id}` (détail), pas dans la liste. Ne pas chercher à y accéder depuis un `ProjectModel` issu de la liste paginée.

8. **`canEdit`/`canSubmit`/`canDelete`** dans les timesheets : Ces flags booléens simplifient la logique UI côté mobile — utiliser directement ces valeurs pour afficher/masquer les boutons d'action.

---

## Fichiers clés

| Fichier | Rôle |
|---|---|
| `lib/screens/Project/ProjectScreen.dart` | Liste paginée avec filtres statut/type/search |
| `lib/screens/Project/project_create_screen.dart` | Formulaire création projet |
| `lib/screens/Project/project_detail_screen.dart` | Détail projet (membres, finances, avancement) |
| `lib/screens/Project/project_timesheets_screen.dart` | Liste feuilles de temps (paginée) |
| `lib/screens/Project/project_timesheet_create_screen.dart` | Formulaire saisie d'heures |
| `lib/screens/Project/project_tasks_screen.dart` | Liste des tâches (si TaskSystem actif) |
| `lib/screens/Project/project_task_create_screen.dart` | Formulaire création de tâche |
| `lib/screens/Project/Widget/project_item_widget.dart` | Carte projet (bande colorée, progression, statut) |
| `lib/screens/Project/Widget/project_status_badge.dart` | Badge coloré de statut |
| `lib/screens/Project/Widget/project_progress_widget.dart` | Barre de progression + indicateur retard |
| `lib/screens/Project/Widget/timesheet_item_widget.dart` | Carte feuille de temps (heures, statut, projet) |
| `lib/screens/Project/Widget/task_item_widget.dart` | Carte tâche (titre, statut, assigné, date) |
| `lib/stores/Project/ProjectStore.dart` | Store MobX — projets + formulaire création |
| `lib/stores/Project/TimesheetStore.dart` | Store MobX — feuilles de temps |
| `lib/stores/Project/TaskStore.dart` | Store MobX — tâches + méta |
| `lib/models/Project/project_model.dart` | Modèle projet + `ProjectListResponse` |
| `lib/models/Project/project_member_model.dart` | Modèle membre |
| `lib/models/Project/timesheet_model.dart` | Modèle feuille de temps + `TimesheetListResponse` |
| `lib/models/Project/task_model.dart` | Modèle tâche + `TaskListResponse` |
| `lib/models/Project/task_meta_model.dart` | Modèle méta (statuts, priorités, membres) |
| `lib/api/project_api.dart` | Toutes les méthodes API Project (DioApiClient) |
| `lib/api/api_routes.dart` | Constantes des URLs |
| `lib/locale/language_en.dart` | Traductions anglaises (référence — ajouter les clés ci-dessus) |
| `lib/locale/language_fr.dart` | Traductions françaises |

---

## Récapitulatif des endpoints backend

| Méthode | URL | Contrôleur | Statut |
|---|---|---|---|
| `GET` | `/api/V1/projects` | `PMCore\Api\ProjectController@getProjects` | ✅ |
| `POST` | `/api/V1/projects` | `PMCore\Api\ProjectController@createProject` | ✅ |
| `GET` | `/api/V1/projects/statistics` | `PMCore\Api\ProjectController@getStatistics` | ✅ |
| `GET` | `/api/V1/projects/{id}` | `PMCore\Api\ProjectController@getProject` | ✅ |
| `PUT` | `/api/V1/projects/{id}` | `PMCore\Api\ProjectController@updateProject` | ✅ |
| `DELETE` | `/api/V1/projects/{id}` | `PMCore\Api\ProjectController@deleteProject` | ✅ |
| `POST` | `/api/V1/projects/{id}/archive` | `PMCore\Api\ProjectController@archiveProject` | ✅ |
| `GET` | `/api/V1/projects/{id}/members` | `PMCore\Api\ProjectController@getMembers` | ✅ |
| `POST` | `/api/V1/projects/{id}/members` | `PMCore\Api\ProjectController@addMember` | ✅ |
| `PUT` | `/api/V1/projects/{id}/members/{memberId}` | `PMCore\Api\ProjectController@updateMember` | ✅ |
| `DELETE` | `/api/V1/projects/{id}/members/{memberId}` | `PMCore\Api\ProjectController@removeMember` | ✅ |
| `GET` | `/api/V1/projects/timesheets` | `PMCore\Api\ProjectController@getTimesheets` | ✅ |
| `POST` | `/api/V1/projects/timesheets` | `PMCore\Api\ProjectController@createTimesheet` | ✅ |
| `GET` | `/api/V1/projects/timesheets/{id}` | `PMCore\Api\ProjectController@getTimesheet` | ✅ |
| `PUT` | `/api/V1/projects/timesheets/{id}` | `PMCore\Api\ProjectController@updateTimesheet` | ✅ |
| `POST` | `/api/V1/projects/timesheets/{id}/submit` | `PMCore\Api\ProjectController@submitTimesheet` | ✅ |
| `DELETE` | `/api/V1/projects/timesheets/{id}` | `PMCore\Api\ProjectController@deleteTimesheet` | ✅ |
| `GET` | `/api/V1/projects/{projectId}/tasks/meta` | `PMCore\Api\ProjectTaskController@getMeta` | ✅ |
| `GET` | `/api/V1/projects/{projectId}/tasks` | `PMCore\Api\ProjectTaskController@getTasks` | ✅ |
| `POST` | `/api/V1/projects/{projectId}/tasks` | `PMCore\Api\ProjectTaskController@createTask` | ✅ |
| `GET` | `/api/V1/projects/{projectId}/tasks/{taskId}` | `PMCore\Api\ProjectTaskController@getTask` | ✅ |
| `PUT` | `/api/V1/projects/{projectId}/tasks/{taskId}` | `PMCore\Api\ProjectTaskController@updateTask` | ✅ |
| `DELETE` | `/api/V1/projects/{projectId}/tasks/{taskId}` | `PMCore\Api\ProjectTaskController@deleteTask` | ✅ |
| `POST` | `/api/V1/projects/{projectId}/tasks/{taskId}/complete` | `PMCore\Api\ProjectTaskController@completeTask` | ✅ |
| `POST` | `/api/V1/projects/{projectId}/tasks/{taskId}/start` | `PMCore\Api\ProjectTaskController@startTask` | ✅ |
| `POST` | `/api/V1/projects/{projectId}/tasks/{taskId}/stop` | `PMCore\Api\ProjectTaskController@stopTask` | ✅ |
