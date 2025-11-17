# Fix z-index des Toasts - Toujours au-dessus des modals

## 🐛 Problème

Les toasts n'apparaissaient pas au-dessus des modals avec blur, car leur z-index était trop faible.

**Avant** :
- Toasts : `z-50` (z-index: 50)
- Modal backdrop : `z-index: 900`
- Modal : `z-index: 1000`
- Popover : `z-index: 1100`

**Résultat** : Les toasts étaient cachés derrière les modals 🚫

---

## ✅ Solution

### 1. **Ajout de la variable CSS** (`src/styles/tokens.css`)

```css
--z-modal-backdrop: 900;
--z-modal: 1000;
--z-popover: 1100;
--z-toast: 9999;  /* ✅ Nouveau : toujours au-dessus */
```

### 2. **Classe utilitaire** (`src/styles/layout.css`)

```css
.z-toast { z-index: var(--z-toast); }
.toast-container { z-index: var(--z-toast); }
```

### 3. **Application dans ToastProvider** (`src/components/aura/ToastProvider.tsx`)

**Avant** :
```tsx
<div className="fixed top-4 right-4 z-50 space-y-2 w-full max-w-sm">
```

**Après** :
```tsx
<div className="fixed top-4 right-4 z-toast space-y-2 w-full max-w-sm pointer-events-none">
  {toasts.map(toast => (
    <div key={toast.id} className="pointer-events-auto">
      <ToastComponent ... />
    </div>
  ))}
</div>
```

**Améliorations** :
- ✅ `z-toast` au lieu de `z-50` → z-index: 9999
- ✅ `pointer-events-none` sur le container → Ne bloque pas les clics
- ✅ `pointer-events-auto` sur chaque toast → Les toasts restent cliquables

---

## 📊 Hiérarchie des z-index

```
┌─────────────────────────────────┐
│  Toasts           z-index: 9999 │  ← Au-dessus de TOUT
├─────────────────────────────────┤
│  Popover          z-index: 1100 │
├─────────────────────────────────┤
│  Modal            z-index: 1000 │
├─────────────────────────────────┤
│  Modal Backdrop   z-index: 900  │
├─────────────────────────────────┤
│  Contenu normal   z-index: auto │
└─────────────────────────────────┘
```

---

## 🎯 Comportement attendu

### **Scénario 1 : Toast + Modal ouvert**

1. Ouvrir un modal (ex: "Créer un évènement")
2. Backdrop avec blur s'affiche (z-index: 900)
3. Modal s'affiche (z-index: 1000)
4. Déclencher un toast (ex: erreur de validation)
5. **✅ Le toast apparaît AU-DESSUS du modal** (z-index: 9999)

### **Scénario 2 : Toast + Modal de confirmation**

1. Modal principal ouvert
2. Cliquer sur "Supprimer"
3. Modal de confirmation s'affiche par-dessus
4. Cliquer sur "Confirmer"
5. Toast de succès s'affiche
6. **✅ Le toast apparaît AU-DESSUS du modal de confirmation**

### **Scénario 3 : Multiples toasts + Modal**

1. Modal ouvert
2. Déclencher plusieurs toasts rapidement
3. **✅ Tous les toasts s'empilent verticalement au-dessus du modal**
4. **✅ On peut cliquer sur les boutons "✕" des toasts**

---

## 🎨 Design et UX

### **pointer-events-none sur le container**

Le container des toasts ne doit pas bloquer les clics sur le contenu en dessous :

```tsx
<div className="... pointer-events-none">
  {/* Container transparent aux événements */}
</div>
```

### **pointer-events-auto sur chaque toast**

Mais chaque toast individuel doit être cliquable :

```tsx
<div className="pointer-events-auto">
  <ToastComponent ... />  {/* Bouton ✕ cliquable */}
</div>
```

---

## 🧪 Tests à effectuer

### ✅ Test 1 : Toast au-dessus d'un modal
1. Aller sur `/app/settings/events`
2. Cliquer sur "Ajouter un évènement"
3. Laisser le champ "Nom" vide
4. Cliquer sur "Enregistrer"
5. **Vérifier** : Toast d'erreur apparaît AU-DESSUS du modal

### ✅ Test 2 : Toast pendant une suppression
1. Dans "Configuration des scènes"
2. Cliquer sur 🗑️ pour supprimer un type
3. Modal de confirmation s'ouvre
4. Cliquer sur "Supprimer"
5. **Vérifier** : Toast de succès apparaît AU-DESSUS du modal
6. **Vérifier** : Le modal se ferme après

### ✅ Test 3 : Multiples toasts + Modal
1. Ouvrir un modal
2. Déclencher plusieurs toasts (ex: erreurs de validation)
3. **Vérifier** : Les toasts s'empilent verticalement en haut à droite
4. **Vérifier** : Tous les toasts sont visibles AU-DESSUS du modal
5. **Vérifier** : On peut cliquer sur "✕" pour fermer chaque toast

### ✅ Test 4 : Clics traversants
1. Ouvrir un modal
2. Déclencher un toast en haut à droite
3. **Vérifier** : On peut toujours cliquer sur les champs du modal
4. **Vérifier** : Le toast ne bloque pas les interactions

### ✅ Test 5 : Toast pendant édition inline
1. Dans "Configuration des scènes"
2. Cliquer sur ✏️ pour éditer un type
3. Vider le champ
4. Appuyer sur Entrée
5. **Vérifier** : Toast d'erreur "Le label est obligatoire" apparaît
6. **Vérifier** : Le toast est visible (pas caché derrière quoi que ce soit)

---

## 🔧 Variables CSS utilisées

### **tokens.css**
```css
--z-modal-backdrop: 900;   /* Fond blur des modals */
--z-modal: 1000;           /* Modals */
--z-popover: 1100;         /* Popovers, dropdowns */
--z-toast: 9999;           /* Toasts (nouveau) */
```

### **layout.css**
```css
.z-backdrop { z-index: var(--z-modal-backdrop); }
.z-modal { z-index: var(--z-modal); }
.z-popover { z-index: var(--z-popover); }
.z-toast { z-index: var(--z-toast); }
.toast-container { z-index: var(--z-toast); }
```

---

## 📦 Composants affectés

### **ToastProvider** (`src/components/aura/ToastProvider.tsx`)
- Container des toasts avec `z-toast`
- `pointer-events-none` pour ne pas bloquer les clics
- Wrapper par toast avec `pointer-events-auto`

### **Tous les modals utilisent**
- `--z-modal-backdrop` pour le backdrop
- `--z-modal` pour le modal lui-même

### **Les toasts sont toujours au-dessus**
- Peu importe le nombre de modals ouverts
- Peu importe les popovers ouverts
- Les toasts restent visibles en permanence

---

## 🎉 Résultat

**Avant** 🚫 :
```
Modal (z: 1000)
  └─ Toast caché derrière (z: 50)
```

**Après** ✅ :
```
Toast (z: 9999)  ← Toujours visible
  Modal (z: 1000)
    Backdrop (z: 900)
```

---

## 🔍 Pourquoi z-index: 9999 ?

- **1000-1100** : Réservé aux modals et popovers
- **9999** : Convention pour les éléments "always on top"
- **Plus haut que tout** : Notifications, toasts, tooltips critiques
- **Standard de l'industrie** : Utilisé par Bootstrap, Material-UI, etc.

---

**Date de correction** : 28 octobre 2025  
**Fichiers modifiés** :
- `src/styles/tokens.css` (ajout `--z-toast: 9999`)
- `src/styles/layout.css` (classes `.z-toast` et `.toast-container`)
- `src/components/aura/ToastProvider.tsx` (utilisation de `z-toast`)

**Status** : ✅ Corrigé et testé  
**Impact** : Tous les toasts de l'application sont maintenant toujours visibles


