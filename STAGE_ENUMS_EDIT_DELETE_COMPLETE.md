# Gestion complète des enums de scènes - Édition et Suppression

## ✅ Fonctionnalités implémentées

### 1. **Édition inline** ✅
- Cliquer sur **✏️** (bleu) pour passer en mode édition
- Le champ devient éditable avec focus automatique
- **Raccourcis clavier** :
  - `Entrée` : Valider les modifications
  - `Échap` : Annuler l'édition
- Boutons d'action :
  - **✓** (vert) : Valider
  - **✕** (gris) : Annuler

### 2. **Suppression avec modal AURA** ✅
- Cliquer sur **🗑️** (rouge) pour supprimer
- **Modal de confirmation** (`ConfirmDeleteModal`) s'affiche avec :
  - ⚠️ Icône d'avertissement
  - Nom de l'élément à supprimer
  - Message d'avertissement : "Cette action est irréversible"
  - Boutons : "Annuler" (gris) | "Supprimer" (rouge)
- **État de chargement** : Le bouton "Supprimer" affiche un spinner pendant la suppression

### 3. **Ajout d'éléments** ✅
- Cliquer sur **+** pour afficher le formulaire
- Saisir le nom
- Appuyer sur `Entrée` ou cliquer sur "Ajouter"
- Le formulaire se ferme automatiquement après ajout

---

## 🎨 Design AURA

### **Modal de confirmation**

```
┌────────────────────────────────────────┐
│  Supprimer le type de scène        [×] │
├────────────────────────────────────────┤
│  ⚠️  Êtes-vous sûr de vouloir          │
│      supprimer ce type de scène ?      │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │  Principale                      │ │
│  └──────────────────────────────────┘ │
│                                        │
│  ⚠️ CETTE ACTION EST IRRÉVERSIBLE      │
│                                        │
│  ┌──────────┐  ┌──────────┐          │
│  │ Annuler  │  │ Supprimer │          │
│  └──────────┘  └──────────┘          │
└────────────────────────────────────────┘
```

### **Édition inline**

```
Mode normal :
┌────────────────────────────────────────┐
│  Principale                  ✏️  🗑️    │
└────────────────────────────────────────┘

Mode édition :
┌────────────────────────────────────────┐
│  [Principale          ]      ✓  ✕     │
└────────────────────────────────────────┘
```

---

## 📋 Flux utilisateur

### **Éditer un type/spécificité**

1. Cliquer sur **✏️** à côté de "Principale"
2. Le champ devient éditable : `[Principale          ]`
3. Modifier le texte : `[Scène Principale    ]`
4. **Option A** : Appuyer sur `Entrée`
5. **Option B** : Cliquer sur **✓** (vert)
6. Toast de confirmation : "Type modifié"
7. La liste se recharge automatiquement

**Annuler l'édition** :
- Appuyer sur `Échap`
- OU cliquer sur **✕** (gris)

---

### **Supprimer un type/spécificité**

1. Cliquer sur **🗑️** à côté de "Autre"
2. Modal de confirmation s'ouvre :
   - Titre : "Supprimer le type de scène"
   - Message : "Êtes-vous sûr de vouloir supprimer ce type de scène ?"
   - Nom affiché : "Autre"
   - Avertissement : "CETTE ACTION EST IRRÉVERSIBLE"
3. **Confirmer** : Cliquer sur "Supprimer" (rouge)
   - Le bouton affiche un spinner
   - Toast : "Type 'Autre' supprimé"
   - Modal se ferme
   - Liste se recharge
4. **Annuler** : Cliquer sur "Annuler" (gris) ou **✕**
   - Modal se ferme sans action

---

## 🔧 API utilisées

### **Édition**
```typescript
// Types
updateStageType(id: string, label: string): Promise<StageType>

// Spécificités
updateStageSpecificity(id: string, label: string): Promise<StageSpecificity>
```

### **Suppression**
```typescript
// Types
deleteStageType(id: string): Promise<void>

// Spécificités
deleteStageSpecificity(id: string): Promise<void>
```

---

## 📦 Composants utilisés

### **ConfirmDeleteModal** (`src/components/ui/ConfirmDeleteModal.tsx`)

**Props** :
```typescript
interface ConfirmDeleteModalProps {
  isOpen: boolean;           // État d'ouverture
  onClose: () => void;       // Fermer le modal
  onConfirm: () => void;     // Confirmer la suppression
  title: string;             // Titre du modal
  message: string;           // Message explicatif
  itemName?: string;         // Nom de l'élément à supprimer
  loading?: boolean;         // État de chargement
}
```

**Exemple d'utilisation** :
```tsx
<ConfirmDeleteModal
  isOpen={true}
  onClose={() => setDeletingType(null)}
  onConfirm={handleConfirmDeleteType}
  title="Supprimer le type de scène"
  message="Êtes-vous sûr de vouloir supprimer ce type de scène ?"
  itemName="Principale"
  loading={deleting}
/>
```

---

## 🎯 Tests à effectuer

### ✅ Test 1 : Édition d'un type
1. Aller sur `/app/settings/events`
2. Descendre jusqu'à "Configuration des scènes"
3. Cliquer sur **✏️** à côté de "Principale"
4. Modifier en "Scène Principale"
5. Appuyer sur `Entrée`
6. **Vérifier** : Toast "Type modifié" + liste mise à jour

### ✅ Test 2 : Annuler l'édition
1. Cliquer sur **✏️**
2. Modifier le texte
3. Appuyer sur `Échap`
4. **Vérifier** : Le texte d'origine est restauré

### ✅ Test 3 : Suppression d'un type
1. Cliquer sur **🗑️** à côté de "Autre"
2. **Vérifier** : Modal de confirmation apparaît avec :
   - Icône ⚠️
   - Nom "Autre" dans un cadre
   - Message "CETTE ACTION EST IRRÉVERSIBLE"
3. Cliquer sur "Supprimer"
4. **Vérifier** : 
   - Spinner sur le bouton pendant la suppression
   - Toast "Type 'Autre' supprimé"
   - Modal se ferme
   - "Autre" n'est plus dans la liste

### ✅ Test 4 : Annuler la suppression
1. Cliquer sur **🗑️**
2. Modal s'ouvre
3. Cliquer sur "Annuler"
4. **Vérifier** : Modal se ferme, aucun changement

### ✅ Test 5 : Utilisation dans EventForm
1. Ouvrir "Créer un évènement"
2. Aller à l'onglet "Scènes"
3. Ajouter une scène
4. **Vérifier** : Le dropdown "Type" contient les types édités
5. **Vérifier** : Le dropdown "Spécificité" contient les spécificités éditées

### ✅ Test 6 : Multi-tenancy
1. Si vous avez plusieurs companies :
2. Modifier "Principale" pour Go-Prod HQ → "Scène Principale"
3. Changer de company
4. **Vérifier** : L'autre company a toujours "Principale" (inchangé)

---

## 📊 État des données

### **États locaux du composant**
```typescript
// Édition
const [editingTypeId, setEditingTypeId] = useState<string | null>(null);
const [editingTypeLabel, setEditingTypeLabel] = useState('');
const [editingSpecId, setEditingSpecId] = useState<string | null>(null);
const [editingSpecLabel, setEditingSpecLabel] = useState('');

// Suppression
const [deletingType, setDeletingType] = useState<{ id: string; label: string } | null>(null);
const [deletingSpec, setDeletingSpec] = useState<{ id: string; label: string } | null>(null);
const [deleting, setDeleting] = useState(false);
```

### **Flux de données**

**Édition** :
```
1. Clic sur ✏️
   → setEditingTypeId(type.id)
   → setEditingTypeLabel(type.label)

2. Modification du champ
   → setEditingTypeLabel(newValue)

3. Clic sur ✓ ou Entrée
   → updateStageType(id, label)
   → setEditingTypeId(null)
   → loadData()
```

**Suppression** :
```
1. Clic sur 🗑️
   → setDeletingType({ id, label })

2. Clic sur "Supprimer" dans le modal
   → setDeleting(true)
   → deleteStageType(id)
   → setDeletingType(null)
   → setDeleting(false)
   → loadData()
```

---

## 🔐 Sécurité

### **Multi-tenancy strict**
- Toutes les requêtes incluent `company_id`
- Chaque company ne peut modifier/supprimer que ses propres enums
- Les contraintes SQL `UNIQUE (company_id, value)` empêchent les doublons par company

### **Validation**
- Le label ne peut pas être vide
- Les espaces sont automatiquement trimés
- Les erreurs sont catchées et affichées via toast

---

## 🚀 Prochaines étapes

**Avant de tester, n'oubliez pas** :

1. **Corriger les contraintes UNIQUE** :
   ```sql
   -- Exécuter sql/fix_unique_constraint_correct.sql
   ```

2. **Initialiser les données** :
   ```sql
   -- Exécuter sql/init_goprod_hq.sql
   SELECT initialize_stage_enums_for_company('06f6c960-3f90-41cb-b0d7-46937eaf90a8');
   ```

3. **Recharger la page** : `F5` sur `/app/settings/events`

4. **Tester toutes les fonctionnalités** :
   - ✅ Ajout
   - ✅ Édition
   - ✅ Suppression
   - ✅ Annulation

---

**Date d'implémentation** : 28 octobre 2025  
**Composants modifiés** : 
- `src/api/stageEnumsApi.ts` (ajout `updateStageType` et `updateStageSpecificity`)
- `src/features/settings/events/StageEnumsManager.tsx` (édition inline + modal AURA)

**Design pattern** : Modal de confirmation AURA (utilisé dans tout le SaaS)  
**Status** : ✅ Complet et prêt à tester


