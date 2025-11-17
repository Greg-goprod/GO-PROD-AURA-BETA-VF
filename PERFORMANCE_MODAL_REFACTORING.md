# 🎭 Refactoring Modal "Ajouter une Performance"

## 📋 Vue d'ensemble

Refactorisation complète du modal de création/édition de performances pour le système de booking, incluant de nouveaux champs SQL, une API améliorée, et une UI enrichie.

---

## ✅ Phase 1 : Modifications SQL (TERMINÉE)

### 1.1 Nouveaux champs dans `artist_performances`

```sql
-- Colonnes ajoutées avec succès
- rejection_reason (TEXT) : Raison du rejet d'une offre
- rejection_date (TIMESTAMPTZ) : Date du rejet
- notes (TEXT) : Notes internes pour l'équipe
- is_confirmed (BOOLEAN, défaut false) : Artiste a confirmé sa présence
- confirmed_at (TIMESTAMPTZ) : Date de confirmation
```

**Fichier** : `sql/add_performance_modal_fields.sql`

### 1.2 Enum `booking_status` complété

```sql
-- Valeurs existantes dans la base de données
1. idee (position 0)
2. offre_a_faire (position 1)
3. offre_envoyee (position 2)
4. offre_acceptee (position 3) -- équivalent de "offre_validee"
5. offre_rejetee (position 4)
```

---

## ✅ Phase 2 : API & Types TypeScript (TERMINÉE)

### 2.1 Types mis à jour

**Fichier** : `src/features/timeline/timelineApi.ts`

```typescript
// Nouveau type BookingStatus
export type BookingStatus = 
  | 'idee' 
  | 'offre_a_faire' 
  | 'offre_envoyee' 
  | 'offre_acceptee'
  | 'offre_rejetee';

// Interface Performance mise à jour
export interface Performance {
  // ... champs existants
  booking_status: BookingStatus; // Typé strictement
  notes?: string | null;         // NOUVEAU
  is_confirmed?: boolean;         // NOUVEAU
  confirmed_at?: string | null;   // NOUVEAU
}

// Interface PerformanceCreate mise à jour
export interface PerformanceCreate {
  // ... champs existants
  booking_status?: BookingStatus; // Typé strictement
  notes?: string | null;          // NOUVEAU
  is_confirmed?: boolean;         // NOUVEAU
}

// Interface PerformanceUpdate mise à jour
export interface PerformanceUpdate {
  // ... champs existants
  booking_status?: BookingStatus | null; // Typé strictement
  notes?: string | null;                 // NOUVEAU
  is_confirmed?: boolean | null;         // NOUVEAU
  confirmed_at?: string | null;          // NOUVEAU
}
```

### 2.2 Fonctions API mises à jour

#### `fetchPerformances()`
- ✅ Ajout de `notes`, `is_confirmed`, `confirmed_at` dans le SELECT
- ✅ Mapping des nouveaux champs dans le retour

#### `createPerformance()`
- ✅ Ajout de `notes` dans l'INSERT
- ✅ Ajout de `is_confirmed` dans l'INSERT (défaut: false)
- ✅ Mapping des nouveaux champs dans le retour

#### `updatePerformance()`
- ✅ Ajout de `notes` dans l'UPDATE conditionnel
- ✅ Ajout de `is_confirmed` dans l'UPDATE conditionnel
- ✅ Ajout de `confirmed_at` dans l'UPDATE conditionnel
- ✅ Mapping des nouveaux champs dans le retour

### 2.3 Nouvelle fonction : `getOrCreatePlaceholderArtist()`

**Objectif** : Créer ou récupérer l'artiste "À définir" pour une entreprise

```typescript
export async function getOrCreatePlaceholderArtist(
  companyId: string
): Promise<string>
```

**Comportement** :
1. Vérifie si un artiste nommé "À définir" existe pour la company
2. Si oui → retourne son ID
3. Si non → crée l'artiste et retourne son ID

**Usage** : Utilisé quand aucun artiste n'est sélectionné lors de la création d'une performance

---

## ✅ Phase 3 : Modal UI (TERMINÉE)

### 3.1 Imports mis à jour

**Fichier** : `src/features/booking/modals/PerformanceModal.tsx`

```typescript
import {
  // ... imports existants
  getOrCreatePlaceholderArtist,  // NOUVEAU
  type BookingStatus,             // NOUVEAU
} from "../../timeline/timelineApi";
```

### 3.2 État du formulaire enrichi

```typescript
const [formData, setFormData] = useState({
  // ... champs existants
  booking_status: "idee" as BookingStatus, // Typé strictement
  notes: "",                                // NOUVEAU
  is_confirmed: false,                      // NOUVEAU
});
```

### 3.3 Logique de sauvegarde améliorée

**Fonctionnalité** : Création automatique de l'artiste "À définir"

```typescript
// Résoudre l'artist_id (créer "À définir" si nécessaire)
let finalArtistId = formData.artist_id;
if (!finalArtistId && initialData?.companyId) {
  finalArtistId = await getOrCreatePlaceholderArtist(initialData.companyId);
}
```

**En création** :
```typescript
await createPerformance({
  // ... champs existants
  notes: formData.notes || null,
  is_confirmed: formData.is_confirmed,
  created_for_event_id: initialData?.eventId,
});
```

**En édition** :
```typescript
await updatePerformance({
  // ... champs existants
  notes: formData.notes || null,
  is_confirmed: formData.is_confirmed,
  confirmed_at: formData.is_confirmed ? new Date().toISOString() : null,
});
```

### 3.4 Interface utilisateur

#### **Colonne 1 : Informations générales**

1. **Artiste** (select + bouton)
   - Options : "Aucun artiste (optionnel)" + liste des artistes
   - Bouton "+ Ajouter un artiste" → ouvre `AddArtistModal`

2. **Statut (booking)** (select) — **ENRICHI**
   - ✅ Idée
   - ✅ Offre à faire
   - ✅ Offre envoyée (**NOUVEAU**)
   - ✅ Offre acceptée (**NOUVEAU**)
   - ✅ Offre rejetée

3. **Confirmation artiste** (checkbox) — **NOUVEAU**
   - Label : "Artiste a confirmé sa présence"
   - Déclenche l'enregistrement de `confirmed_at` lors de la sauvegarde

#### **Colonne 2 : Planning**

(Inchangée)
- Jour*
- Scène*
- Heure de début*

#### **Colonne 3 : Durée et cachet**

(Inchangée)
- Durée (min)* : Standard (60/75/90) ou Personnalisée
- Devise : EUR / CHF / USD
- Montant

#### **Notes internes (full width)** — **NOUVEAU**

- Textarea (3 lignes, redimensionnable)
- Placeholder : "Notes internes pour l'équipe..."
- Position : En bas du modal, après les 3 colonnes

---

## 📊 Workflow utilisateur

### Création d'une performance

1. Ouvrir le modal depuis la timeline ou booking
2. **(Optionnel)** Sélectionner un artiste
   - Si aucun artiste sélectionné → création automatique de "À définir"
3. Sélectionner jour*, scène*, heure*, durée*
4. **(Optionnel)** Saisir montant, devise, notes
5. Choisir un statut de booking
6. **(Optionnel)** Cocher "Artiste a confirmé"
7. Cliquer "Enregistrer"

### Édition d'une performance

1. Ouvrir le modal depuis une carte existante
2. Modifier les champs nécessaires
3. Si "Artiste a confirmé" est coché → `confirmed_at` est mis à jour
4. Cliquer "Enregistrer"

### Rejet d'une performance

1. En mode édition, sélectionner "Offre rejetée" dans le statut
2. **(Future feature)** Ouvrir `RejectOfferModal` pour collecter `rejection_reason` et `rejection_date`

---

## 🔍 Points de vigilance

### 1. Artiste "À définir"

- **Scope** : Global à l'entreprise (non lié à un événement)
- **Comportement** : Créé automatiquement si aucun artiste sélectionné
- **Réutilisation** : Si déjà créé, l'ID existant est réutilisé

### 2. Vérification d'unicité

La fonction `checkPerformanceUniqueness()` vérifie qu'il n'existe pas déjà une performance pour :
- Même artiste
- Même jour
- Même scène
- Même heure

### 3. Synchronisation timeline/booking

- Le modal appelle `onSuccess()` après sauvegarde
- Le parent (timeline ou booking) recharge ses données via `loadData()` ou équivalent

### 4. Confirmation artiste

- `confirmed_at` est mis à jour **uniquement en mode édition**
- En mode création, `confirmed_at` reste `null` (sera mis à jour plus tard)

---

## 📝 Tests recommandés

### Test 1 : Création sans artiste
1. Ouvrir modal de création
2. Ne pas sélectionner d'artiste
3. Remplir jour, scène, heure, durée
4. Enregistrer
5. **Vérifier** : Un artiste "À définir" a été créé automatiquement

### Test 2 : Ajout de notes
1. Ouvrir modal de création/édition
2. Saisir du texte dans "Notes internes"
3. Enregistrer
4. **Vérifier** : Les notes sont sauvegardées et visibles en réouverture

### Test 3 : Confirmation artiste
1. Ouvrir modal en mode édition
2. Cocher "Artiste a confirmé sa présence"
3. Enregistrer
4. **Vérifier** : `is_confirmed = true` et `confirmed_at` est défini

### Test 4 : Tous les statuts booking
1. Créer une performance avec statut "Idée"
2. Éditer → changer en "Offre à faire"
3. Éditer → changer en "Offre envoyée"
4. Éditer → changer en "Offre acceptée"
5. **Vérifier** : Chaque statut est bien sauvegardé

### Test 5 : Rejet d'offre
1. Créer une performance
2. Éditer → changer en "Offre rejetée"
3. **(Future)** Remplir le motif de rejet dans `RejectOfferModal`
4. **Vérifier** : `booking_status = offre_rejetee`, `rejection_reason` et `rejection_date` sont définis

---

## 🎯 Améliorations futures suggérées

### 1. Édition de performances existantes
Actuellement, le modal ne charge pas complètement une performance existante en mode édition (ligne 111 du fichier).

**Action recommandée** : Créer `fetchPerformanceById()` pour charger toutes les données d'une performance.

### 2. Modal de rejet enrichi
Actuellement, le `RejectOfferModal` existe mais n'est pas déclenché automatiquement.

**Action recommandée** : Détecter le changement vers "Offre rejetée" et ouvrir automatiquement `RejectOfferModal`.

### 3. Validation des doublons en temps réel
Actuellement, la vérification d'unicité se fait uniquement à la sauvegarde.

**Action recommandée** : Détecter les conflits dès la saisie (jour + scène + heure + artiste) et afficher un warning.

### 4. Historique des confirmations
`confirmed_at` est écrasé à chaque confirmation.

**Action recommandée** : Créer une table `performance_confirmations` pour un historique complet.

### 5. Affichage des notes dans la timeline
Les notes sont actuellement invisibles dans la timeline.

**Action recommandée** : Afficher une icône "note" sur les cartes de performance avec un tooltip.

---

## 📦 Fichiers modifiés

| Fichier | Type | Statut |
|---------|------|--------|
| `sql/add_performance_modal_fields.sql` | SQL | ✅ Créé |
| `src/features/timeline/timelineApi.ts` | API | ✅ Modifié |
| `src/features/booking/modals/PerformanceModal.tsx` | UI | ✅ Modifié |

---

## 🎉 Résumé

Le modal "Ajouter une performance" est maintenant :

- ✅ **Complet** : Supporte tous les champs nécessaires (`notes`, `is_confirmed`, `confirmed_at`)
- ✅ **Robuste** : Gestion automatique de l'artiste "À définir"
- ✅ **Flexible** : Supporte les 5 statuts de booking
- ✅ **Typé** : Utilise des types TypeScript stricts pour `BookingStatus`
- ✅ **Cohérent** : S'intègre parfaitement avec la timeline et le booking
- ✅ **Documenté** : Code clair avec commentaires explicatifs

**Prochaine étape recommandée** : Tests utilisateurs complets sur les 5 scénarios ci-dessus.

