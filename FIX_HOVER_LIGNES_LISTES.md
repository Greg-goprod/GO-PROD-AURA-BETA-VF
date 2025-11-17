# 🎨 Correction du Hover des Lignes dans les Listes

## 🎯 Problème résolu

Le hover des lignes dans les listes était **illisible en mode dark** et **pas assez contrasté en mode clair**.

## ✅ Modifications appliquées

### 1. Nouvelles variables de couleur dans le thème Aura

**Fichier**: `src/styles/tokens.css`

Ajout de la variable `--color-hover-row` dans les deux thèmes :

#### Mode Clair
```css
--color-hover-row: #F5F3FF;  /* Violet très léger avec bon contraste */
```

#### Mode Dark
```css
--color-hover-row: #1F2842;  /* Bleu-gris contrasté visible sur fond sombre */
```

### 2. Simplification du style de hover pour les tables

**Fichier**: `src/styles/utilities.css`

**AVANT** (illisible) :
```css
.dark .table tr:hover td { background: color-mix(in oklab, var(--color-bg-elevated) 75%, black) }
html:not(.dark) .table tr:hover td { background: color-mix(in oklab, var(--color-bg-elevated) 50%, var(--color-primary)) }
```

**APRÈS** (lisible et contrasté) :
```css
.table tr:hover td { background: var(--color-hover-row) }
```

### 3. Ajout de la couleur dans Tailwind Config

**Fichier**: `tailwind.config.ts`

```ts
'hover-row': 'var(--color-hover-row)',
```

Permet d'utiliser `bg-hover-row` dans les classes Tailwind si nécessaire.

### 4. Correction des pages avec listes personnalisées

Les pages suivantes ont été corrigées pour utiliser la nouvelle variable `--color-hover-row` :

#### Pages corrigées :

1. **src/pages/app/artistes/index.tsx** (Liste des artistes)
2. **src/pages/app/contacts/personnes.tsx** (Liste des contacts)
3. **src/pages/app/contacts/entreprises.tsx** (Liste des entreprises)
4. **src/pages/app/artistes/partials/SpotifySearchModal.tsx** (Résultats de recherche Spotify)
5. **src/pages/settings/SettingsContactsPage.tsx** (Options de configuration)
6. **src/features/settings/events/StageEnumsManager.tsx** (Types et spécificités de scènes)
7. **templates/NewPageTemplate.tsx** (Template pour nouvelles pages)

#### Méthode appliquée :

```tsx
// AVANT
<tr className="hover:bg-gray-50 dark:hover:bg-gray-750">

// APRÈS
<tr 
  style={{ transition: 'background 0.15s ease' }}
  onMouseEnter={(e) => e.currentTarget.style.background = 'var(--color-hover-row)'}
  onMouseLeave={(e) => e.currentTarget.style.background = ''}
>
```

### 5. Pages utilisant automatiquement la correction

Ces pages utilisent la classe `.table` et bénéficient automatiquement de la correction :

- **src/pages/admin/PermissionsPage.tsx** (Table des utilisateurs)
- **src/pages/Home.tsx** (Table des réservations récentes)

## 🎨 Palette de couleurs

### Mode Clair
| Élément | Variable | Hex | Effet |
|---------|----------|-----|-------|
| Hover ligne | `--color-hover-row` | `#F5F3FF` | Violet très léger, excellent contraste |

### Mode Dark
| Élément | Variable | Hex | Effet |
|---------|----------|-----|-------|
| Hover ligne | `--color-hover-row` | `#1F2842` | Bleu-gris, bien visible sur fond sombre |

## ✅ Avantages

### 1. Cohérence visuelle
- ✅ Même couleur de hover dans toute l'application
- ✅ Respecte la charte AURA
- ✅ Design system unifié

### 2. Accessibilité améliorée
- ✅ **Mode clair** : Contraste suffisant et agréable à l'œil
- ✅ **Mode dark** : Visible et lisible, pas trop agressif
- ✅ Transition fluide (0.15s ease)

### 3. Maintenabilité
- ✅ Une seule variable CSS à modifier pour tout changer
- ✅ Support automatique Light/Dark via CSS variables
- ✅ Facile à adapter si besoin dans le futur

## 🧪 Tests à effectuer

### Test 1 : Mode Clair
1. Ouvrir l'application en mode clair
2. Naviguer vers une page avec liste (Artistes, Contacts, etc.)
3. ✅ **Vérifier** : Le hover est visible avec une teinte violet clair
4. ✅ **Vérifier** : Le texte reste parfaitement lisible

### Test 2 : Mode Dark
1. Basculer en mode dark
2. Naviguer vers une page avec liste
3. ✅ **Vérifier** : Le hover est clairement visible avec une teinte bleu-gris
4. ✅ **Vérifier** : Le texte reste parfaitement lisible

### Test 3 : Transition
1. Survoler rapidement plusieurs lignes
2. ✅ **Vérifier** : La transition est fluide (0.15s)
3. ✅ **Vérifier** : Pas de saccades ou de ralentissements

## 📝 Notes

- Les erreurs de linting dans `SettingsContactsPage.tsx` existaient déjà avant les modifications
- Toutes les pages utilisant la classe `.table` bénéficient automatiquement de la correction
- Le template `NewPageTemplate.tsx` est à jour pour les futures pages











