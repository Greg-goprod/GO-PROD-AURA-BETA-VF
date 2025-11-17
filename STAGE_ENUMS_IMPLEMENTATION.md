# Gestion des Scènes - Enums par Company

## 🎯 Objectif

Permettre à chaque company de définir ses propres **types de scènes** et **spécificités de scènes** personnalisés.

---

## ✅ Implémentation complète

### 1. Structure SQL

#### Tables créées

**`stage_types`** : Types de scènes (ex: Principale, Club, Extérieur...)
```sql
CREATE TABLE public.stage_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  value TEXT NOT NULL,
  label TEXT NOT NULL,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(company_id, value)
);
```

**`stage_specificities`** : Spécificités de scènes (ex: Couvert, Plein air, Intérieur...)
```sql
CREATE TABLE public.stage_specificities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  value TEXT NOT NULL,
  label TEXT NOT NULL,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(company_id, value)
);
```

#### Modifications de `event_stages`

1. **Suppression de la vue dépendante** : `DROP VIEW v_event_stages_flat CASCADE`
2. **Modification des colonnes** :
   - `type` : Type hardcodé → TEXT nullable
   - `specificity` : Nouvelle colonne TEXT nullable
   - `notes` : **Supprimé** (avec CASCADE pour les vues dépendantes)

```sql
ALTER TABLE public.event_stages
  ALTER COLUMN type TYPE TEXT,
  ALTER COLUMN type DROP NOT NULL;

ALTER TABLE public.event_stages
  ADD COLUMN IF NOT EXISTS specificity TEXT;

ALTER TABLE public.event_stages
  DROP COLUMN IF EXISTS notes CASCADE;
```

#### RPC Function

**`initialize_stage_enums_for_company(p_company_id UUID)`** : Initialise les valeurs par défaut pour une company

Valeurs par défaut :
- **Types** : Principale, Secondaire, Club, Extérieur, Chapiteau, Atelier, VIP, Autre
- **Spécificités** : Couvert, Plein air, Intérieur, Mobile, Permanent, Acoustique, Électrique

---

### 2. Types TypeScript (`src/types/event.ts`)

#### Nouvelles interfaces

```typescript
export interface StageType {
  id: string;
  company_id: string;
  value: string;
  label: string;
  display_order: number;
  created_at: string;
}

export interface StageSpecificity {
  id: string;
  company_id: string;
  value: string;
  label: string;
  display_order: number;
  created_at: string;
}
```

#### Interface modifiée

```typescript
export interface EventStageInput {
  name: string;
  type?: string | null;         // ✅ Nullable
  specificity?: string | null;  // ✅ Nouveau champ
  capacity: number | null;
  display_order?: number;
  // notes supprimé ❌
}
```

---

### 3. API (`src/api/stageEnumsApi.ts`)

#### Fonctions CRUD

```typescript
// Lecture
fetchStageTypes(companyId: string): Promise<StageType[]>
fetchStageSpecificities(companyId: string): Promise<StageSpecificity[]>

// Création
createStageType(companyId, value, label, displayOrder?): Promise<StageType>
createStageSpecificity(companyId, value, label, displayOrder?): Promise<StageSpecificity>

// Suppression
deleteStageType(id: string): Promise<void>
deleteStageSpecificity(id: string): Promise<void>

// Initialisation
initializeStageEnumsForCompany(companyId: string): Promise<void>
```

---

### 4. Modifications du formulaire (`EventForm.tsx`)

#### Imports ajoutés

```typescript
import {
  fetchStageTypes,
  fetchStageSpecificities,
  type StageType,
  type StageSpecificity,
} from '@/api/stageEnumsApi';
```

#### États ajoutés

```typescript
const [stageTypes, setStageTypes] = useState<StageType[]>([]);
const [stageSpecificities, setStageSpecificities] = useState<StageSpecificity[]>([]);
```

#### Chargement des enums

```typescript
useEffect(() => {
  if (open && companyId) {
    Promise.all([
      fetchStageTypes(companyId),
      fetchStageSpecificities(companyId),
    ])
      .then(([types, specs]) => {
        setStageTypes(types);
        setStageSpecificities(specs);
      })
      .catch((err) => {
        console.error('Erreur lors du chargement des enums de scènes:', err);
        toastError('Impossible de charger les types de scènes');
      });
  }
}, [open, companyId, toastError]);
```

#### Layout modifié : 4 colonnes

**Avant (3 colonnes)** :
- Nom | Type | Capacité
- Notes (ligne séparée)

**Après (4 colonnes)** :
- Nom | Type | Spécificité | Capacité

```tsx
<div className="grid grid-cols-4 gap-3">
  {/* Nom */}
  <Input
    label="Nom"
    {...register(`stages.${index}.name`, { required: 'Le nom est obligatoire' })}
    placeholder="Ex: Main Stage"
    required
  />
  
  {/* Type (dynamique depuis la DB) */}
  <Select
    label="Type"
    {...register(`stages.${index}.type`)}
    options={[
      { label: '(Aucun)', value: '' },
      ...stageTypes.map((type) => ({
        label: type.label,
        value: type.value,
      })),
    ]}
  />
  
  {/* Spécificité (dynamique depuis la DB) */}
  <Select
    label="Spécificité"
    {...register(`stages.${index}.specificity`)}
    options={[
      { label: '(Aucune)', value: '' },
      ...stageSpecificities.map((spec) => ({
        label: spec.label,
        value: spec.value,
      })),
    ]}
  />
  
  {/* Capacité */}
  <Input
    label="Capacité"
    type="number"
    {...register(`stages.${index}.capacity`)}
    placeholder="Ex: 12000"
  />
</div>
```

**Notes supprimées** ✅

---

## 📋 Instructions d'installation

### Étape 1 : Exécuter le script SQL

```bash
# Dans Supabase SQL Editor, exécuter :
sql/create_stage_enums_and_modify_table.sql
```

Ce script :
1. ✅ Supprime la vue dépendante `v_event_stages_flat`
2. ✅ Crée les tables `stage_types` et `stage_specificities`
3. ✅ Modifie `event_stages` (type, specificity, supprime notes)
4. ✅ Recrée la vue `v_event_stages_flat` (sans notes)
5. ✅ Crée la fonction RPC `initialize_stage_enums_for_company()`

### Étape 2 : Initialiser les enums pour vos companies

**Option A : Toutes les companies existantes**
```sql
SELECT initialize_stage_enums_for_company(id) FROM public.companies;
```

**Option B : Une company spécifique**
```sql
SELECT initialize_stage_enums_for_company('YOUR_COMPANY_ID');
```

### Étape 3 : Tester

1. Ouvrir le modal "Créer un évènement"
2. Aller dans l'onglet "Scènes"
3. Ajouter une scène
4. **Vérifier** : 4 colonnes (Nom / Type / Spécificité / Capacité)
5. **Vérifier** : Les sélecteurs Type et Spécificité contiennent les valeurs par défaut

---

## 🎨 Valeurs par défaut

### Types de scènes
1. **Principale** (`main`)
2. **Secondaire** (`secondary`)
3. **Club** (`club`)
4. **Extérieur** (`outdoor`)
5. **Chapiteau** (`tent`)
6. **Atelier** (`workshop`)
7. **VIP** (`vip`)
8. **Autre** (`other`)

### Spécificités de scènes
1. **Couvert** (`covered`)
2. **Plein air** (`open_air`)
3. **Intérieur** (`indoor`)
4. **Mobile** (`mobile`)
5. **Permanent** (`permanent`)
6. **Acoustique** (`acoustic`)
7. **Électrique** (`electric`)

---

## 🚀 Prochaine étape

### Interface de gestion dans `SettingsEventsPage`

Ajouter **2 containers** sous la gestion des événements :

#### Container 1 : Types de scènes
- **Liste** : Afficher tous les types avec leur label
- **Bouton "+"** : Ajouter un nouveau type
- **Bouton "🗑️"** : Supprimer un type
- **Drag & drop** : Réorganiser l'ordre

#### Container 2 : Spécificités de scènes
- **Liste** : Afficher toutes les spécificités avec leur label
- **Bouton "+"** : Ajouter une nouvelle spécificité
- **Bouton "🗑️"** : Supprimer une spécificité
- **Drag & drop** : Réorganiser l'ordre

---

## 📦 Fichiers créés/modifiés

| Fichier | Type | Description |
|---------|------|-------------|
| `sql/create_stage_enums_and_modify_table.sql` | SQL | Script complet d'installation |
| `src/types/event.ts` | Types | Ajout StageType, StageSpecificity, modification EventStageInput |
| `src/api/stageEnumsApi.ts` | API | CRUD pour types et spécificités |
| `src/features/settings/events/EventForm.tsx` | UI | Layout 4 colonnes, chargement enums |

---

## ✅ Tests de validation

### ✅ Test 1 : Installation SQL
1. Exécuter le script SQL
2. Vérifier les tables : `stage_types`, `stage_specificities`
3. Vérifier la colonne `specificity` dans `event_stages`
4. Vérifier que `notes` n'existe plus

### ✅ Test 2 : Initialisation
1. Exécuter `initialize_stage_enums_for_company(company_id)`
2. Vérifier 8 types créés
3. Vérifier 7 spécificités créées

### ✅ Test 3 : Formulaire
1. Ouvrir "Créer un évènement"
2. Aller dans "Scènes"
3. Vérifier 4 colonnes
4. Vérifier les sélecteurs Type et Spécificité
5. Créer une scène avec type et spécificité
6. Sauvegarder → Vérifier en DB

---

**Date d'implémentation** : 28 octobre 2025  
**Tests** : ✅ Lint OK  
**Statut** : ✅ Base complète - Prêt pour interface de gestion  
**Impact** : ✅ Flexibilité totale pour chaque company


