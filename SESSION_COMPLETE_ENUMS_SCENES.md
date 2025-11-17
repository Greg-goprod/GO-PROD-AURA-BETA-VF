# Session complète : Gestion des Enums de Scènes et Corrections

## 🎯 Objectifs de la session

1. ✅ Implémenter les dropdowns de types et spécificités de scènes dans le formulaire d'événement
2. ✅ Créer les containers de gestion des enums dans SettingsEventsPage
3. ✅ Permettre l'ajout, l'édition et la suppression des types et spécificités
4. ✅ Utiliser les modals AURA pour les confirmations de suppression
5. ✅ Fixer le z-index des toasts pour qu'ils soient toujours visibles
6. ✅ Corriger l'erreur de création d'événement (status constraint)

---

## 📦 Fonctionnalités implémentées

### 1. **Enums de scènes SQL** ✅

#### Tables créées
```sql
-- Types de scènes
CREATE TABLE public.stage_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    value TEXT NOT NULL,
    label TEXT NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 999,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (company_id, value)
);

-- Spécificités de scènes
CREATE TABLE public.stage_specificities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id),
    value TEXT NOT NULL,
    label TEXT NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 999,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (company_id, value)
);
```

#### Modification de `event_stages`
```sql
ALTER TABLE event_stages
    ALTER COLUMN type TYPE TEXT,
    ALTER COLUMN type DROP NOT NULL,
    ADD COLUMN specificity TEXT,
    DROP COLUMN notes;
```

#### Fonction d'initialisation
```sql
CREATE OR REPLACE FUNCTION initialize_stage_enums_for_company(p_company_id UUID)
RETURNS void AS $$
BEGIN
    -- Insérer 8 types par défaut
    INSERT INTO public.stage_types (company_id, value, label, display_order)
    VALUES
        (p_company_id, 'main', 'Principale', 1),
        (p_company_id, 'secondary', 'Secondaire', 2),
        (p_company_id, 'club', 'Club', 3),
        (p_company_id, 'outdoor', 'Extérieur', 4),
        (p_company_id, 'tent', 'Chapiteau', 5),
        (p_company_id, 'workshop', 'Atelier', 6),
        (p_company_id, 'vip', 'VIP', 7),
        (p_company_id, 'other', 'Autre', 8)
    ON CONFLICT (company_id, value) DO NOTHING;
    
    -- Insérer 7 spécificités par défaut
    INSERT INTO public.stage_specificities (company_id, value, label, display_order)
    VALUES
        (p_company_id, 'covered', 'Couvert', 1),
        (p_company_id, 'open_air', 'Plein air', 2),
        (p_company_id, 'indoor', 'Intérieur', 3),
        (p_company_id, 'mobile', 'Mobile', 4),
        (p_company_id, 'permanent', 'Permanent', 5),
        (p_company_id, 'acoustic', 'Acoustique', 6),
        (p_company_id, 'electric', 'Électrique', 7)
    ON CONFLICT (company_id, value) DO NOTHING;
END;
$$ LANGUAGE plpgsql;
```

---

### 2. **API des enums** ✅

**Fichier** : `src/api/stageEnumsApi.ts`

#### Fonctions implémentées
```typescript
// Récupération
fetchStageTypes(companyId: string): Promise<StageType[]>
fetchStageSpecificities(companyId: string): Promise<StageSpecificity[]>

// Création
createStageType(companyId: string, value: string, label: string): Promise<StageType>
createStageSpecificity(companyId: string, value: string, label: string): Promise<StageSpecificity>

// Modification (nouveau)
updateStageType(id: string, label: string): Promise<StageType>
updateStageSpecificity(id: string, label: string): Promise<StageSpecificity>

// Suppression
deleteStageType(id: string): Promise<void>
deleteStageSpecificity(id: string): Promise<void>

// Initialisation
initializeStageEnumsForCompany(companyId: string): Promise<void>
```

---

### 3. **Composant de gestion** ✅

**Fichier** : `src/features/settings/events/StageEnumsManager.tsx`

#### Fonctionnalités
- ✅ 2 containers côte à côte (Types | Spécificités)
- ✅ Bouton "+" pour ajouter un type/spécificité
- ✅ Formulaire inline pour création
- ✅ **Édition inline** avec bouton "✏️" :
  - Clic sur ✏️ → Le champ devient éditable
  - Raccourcis : `Entrée` pour valider, `Échap` pour annuler
  - Boutons : ✓ (vert) pour valider, ✕ (gris) pour annuler
- ✅ **Suppression avec modal AURA** :
  - Clic sur 🗑️ → Modal de confirmation s'ouvre
  - Affiche l'icône ⚠️, le nom de l'élément, et "CETTE ACTION EST IRRÉVERSIBLE"
  - Boutons : "Annuler" (gris) | "Supprimer" (rouge avec spinner)
- ✅ Bouton "Initialiser les valeurs par défaut" si aucune valeur

---

### 4. **Intégration dans EventForm** ✅

**Fichier** : `src/features/settings/events/EventForm.tsx`

#### Onglet "Scènes" - Layout 4 colonnes
```
┌─────────────┬────────────┬──────────────┬──────────┐
│ Nom         │ Type       │ Spécificité  │ Capacité │
│ [Input]     │ [Select]   │ [Select]     │ [Input]  │
└─────────────┴────────────┴──────────────┴──────────┘
```

#### Dropdowns dynamiques
```typescript
// Les dropdowns se peuplent automatiquement depuis la DB
<Select
  label="Type"
  size="sm"
  options={[
    { label: '(Aucun)', value: '' },
    ...stageTypes.map(type => ({ label: type.label, value: type.value }))
  ]}
/>

<Select
  label="Spécificité"
  size="sm"
  options={[
    { label: '(Aucune)', value: '' },
    ...stageSpecificities.map(spec => ({ label: spec.label, value: spec.value }))
  ]}
/>
```

#### Alignement de hauteur
- Tous les champs (Input et Select) ont **36px de hauteur**
- Classe CSS `.select-sm` ajoutée pour les Select
- Prop `size="sm"` sur tous les Select de l'onglet Scènes

---

### 5. **Modal de confirmation AURA** ✅

**Fichier** : `src/components/ui/ConfirmDeleteModal.tsx` (existant, réutilisé)

#### Remplacement de `confirm()`
**Avant** :
```typescript
const handleDeleteType = async (id: string, label: string) => {
  if (!confirm(`Supprimer le type "${label}" ?`)) return;
  // ...
};
```

**Après** :
```typescript
const handleDeleteType = (id: string, label: string) => {
  setDeletingType({ id, label });
};

const handleConfirmDeleteType = async () => {
  setDeleting(true);
  await deleteStageType(deletingType.id);
  setDeleting(false);
  setDeletingType(null);
};

// Dans le JSX
<ConfirmDeleteModal
  isOpen={!!deletingType}
  onClose={() => setDeletingType(null)}
  onConfirm={handleConfirmDeleteType}
  title="Supprimer le type de scène"
  message="Êtes-vous sûr de vouloir supprimer ce type de scène ?"
  itemName={deletingType?.label}
  loading={deleting}
/>
```

---

### 6. **Fix z-index des toasts** ✅

**Problème** : Les toasts (z-index: 50) étaient cachés derrière les modals (z-index: 1000)

**Solution** :
```css
/* src/styles/tokens.css */
--z-modal-backdrop: 900;
--z-modal: 1000;
--z-popover: 1100;
--z-toast: 9999;  /* ✅ Toujours au-dessus */

/* src/styles/layout.css */
.z-toast { z-index: var(--z-toast); }
```

```tsx
/* src/components/aura/ToastProvider.tsx */
<div className="fixed top-4 right-4 z-toast space-y-2 w-full max-w-sm pointer-events-none">
  {toasts.map(toast => (
    <div key={toast.id} className="pointer-events-auto">
      <ToastComponent ... />
    </div>
  ))}
</div>
```

**Résultat** : Les toasts apparaissent toujours au-dessus des modals, même avec blur

---

### 7. **Fix erreur de création d'événement** ✅

**Problème** : `new row for relation "events" violates check constraint "events_status_check"`

**Cause** : Valeur par défaut `status: 'draft'` non autorisée par la contrainte CHECK

**Contrainte SQL** :
```sql
CHECK (status = ANY (ARRAY['planned', 'ongoing', 'done', 'cancelled']))
```

**Solution** :
```typescript
// src/api/eventsApi.ts (2 endroits)
// ❌ Avant
status: data.status || 'draft',

// ✅ Après
status: data.status || 'planned',
```

**Résultat** : Événements créés avec succès avec `status='planned'`

---

### 8. **Logs de debug améliorés** ✅

```typescript
// src/api/eventsApi.ts
if (error) {
  console.error('❌ Erreur createEvent:', error);
  console.error('📋 Payload envoyé:', payload);
  throw new Error(error.message || 'Erreur lors de la création de l\'événement');
}

// src/features/settings/events/EventForm.tsx
catch (err: any) {
  console.error('❌ Erreur sauvegarde évènement:', err);
  console.error('📝 Données du formulaire:', data);
  const errorMessage = err?.message || err?.error_description || err?.hint || 'Erreur';
  toastError(errorMessage);
}
```

---

## 📊 Scripts SQL exécutés

### 1. Création des tables et modification de event_stages
**Fichier** : `sql/create_stage_enums_and_modify_table.sql`
- ✅ Créé `stage_types` et `stage_specificities`
- ✅ Modifié `event_stages` (ajout `specificity`, suppression `notes`)
- ✅ Créé fonction `initialize_stage_enums_for_company`

### 2. Correction des contraintes UNIQUE
**Fichier** : `sql/fix_unique_constraint_correct.sql`
- ✅ Supprimé `stage_types_value_key` (mauvaise contrainte)
- ✅ Ajouté `stage_types_company_id_value_key` (bonne contrainte)
- ✅ Idem pour `stage_specificities`

### 3. Initialisation pour Go-Prod HQ
```sql
SELECT initialize_stage_enums_for_company('06f6c960-3f90-41cb-b0d7-46937eaf90a8');
```
**Résultat** : 9 types + 7 spécificités créés

---

## 📄 Fichiers créés/modifiés

### **Créés**
- `src/api/stageEnumsApi.ts` (API complète)
- `src/features/settings/events/StageEnumsManager.tsx` (Composant de gestion)
- `sql/create_stage_enums_and_modify_table.sql`
- `sql/fix_unique_constraint_correct.sql`
- `sql/fix_stage_enums_unique_constraint.sql`
- `sql/init_goprod_hq.sql`
- `sql/check_demo_company.sql`
- `sql/diagnostic_enums_auto.sql`
- `sql/initialiser_enums_auto.sql`
- `STAGE_ENUMS_IMPLEMENTATION.md`
- `INSTALLATION_STAGE_ENUMS.md`
- `STAGE_ENUMS_UI_COMPLETE.md`
- `STAGE_ENUMS_EDIT_DELETE_COMPLETE.md`
- `TOAST_Z_INDEX_FIX.md`
- `FIX_EVENT_STATUS_CONSTRAINT.md`
- `DIAGNOSTIC_STAGE_ENUMS.md`

### **Modifiés**
- `src/api/eventsApi.ts` (fix status `'planned'` au lieu de `'draft'`)
- `src/features/settings/events/EventForm.tsx` (dropdowns dynamiques, logs)
- `src/pages/settings/SettingsEventsPage.tsx` (intégration StageEnumsManager)
- `src/types/event.ts` (ajout `StageType`, `StageSpecificity`)
- `src/components/ui/Select.tsx` (ajout prop `size`)
- `src/styles/utilities.css` (classes `.select` et `.select-sm`)
- `src/styles/tokens.css` (ajout `--z-toast: 9999`)
- `src/styles/layout.css` (classe `.z-toast`)
- `src/components/aura/ToastProvider.tsx` (utilisation de `z-toast`)

---

## 🎯 Tests effectués

### ✅ Test 1 : Diagnostic initial
- Vérification de la structure de `event_stages` : ✅ colonne `specificity` présente
- Vérification des contraintes : ✅ contraintes UNIQUE corrigées
- Vérification des données : ✅ 9 types + 7 spécificités

### ✅ Test 2 : Containers de gestion
- Affichage des 2 containers : ✅
- Liste des types et spécificités : ✅
- Bouton "Initialiser" si vide : ✅

### ✅ Test 3 : Édition inline
- Clic sur ✏️ → Mode édition : ✅
- Modification du label : ✅
- Validation avec Entrée ou ✓ : ✅
- Annulation avec Échap ou ✕ : ✅

### ✅ Test 4 : Suppression avec modal
- Clic sur 🗑️ → Modal s'ouvre : ✅
- Affichage du nom et avertissement : ✅
- Confirmation → Suppression : ✅
- Annulation → Fermeture : ✅

### ✅ Test 5 : Création d'événement
- Formulaire avec dropdowns peuplés : ✅
- Création avec scène et enums : ✅
- Toast de succès : ✅

### ✅ Test 6 : Z-index des toasts
- Toast au-dessus des modals : ✅
- Toast au-dessus du modal de confirmation : ✅
- Toasts cliquables (bouton ✕) : ✅

---

## 🎉 Résultat final

### **Interface complète** : `/app/settings/events`

```
┌─────────────────────────────────────────────────┐
│  Gestion des évènements           [+ Ajouter]   │
├─────────────────────────────────────────────────┤
│  [Liste des événements]                         │
│                                                  │
│  ┌─ Configuration des scènes ─────────────────┐ │
│  │                                             │ │
│  │  ┌── Types de scènes ──┐  ┌── Spécificités ┐│
│  │  │ Principale    ✏️ 🗑️ │  │ Couvert    ✏️ 🗑️││
│  │  │ Secondaire    ✏️ 🗑️ │  │ Plein air  ✏️ 🗑️││
│  │  │ Club          ✏️ 🗑️ │  │ Intérieur  ✏️ 🗑️││
│  │  │ ...                  │  │ ...            ││
│  │  └─────────────────────┘  └────────────────┘│
│  └──────────────────────────────────────────────┘
└─────────────────────────────────────────────────┘
```

### **Modal "Créer un évènement"**

```
┌─────────────────────────────────────────────────┐
│  Créer un évènement                        [×]  │
├─────────────────────────────────────────────────┤
│  📋 Informations générales                      │
│  ┌─────────────────────────────────────────────┐│
│  │ Nom: [FESTIVAL TEST 2026]                  ││
│  │ Dates: [18/12/2025] - [21/12/2025]         ││
│  │ Couleur: [#3b82f6]                          ││
│  └─────────────────────────────────────────────┘│
│                                                  │
│  🎪 Scènes                                       │
│  ┌─────────────────────────────────────────────┐│
│  │ Nom        Type       Spécificité  Capacité ││
│  │ RAIFFEISEN [mainstage▼] [open_air▼] 15000  ││
│  └─────────────────────────────────────────────┘│
│                                                  │
│  [Annuler]                        [Enregistrer] │
└─────────────────────────────────────────────────┘
```

---

## 📈 Impact

### **Multi-tenancy**
- ✅ Chaque company peut définir ses propres types et spécificités
- ✅ Les valeurs par défaut sont initialisées par company
- ✅ Les contraintes `UNIQUE (company_id, value)` empêchent les doublons

### **Flexibilité**
- ✅ Ajout/édition/suppression à la volée
- ✅ Pas de redéploiement nécessaire
- ✅ Valeurs dynamiques dans les formulaires

### **UX AURA**
- ✅ Modals de confirmation cohérents avec le reste de l'app
- ✅ Toasts toujours visibles
- ✅ Édition inline intuitive

---

**Date de session** : 30 octobre 2025  
**Durée** : Session complète  
**Status** : ✅ Tous les objectifs atteints  
**Prêt pour production** : Oui, après tests utilisateurs finaux


