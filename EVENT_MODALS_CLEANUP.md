# ✅ Nettoyage des modals "Créer un évènement"

**Date** : 2025-10-28  
**Objectif** : N'avoir qu'**un seul modal** pour créer/éditer des évènements

---

## 🎯 Problème initial

Il y avait **3 fichiers différents** pour créer des évènements, créant confusion et incohérence :

1. ❌ `src/features/settings/events/EventQuickAddModal.tsx` (inutilisé)
2. ❌ `src/components/events/EventQuickCreateModal.tsx` (utilisé par EventSelector, simplifié)
3. ✅ `src/features/settings/events/EventForm.tsx` (complet, utilisé par `/app/settings/events`)

---

## 🔧 Actions effectuées

### 1. Fichiers supprimés

#### ❌ `src/features/settings/events/EventQuickAddModal.tsx`
- **Raison** : Doublon non utilisé
- **État** : Supprimé

#### ❌ `src/components/events/EventQuickCreateModal.tsx`
- **Raison** : Version simplifiée, remplacée par EventForm
- **État** : Supprimé

#### ❌ `src/components/events/EventForm.tsx`
- **Raison** : Doublon, seul celui dans `features/settings/events/` doit être utilisé
- **État** : Supprimé

### 2. Fichier conservé et modifié

#### ✅ `src/features/settings/events/EventForm.tsx`

**Pourquoi** :
- Modal **complet** avec gestion des jours et scènes
- Utilisé par la page `/app/settings/events`
- Intégration avec `react-hook-form`
- Support création ET édition

**Modifications appliquées** :

##### a) Section "Informations générales" en 3 colonnes

**Avant** :
```tsx
<div className="space-y-4">
  <Input label="Nom" />
  
  <div className="grid grid-cols-2">
    <DatePickerPopup label="Début" />
    <DatePickerPopup label="Fin" />
  </div>
  
  <div>Couleur + picker</div>
  
  <Textarea label="Notes" rows={4} />
</div>
```

**Après** :
```tsx
<div className="space-y-3">
  <div className="grid grid-cols-3 gap-3">
    <div className="col-span-3">
      <Input label="Nom" placeholder="Festival 2026" />
    </div>
    
    <DatePickerPopup label="Début" />
    <DatePickerPopup label="Fin" />
    <div className="flex items-center justify-center">—</div>
  </div>
  
  <Textarea label="Notes" rows={3} />
</div>
```

**Changements** :
- ❌ **Couleur supprimée**
- ✅ **Layout 3 colonnes** (Nom | Dates | Indicateur)
- ✅ **Placeholder réduit** : "Festival 2026" (au lieu de "Ex: Festival 2026")
- ✅ **Hauteur réduite** : `space-y-3`, `gap-3`, `rows={3}`
- ✅ **Notes intégrées** (pas en onglet séparé)

### 3. Mise à jour de `EventSelector.tsx`

**Avant** :
```tsx
import { EventQuickCreateModal } from './EventQuickCreateModal';

<EventQuickCreateModal
  open={showQuickCreate}
  onClose={() => setShowQuickCreate(false)}
  onSuccess={handleQuickCreateSuccess}
  companyId={companyId}
/>
```

**Après** :
```tsx
import { EventForm } from '@/features/settings/events/EventForm';

{companyId && (
  <EventForm
    open={showQuickCreate}
    onClose={() => {
      setShowQuickCreate(false);
      loadEvents();
    }}
    companyId={companyId}
  />
)}
```

**Changements** :
- ✅ Utilise maintenant `EventForm` (modal complet)
- ✅ Recharge automatiquement la liste après fermeture
- ✅ Callback `onSuccess` supprimé (géré par `onClose`)

---

## 📊 Structure finale

### Un seul modal : `EventForm.tsx`

**Localisation** : `src/features/settings/events/EventForm.tsx`

**Utilisé par** :
1. ✅ `/app/settings/events` (bouton "Ajouter un évènement")
2. ✅ `EventSelector` (bouton "Nouveau" dans le header)

**Fonctionnalités** :
- ✅ **Création** d'évènements
- ✅ **Édition** d'évènements existants
- ✅ **3 onglets** :
  - Informations générales (nom, dates, notes)
  - Jours (avec horaires)
  - Scènes (avec types et capacités)
- ✅ **Validation** avec `react-hook-form`
- ✅ **Intégration** avec Supabase
- ✅ **Store** : Mise à jour de `currentEvent`

---

## 🎨 Layout final du modal

### Onglet "Informations générales"

```
┌───────────────────────────────────────────────────────┐
│ [Info] [Jours (2)] [Scènes (1)]                      │
├───────────────────────────────────────────────────────┤
│                                                       │
│ Nom de l'évènement *                                  │
│ [Festival 2026                             ]          │
│                                                       │
│ Date de début      Date de fin         [—]           │
│ [15/06/2026]      [17/06/2026]                       │
│                                                       │
│ Notes                                                 │
│ [Notes internes...                        ]           │
│                                                       │
└───────────────────────────────────────────────────────┘
[Annuler]                             [💾 Enregistrer]
```

**Caractéristiques** :
- **3 colonnes** : Nom (full), Dates, Placeholder
- **Pas de couleur** : Supprimée (défaut #3b82f6)
- **Notes intégrées** : Dans le même onglet
- **Compact** : `space-y-3`, `gap-3`, `rows={3}`

### Onglet "Jours"

- Liste des jours avec date, horaires, notes
- Bouton "Ajouter un jour"
- Validation : `close_time` peut être avant `open_time` (prolongation après minuit)

### Onglet "Scènes"

- Liste des scènes avec nom, type, capacité, notes
- Bouton "Ajouter une scène"
- Types : main, secondary, other

---

## 📁 Arborescence finale

```
src/
├── features/
│   └── settings/
│       └── events/
│           └── EventForm.tsx          ✅ SEUL MODAL À UTILISER
│
├── components/
│   └── events/
│       ├── EventSelector.tsx          ✅ Utilise EventForm
│       ├── EventQuickCreateModal.tsx  ❌ SUPPRIMÉ
│       └── EventForm.tsx              ❌ SUPPRIMÉ
│
└── features/
    └── settings/
        └── events/
            └── EventQuickAddModal.tsx ❌ SUPPRIMÉ
```

---

## ✅ Avantages

### 1. Simplicité

- ✅ **Un seul fichier** à maintenir
- ✅ **Pas de confusion** sur quel modal utiliser
- ✅ **Code unique** pour création et édition

### 2. Cohérence

- ✅ **Même UI** partout (Settings et EventSelector)
- ✅ **Mêmes validations**
- ✅ **Même comportement**

### 3. Maintenabilité

- ✅ **Un seul endroit** à modifier pour les évolutions
- ✅ **Pas de duplication** de code
- ✅ **Tests plus simples**

---

## 🧪 Tests de validation

### Test 1 : Création depuis Settings

1. Aller sur `/app/settings/events`
2. Cliquer "Ajouter un évènement"
3. **Vérifier** : Modal s'ouvre
4. **Vérifier** : Layout 3 colonnes
5. **Vérifier** : Pas de champ couleur
6. **Vérifier** : Onglet "Jours" visible
7. Créer un évènement
8. **Vérifier** : Sauvegarde OK, modal se ferme

### Test 2 : Création depuis EventSelector

1. Cliquer sur "Nouveau" dans EventSelector (header)
2. **Vérifier** : Même modal que Settings
3. **Vérifier** : Layout 3 colonnes
4. Créer un évènement
5. **Vérifier** : Liste rechargée, évènement sélectionné

### Test 3 : Édition depuis Settings

1. Aller sur `/app/settings/events`
2. Cliquer "Éditer" sur un évènement
3. **Vérifier** : Modal s'ouvre avec données pré-remplies
4. **Vérifier** : Onglets "Jours" et "Scènes" affichent les données
5. Modifier et enregistrer
6. **Vérifier** : Modifications sauvegardées

### Test 4 : Layout 3 colonnes

1. Ouvrir le modal
2. **Vérifier** : Nom sur toute la largeur
3. **Vérifier** : Date début (col 1), Date fin (col 2), Placeholder (col 3)
4. **Vérifier** : Espacement réduit (`gap-3`)

### Test 5 : Pas de couleur

1. Ouvrir le modal
2. **Vérifier** : **Pas de champ couleur**
3. Créer un évènement
4. **Vérifier** en base : `color_hex = '#3b82f6'` (défaut)

---

## 📝 Migration effectuée

| Fichier | Avant | Après |
|---------|-------|-------|
| `EventQuickAddModal.tsx` | Inutilisé | ❌ **Supprimé** |
| `EventQuickCreateModal.tsx` | Utilisé par EventSelector | ❌ **Supprimé** |
| `EventForm.tsx` (components) | Doublon | ❌ **Supprimé** |
| `EventForm.tsx` (features) | Utilisé par Settings | ✅ **Modifié** + **Seul modal** |
| `EventSelector.tsx` | Utilisait QuickCreate | ✅ **Modifié** (utilise EventForm) |

---

## 🚀 Prochaines étapes possibles

### Améliorations futures

1. **Validation avancée** :
   - Date fin ≥ Date début
   - Calcul automatique nombre de jours
   - Indicateur visuel dans colonne 3

2. **Création automatique des jours** :
   - Si dates définies, générer les jours automatiquement
   - Horaires par défaut : 11:00 - 02:00

3. **Templates d'évènements** :
   - Prédéfinis : "Festival 3 jours", "Concert 1 soir"
   - Copie depuis évènement précédent

4. **Amélioration UX** :
   - Drag & drop pour réordonner jours/scènes
   - Duplication rapide de jours/scènes
   - Prévisualisation avant sauvegarde

---

## ✅ Résultat final

### Un seul modal : `EventForm.tsx`

- ✅ **Utilisé partout** (Settings + EventSelector)
- ✅ **Layout 3 colonnes** (nom, dates, placeholder)
- ✅ **Pas de couleur** (défaut automatique)
- ✅ **Compact** (espacements réduits)
- ✅ **Complet** (info + jours + scènes)
- ✅ **Maintenu** dans un seul endroit

**Plus de confusion ! Un seul modal à utiliser et maintenir !** 🎉


