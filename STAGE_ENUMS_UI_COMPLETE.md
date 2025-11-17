# Interface de Gestion des Scènes - Implémentation complète

## ✅ Corrections et ajouts réalisés

### 1. Alignement de hauteur des dropdowns ✅

#### Ajout des styles CSS (`src/styles/utilities.css`)

```css
/* selects */
.select{ height:44px; background:var(--color-bg-surface); color:var(--color-text-primary);
  border:1px solid var(--color-border); border-radius:14px; padding:0 .75rem;
  transition: all 0.2s ease; cursor: pointer;
}

/* Select compact pour formulaires */
.select-sm{ height:36px; background:var(--color-bg-surface); color:var(--color-text-primary);
  border:1px solid var(--color-border); border-radius:10px; padding:0 .65rem;
  transition: all 0.2s ease; font-size: 0.875rem; cursor: pointer;
}
```

**Hauteurs** :
- `.select` : 44px (même que `.input`)
- `.select-sm` : **36px** (même que `.input-sm`)

---

#### Modification du composant Select (`src/components/ui/Select.tsx`)

**Ajout du prop `size`** :
```typescript
type Props = {
  // ...
  size?: 'default' | 'sm'
}

export function Select({ size = 'default', ...rest }: Props) {
  const selectClass = size === 'sm' ? 'select-sm' : 'select';
  // ...
}
```

---

#### Utilisation dans EventForm (`src/features/settings/events/EventForm.tsx`)

```tsx
<Select
  label="Type"
  size="sm"  // ✅ Même hauteur que Input
  {...register(`stages.${index}.type`)}
  options={[
    { label: '(Aucun)', value: '' },
    ...stageTypes.map((type) => ({
      label: type.label,
      value: type.value,
    })),
  ]}
/>
```

**Résultat** : Les 4 champs (Nom / Type / Spécificité / Capacité) ont maintenant **exactement la même hauteur (36px)**.

---

### 2. Containers de gestion dans SettingsEventsPage ✅

#### Nouveau composant (`src/features/settings/events/StageEnumsManager.tsx`)

**Fonctionnalités** :
- ✅ Affichage en 2 colonnes (Types | Spécificités)
- ✅ Bouton "+" pour ajouter un type/spécificité
- ✅ Formulaire inline pour création
- ✅ Bouton "🗑️" pour supprimer
- ✅ Bouton "Initialiser valeurs par défaut" si aucune valeur
- ✅ Toast de confirmation/erreur
- ✅ Design cohérent avec AURA

**Layout** :
```
┌─────────────────────────┬─────────────────────────┐
│ Types de scènes      [+]│ Spécificités         [+]│
├─────────────────────────┼─────────────────────────┤
│ Principale         [🗑️] │ Couvert            [🗑️] │
│ Secondaire         [🗑️] │ Plein air          [🗑️] │
│ Club               [🗑️] │ Intérieur          [🗑️] │
│ ...                     │ ...                     │
└─────────────────────────┴─────────────────────────┘
```

---

#### Intégration dans SettingsEventsPage

**Position** : Sous la section "Gestion des évènements"

```tsx
{/* Gestion des types et spécificités de scènes */}
{currentCompanyId && (
  <div className="mt-12">
    <h2 className="text-2xl font-bold">Configuration des scènes</h2>
    <StageEnumsManager companyId={currentCompanyId} />
  </div>
)}
```

---

### 3. Chargement des enums dans EventForm ✅

**Code déjà en place** :
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
        toastError('Impossible de charger les types de scènes');
      });
  }
}, [open, companyId]);
```

**Dropdowns peuplés dynamiquement** :
```tsx
<Select
  options={[
    { label: '(Aucun)', value: '' },
    ...stageTypes.map((type) => ({
      label: type.label,
      value: type.value,
    })),
  ]}
/>
```

---

## 🎯 Utilisation

### Étape 1 : Initialiser les enums SQL

**Dans Supabase SQL Editor** :
```sql
-- Exécuter le script de correction
-- sql/fix_stage_enums_unique_constraint.sql

-- Puis initialiser pour toutes les companies
SELECT initialize_stage_enums_for_company(id) FROM public.companies;
```

**Résultat** : 8 types et 7 spécificités créés par company.

---

### Étape 2 : Accéder à la page

**URL** : `http://localhost:5180/app/settings/events`

**Structure de la page** :
1. **Section "Gestion des évènements"**
   - Liste des événements
   - Bouton "Ajouter un évènement"
   - Carte événement actuel

2. **Section "Configuration des scènes"** (nouveau ✅)
   - Container "Types de scènes"
   - Container "Spécificités de scènes"

---

### Étape 3 : Gérer les types et spécificités

#### Ajouter un type

1. Cliquer sur le bouton **"+"** dans "Types de scènes"
2. Saisir le nom : "Festival"
3. Appuyer sur **Entrée** ou cliquer sur **"Ajouter"**
4. Le type apparaît dans la liste

#### Supprimer un type

1. Cliquer sur le bouton **"🗑️"** à droite du type
2. Confirmer la suppression
3. Le type est supprimé

**Même fonctionnement pour les spécificités.**

---

### Étape 4 : Utiliser dans le modal "Créer un évènement"

1. **Ouvrir le modal** : Cliquer sur "Ajouter un évènement"
2. **Aller à l'onglet "Scènes"**
3. **Ajouter une scène** : Cliquer sur "+ Ajouter une scène"
4. **Remplir les champs** :
   - Nom : "Main Stage"
   - Type : Sélectionner "Principale" (dropdown peuplé ✅)
   - Spécificité : Sélectionner "Plein air" (dropdown peuplé ✅)
   - Capacité : 12000

**Résultat** : Les 4 champs sont **parfaitement alignés en hauteur (36px)**.

---

## 📋 Checklist de test

### ✅ Test 1 : Hauteur des dropdowns
1. Ouvrir "Créer un évènement" > onglet "Scènes"
2. Ajouter une scène
3. **Vérifier** : Les 4 champs (Nom / Type / Spécificité / Capacité) ont la même hauteur

### ✅ Test 2 : Dropdowns peuplés
1. Dans l'onglet "Scènes"
2. **Vérifier** : Le dropdown "Type" contient les types (Principale, Secondaire, etc.)
3. **Vérifier** : Le dropdown "Spécificité" contient les spécificités (Couvert, Plein air, etc.)

### ✅ Test 3 : Containers de gestion
1. Aller sur `http://localhost:5180/app/settings/events`
2. **Vérifier** : Section "Configuration des scènes" visible
3. **Vérifier** : 2 containers (Types / Spécificités) côte à côte

### ✅ Test 4 : Ajout d'un type
1. Cliquer sur "+" dans "Types de scènes"
2. Saisir "Festival"
3. Cliquer sur "Ajouter"
4. **Vérifier** : "Festival" apparaît dans la liste
5. **Vérifier** : Dans le modal, "Festival" est disponible dans le dropdown

### ✅ Test 5 : Suppression d'un type
1. Cliquer sur "🗑️" à côté d'un type
2. Confirmer
3. **Vérifier** : Le type est supprimé de la liste
4. **Vérifier** : Dans le modal, le type n'est plus dans le dropdown

### ✅ Test 6 : Initialisation des valeurs
1. Supprimer tous les types et spécificités
2. **Vérifier** : Un message "Aucune valeur trouvée" apparaît avec un bouton "Initialiser"
3. Cliquer sur "Initialiser les valeurs par défaut"
4. **Vérifier** : 8 types et 7 spécificités sont créés

---

## 📊 Récapitulatif des fichiers modifiés

| Fichier | Modifications |
|---------|---------------|
| `src/styles/utilities.css` | ✅ Ajout `.select` et `.select-sm` |
| `src/components/ui/Select.tsx` | ✅ Ajout prop `size` |
| `src/features/settings/events/EventForm.tsx` | ✅ Ajout `size="sm"` aux Select |
| `src/features/settings/events/StageEnumsManager.tsx` | ✅ Création composant |
| `src/pages/settings/SettingsEventsPage.tsx` | ✅ Intégration StageEnumsManager |
| `src/api/stageEnumsApi.ts` | ✅ Correction import supabaseClient |

---

## 🎨 Valeurs par défaut

### Types de scènes (8)
1. Principale
2. Secondaire
3. Club
4. Extérieur
5. Chapiteau
6. Atelier
7. VIP
8. Autre

### Spécificités de scènes (7)
1. Couvert
2. Plein air
3. Intérieur
4. Mobile
5. Permanent
6. Acoustique
7. Électrique

---

**Date d'implémentation** : 28 octobre 2025  
**Tests** : ✅ Lint OK  
**Statut** : ✅ Interface complète et fonctionnelle  
**Impact** : ✅ Gestion totale des enums de scènes par company


