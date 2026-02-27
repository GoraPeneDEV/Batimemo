# Fonctionnalité Gestion des Dépenses (Expense Management)

## Vue d'ensemble

Le module de gestion des dépenses permet aux employés de soumettre des demandes de remboursement (avec pièce jointe optionnelle ou obligatoire), de suivre le statut de leurs demandes, et de les annuler si nécessaire. Les managers peuvent approuver ou rejeter les demandes via un module d'approbation distinct.

> **Architecture API** : Ce module utilise l'**API Legacy** (`network_utils.dart` + `ApiService`) et non le client Dio moderne. C'est un point clé qui le distingue des modules Project et Leave qui utilisent `DioApiClient`.

---

## Architecture Flutter (App Mobile)

```
lib/
├── screens/
│   └── Expense/
│       ├── ExpenseScreen.dart              # Liste paginée des demandes
│       ├── expense_create_screen.dart      # Formulaire de création
│       └── Widget/
│           └── expense_item_widget.dart    # Carte d'affichage d'une dépense
│
├── models/
│   ├── Expense/
│   │   ├── expense_request_model.dart      # Modèle demande + réponse paginée
│   │   └── expense_type_model.dart         # Modèle type de dépense (Hive cache)
│   └── expense_model.dart                  # Modèle simplifié (usage interne)
│
├── api/
│   ├── api_service.dart                    # ✅ Méthodes API Expense (Legacy HTTP)
│   ├── api_routes.dart                     # Constantes des URLs
│   ├── network_utils.dart                  # Client HTTP bas niveau (headers, JWT)
│   └── config.dart                         # Base URL, clés SharedPreferences
│
└── screens/Expense/
    ├── ExpenseStore.dart                   # MobX Store (état + actions)
    └── ExpenseStore.g.dart                 # Fichier généré (build_runner)
```

---

## Base de données (côté Backend)

| Colonne | Type | Description |
|---|---|---|
| `id` | bigint | Clé primaire |
| `date` | date | Date de la dépense (format: MM/dd/yyyy) |
| `type` | varchar | Type de dépense (ex: Travel, Meal) |
| `actualAmount` | decimal | Montant demandé |
| `approvedAmount` | decimal | Montant approuvé (après action manager) |
| `status` | varchar | `pending` / `approved` / `rejected` / `cancelled` |
| `comments` | text | Remarques / description |
| `attachmentUrl` | varchar | URL du fichier de reçu uploadé |
| `requestedBy` | FK | Employé demandeur |
| `approvedBy` | FK | Manager approbateur |
| `createdAt` | timestamp | Date de création |

---

## Modèles Dart

### `ExpenseRequestModel`

```dart
class ExpenseRequestModel {
  int? id;
  String? date;           // Format: MM/dd/yyyy
  String? type;           // Nom du type (ex: "Travel")
  num? actualAmount;      // Montant demandé
  num? approvedAmount;    // Montant approuvé
  String? status;         // pending | approved | rejected | cancelled
  String? createdAt;
  String? approvedBy;     // Nom du manager
  String? comments;
  String? attachmentUrl;  // URL de la pièce jointe
  String? requestedBy;    // Nom de l'employé
}
```

### `ExpenseRequestResponse`

```dart
class ExpenseRequestResponse {
  int totalCount;
  List<ExpenseRequestModel> values;
}
```

### `ExpenseTypeModel` (avec cache Hive)

```dart
@HiveType(typeId: 3)
class ExpenseTypeModel {
  @HiveField(0) int? id;
  @HiveField(1) String? name;          // Ex: "Travel", "Meal", "Office Supplies"
  @HiveField(2) bool? isImgRequired;   // true = pièce jointe obligatoire
}
```

> **Note** : `ExpenseTypeModel` est mis en cache avec **Hive** (typeId: 3) pour une utilisation hors-ligne du formulaire de création.

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

Le token est stocké dans **SharedPreferences** avec la clé `tokenPref`.
En mode **SaaS multi-tenant**, l'header `X-Tenant-ID` est aussi ajouté automatiquement.

---

### Endpoints Expense

#### `GET /expense/getExpenseTypes`

Récupère la liste des types de dépenses configurés.

**Paramètres** : aucun

**Réponse** :
```json
[
  { "id": 1, "name": "Travel", "isImgRequired": false },
  { "id": 2, "name": "Meal", "isImgRequired": true },
  { "id": 3, "name": "Office Supplies", "isImgRequired": false }
]
```

---

#### `GET /expense/getExpenseRequests`

Liste paginée des demandes de l'employé connecté.

**Paramètres de requête** :

| Paramètre | Type | Description |
|---|---|---|
| `skip` | int | Offset de pagination |
| `take` | int | Nombre de résultats (défaut: 10) |
| `status` | string | Filtre: `pending` / `approved` / `rejected` / `cancelled` |
| `date` | string | Filtre date au format `MM/dd/yyyy` |

**Réponse** :
```json
{
  "totalCount": 42,
  "values": [
    {
      "id": 7,
      "date": "02/15/2026",
      "type": "Travel",
      "actualAmount": 120.50,
      "approvedAmount": 100.00,
      "status": "approved",
      "comments": "Déplacement client Paris",
      "attachmentUrl": "https://...",
      "requestedBy": "Jean Dupont",
      "approvedBy": "Marie Martin",
      "createdAt": "2026-02-15T10:30:00"
    }
  ]
}
```

---

#### `POST /expense/createExpenseRequest`

Crée une nouvelle demande de dépense.

**Payload** :
```json
{
  "date": "02/23/2026",
  "amount": "120.50",
  "typeId": "2",
  "comments": "Repas client"
}
```

> **Note** : `amount` est envoyé en **String**, et `typeId` aussi (conversion dans `ApiService`).
> Le statut est automatiquement défini à `pending` côté serveur.

**Réponse** :
```json
{
  "status": "success",
  "message": "Expense request created successfully"
}
```

---

#### `POST /expense/uploadExpenseDocument`

Upload la pièce jointe (reçu / facture) après la création de la demande.

**Type de requête** : `multipart/form-data`

**Champ** : `file` — le fichier image ou PDF

**En-têtes** :
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Réponse** :
```json
{ "status": "success" }
```

> **Note** : L'upload est effectué **après** la création de la demande, comme deuxième étape dans `sendExpenseRequest()`.

---

#### `POST /expense/cancel`

Annule une demande de dépense en statut `pending`.

**Payload** :
```json
{ "id": 7 }
```

**Réponse** :
```json
{
  "status": "success",
  "message": "Expense request cancelled successfully"
}
```

---

### Endpoints Approbation (Manager)

#### `GET /approvals/expenseRequests`

Liste les demandes de dépenses à approuver (accès manager).

**Paramètres** : identiques à `getExpenseRequests`

---

#### `POST /approvals/expenseAction`

Approuve ou rejette une demande.

**Payload** :
```json
{
  "id": 7,
  "status": "approved",
  "comments": "Justificatif valide"
}
```

---

## Flux complet d'une demande

```
Employé crée une demande [pending]
        ↓
  (optionnel/obligatoire selon type)
  Upload pièce jointe → uploadExpenseDocument
        ↓
  Manager consulte la liste via approvals/expenseRequests
        ↓
  ┌─────────────────────┐
Approuver              Rejeter
[approved]             [rejected]
(approvedAmount set)
        ↓
  Employé peut consulter le statut + montant approuvé
        ↓
  Si pending uniquement → Annulation possible [cancelled]
```

---

## Gestion d'état — `ExpenseStore` (MobX)

### Observables

| Propriété | Type | Description |
|---|---|---|
| `pagingController` | `PagingController<int, ExpenseRequestModel>` | Contrôleur de pagination infinie |
| `isLoading` | `bool` | Indicateur de chargement |
| `expenseTypes` | `ObservableList<ExpenseTypeModel>` | Types disponibles |
| `selectedExpenseType` | `ExpenseTypeModel?` | Type sélectionné dans le formulaire |
| `selectedDate` | `DateTime` | Date sélectionnée (défaut: aujourd'hui) |
| `selectedStatus` | `String?` | Filtre statut actif |
| `dateFilter` | `String` | Filtre date actif (format MM/dd/yyyy) |
| `fileName` | `String` | Nom du fichier sélectionné |
| `filePath` | `String` | Chemin local du fichier |
| `isImgRequired` | `bool` | Si l'image est obligatoire pour le type sélectionné |
| `file` | `File?` | Objet File pour l'upload |

### Actions

| Action | Description |
|---|---|
| `fetchExpenseRequests(pageKey)` | Charge une page de demandes (pagination infinie) |
| `cancelExpense(id)` | Annule une demande, puis refresh la liste |
| `sendExpenseRequest(amount, remarks)` | Crée la demande + upload fichier si présent |
| `loadExpenseTypes()` | Charge les types (depuis cache Hive ou API) |
| `getFile()` | Ouvre le FilePicker et sélectionne un fichier |

---

## Flux de données détaillé

### Affichage de la liste

```
ExpenseScreen.initState()
  └── pagingController.addPageRequestListener(fetchExpenseRequests)
        └── ExpenseStore.fetchExpenseRequests(pageKey)
              └── ApiService.getExpenseRequests(skip: pageKey, take: 10, ...)
                    └── network_utils.getRequestWithQuery(endpoint, queryParams)
                          └── buildHeader()  ← JWT depuis SharedPreferences
                                └── HTTP GET /expense/getExpenseRequests?skip=0&take=10
                                      └── handleResponse() → parse JSON
                                            └── ExpenseRequestResponse.fromJson()
                                                  └── pagingController.appendPage()
                                                        └── UI rebuild via Observer
```

### Création d'une dépense

```
ExpenseCreateScreen → tap "Submit Expense"
  └── ExpenseStore.sendExpenseRequest(amount, remarks)
        ├── Step 1: ApiService.sendExpenseRequest({
        │     "date": "MM/dd/yyyy",
        │     "amount": amount.toString(),
        │     "typeId": selectedExpenseType.id.toString(),
        │     "comments": remarks
        │   })
        │     └── HTTP POST /expense/createExpenseRequest
        │
        └── Step 2 (si filePath != ''):
              ApiService.uploadExpenseDocument(filePath)
                └── multipartRequest() → HTTP POST /expense/uploadExpenseDocument
                      └── Fichier joint en multipart/form-data
```

---

## Client HTTP Legacy (`network_utils.dart`)

Ce module **n'utilise pas Dio** mais le package `http` natif :

```dart
// Construction des headers (JWT + Tenant)
Map<String, String> buildHeader() {
  final headers = {'Content-Type': 'application/json'};
  final token = getStringAsync(tokenPref);
  if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
  if (getIsSaaSMode()) headers['X-Tenant-ID'] = getTenantId();
  return headers;
}

// Requête GET avec paramètres
Future getRequestWithQuery(String endpoint, Map<String, String> query)

// Requête POST JSON
Future postRequest(String endpoint, Map body)

// Upload multipart (pièces jointes)
Future<bool> multipartRequest(String endpoint, String filePath) {
  MultipartRequest request = MultipartRequest('POST', Uri.parse(endpoint));
  MultipartFile file = await MultipartFile.fromPath("file", filePath);
  request.files.add(file);
  request.headers.addAll(buildHeader());
  // timeout: 30 secondes
}
```

### Comparaison API Legacy vs Dio

| Critère | Legacy (`network_utils`) | Moderne (`DioApiClient`) |
|---|---|---|
| **Modules** | Expense, Leave, Attendance, Payroll… | Project, (futurs modules) |
| **Interception** | Manuelle (dans chaque méthode) | `AuthInterceptor`, `ErrorInterceptor` |
| **Erreurs** | `handleResponse()` manuellement | Exceptions typées (`ApiException`) |
| **Upload** | `MultipartRequest` natif | Dio FormData |
| **JWT** | `buildHeader()` dans chaque appel | Injecté par `AuthInterceptor` |
| **Timeout** | 30s hardcodé | Configurable via `DioApiClient` |

---

## Cache Hive

Les types de dépenses sont mis en cache localement avec **Hive** :

```dart
// TypeId Hive: 3
@HiveType(typeId: 3)
class ExpenseTypeModel { ... }

// Lors du chargement
Future loadExpenseTypes() async {
  final cached = hiveBox.get('expenseTypes');  // Cache local
  if (cached != null) {
    expenseTypes = ObservableList.of(cached);
  } else {
    final apiResult = await ApiService.getExpenseTypes();
    hiveBox.put('expenseTypes', apiResult);    // Mise en cache
    expenseTypes = ObservableList.of(apiResult);
  }
}
```

---

## Pagination Infinie

Le module utilise le package `infinite_scroll_pagination` :

```dart
PagingController<int, ExpenseRequestModel> pagingController =
  PagingController(firstPageKey: 0);

// Logique de pagination
Future<void> fetchExpenseRequests(int pageKey) async {
  final result = await ApiService.getExpenseRequests(skip: pageKey, take: 10);
  final isLastPage = (pageKey + result.values.length) >= result.totalCount;

  if (isLastPage) {
    pagingController.appendLastPage(result.values);
  } else {
    pagingController.appendPage(result.values, pageKey + result.values.length);
  }
}
```

**Filtrage** : Modifie `selectedStatus` / `dateFilter` puis appelle `pagingController.refresh()` pour recharger depuis la page 0.

---

## Upload de fichiers

### Processus complet

```
1. Utilisateur tape "Upload Receipt/Document"
      ↓
2. ExpenseStore.getFile()
   └── FilePicker.platform.pickFiles(type: FileType.image)
   └── Met à jour: file, filePath, fileName
      ↓
3. UI affiche le nom du fichier sélectionné
      ↓
4. À la soumission (sendExpenseRequest) :
   - Si isImgRequired == true et filePath == '' → Erreur "Image is required"
   - Si filePath != '' → multipartRequest(/expense/uploadExpenseDocument)
```

---

## Localisation (Traductions)

### Fichiers de traduction

| Fichier | Langue |
|---|---|
| `lib/locale/language_en.dart` | Anglais (référence) |
| `lib/locale/language_fr.dart` | Français |
| `lib/locale/language_es.dart` | Espagnol |
| `lib/locale/language_de.dart` | Allemand |
| `lib/locale/language_ar.dart` | Arabe |
| *(+ autres langues)* | … |

### Clés de traduction liées à Expense

| Clé | Valeur (EN) | Description |
|---|---|---|
| `lblExpense` | "Expense" | Titre du module |
| `lblCreateExpense` | "Create Expense" | Titre du formulaire |
| `lblExpenseType` | "Expense type" | Label du sélecteur de type |
| `lblExpenseDetails` | "Expense Details" | Section détails |
| `lblNewExpense` | "New Expense" | Bouton de création |
| `lblSelectExpenseType` | "Select expense type" | Placeholder dropdown |
| `lblPleaseSelectExpenseType` | "Please select an expense type" | Message de validation |
| `lblAmount` | "Amount" | Label montant |
| `lblEnterAmount` | "Enter Amount" | Placeholder montant |
| `lblRemarks` | "Remarks" | Label remarques |
| `lblEnterRemarksOrDescription` | "Enter remarks or description" | Placeholder remarques |
| `lblDate` | "Date" | Label date |
| `lblSelectDate` | "Select a date" | Placeholder date |
| `lblPleaseSelectDate` | "Please select a date" | Message de validation |
| `lblStatus` | "Status" | Label statut |
| `lblPending` | "Pending" | Statut en attente |
| `lblApproved` | "Approved" | Statut approuvé |
| `lblRejected` | "Rejected" | Statut rejeté |
| `lblCancelled` | "Cancelled" | Statut annulé |
| `lblFilters` | "Filters" | Titre du panneau de filtres |
| `lblFilterByDate` | "Filter by date" | Label filtre date |
| `lblSelectStatus` | "Select status" | Placeholder filtre statut |
| `lblApply` | "Apply" | Bouton appliquer les filtres |
| `lblReset` | "Reset" | Bouton réinitialiser les filtres |
| `lblCancel` | "Cancel" | Bouton annuler |
| `lblConfirmCancelExpense` | "Are you sure you want to cancel this expense request?" | Confirmation annulation |
| `lblExpenseRequestCancelledSuccessfully` | "Expense request cancelled successfully" | Toast succès annulation |
| `lblSubmitExpense` | "Submit Expense" | Bouton soumission |
| `lblSubmittedSuccessfully` | "Submitted" | Toast succès création |
| `lblYourExpenseRequestsWillAppearHere` | "Your expense requests will appear here" | État vide de la liste |
| `lblNoRequests` | "No Requests" | Titre état vide |
| `lblNoExpenseTypesAreConfigured` | "No expense types are configured" | Erreur chargement types |
| `lblSupportingDocument` | "Supporting Document" | Section pièce jointe |
| `lblUploadReceiptDocument` | "Upload Receipt/Document" | Bouton upload |
| `lblTapToSelectImageFile` | "Tap to select image file" | Sous-titre zone upload |
| `lblUploadedDocument` | "Uploaded document" | Confirmation fichier sélectionné |
| `lblImageIsRequired` | "Image is required" | Erreur si image manquante |

### Utilisation dans le code

```dart
// Variable globale
language.lblExpense         // Accès direct
language.lblAmount
// ...

// Pas de BuildContext requis — accessible partout
```

---

## Intégration dans la Navigation

```dart
// navigation_screen.dart
// L'onglet Expense est affiché conditionnellement selon le module activé

if (moduleService.isExpenseModuleEnabled()) {
  pages.add(const ExpenseScreen());
  navItems.add(_modernNavItem(
    icon: Iconsax.money_send,
    activeIcon: Iconsax.money_send5,
    label: language.lblExpense,
  ));
}
```

---

## Gestion des erreurs

### Vérifications côté app

| Condition | Erreur affichée |
|---|---|
| Pas de type sélectionné | `lblPleaseSelectExpenseType` |
| Pas de date sélectionnée | `lblPleaseSelectDate` |
| Montant vide ou non numérique | Validation formulaire |
| Image requise mais non sélectionnée | `lblImageIsRequired` |
| Pas de connexion Internet | `noInternetMsg` |
| Timeout (> 30s) | Message d'erreur réseau |
| Erreur 401 | Déconnexion automatique (`logoutAlt()`) |

### Exceptions Dio (pour futurs endpoints)

```
ApiException
├── NetworkException          (pas de réseau)
├── TimeoutException          (dépassement délai)
├── UnauthorizedException     (401 → auto logout)
├── NotFoundException         (404)
├── ValidationException       (422)
├── ServerException           (500)
├── BadRequestException       (400)
└── ForbiddenException        (403)
```

---

## Statuts des demandes

| Valeur | Label (FR) | Couleur suggérée | Actions possibles |
|---|---|---|---|
| `pending` | En attente | Orange | Annuler (employé) / Approuver ou Rejeter (manager) |
| `approved` | Approuvé | Vert | Lecture seule |
| `rejected` | Rejeté | Rouge | Lecture seule |
| `cancelled` | Annulé | Gris | Lecture seule |

---

## Fichiers clés

| Fichier | Rôle |
|---|---|
| `lib/screens/Expense/ExpenseScreen.dart` | Liste paginée avec filtres status/date |
| `lib/screens/Expense/expense_create_screen.dart` | Formulaire de création (type, montant, date, pièce jointe) |
| `lib/screens/Expense/Widget/expense_item_widget.dart` | Widget carte d'une demande (montant, statut, date) |
| `lib/screens/Expense/ExpenseStore.dart` | Store MobX — état + toutes les actions |
| `lib/screens/Expense/ExpenseStore.g.dart` | Code généré par build_runner |
| `lib/models/Expense/expense_request_model.dart` | Modèle complet + réponse paginée |
| `lib/models/Expense/expense_type_model.dart` | Modèle type de dépense (avec cache Hive typeId: 3) |
| `lib/models/expense_model.dart` | Modèle simplifié (usage interne) |
| `lib/api/api_service.dart` | Toutes les méthodes API Expense |
| `lib/api/api_routes.dart` | Constantes des URLs des endpoints |
| `lib/api/network_utils.dart` | Client HTTP bas niveau (headers JWT, multipart, timeout) |
| `lib/api/config.dart` | Base URL + clés SharedPreferences |
| `lib/locale/language_en.dart` | Traductions anglaises (référence) |
| `lib/locale/language_fr.dart` | Traductions françaises |
