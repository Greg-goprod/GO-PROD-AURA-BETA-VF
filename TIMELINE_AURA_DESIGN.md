# 🎨 Timeline AURA - Guide de Design

## 📊 Vue d'ensemble

La Timeline a été entièrement redesignée pour correspondre à la charte graphique AURA, inspirée de l'image de référence fournie.

---

## ✨ Composants améliorés

### 1. **DailySummaryCards** (Cartes KPI)

#### 🎯 Structure
4 cartes en responsive grid :
- **Cartes par jour** : violet clair avec icône Calendar
- **Carte Total Général** : gradient violet avec icône TrendingUp (bordure renforcée)
- **Carte Taux de Change** : ambre avec icône DollarSign

#### 🎨 Styles AURA
```tsx
// Carte standard (par jour)
bg-white dark:bg-gray-800
rounded-xl p-5
border border-gray-200 dark:border-gray-700
hover:shadow-md transition-shadow

// Carte Total Général
bg-gradient-to-br from-violet-50 to-purple-50 dark:from-violet-900/20 dark:to-purple-900/20
border-2 border-violet-300 dark:border-violet-700
hover:shadow-lg

// Carte Taux de Change
bg-amber-50 dark:bg-amber-900/20
border border-amber-200 dark:border-amber-700
```

#### 📈 Montants affichés
- EUR, USD, GBP, CHF par devise
- Total CHF calculé automatiquement avec conversion
- Taux de change en temps réel

---

### 2. **PerformanceCard** (Cartes d'artistes)

#### 🎯 Structure
- Nom de l'artiste en **GROS** et **UPPERCASE**
- Montant en **LARGE** avec couleur selon statut
- Horaires début-fin (format 21:00-22:15)
- 3 icônes d'actions en bas à droite :
  - 👁️ **Eye** : Voir les détails
  - ✏️ **Edit2** : Modifier
  - 🗑️ **Trash2** : Supprimer (en rouge)

#### 🎨 Couleurs selon statut

| Statut | Fond | Bordure | Montant | Usage |
|--------|------|---------|---------|-------|
| `idee` / `offre_a_faire` | Blanc | **Orange 2px** | Orange | Offre à créer |
| `offre_envoyee` / `sent` | Bleu clair | Bleu | Bleu | Offre envoyée |
| `offre_validee` / `accepted` | **Vert clair** | Vert | Vert | Offre acceptée |
| `offre_rejetee` / `rejected` | Rouge clair | Rouge | Rouge | Offre rejetée |
| Par défaut | Gris clair | Gris | Gris | Autre |

#### 💡 Exemple de styles

```tsx
// Offre à faire (SOFIAN PAMART dans l'image)
bg-white dark:bg-gray-800
border-2 border-orange-400 dark:border-orange-500
text-orange-600 dark:text-orange-400 (montant)

// Offre validée (NISKA dans l'image)
bg-green-50 dark:bg-green-900/20
border border-green-400 dark:border-green-600
text-green-600 dark:text-green-400 (montant)
```

#### 🎯 Border Radius
- `rounded-xl` (12px) au lieu de `rounded-lg` (8px)
- Plus moderne et conforme AURA

#### ✨ Animations
```tsx
hover:shadow-md transition-all duration-200
// Drag & Drop
opacity-50 shadow-xl scale-105 (quand en train de déplacer)
```

---

### 3. **TimelineGrid** (Grille principale)

#### 🎯 Améliorations

##### Header
- **Bordures renforcées** : `border-2` pour les séparateurs principaux
- **Colonne scènes** : fond gris clair avec texte en UPPERCASE et tracking-wide
- **Titre des jours** : format complet "vendredi 28 novembre 2025" (comme dans l'image)
- **Bande horaire** : fond gris clair, centrage des heures

##### Colonne des scènes
- **Indicateur violet** : barre verticale ronde à gauche de chaque nom de scène
  ```tsx
  <div className="w-1 h-8 bg-violet-400 dark:bg-violet-500 rounded-full mr-3"></div>
  ```
- Fond légèrement grisé pour distinction
- Font semibold

##### Cellules droppables
- **Hover** : fond gris très léger (50% opacity)
- **Drop actif** : fond violet clair avec bordure violet
  ```tsx
  bg-violet-50 dark:bg-violet-900/20 
  border-violet-300 dark:border-violet-600
  ```
- Transition douce sur 200ms

##### Container principal
```tsx
bg-white dark:bg-gray-900
border border-gray-200 dark:border-gray-700
rounded-xl overflow-hidden shadow-sm
```

---

## 🌈 Palette AURA utilisée

### Couleurs principales
- **Primary Violet** : `#7C3AED` (light) / `#7A49DB` (dark)
- **Success Green** : `#22C55E`
- **Warning Orange** : `#F59E0B`
- **Error Red** : `#EF4444`
- **Info Blue** : `#3B82F6`

### Couleurs par statut de performance
```css
/* Offre à faire */
--orange-400: #FB923C
--orange-500: #F97316
--orange-600: #EA580C

/* Offre validée */
--green-400: #4ADE80
--green-600: #16A34A

/* Offre envoyée */
--blue-300: #93C5FD
--blue-600: #2563EB

/* Offre rejetée */
--red-400: #F87171
--red-600: #DC2626

/* Violet AURA (indicateurs) */
--violet-400: #A78BFA
--violet-500: #8B5CF6
```

---

## 📏 Spacing & Typography

### Border Radius
- `rounded-xl` : 12px (cartes, grille, performances)
- `rounded-lg` : 10px (icônes, boutons)
- `rounded-full` : infini (indicateurs, badges)

### Shadows
```css
shadow-sm: 0 1px 2px rgba(2,6,23,.08)
shadow-md: 0 6px 12px rgba(2,6,23,.12)
shadow-lg: 0 12px 24px rgba(2,6,23,.16)
shadow-xl: 0 24px 40px rgba(2,6,23,.2)
```

### Typography
- **Font** : Manrope, Inter, sans-serif
- **Titres cartes KPI** : text-sm font-bold uppercase tracking-wide
- **Nom artiste** : text-sm font-bold uppercase
- **Montant** : text-lg font-bold
- **Horaires** : text-xs opacity-75
- **Labels scènes** : text-sm font-semibold

---

## ✅ Tests & Validations

### À vérifier
- [ ] Cartes KPI affichent correctement les montants multi-devises
- [ ] Conversion CHF automatique fonctionne
- [ ] Cartes de performances ont les bonnes couleurs selon le statut
- [ ] Drag & Drop fonctionne avec le nouveau design
- [ ] Icônes d'actions sont cliquables et fonctionnelles
- [ ] Dark mode s'applique correctement partout
- [ ] Hover et transitions sont fluides
- [ ] Indicateurs violets visibles sur chaque ligne de scène

### Statuts à tester
- [x] `offre_a_faire` → bordure orange 2px
- [x] `offre_envoyee` → fond bleu clair
- [x] `offre_validee` → fond vert clair
- [x] `offre_rejetee` → fond rouge clair

---

## 🚀 Prochaines améliorations possibles

1. **Animations avancées** : Spring animations pour drag & drop
2. **API Taux de change** : Connexion à une API réelle pour les taux
3. **Filtres visuels** : Filtrer par statut avec couleurs
4. **Zoom timeline** : Ajuster la largeur des heures
5. **Export PDF** : Générer un PDF de la timeline avec le design AURA
6. **Responsive mobile** : Adapter pour tablettes/mobiles

---

## 📚 Fichiers modifiés

- `src/features/timeline/components/DailySummaryCards.tsx` ✅
- `src/features/timeline/components/PerformanceCard.tsx` ✅
- `src/features/timeline/components/TimelineGrid.tsx` ✅
- `TIMELINE_AURA_DESIGN.md` (ce fichier) ✅

---

## 💡 Notes importantes

- Les taux de change sont actuellement **hardcodés** dans `DailySummaryCards.tsx` (ligne 44-48)
- Pour les connecter à une API réelle, remplacer par un `useEffect` qui fetch les taux
- Les couleurs de statut sont **centralisées** dans `getStatusStyles()` (PerformanceCard.tsx)
- Pour ajouter un nouveau statut, modifier uniquement cette fonction

---

**Design by AURA System** 🎨✨

