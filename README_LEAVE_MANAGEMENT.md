# Leave Management — Documentation d'implémentation

Ce document explique en détail comment la fonctionnalité **Leave Management** est implémentée dans l'application Flutter `oyee_app`. Il sert de base pour comprendre l'architecture et reproduire le même pattern pour ajouter d'autres fonctionnalités.

---

## Table des matières

1. [Architecture générale](#1-architecture-générale)
2. [Arborescence des fichiers](#2-arborescence-des-fichiers)
3. [Couche Modèles](#3-couche-modèles)
4. [Couche Repository (API)](#4-couche-repository-api)
5. [Couche Store (MobX)](#5-couche-store-mobx)
6. [Couche UI — Screens](#6-couche-ui--screens)
7. [Navigation](#7-navigation)
8. [Flux de données complet](#8-flux-de-données-complet)
9. [Pattern pour ajouter une nouvelle fonctionnalité](#9-pattern-pour-ajouter-une-nouvelle-fonctionnalité)

---

## 1. Architecture générale

L'application suit une architecture en **4 couches** :

```
┌─────────────────────────────────────────────────────┐
│                  UI (Screens)                        │
│  Affiche les données, capte les actions utilisateur  │
├─────────────────────────────────────────────────────┤
│              Store (MobX)                            │
│  Gère l'état global, orchestre les appels API        │
├─────────────────────────────────────────────────────┤
│            Repository (Dio)                          │
│  Effectue les requêtes HTTP, sérialise les données   │
├─────────────────────────────────────────────────────┤
│              Modèles (Dart)                          │
│  Définissent la structure des données                │
└─────────────────────────────────────────────────────┘
```

**Bibliothèques clés :**
| Bibliothèque | Rôle |
|---|---|
| `mobx` + `flutter_mobx` | Gestion d'état réactif |
| `provider` | Injection de dépendances (accès au Store dans les Screens) |
| `dio` | Client HTTP avec intercepteurs |
| `intl` | Formatage des dates |
| `file_picker` | Sélection de fichiers (documents) |
| `shimmer` | Skeleton de chargement |
| `table_calendar` | Calendrier visuel |

---

## 2. Arborescence des fichiers

```
lib/
├── models/
│   └── leave/
│       ├── leave_request.dart          # Demande de congé
│       ├── leave_type.dart             # Type de congé (annuel, maladie...)
│       ├── leave_balance.dart          # Solde pour un type
│       ├── leave_balance_summary.dart  # Résumé de tous les soldes
│       ├── leave_statistics.dart       # Statistiques annuelles
│       ├── compensatory_off.dart       # Récupération (comp-off)
│       ├── simple_user.dart            # Utilisateur simplifié
│       ├── team_calendar_item.dart     # Élément du calendrier équipe
│       └── comp_off_detail.dart        # Détail comp-off dans une demande
│
├── api/
│   └── dio_api/
│       └── repositories/
│           └── leave_repository.dart   # Toutes les requêtes HTTP Leave
│
├── stores/
│   ├── leave_store.dart                # Store MobX (état + actions)
│   └── leave_store.g.dart              # Code généré (ne pas éditer manuellement)
│
└── screens/
    └── Leave/
        ├── leave_dashboard_screen.dart         # Tableau de bord principal
        ├── leave_requests_list_screen.dart     # Liste des demandes
        ├── leave_request_form_screen.dart      # Formulaire créer/modifier
        ├── leave_request_detail_screen.dart    # Détail + annulation
        ├── leave_statistics_screen.dart        # Statistiques
        ├── team_calendar_screen.dart           # Calendrier équipe
        └── compensatory_off/
            ├── comp_off_list_screen.dart       # Liste comp-offs
            ├── comp_off_form_screen.dart       # Formulaire comp-off
            └── comp_off_detail_screen.dart     # Détail comp-off
```

---

## 3. Couche Modèles

Les modèles définissent la structure des données. Chaque modèle suit ce pattern :

```dart
class LeaveRequest {
  // Champs
  final int id;
  final String status;
  // ...

  // Constructeur
  LeaveRequest({required this.id, required this.status, ...});

  // Désérialisation depuis JSON (API → Dart)
  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      status: json['status'],
      // ...
    );
  }

  // Sérialisation vers JSON (Dart → API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      // ...
    };
  }

  // Getters calculés (propriétés dérivées)
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
}
```

### Modèles et leur rôle

| Modèle | Fichier | Description |
|---|---|---|
| `LeaveRequest` | `leave_request.dart` | Une demande de congé complète avec statut, dates, notes, approbation, annulation |
| `LeaveType` | `leave_type.dart` | Type de congé (annuel, maladie, comp-off...) avec ses règles |
| `LeaveBalance` | `leave_balance.dart` | Solde pour un type précis : droit + utilisé + disponible |
| `LeaveBalanceSummary` | `leave_balance_summary.dart` | Tous les soldes d'une année pour un utilisateur |
| `LeaveStatistics` | `leave_statistics.dart` | Compteurs annuels : pending/approved/rejected + breakdown par type |
| `CompensatoryOff` | `compensatory_off.dart` | Demande de récupération (jour travaillé → jours offerts) |
| `SimpleUser` | `simple_user.dart` | Utilisateur simplifié (id, name, photo) pour les approbations |
| `TeamCalendarItem` | `team_calendar_item.dart` | Congé d'un collègue visible dans le calendrier équipe |

### Champs importants de `LeaveRequest`

```dart
// Identification
int id
String status          // 'pending' | 'approved' | 'rejected' | 'cancelled'

// Dates
String fromDate        // Format: 'YYYY-MM-DD'
String toDate
double totalDays

// Options
bool isHalfDay
String? halfDayType    // 'first_half' | 'second_half'
String? userNotes
String? emergencyContact
String? emergencyPhone
bool? isAbroad
String? abroadLocation
String? documentUrl

// Comp-off
bool usesCompOff
List<int>? compOffIds

// Approbation (remplis par le serveur)
SimpleUser? approvedBy
DateTime? approvedAt
String? approvalNotes

// Annulation
String? cancelReason
bool canCancel         // Flag serveur pour savoir si l'annulation est permise

// Getters calculés
bool get isPending   => status == 'pending';
bool get isApproved  => status == 'approved';
bool get isRejected  => status == 'rejected';
bool get isCancelled => status == 'cancelled';
```

---

## 4. Couche Repository (API)

Le repository est la **seule couche** qui communique avec l'API. Il utilise **Dio** comme client HTTP.

**Fichier :** `lib/api/dio_api/repositories/leave_repository.dart`

**Base URL :** `https://batimemo.com/api/V1/`

### Pattern d'un appel API

```dart
Future<LeaveRequest?> getLeaveRequest(int id) async {
  return safeApiCall(() async {
    final response = await dio.get('leave/requests/$id');
    return LeaveRequest.fromJson(response.data['data']);
  });
}
```

Le wrapper `safeApiCall` :
- Capture toutes les exceptions réseau
- Retourne `null` en cas d'erreur
- Log l'erreur pour le debug

### Endpoints disponibles

#### Congés (Leave Requests)

| Méthode | Endpoint | Description |
|---|---|---|
| GET | `leave/types` | Liste des types de congés avec soldes |
| GET | `leave/balance?year=XXXX` | Soldes de l'utilisateur pour une année |
| GET | `leave/requests` | Liste paginée (params: skip, take, status, year, leaveTypeId) |
| GET | `leave/requests/{id}` | Détail d'une demande |
| POST | `leave/requests` | Créer une demande (JSON ou FormData si document) |
| POST | `leave/requests/{id}` | Modifier (avec `_method=PUT` pour Laravel) |
| DELETE | `leave/requests/{id}` | Annuler une demande |
| POST | `leave/requests/{id}/upload` | Uploader un document justificatif |
| GET | `leave/statistics?year=XXXX` | Statistiques annuelles |
| GET | `leave/team-calendar?fromDate=X&toDate=Y` | Congés de l'équipe |

#### Récupérations (Comp-Off)

| Méthode | Endpoint | Description |
|---|---|---|
| GET | `comp-off/list` | Liste paginée des comp-offs |
| GET | `comp-off/{id}` | Détail d'un comp-off |
| GET | `comp-off/balance` | Solde comp-off de l'utilisateur |
| POST | `comp-off/request` | Créer une demande de comp-off |
| PUT | `comp-off/{id}` | Modifier un comp-off en attente |
| DELETE | `comp-off/{id}` | Supprimer un comp-off |
| GET | `comp-off/statistics?year=XXXX` | Statistiques comp-off |

### Gestion des uploads (FormData)

Quand un document est joint, la requête utilise `FormData` au lieu de JSON :

```dart
final formData = FormData.fromMap({
  'leave_type_id': leaveTypeId,
  'from_date': fromDate,
  // ...autres champs...
  'document': await MultipartFile.fromFile(
    document.path,
    filename: document.path.split('/').last,
  ),
});
final response = await dio.post('leave/requests', data: formData);
```

### Méthode PUT via POST (compatibilité Laravel)

Laravel nécessite d'envoyer PUT sous forme de POST avec `_method=PUT` pour les FormData :

```dart
final formData = FormData.fromMap({
  '_method': 'PUT',  // Laravel method spoofing
  'from_date': fromDate,
  // ...
});
final response = await dio.post('leave/requests/$id', data: formData);
```

---

## 5. Couche Store (MobX)

Le Store est le **chef d'orchestre** : il maintient l'état global et expose des actions que les Screens appellent.

**Fichier :** `lib/stores/leave_store.dart`
**Fichier généré :** `lib/stores/leave_store.g.dart` (généré par `build_runner`, ne pas éditer)

### Structure du Store

```dart
class LeaveStore = _LeaveStore with _$LeaveStore;

abstract class _LeaveStore with Store {
  final LeaveRepository _repository;

  _LeaveStore(this._repository);

  // ─── État Observable ───────────────────────────────────────────
  @observable bool isLoading = false;
  @observable String? error;

  @observable ObservableList<LeaveType> leaveTypes = ObservableList();
  @observable LeaveBalanceSummary? leaveBalanceSummary;

  @observable ObservableList<LeaveRequest> leaveRequests = ObservableList();
  @observable int totalLeaveRequestsCount = 0;
  @observable LeaveRequest? selectedLeaveRequest;

  @observable LeaveStatistics? leaveStatistics;
  @observable TeamCalendar? teamCalendar;

  @observable ObservableList<CompensatoryOff> compensatoryOffs = ObservableList();
  @observable int totalCompOffsCount = 0;
  @observable CompensatoryOff? selectedCompensatoryOff;
  @observable CompensatoryOffBalance? compOffBalance;
  @observable CompensatoryOffStatistics? compOffStatistics;

  // ─── Actions ────────────────────────────────────────────────────
  @action
  Future<void> fetchLeaveTypes() async { ... }

  @action
  Future<bool> createLeaveRequest({...}) async { ... }
  // ...
}
```

### Règles MobX importantes

- **`@observable`** : variable réactive — quand elle change, les Widgets qui l'écoutent se reconstruisent
- **`@action`** : méthode qui peut modifier des observables
- **`Observer`** : Widget Flutter qui se reconstruit automatiquement quand un observable change

### Pattern d'une action du Store

```dart
@action
Future<bool> createLeaveRequest({
  required int leaveTypeId,
  required String fromDate,
  required String toDate,
  required String userNotes,
  // ...autres paramètres...
}) async {
  isLoading = true;
  error = null;

  try {
    final result = await _repository.createLeaveRequest(
      leaveTypeId: leaveTypeId,
      fromDate: fromDate,
      toDate: toDate,
      userNotes: userNotes,
    );

    if (result != null) {
      // Rafraîchir les données affectées
      await fetchLeaveRequests();
      await fetchLeaveBalance();
      return true;
    }

    error = 'Erreur lors de la création';
    return false;
  } catch (e) {
    error = e.toString();
    return false;
  } finally {
    isLoading = false;
  }
}
```

### Actions avec pagination (loadMore)

```dart
@action
Future<void> fetchLeaveRequests({
  int skip = 0,
  int take = 20,
  String? status,
  bool loadMore = false,  // true = ajouter à la liste, false = remplacer
}) async {
  if (!loadMore) isLoading = true;

  final result = await _repository.getLeaveRequests(
    skip: skip, take: take, status: status,
  );

  if (result != null) {
    totalLeaveRequestsCount = result['totalCount'];

    if (loadMore) {
      leaveRequests.addAll(result['values']);  // Infini scroll
    } else {
      leaveRequests = ObservableList.of(result['values']);
    }
  }

  isLoading = false;
}
```

### Rafraîchissement automatique après mutation

Après create/update/delete, le Store rafraîchit automatiquement les listes et soldes affectés :

```dart
// Après création d'une demande
await fetchLeaveRequests();     // Rafraîchit la liste
await fetchLeaveBalance();      // Rafraîchit les soldes (jours déduits)

// Après utilisation de comp-off
await fetchCompensatoryOffBalance();  // Rafraîchit le solde comp-off
```

---

## 6. Couche UI — Screens

### 6.1 Leave Dashboard Screen

**Fichier :** `lib/screens/Leave/leave_dashboard_screen.dart`

**Rôle :** Page principale du module, point d'entrée.

**Ce qu'elle affiche :**
1. **Carte de soldes** (gradient en haut) — affiche les 3 premiers types de congés avec barre de progression. Bouton "Voir tout" → bottom sheet avec le détail complet.
2. **Grille d'actions rapides** — 4 tuiles (Mes Congés, Statistiques, Calendrier Équipe, Comp-Off).
3. **Carte statistiques** — compteurs Pending/Approved/Rejected de l'année.
4. **Section congés à venir** — les 3 prochains congés approuvés.

**Données chargées au démarrage :**
```dart
@override
void initState() {
  super.initState();
  final store = context.read<LeaveStore>();
  store.fetchLeaveBalance();
  store.fetchLeaveStatistics();
  store.fetchLeaveTypes();
}
```

**FAB :** Bouton `+ Nouveau Congé` → `LeaveRequestFormScreen`

**Skeleton de chargement :** Utilise `shimmer` pour afficher des placeholders pendant le chargement.

**Pattern Observer dans un Screen :**
```dart
class _LeaveDashboardScreenState extends State<LeaveDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final store = context.read<LeaveStore>();

    return Observer(
      builder: (_) {
        if (store.isLoading) return _buildSkeleton();
        if (store.error != null) return _buildError(store);

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await store.fetchLeaveBalance();
              await store.fetchLeaveStatistics();
            },
            child: ListView(
              children: [
                _buildBalanceCard(store),
                _buildQuickActions(),
                _buildStatsCard(store),
                _buildUpcomingLeaves(store),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LeaveRequestFormScreen()),
            ),
            label: Text('+ Nouveau Congé'),
          ),
        );
      },
    );
  }
}
```

---

### 6.2 Leave Requests List Screen

**Fichier :** `lib/screens/Leave/leave_requests_list_screen.dart`

**Rôle :** Liste paginée de toutes les demandes de congé avec filtres.

**Fonctionnalités :**
- Filtres : statut (All/Pending/Approved/Rejected/Cancelled), année, type de congé
- Barre de résumé des filtres actifs avec bouton Clear
- Chaque carte affiche : type, ID, plage de dates, durée, badge statut coloré
- Scroll infini (20 items / page)
- Pull-to-refresh
- États vides et d'erreur

**Initialisation :**
```dart
@override
void initState() {
  super.initState();
  final store = context.read<LeaveStore>();
  store.fetchLeaveRequests();
  store.fetchLeaveTypes();  // Pour le filtre par type
}
```

**Scroll infini :**
```dart
_scrollController.addListener(() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    final store = context.read<LeaveStore>();
    if (store.leaveRequests.length < store.totalLeaveRequestsCount) {
      store.fetchLeaveRequests(
        skip: store.leaveRequests.length,
        status: _selectedStatus,
        loadMore: true,
      );
    }
  }
});
```

---

### 6.3 Leave Request Form Screen

**Fichier :** `lib/screens/Leave/leave_request_form_screen.dart`

**Rôle :** Formulaire de création ET de modification d'une demande.

**Mode édition :** Si `leaveRequest` est passé en paramètre, le formulaire est pré-rempli et appelle `updateLeaveRequest`.

**Champs du formulaire :**

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| Type de congé | Dropdown | Oui | Liste depuis `store.leaveTypes` |
| Date début | DatePicker | Oui | Min: aujourd'hui |
| Date fin | DatePicker | Oui | Min: date début |
| Demi-journée | Toggle + Dropdown | Non | Premier/Deuxième mi-temps |
| Motif / Notes | TextArea | Oui | Raison de la demande |
| Contact urgence | TextField | Non | Nom du contact |
| Téléphone urgence | TextField | Non | Numéro |
| Voyage à l'étranger | Toggle + TextField | Non | Localisation si activé |
| Document | FilePicker | Non | PDF/JPG/PNG, max 5MB |
| Utiliser Comp-Off | Toggle + MultiSelect | Non | Sélection parmi les comp-offs disponibles |

**Validation :**
```dart
final _formKey = GlobalKey<FormState>();

// Dans le bouton submit :
if (_formKey.currentState!.validate()) {
  _formKey.currentState!.save();
  // Appel store...
}
```

**Soumission :**
```dart
final success = await store.createLeaveRequest(
  leaveTypeId: _selectedLeaveTypeId!,
  fromDate: DateFormat('yyyy-MM-dd').format(_fromDate!),
  toDate: DateFormat('yyyy-MM-dd').format(_toDate!),
  userNotes: _notes,
  isHalfDay: _isHalfDay,
  halfDayType: _halfDayType,
  document: _selectedFile,
  useCompOff: _useCompOff,
  compOffIds: _selectedCompOffIds,
);

if (success) {
  Navigator.pop(context);
}
```

---

### 6.4 Leave Request Detail Screen

**Fichier :** `lib/screens/Leave/leave_request_detail_screen.dart`

**Rôle :** Affichage complet d'une demande + actions (modifier, annuler).

**Sections affichées :**
1. Badge statut coloré (Pending = orange, Approved = vert, Rejected = rouge, Cancelled = gris)
2. Informations de la demande (type, ID, dates, durée)
3. Détails personnels (motif, contact urgence, localisation, document)
4. Détails comp-off utilisé (si applicable)
5. Informations d'approbation/rejet (par qui, quand, notes)
6. Informations d'annulation (par qui, quand, raison)

**Actions disponibles (selon le statut) :**
- **Modifier** : visible si `isPending` → redirige vers `LeaveRequestFormScreen` avec la demande
- **Annuler** : visible si `isPending && canCancel` → dialog de confirmation avec champ raison optionnel

**Dialog d'annulation :**
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text('Annuler la demande'),
    content: Column(
      children: [
        Text('Êtes-vous sûr ?'),
        TextField(
          controller: _cancelReasonController,
          decoration: InputDecoration(hintText: 'Raison (optionnelle)'),
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Non')),
      ElevatedButton(
        onPressed: () async {
          final success = await store.cancelLeaveRequest(
            widget.leaveRequest.id,
            reason: _cancelReasonController.text,
          );
          if (success) Navigator.pop(context); // Ferme le dialog
        },
        child: Text('Confirmer'),
      ),
    ],
  ),
);
```

---

### 6.5 Leave Statistics Screen

**Fichier :** `lib/screens/Leave/leave_statistics_screen.dart`

**Rôle :** Vue analytique des congés pour une année donnée.

**Contenu :**
- Sélecteur d'année (bottom sheet avec les 5 dernières années)
- Cartes compteurs : Pending / Approved / Rejected
- Tableau des soldes par type (droit, utilisé, disponible + barre de progression)
- Liste des congés à venir approuvés
- Répartition par type de congé (jours + nombre de demandes)

**Chargement par année :**
```dart
void _onYearChanged(int year) {
  setState(() => _selectedYear = year);
  store.fetchLeaveStatistics(year: year);
  store.fetchLeaveBalance(year: year);
}
```

---

### 6.6 Team Calendar Screen

**Fichier :** `lib/screens/Leave/team_calendar_screen.dart`

**Rôle :** Visualiser les congés approuvés des collègues.

**Fonctionnalités :**
- Navigation mois par mois (précédent / suivant)
- Vue liste : congés groupés par période, avec avatar + nom utilisateur
- Vue calendrier : grille visuelle avec indicateurs de jours
- Chaque carte : nom, type de congé, plage de dates, durée, indicateur demi-journée

**Chargement par mois :**
```dart
void _loadMonth(DateTime month) {
  final from = DateTime(month.year, month.month, 1);
  final to = DateTime(month.year, month.month + 1, 0);
  store.fetchTeamCalendar(
    fromDate: DateFormat('yyyy-MM-dd').format(from),
    toDate: DateFormat('yyyy-MM-dd').format(to),
  );
}
```

---

### 6.7 Compensatory Off Screens

**Fichiers :** `lib/screens/Leave/compensatory_off/`

Ces 3 écrans suivent exactement le même pattern que les écrans Leave Request.

| Screen | Rôle | Actions Store |
|---|---|---|
| `comp_off_list_screen.dart` | Liste paginée avec filtre statut | `fetchCompensatoryOffs()` |
| `comp_off_form_screen.dart` | Formulaire (date travaillée, heures, motif) | `requestCompensatoryOff()` / `updateCompensatoryOff()` |
| `comp_off_detail_screen.dart` | Détail + lien vers congé si utilisé | `fetchCompensatoryOff()` |

---

## 7. Navigation

**Arbre de navigation :**

```
LeaveDashboardScreen
  ├── [FAB] → LeaveRequestFormScreen (création)
  ├── [Mes Congés] → LeaveRequestsListScreen
  │     ├── [Carte] → LeaveRequestDetailScreen
  │     │     └── [Modifier] → LeaveRequestFormScreen (édition)
  │     └── [FAB] → LeaveRequestFormScreen (création)
  ├── [Statistiques] → LeaveStatisticsScreen
  ├── [Calendrier Équipe] → TeamCalendarScreen
  └── [Comp-Off] → CompOffListScreen
        ├── [Carte] → CompOffDetailScreen
        └── [FAB] → CompOffFormScreen
```

**Méthode de navigation utilisée :**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => LeaveRequestDetailScreen(leaveRequest: request),
  ),
);
```

**Passer des données à l'écran suivant :**
```dart
// Dans le screen appelant :
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => LeaveRequestFormScreen(
      leaveRequest: existingRequest,  // null = création, non-null = édition
    ),
  ),
);

// Dans le screen destination :
class LeaveRequestFormScreen extends StatefulWidget {
  final LeaveRequest? leaveRequest;  // Null si nouveau
  const LeaveRequestFormScreen({this.leaveRequest});
}
```

**Accéder au Store depuis n'importe quel Screen :**
```dart
// Lecture seule (ne déclenche pas de rebuild)
final store = context.read<LeaveStore>();

// Dans un Observer (déclenche rebuild sur changement)
Observer(
  builder: (_) {
    final store = context.read<LeaveStore>();
    return Text('${store.totalLeaveRequestsCount} demandes');
  },
)
```

---

## 8. Flux de données complet

**Exemple : Créer une demande de congé**

```
1. Utilisateur remplit LeaveRequestFormScreen
       │
2. Appuie sur "Soumettre"
       │
3. store.createLeaveRequest(...) appelé
       │
4. isLoading = true  →  Observer déclenche rebuild  →  UI affiche loader
       │
5. repository.createLeaveRequest(...)  →  POST leave/requests
       │
       ├── [Succès 201]
       │     │
       │   6. Retourne {message, leaveRequestId, leaveRequest}
       │     │
       │   7. store.fetchLeaveRequests()  →  Rafraîchit la liste
       │   8. store.fetchLeaveBalance()   →  Met à jour les soldes
       │   9. isLoading = false
       │  10. return true
       │     │
       │  11. Screen navigue vers la liste
       │
       └── [Erreur]
             │
           6. store.error = "Message d'erreur"
           7. isLoading = false
           8. return false
             │
           9. Screen affiche un dialog d'erreur
```

---

## 9. Pattern pour ajouter une nouvelle fonctionnalité

Pour ajouter une fonctionnalité du même type (ex: gestion des notes de frais, des formations, etc.), suivre ces étapes dans l'ordre :

### Étape 1 : Créer les Modèles

```
lib/models/
└── expense/
    ├── expense_request.dart        # Entité principale
    ├── expense_type.dart           # Types (transport, repas...)
    └── expense_statistics.dart     # Statistiques
```

Chaque modèle doit avoir :
- Tous les champs de l'API
- `factory X.fromJson(Map<String, dynamic> json)`
- `Map<String, dynamic> toJson()`
- Getters calculés si nécessaire

### Étape 2 : Créer le Repository

```
lib/api/dio_api/repositories/
└── expense_repository.dart
```

Structure :
```dart
class ExpenseRepository {
  final Dio _dio;
  ExpenseRepository(this._dio);

  Future<List<ExpenseRequest>?> getExpenseRequests({int skip = 0, int take = 20}) async {
    return safeApiCall(() async {
      final response = await _dio.get('expenses', queryParameters: {'skip': skip, 'take': take});
      final list = response.data['data'] as List;
      return list.map((e) => ExpenseRequest.fromJson(e)).toList();
    });
  }

  Future<bool?> createExpenseRequest({required double amount, required String description}) async {
    return safeApiCall(() async {
      final response = await _dio.post('expenses', data: {
        'amount': amount,
        'description': description,
      });
      return response.statusCode == 201;
    });
  }
}
```

### Étape 3 : Créer le Store MobX

```
lib/stores/
├── expense_store.dart
└── expense_store.g.dart   # Généré automatiquement
```

Structure :
```dart
part 'expense_store.g.dart';

class ExpenseStore = _ExpenseStore with _$ExpenseStore;

abstract class _ExpenseStore with Store {
  final ExpenseRepository _repository;
  _ExpenseStore(this._repository);

  @observable bool isLoading = false;
  @observable String? error;
  @observable ObservableList<ExpenseRequest> expenses = ObservableList();
  @observable int totalCount = 0;

  @action
  Future<void> fetchExpenses({int skip = 0, bool loadMore = false}) async {
    if (!loadMore) isLoading = true;
    final result = await _repository.getExpenseRequests(skip: skip);
    if (result != null) {
      if (loadMore) expenses.addAll(result);
      else expenses = ObservableList.of(result);
    }
    isLoading = false;
  }

  @action
  Future<bool> createExpense({required double amount, required String description}) async {
    isLoading = true;
    final success = await _repository.createExpenseRequest(amount: amount, description: description);
    if (success == true) {
      await fetchExpenses();
    }
    isLoading = false;
    return success == true;
  }
}
```

**Générer le fichier `.g.dart` :**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Étape 4 : Enregistrer le Store avec Provider

Trouver où les stores sont déclarés (généralement dans `main.dart` ou `app.dart`) et ajouter :

```dart
MultiProvider(
  providers: [
    // ...stores existants...
    Provider<ExpenseRepository>(create: (_) => ExpenseRepository(dio)),
    ProxyProvider<ExpenseRepository, ExpenseStore>(
      update: (_, repo, __) => ExpenseStore(repo),
    ),
  ],
  child: MaterialApp(...),
)
```

### Étape 5 : Créer les Screens

```
lib/screens/Expense/
├── expense_dashboard_screen.dart   # Tableau de bord
├── expense_list_screen.dart        # Liste paginée
├── expense_form_screen.dart        # Créer/Modifier
└── expense_detail_screen.dart      # Détail + actions
```

Structure minimale d'un screen :

```dart
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    context.read<ExpenseStore>().fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<ExpenseStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Notes de Frais')),
      body: Observer(
        builder: (_) {
          // 1. Afficher le skeleton pendant le chargement
          if (store.isLoading && store.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Afficher l'erreur
          if (store.error != null) {
            return Center(
              child: Column(
                children: [
                  Text('Erreur: ${store.error}'),
                  ElevatedButton(
                    onPressed: () => store.fetchExpenses(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // 3. Afficher la liste
          if (store.expenses.isEmpty) {
            return const Center(child: Text('Aucune note de frais'));
          }

          return RefreshIndicator(
            onRefresh: () => store.fetchExpenses(),
            child: ListView.builder(
              itemCount: store.expenses.length,
              itemBuilder: (_, i) => _buildExpenseCard(store.expenses[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
        ),
        label: const Text('+ Nouvelle Note'),
      ),
    );
  }
}
```

### Étape 6 : Ajouter la navigation

Ajouter l'entrée dans la page principale du module (ex: menu latéral ou dashboard) :

```dart
// Dans le menu ou dashboard principal
ListTile(
  leading: const Icon(Icons.receipt),
  title: const Text('Notes de Frais'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ExpenseDashboardScreen()),
  ),
),
```

---

## Résumé des conventions du projet

| Convention | Valeur |
|---|---|
| Gestion d'état | MobX (`@observable`, `@action`, `Observer`) |
| Injection de dépendances | `Provider` + `context.read<Store>()` |
| Client HTTP | `Dio` avec `safeApiCall` wrapper |
| Format de date API | `yyyy-MM-dd` (ex: `2025-01-15`) |
| Format de date UI | `DD MMM YYYY` (ex: `15 Jan 2025`) |
| Pagination | `skip` + `take` (20 items par page) |
| PUT via POST | `_method: 'PUT'` dans FormData (Laravel) |
| Fichiers générés | `*.g.dart` — ne jamais éditer manuellement |
| Mode sombre | `appStore.isDarkModeOn` dans tous les screens |
| Skeleton loading | Bibliothèque `shimmer` |
| Icônes | Bibliothèque `iconsax` |
