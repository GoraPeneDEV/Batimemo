# Fonctionnalité Gestion des Congés (Leave Management)

## Vue d'ensemble

Le module de gestion des congés permet aux employés de soumettre des demandes de congé en libre-service, aux managers de les approuver ou rejeter, et aux administrateurs RH de gérer les soldes, les types de congé et de générer des rapports. L'ensemble du module expose également une **API REST mobile complète**.

---

## Architecture

```
app/
├── Http/Controllers/
│   ├── LeaveController.php           # Web : demandes (admin + self-service)
│   ├── LeaveTypeController.php       # Web : types de congé
│   ├── LeaveBalanceController.php    # Web : soldes
│   ├── LeaveReportController.php     # Web : rapports
│   └── Api/
│       └── LeaveController.php       # API mobile (JWT)
├── Models/
│   ├── LeaveRequest.php              # Demande de congé
│   ├── LeaveType.php                 # Type de congé
│   ├── UserAvailableLeave.php        # Solde disponible par employé
│   ├── LeaveAccrual.php              # Accumulation automatique
│   └── LeaveBalanceAdjustment.php    # Ajustements manuels
├── Enums/
│   └── LeaveRequestStatus.php        # pending | approved | rejected | cancelled | cancelled_by_admin
└── Notifications/Leave/
    ├── LeaveApproved.php
    ├── LeaveRejected.php
    ├── LeaveRequestSubmitted.php
    └── CancelLeaveRequest.php

resources/views/
├── leave/                            # Vues demandes de congé
├── leave-types/                      # Vues types de congé
└── leave-balance/                    # Vues soldes
```

---

## Base de données

### `leave_types`
| Colonne | Type | Description |
|---|---|---|
| `id` | bigint | Clé primaire |
| `name` | string | Nom (ex: Congé annuel) |
| `code` | string unique | Code court (ex: CA, CM) |
| `is_paid` | boolean | Congé payé ou non |
| `is_proof_required` | boolean | Justificatif obligatoire |
| `is_comp_off_type` | boolean | Congé compensatoire |
| `status` | enum | active / inactive |
| `is_accrual_enabled` | boolean | Accumulation automatique |
| `accrual_frequency` | enum | monthly / quarterly / yearly |
| `accrual_rate` | decimal | Jours accumulés par période |
| `max_accrual_limit` | decimal | Plafond d'accumulation |
| `allow_carry_forward` | boolean | Report d'une année à l'autre |
| `max_carry_forward` | decimal | Max jours reportés |
| `carry_forward_expiry_months` | int | Mois avant expiration des jours reportés |
| `allow_encashment` | boolean | Encaissement autorisé |
| `max_encashment_days` | decimal | Max jours encaissables |

### `leave_requests`
| Colonne | Type | Description |
|---|---|---|
| `id` | bigint | Clé primaire |
| `user_id` | FK | Employé demandeur |
| `leave_type_id` | FK | Type de congé |
| `from_date` | date | Date début |
| `to_date` | date | Date fin |
| `total_days` | decimal(4,2) | Jours calculés (0.5 pour demi-journée) |
| `is_half_day` | boolean | Demi-journée |
| `half_day_type` | enum | first_half / second_half |
| `status` | enum | pending / approved / rejected / cancelled / cancelled_by_admin |
| `user_notes` | string(500) | Motif de l'employé |
| `document` | string | Chemin du fichier justificatif |
| `emergency_contact` | string | Contact d'urgence |
| `emergency_phone` | string | Téléphone d'urgence |
| `is_abroad` | boolean | Voyage à l'étranger |
| `abroad_location` | string | Lieu du voyage |
| `approved_by_id` | FK | Approbateur |
| `approved_at` | timestamp | Date approbation |
| `approval_notes` | text | Notes de l'approbateur |
| `rejected_by_id` | FK | Rejeteur |
| `rejected_at` | timestamp | Date rejet |
| `cancelled_by_id` | FK | Annuleur |
| `cancel_reason` | string(500) | Motif d'annulation |
| `use_comp_off` | boolean | Utilise des congés compensatoires |
| `comp_off_days_used` | decimal(4,2) | Jours compensatoires utilisés |
| `comp_off_ids` | JSON | IDs des congés compensatoires |

### `users_available_leaves`
| Colonne | Type | Description |
|---|---|---|
| `user_id` | FK | Employé |
| `leave_type_id` | FK | Type |
| `year` | int | Année |
| `entitled_leaves` | decimal | Droit initial |
| `carried_forward_leaves` | decimal | Jours reportés |
| `additional_leaves` | decimal | Allocations spéciales |
| `used_leaves` | decimal | Consommés |
| `available_leaves` | decimal | Restants (calculé) |
| `carry_forward_expiry_date` | date | Expiration des jours reportés |

> Contrainte unique : `(user_id, leave_type_id, year)`

### `leave_accruals`
Enregistre chaque accumulation automatique (balance_before → balance_after).

### `leave_balance_adjustments`
Trace chaque ajustement manuel RH avec motif et historique des soldes.

---

## Flux complet d'une demande de congé

```
Employé → Soumet demande → [PENDING]
                                ↓
                        Manager reçoit notification (email + push)
                                ↓
              ┌─────────────────┴─────────────────┐
           Approve                              Reject
              ↓                                    ↓
          [APPROVED]                          [REJECTED]
    - Solde décrémenté                  - Motif enregistré
    - Comp-offs marqués utilisés        - Comp-offs libérés
    - Notification envoyée              - Notification envoyée
              ↓
    Employé peut annuler avant début
              ↓
         [CANCELLED]
    - Solde restauré
    - Comp-offs libérés
```

---

## Routes Web

### Types de congé (Admin)
```
GET    /hrcore/leave-types                     → listing
GET    /hrcore/leave-types/datatable           → DataTable AJAX
POST   /hrcore/leave-types                     → créer
GET    /hrcore/leave-types/{id}/edit           → formulaire édition
PUT    /hrcore/leave-types/{id}                → mettre à jour
DELETE /hrcore/leave-types/{id}                → supprimer
POST   /hrcore/leave-types/{id}/toggle-status  → activer/désactiver
```

### Demandes de congé (Admin)
```
GET    /hrcore/leaves                          → listing toutes les demandes
GET    /hrcore/leaves/datatable                → DataTable AJAX
POST   /hrcore/leaves                          → créer (pour un employé)
GET    /hrcore/leaves/{id}                     → détails
PUT    /hrcore/leaves/{id}                     → modifier
DELETE /hrcore/leaves/{id}                     → supprimer
POST   /hrcore/leaves/{id}/approve             → approuver
POST   /hrcore/leaves/{id}/reject              → rejeter
POST   /hrcore/leaves/{id}/cancel              → annuler
POST   /hrcore/leaves/{id}/action              → AJAX approve/reject/cancel
GET    /hrcore/leaves/team                     → calendrier équipe
```

### Soldes (Admin)
```
GET    /hrcore/leave-balance                   → listing soldes
GET    /hrcore/leave-balance/{employeeId}      → solde d'un employé
POST   /hrcore/leave-balance/set-initial       → définir l'allocation initiale
POST   /hrcore/leave-balance/adjust            → ajustement manuel
POST   /hrcore/leave-balance/bulk-set          → allocation en masse
```

### Self-Service (Employé)
```
GET    /hrcore/my/leaves                       → mes congés
GET    /hrcore/my/leaves/apply                 → formulaire de demande
POST   /hrcore/my/leaves/apply                 → soumettre une demande
GET    /hrcore/my/leaves/balance               → mon solde
GET    /hrcore/my/leaves/{id}                  → détails de ma demande
POST   /hrcore/my/leaves/{id}/cancel           → annuler ma demande
```

### Rapports
```
GET    /hrcore/leave-reports/dashboard          → tableau de bord analytique
GET    /hrcore/leave-reports/balance            → rapport de soldes
GET    /hrcore/leave-reports/balance/export     → export Excel
GET    /hrcore/leave-reports/history            → historique des demandes
GET    /hrcore/leave-reports/history/export     → export Excel
GET    /hrcore/leave-reports/department         → utilisation par département
GET    /hrcore/leave-reports/compliance         → conformité (expiration, encaissement)
```

---

## API Mobile (REST)

> **Authentification :** JWT Bearer Token
> **Préfixe :** `/api/V1/leave/`

### Endpoints

| Méthode | URL | Description |
|---|---|---|
| `GET` | `/api/V1/leave/types` | Types de congé actifs avec solde de l'utilisateur |
| `GET` | `/api/V1/leave/balance` | Solde de l'utilisateur connecté (param: `?year=`) |
| `GET` | `/api/V1/leave/requests` | Liste paginée (params: `skip`, `take`, `status`, `year`) |
| `POST` | `/api/V1/leave/requests` | Créer une demande de congé |
| `GET` | `/api/V1/leave/requests/{id}` | Détails d'une demande |
| `PUT` | `/api/V1/leave/requests/{id}` | Modifier une demande en attente |
| `DELETE` | `/api/V1/leave/requests/{id}` | Annuler une demande |
| `POST` | `/api/V1/leave/requests/{id}/upload` | Joindre un document (max 5 Mo) |
| `GET` | `/api/V1/leave/statistics` | Statistiques d'utilisation |
| `GET` | `/api/V1/leave/team-calendar` | Calendrier des congés de l'équipe |

### Exemple de payload — Créer une demande
```json
{
  "leave_type_id": 1,
  "from_date": "2026-03-10",
  "to_date": "2026-03-12",
  "is_half_day": false,
  "user_notes": "Vacances familiales",
  "emergency_contact": "Marie Tremblay",
  "emergency_phone": "+1 514 000 0000",
  "is_abroad": false,
  "use_comp_off": false
}
```

### Exemple de payload — Demi-journée
```json
{
  "leave_type_id": 2,
  "from_date": "2026-03-15",
  "to_date": "2026-03-15",
  "is_half_day": true,
  "half_day_type": "first_half",
  "user_notes": "Rendez-vous médical"
}
```

---

## Notifications

Chaque événement déclenche une notification multi-canal :

| Événement | Classes | Canaux |
|---|---|---|
| Demande soumise | `LeaveRequestSubmitted`, `NewLeaveRequest` | Email, Base de données, FCM (push) |
| Demande approuvée | `LeaveApproved`, `LeaveRequestApproval` | Email, Base de données, FCM |
| Demande rejetée | `LeaveRejected` | Email, Base de données, FCM |
| Demande annulée | `CancelLeaveRequest` | Email, Base de données, FCM |

> Les notifications FCM permettent les **notifications push mobiles** via Firebase Cloud Messaging.

---

## Fonctionnalités spéciales

### Accumulation automatique (Accrual)
- Paramétrable par type de congé : mensuel, trimestriel, annuel
- Le modèle `LeaveAccrual` enregistre chaque accumulation
- Méthode statique `LeaveAccrual::processAccruals($frequency)` à appeler via scheduler

### Congés compensatoires (Comp-off)
- Un employé peut choisir d'utiliser ses comp-offs pour couvrir tout ou partie d'un congé
- Les IDs des comp-offs utilisés sont stockés en JSON dans `comp_off_ids`
- En cas d'annulation, les comp-offs sont automatiquement libérés

### Demi-journées
- `is_half_day = true` avec `half_day_type = first_half | second_half`
- Comptabilisé comme 0.5 jour dans `total_days`

### Calcul des jours ouvrables
- Paramètre `weekend_included_in_leave` : inclure ou non les weekends
- Paramètre `holidays_included_in_leave` : inclure ou non les jours fériés
- Paramètre `min_advance_notice_days` : préavis minimum obligatoire

### Report et encaissement
- Chaque type de congé peut autoriser le report annuel (`allow_carry_forward`)
- Les jours reportés peuvent avoir une date d'expiration
- L'encaissement (`allow_encashment`) permet à l'employé de se faire payer ses jours non pris

---

## Règles de gestion

1. Les demandes ne peuvent pas se chevaucher (overlap detection)
2. Le solde est vérifié avant approbation
3. Seules les demandes en statut `pending` peuvent être modifiées ou rejetées
4. Une demande approuvée peut être annulée si elle n'a pas encore commencé
5. L'annulation restaure automatiquement le solde de l'employé
6. Les documents justificatifs sont stockés dans `storage/public/uploads/leaverequestdocuments/`

---

## Statuts possibles

| Statut | Description |
|---|---|
| `pending` | En attente d'approbation |
| `approved` | Approuvé par le manager |
| `rejected` | Rejeté avec motif |
| `cancelled` | Annulé par l'employé |
| `cancelled_by_admin` | Annulé par un administrateur |

---

## Permissions disponibles (non actives en test)

```
hrcore.view-leaves              hrcore.approve-leave
hrcore.view-own-leaves          hrcore.reject-leave
hrcore.create-leave             hrcore.cancel-leave
hrcore.edit-leave               hrcore.view-leave-balances
hrcore.delete-leave             hrcore.manage-leave-balances
hrcore.view-leave-reports       hrcore.view-leave-types
hrcore.create-leave-types       hrcore.edit-leave-types
hrcore.delete-leave-types
```

---

## Fichiers clés

| Fichier | Rôle |
|---|---|
| `app/Http/Controllers/LeaveController.php` | Contrôleur principal web |
| `app/Http/Controllers/Api/LeaveController.php` | Contrôleur API mobile |
| `app/Models/LeaveRequest.php` | Modèle + logique métier |
| `app/Models/LeaveType.php` | Configuration des types |
| `app/Models/UserAvailableLeave.php` | Suivi des soldes |
| `app/Enums/LeaveRequestStatus.php` | Enum des statuts |
| `routes/web.php` | Routes web (admin + self-service) |
| `routes/self-service.php` | Routes self-service employé |
| `resources/views/leave/` | Vues Blade |
