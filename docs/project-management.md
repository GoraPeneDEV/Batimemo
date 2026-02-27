# Fonctionnalité Gestion de Projets (PMCore)

## Vue d'ensemble

Le module PMCore est un système complet de gestion de projets qui couvre le cycle de vie d'un projet de bout en bout : création, affectation d'équipe, suivi des tâches, feuilles de temps, planification des ressources et suivi financier. Il s'intègre avec les modules **TaskSystem**, **CRMCore** et **AccountingCore**.

Il expose une **API REST mobile (3 endpoints implémentés ✅, 16 endpoints planifiés)** via `App\Http\Controllers\Api\ProjectController`, suivant la même structure que le module Leave.

> **Documentation mobile Flutter** : voir [`projet-management-mobile.md`](./projet-management-mobile.md) pour l'architecture complète de l'application mobile (modèles Dart, MobX Store, `DioApiClient`, pagination, traductions, widgets).

---

## Architecture

```
app/
└── Http/Controllers/Api/
    └── ProjectController.php               # ✅ API mobile (3 endpoints — liste, créer, détail)

Modules/PMCore/
├── App/
│   ├── Http/Controllers/
│   │   ├── Api/
│   │   │   └── ProjectController.php        # 🔜 API mobile étendue (16 endpoints planifiés)
│   │   ├── ProjectController.php            # CRUD projets + gestion équipe (web)
│   │   ├── ProjectTaskController.php        # Tâches de projet (si TaskSystem actif)
│   │   ├── TimesheetController.php          # Feuilles de temps (web)
│   │   ├── ResourceController.php           # Planification des ressources
│   │   ├── ProjectDashboardController.php   # Tableau de bord analytique
│   │   ├── ProjectReportController.php      # Rapports
│   │   ├── ProjectStatusController.php      # Statuts personnalisés
│   │   ├── SettingsController.php           # Configuration du module
│   │   └── PMCoreController.php             # Contrôleur racine (scaffolding)
│   ├── Models/
│   │   ├── Project.php                      # Modèle projet
│   │   ├── ProjectMember.php                # Membres d'un projet
│   │   ├── ProjectStatus.php                # Statuts personnalisés
│   │   ├── Timesheet.php                    # Feuilles de temps
│   │   ├── ResourceAllocation.php           # Allocations de ressources
│   │   └── ResourceCapacity.php             # Capacité journalière
│   ├── Enums/
│   │   ├── ProjectStatus.php                # planning | in_progress | on_hold | completed | cancelled
│   │   ├── ProjectPriority.php              # low | medium | high | critical
│   │   ├── ProjectType.php                  # residential | commercial | industrial | infrastructure | renovation | other
│   │   ├── ProjectMemberRole.php            # manager | lead | coordinator | member | viewer | client
│   │   └── TimesheetStatus.php              # draft | submitted | approved | rejected | invoiced
│   ├── Policies/
│   │   ├── ProjectPolicy.php
│   │   ├── ProjectTaskPolicy.php
│   │   └── TimesheetPolicy.php
│   └── Services/
│       └── PMIntegrationService.php         # Vérification des modules, utilitaires
└── routes/
    ├── web.php                              # Routes web
    └── api.php                              # Routes API mobile (étendue — planifié)

routes/
└── api.php                                  # ✅ Routes API mobile actives (V1/projects)
```

---

## Base de données

### `projects`
| Colonne | Type | Description |
|---|---|---|
| `id` | bigint | Clé primaire |
| `name` | varchar(255) | Nom du projet |
| `code` | varchar(50) unique | Code auto-généré (ex: PRJ-001) |
| `description` | longtext | Description |
| `status` | varchar | planning / in_progress / on_hold / completed / cancelled |
| `type` | varchar | internal / client / maintenance / development |
| `priority` | varchar | low / medium / high / urgent |
| `start_date` | date | Date de début |
| `end_date` | date | Date de fin (deadline) |
| `budget` | decimal(15,2) | Budget alloué |
| `actual_cost` | decimal(15,2) | Coût réel (calculé depuis timesheets) |
| `actual_revenue` | decimal(15,2) | Revenu réel (calculé depuis timesheets) |
| `completion_percentage` | int | Pourcentage d'avancement |
| `completed_at` | timestamp | Date de complétion |
| `is_archived` | boolean | Archivé ou non |
| `color_code` | varchar(7) | Couleur hex (ex: #007bff) |
| `is_billable` | boolean | Projet facturable |
| `hourly_rate` | decimal(8,2) | Taux horaire du projet |
| `client_id` | FK | Client (module CRMCore) |
| `project_manager_id` | FK | Chef de projet |
| `created_by_id` | FK | Créateur |
| `deleted_at` | timestamp | Soft delete |

> **Index** : `[status, type]`, `[client_id]`, `[project_manager_id]`, `[is_archived, status]`

---

### `project_members`
| Colonne | Type | Description |
|---|---|---|
| `id` | bigint | Clé primaire |
| `project_id` | FK | Projet |
| `user_id` | FK | Employé |
| `role` | varchar | manager / lead / coordinator / member / viewer / client |
| `hourly_rate` | decimal(8,2) | Taux horaire du membre sur ce projet |
| `allocation_percentage` | int (0-100) | % du temps alloué |
| `joined_at` | timestamp | Date d'ajout |
| `left_at` | timestamp | Date de retrait (null = actif) |

> **Contrainte unique** : `[project_id, user_id]`

---

### `timesheets`
| Colonne | Type | Description |
|---|---|---|
| `id` | bigint | Clé primaire |
| `user_id` | FK | Employé |
| `project_id` | FK | Projet |
| `task_id` | FK optionnel | Tâche liée (TaskSystem) |
| `date` | date | Date du travail |
| `hours` | decimal(4,2) | Heures travaillées |
| `description` | longtext | Description du travail |
| `is_billable` | boolean | Heures facturables |
| `billing_rate` | decimal(8,2) | Taux de facturation |
| `cost_rate` | decimal(8,2) | Taux de coût |
| `cost_amount` | decimal(8,2) | Montant coût (calculé auto) |
| `billable_amount` | decimal(8,2) | Montant facturable (calculé auto) |
| `status` | enum | draft / submitted / approved / rejected / invoiced |
| `approved_by_id` | FK | Approbateur |
| `approved_at` | timestamp | Date d'approbation |

> **Index** : `[user_id, date]`, `[project_id, date]`, `[status]`, `[is_billable]`

---

### `resource_allocations`
| Colonne | Type | Description |
|---|---|---|
| `id` | bigint | Clé primaire |
| `user_id` | FK | Ressource (employé) |
| `project_id` | FK | Projet |
| `start_date` | date | Début de l'allocation |
| `end_date` | date | Fin (null = indéfini) |
| `allocation_percentage` | decimal(5,2) | % d'allocation (0–100%) |
| `hours_per_day` | decimal(3,1) | Heures/jour (défaut: 8.0) |
| `allocation_type` | enum | project / task / phase |
| `task_id` | FK optionnel | Tâche associée |
| `phase` | varchar | Phase du projet |
| `is_billable` | boolean | Allocation facturable |
| `is_confirmed` | boolean | Allocation confirmée |
| `status` | enum | planned / active / completed / cancelled |

> **Index** : `[user_id, start_date, end_date]`, `[status]`

---

### `resource_capacities`
| Colonne | Type | Description |
|---|---|---|
| `user_id` | FK | Employé |
| `date` | date | Jour |
| `available_hours` | decimal(3,1) | Heures disponibles |
| `allocated_hours` | decimal(3,1) | Heures allouées |
| `utilized_hours` | decimal(3,1) | Heures saisies (timesheets) |
| `is_working_day` | boolean | Jour ouvrable |
| `leave_type` | varchar | Type de congé si absent |

> **Contrainte unique** : `[user_id, date]`

---

### `project_statuses`
| Colonne | Type | Description |
|---|---|---|
| `name` | varchar unique | Nom du statut |
| `slug` | varchar unique | Slug URL |
| `color` | varchar(7) | Couleur hex |
| `sort_order` | int | Ordre d'affichage |
| `is_active` | boolean | Actif |
| `is_default` | boolean | Statut par défaut |
| `is_completed` | boolean | Marque comme terminé |

---

## Flux complet d'un projet

```
Création projet [planning]
        ↓
  Ajout membres (rôles + allocation %)
        ↓
  Création tâches (si TaskSystem actif)
        ↓
  Saisie timesheets [draft]
        ↓
     Soumission [submitted]
        ↓
  ┌─────────────────┐
Approuver         Rejeter
[approved]        [rejected]
  ↓
[invoiced]
        ↓
  Mise à jour coûts/revenus du projet (auto)
        ↓
  Clôture → [completed] / Archive
```

---

## Routes Web

### Tableau de bord
```
GET  /projects/dashboard                       → tableau de bord analytique
```

### Projets (CRUD)
```
GET    /projects                               → liste des projets
GET    /projects/data/ajax                     → DataTable AJAX
GET    /projects/create                        → formulaire de création
POST   /projects                               → créer un projet
GET    /projects/{project}                     → détails du projet
GET    /projects/{project}/edit                → formulaire d'édition
PUT    /projects/{project}                     → mettre à jour
DELETE /projects/{project}                     → supprimer
POST   /projects/{project}/duplicate           → dupliquer le projet
POST   /projects/{project}/archive             → archiver le projet
```

### Membres d'équipe
```
POST   /projects/{project}/members             → ajouter un membre
GET    /projects/{project}/members/{member}    → détails d'un membre
PUT    /projects/{project}/members/{member}    → modifier rôle / allocation
DELETE /projects/{project}/members/{member}    → retirer un membre
```

### Tâches (si module TaskSystem actif)
```
GET    /projects/{project}/tasks               → liste des tâches
GET    /projects/{project}/tasks/board         → vue Kanban
GET    /projects/{project}/tasks/data/ajax     → DataTable AJAX
POST   /projects/{project}/tasks               → créer une tâche
GET    /projects/{project}/tasks/{task}        → détails tâche
PUT    /projects/{project}/tasks/{task}        → modifier tâche
DELETE /projects/{project}/tasks/{task}        → supprimer tâche
POST   /projects/{project}/tasks/{task}/complete → marquer terminée
POST   /projects/{project}/tasks/{task}/start  → démarrer chrono
POST   /projects/{project}/tasks/{task}/stop   → arrêter chrono
POST   /projects/{project}/tasks/reorder       → réordonner (drag & drop)
```

### Feuilles de temps
```
GET    /projects/timesheets                    → liste des feuilles de temps
GET    /projects/timesheets/data/ajax          → DataTable AJAX
GET    /projects/timesheets/statistics         → statistiques
GET    /projects/timesheets/create             → formulaire de création
POST   /projects/timesheets                    → soumettre
GET    /projects/timesheets/{timesheet}        → détails
GET    /projects/timesheets/{timesheet}/edit   → modifier
PUT    /projects/timesheets/{timesheet}        → mettre à jour
DELETE /projects/timesheets/{timesheet}        → supprimer
POST   /projects/timesheets/{timesheet}/submit → soumettre pour approbation
POST   /projects/timesheets/{timesheet}/approve → approuver
POST   /projects/timesheets/{timesheet}/reject  → rejeter
GET    /projects/{project}/timesheets           → timesheets d'un projet
GET    /projects/timesheets/projects/{project}/tasks → tâches d'un projet (select)
```

### Ressources
```
GET    /projects/resources                     → vue planification des ressources
GET    /projects/resources/data/ajax           → DataTable AJAX
GET    /projects/resources/create              → formulaire d'allocation
POST   /projects/resources                     → créer allocation
GET    /projects/resources/capacity            → vue capacité globale
GET    /projects/resources/capacity/data       → données de capacité
GET    /projects/resources/{user}/schedule     → planning d'une ressource
GET    /projects/resources/{allocation}/edit   → modifier allocation
PUT    /projects/resources/{allocation}        → mettre à jour
DELETE /projects/resources/{allocation}        → supprimer
POST   /projects/resources/availability        → vérifier disponibilité
```

### Statuts personnalisés
```
GET    /projects/project-statuses              → listing des statuts
GET    /projects/project-statuses/data/ajax    → DataTable AJAX
POST   /projects/project-statuses              → créer un statut
GET    /projects/project-statuses/{id}         → détails
PUT    /projects/project-statuses/{id}         → modifier
DELETE /projects/project-statuses/{id}         → supprimer
POST   /projects/project-statuses/{id}/toggle-active → activer/désactiver
POST   /projects/project-statuses/sort-order   → réordonner
POST   /projects/project-statuses/set-default  → définir comme statut par défaut
```

### Rapports
```
GET    /projects/reports                       → vue générale rapports
GET    /projects/reports/time                  → rapport temps (billable vs non)
GET    /projects/reports/budget                → rapport budget vs réel
GET    /projects/reports/resource              → rapport utilisation ressources
POST   /projects/reports/export                → export
```

### Recherche & Paramètres
```
GET    /projects/users/search                  → recherche d'utilisateurs (membre)
GET    /projects/clients/search                → recherche de clients (CRMCore)
GET    /projects/search                        → recherche de projets
GET    /projects/settings                      → paramètres du module
POST   /projects/settings/update               → sauvegarder les paramètres
```

---

## API Mobile (REST)

---

### ✅ Endpoints implémentés — `app/Http/Controllers/Api/ProjectController.php`

> **Authentification :** JWT — `Authorization: Bearer <token>` (`auth:api`)
> **Contrôleur :** `app/Http/Controllers/Api/ProjectController.php`
> **Fichier de routes :** `routes/api.php`
> **Préfixe :** `/api/V1/projects`
> **Sécurité :** Chaque endpoint vérifie que l'utilisateur est **manager ou membre actif** du projet

| Méthode | URL | Méthode contrôleur | Description |
|---|---|---|---|
| `GET` | `/api/V1/projects` | `getProjects()` | Liste paginée des projets accessibles |
| `POST` | `/api/V1/projects` | `createProject()` | Créer un nouveau projet |
| `GET` | `/api/V1/projects/{id}` | `getProject()` | Détails complets d'un projet |

#### Paramètres de requête — `GET /api/V1/projects`

| Paramètre | Type | Défaut | Description |
|---|---|---|---|
| `page` | int | `1` | Page de pagination |
| `perPage` | int | `15` | Nombre de résultats par page |
| `status` | string | — | Filtrer par statut (`planning`, `in_progress`, `on_hold`, `completed`, `cancelled`) |
| `type` | string | — | Filtrer par type (`residential`, `commercial`, `industrial`, `infrastructure`, `renovation`, `other`) |
| `search` | string | — | Recherche dans `name` et `code` |

#### Payload — `POST /api/V1/projects`

```json
{
  "name": "Réno cuisine Dubois",
  "description": "Rénovation complète de la cuisine au 123 rue Principale",
  "type": "residential",
  "priority": "high",
  "startDate": "2026-03-01",
  "endDate": "2026-05-31",
  "budget": 45000.00,
  "isBillable": true,
  "hourlyRate": 95.00,
  "colorCode": "#d4820a",
  "clientId": 12
}
```

> Le `status` est automatiquement défini à `planning` à la création.
> Le créateur est automatiquement ajouté comme membre avec le rôle `manager`.
> Le `code` (ex: `REN-001`) est généré automatiquement.

#### Réponse — liste de projets (`GET /api/V1/projects`)

```json
{
  "statusCode": 200,
  "status": "success",
  "data": {
    "projects": [
      {
        "id": 3,
        "name": "Réno cuisine Dubois",
        "code": "REN-001",
        "description": "Rénovation complète de la cuisine au 123 rue Principale",
        "status": "in_progress",
        "statusLabel": "in_progress",
        "type": "residential",
        "typeLabel": "residential",
        "priority": "high",
        "priorityLabel": "high",
        "startDate": "2026-03-01",
        "endDate": "2026-05-31",
        "budget": "45000.00",
        "actualCost": "12500.00",
        "completionPct": 25,
        "isOverdue": false,
        "isBillable": true,
        "hourlyRate": "95.00",
        "colorCode": "#d4820a",
        "clientName": "Famille Dubois",
        "projectManager": "Jean Tremblay",
        "membersCount": 4,
        "isArchived": false,
        "createdAt": "2026-02-10 09:00:00"
      }
    ],
    "total": 12,
    "page": 1,
    "perPage": 15,
    "lastPage": 1
  }
}
```

#### Réponse — détails d'un projet (`GET /api/V1/projects/{id}`)

```json
{
  "statusCode": 200,
  "status": "success",
  "data": {
    "id": 3,
    "name": "Réno cuisine Dubois",
    "code": "REN-001",
    "description": "Rénovation complète de la cuisine au 123 rue Principale",
    "status": "in_progress",
    "statusLabel": "in_progress",
    "type": "residential",
    "typeLabel": "residential",
    "priority": "high",
    "priorityLabel": "high",
    "startDate": "2026-03-01",
    "endDate": "2026-05-31",
    "budget": "45000.00",
    "actualCost": "12500.00",
    "completionPct": 25,
    "isOverdue": false,
    "isBillable": true,
    "hourlyRate": "95.00",
    "colorCode": "#d4820a",
    "clientName": "Famille Dubois",
    "projectManager": "Jean Tremblay",
    "membersCount": 4,
    "isArchived": false,
    "createdAt": "2026-02-10 09:00:00",
    "members": [
      {
        "userId": 8,
        "name": "Marie Gagnon",
        "role": "lead",
        "joinedAt": "2026-02-10",
        "isActive": true
      }
    ]
  }
}
```

---

### 🔜 Endpoints planifiés (à implémenter)

> **Contrôleur cible :** `Modules/PMCore/App/Http/Controllers/Api/ProjectController.php`

#### Projets (suite)

| Méthode | URL | Description |
|---|---|---|
| `GET` | `/api/V1/projects/statistics` | Statistiques du tableau de bord |
| `PUT` | `/api/V1/projects/{id}` | Mettre à jour un projet |
| `DELETE` | `/api/V1/projects/{id}` | Supprimer un projet (soft delete) |
| `POST` | `/api/V1/projects/{id}/archive` | Archiver / désarchiver |

#### Membres

| Méthode | URL | Description |
|---|---|---|
| `GET` | `/api/V1/projects/{id}/members` | Liste des membres actifs |
| `POST` | `/api/V1/projects/{id}/members` | Ajouter un membre |
| `PUT` | `/api/V1/projects/{id}/members/{memberId}` | Modifier rôle / allocation |
| `DELETE` | `/api/V1/projects/{id}/members/{memberId}` | Retirer un membre |

#### Feuilles de temps

| Méthode | URL | Description |
|---|---|---|
| `GET` | `/api/V1/projects/timesheets` | Mes feuilles de temps (paginées) |
| `POST` | `/api/V1/projects/timesheets` | Créer une entrée de temps |
| `GET` | `/api/V1/projects/timesheets/{id}` | Détails d'une feuille de temps |
| `PUT` | `/api/V1/projects/timesheets/{id}` | Modifier (draft uniquement) |
| `POST` | `/api/V1/projects/timesheets/{id}/submit` | Soumettre pour approbation |
| `DELETE` | `/api/V1/projects/timesheets/{id}` | Supprimer (draft uniquement) |

#### Payload — Ajouter un membre
```json
{
  "userId": 8,
  "role": "lead",
  "hourlyRate": 85.00,
  "allocationPercentage": 75
}
```

#### Payload — Créer une feuille de temps
```json
{
  "projectId": 3,
  "date": "2026-02-21",
  "hours": 6.5,
  "description": "Installation des armoires de cuisine — côté ouest",
  "isBillable": true,
  "billingRate": 95.00,
  "costRate": 65.00,
  "taskId": null
}
```

---

## Enums

### `ProjectStatus`
| Valeur | Label | Couleur |
|---|---|---|
| `planning` | En planification | Bleu |
| `in_progress` | En cours | Vert |
| `on_hold` | En pause | Orange |
| `completed` | Terminé | Gris |
| `cancelled` | Annulé | Rouge |

### `ProjectPriority`
| Valeur | Label |
|---|---|
| `low` | Faible |
| `medium` | Moyen (défaut) |
| `high` | Élevé |
| `critical` | Critique |

### `ProjectType`
| Valeur | Label |
|---|---|
| `residential` | Résidentiel |
| `commercial` | Commercial |
| `industrial` | Industriel |
| `infrastructure` | Infrastructure |
| `renovation` | Rénovation |
| `other` | Autre (défaut) |

### `ProjectMemberRole` — Permissions par rôle
| Rôle | Permissions |
|---|---|
| `manager` | view, edit, delete, manage_members, manage_tasks, manage_budget |
| `lead` | view, edit, manage_tasks, assign_tasks, log_time |
| `coordinator` | view, edit_tasks, create_tasks, manage_schedule, log_time |
| `member` | view, edit_tasks, create_tasks, log_time |
| `viewer` | view uniquement |
| `client` | view, comment |

### `TimesheetStatus`
```
draft → submitted → approved → invoiced
                  ↓
                rejected
```

---

## Suivi financier

Les financiers d'un projet sont calculés et mis à jour automatiquement depuis les feuilles de temps :

| Indicateur | Calcul |
|---|---|
| `actual_cost` | Σ `cost_amount` de toutes les timesheets approuvées |
| `actual_revenue` | Σ `billable_amount` des timesheets facturables approuvées |
| `budget_variance` | `budget - actual_cost` |
| `budget_variance_percentage` | `(budget_variance / budget) × 100` |
| `profit_margin` | `actual_revenue - actual_cost` |
| `profit_margin_percentage` | `(profit_margin / actual_revenue) × 100` |
| `total_hours` | Σ heures de toutes les timesheets |
| `billable_hours` | Σ heures des timesheets facturables |

---

## Gestion des ressources

### Capacité journalière
- Chaque employé dispose d'un enregistrement `resource_capacities` par jour de travail
- `available_hours` = heures de travail normales (défaut 8h)
- `allocated_hours` = recalculé automatiquement depuis les allocations actives
- `utilized_hours` = recalculé automatiquement depuis les timesheets

### Détection de conflits
- La méthode `checkCapacityConflicts()` identifie les jours où `allocated_hours > available_hours`
- `isOverallocated` retourne `true` si la somme dépasse 100% de la capacité

### Calculs automatiques
| Accesseur | Formule |
|---|---|
| `daily_allocated_hours` | `hours_per_day × allocation_percentage / 100` |
| `weekly_allocated_hours` | `daily × 5` |
| `monthly_allocated_hours` | `daily × 22` |
| `total_allocated_hours` | `jours_ouvrables × daily_allocated_hours` |

---

## Intégrations optionnelles

| Module | Rôle |
|---|---|
| **TaskSystem** | Gestion des tâches avec Kanban, chronomètre, réorganisation drag & drop |
| **CRMCore** | Liaison projet–client via le modèle `Company` |
| **AccountingCore** | Intégration budget (en développement) |
| **Calendar** | Événements liés aux projets via relation polymorphique |

La disponibilité de chaque module est vérifiée via `PMIntegrationService` avant d'exposer les fonctionnalités correspondantes.

---

## Permissions disponibles

```
pmcore.view-projects              pmcore.manage-project-team
pmcore.view-own-projects          pmcore.add-project-member
pmcore.create-project             pmcore.remove-project-member
pmcore.edit-project               pmcore.view-project-members
pmcore.edit-own-project           pmcore.view-timesheets
pmcore.delete-project             pmcore.manage-project-settings
pmcore.archive-project            pmcore.export-projects
pmcore.duplicate-project          pmcore.view-project-dashboard
                                  pmcore.view-project-reports
```

---

## Configuration du module

Paramètres gérés via `PMCoreSettings` :

| Paramètre | Défaut | Description |
|---|---|---|
| `default_project_status` | `planning` | Statut initial d'un nouveau projet |
| `default_project_priority` | `medium` | Priorité par défaut |
| `default_is_billable` | `true` | Facturable par défaut |
| `auto_generate_codes` | `true` | Générer automatiquement le code projet |
| `code_prefix_length` | `3` | Longueur du préfixe du code |
| `code_separator` | `-` | Séparateur dans le code (ex: PRJ-001) |

---

## Fichiers clés

| Fichier | Rôle |
|---|---|
| `app/Http/Controllers/Api/ProjectController.php` | ✅ API mobile active — 3 endpoints (liste, créer, détail) |
| `routes/api.php` | ✅ Routes API mobile actives (`V1/projects`) |
| `Modules/PMCore/App/Http/Controllers/Api/ProjectController.php` | 🔜 API mobile étendue — 16 endpoints planifiés |
| `Modules/PMCore/App/Http/Controllers/ProjectController.php` | Contrôleur web principal projets |
| `Modules/PMCore/App/Http/Controllers/TimesheetController.php` | Feuilles de temps (web) |
| `Modules/PMCore/App/Http/Controllers/ResourceController.php` | Planification ressources |
| `Modules/PMCore/App/Http/Controllers/ProjectTaskController.php` | Tâches (si TaskSystem) |
| `Modules/PMCore/App/Http/Controllers/ProjectDashboardController.php` | Analytics |
| `Modules/PMCore/App/Models/Project.php` | Modèle + logique métier |
| `Modules/PMCore/App/Models/ProjectMember.php` | Membres de l'équipe |
| `Modules/PMCore/App/Models/Timesheet.php` | Feuilles de temps |
| `Modules/PMCore/App/Models/ResourceAllocation.php` | Allocations ressources |
| `Modules/PMCore/App/Models/ResourceCapacity.php` | Capacité journalière |
| `Modules/PMCore/App/Policies/ProjectPolicy.php` | Autorisation accès projets |
| `Modules/PMCore/App/Services/PMIntegrationService.php` | Utilitaires & intégrations |
| `Modules/PMCore/routes/web.php` | Routes web |
| `Modules/PMCore/routes/api.php` | Routes API étendue (à venir) |
| `docs/projet-management-mobile.md` | 📱 Documentation complète du module mobile Flutter |
