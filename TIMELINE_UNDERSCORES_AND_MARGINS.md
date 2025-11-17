# 🔧 Timeline - Suppression des Underscores et Marge de Fin

## ✅ **Modifications appliquées**

### 1. **Underscores remplacés par des espaces** ✓
Les types de scènes avec underscores (ex: `open_air`) sont maintenant affichés avec des espaces (ex: `Open Air`).

### 2. **Dernière colonne = 1/2 heure** ✓
La marge après la dernière heure affichée est maintenant clairement définie et égale à 1/2 heure.

---

## 🔧 **Correction 1 : Suppression des underscores**

### **Problème**
Les types de scènes stockés avec des underscores (ex: `open_air`, `main_stage`) étaient affichés tels quels.

```
┌──────────────────────────┐
│ ● Scène Extérieure       │
│   open_air               │ ← Underscore visible
└──────────────────────────┘
```

### **Solution**
Remplacement des underscores par des espaces avec `replace(/_/g, ' ')`.

```tsx
// Avant
{stage.type}

// Après
{stage.type.replace(/_/g, ' ')}
```

### **Résultat**
```
┌──────────────────────────┐
│ ● Scène Extérieure       │
│   Open Air               │ ← Espace + Capitalisation
└──────────────────────────┘
```

**Transformation** :
- `open_air` → `Open Air`
- `main_stage` → `Main Stage`
- `club` → `Club` (inchangé)
- `secondary` → `Secondary` (inchangé)

---

## 🔧 **Correction 2 : Dernière colonne = 1/2 heure**

### **État actuel**
La marge de droite était déjà de 1/2 heure dans le code (`totalWidth = MARGIN_LEFT + ... + MARGIN_LEFT`), mais je l'ai rendue **explicite** pour plus de clarté.

### **Solution**
Création d'une constante `MARGIN_RIGHT` distincte.

```tsx
// Avant
const MARGIN_LEFT = HOUR_WIDTH / 2;
const totalWidth = MARGIN_LEFT + (totalHours * HOUR_WIDTH) + MARGIN_LEFT;

// Après
const MARGIN_LEFT = HOUR_WIDTH / 2;   // 2ème colonne (marge avant)
const MARGIN_RIGHT = HOUR_WIDTH / 2;  // Dernière colonne (marge après)
const totalWidth = MARGIN_LEFT + (totalHours * HOUR_WIDTH) + MARGIN_RIGHT;
```

### **Résultat**
```
┌────────────┬────┬─────────────────────────────────┬────┐
│ Scènes     │0.5h│ Timeline (heures + perfs)       │0.5h│
│ + Dates    │    │                                 │    │
│ (240px)    │    │                                 │    │
└────────────┴────┴─────────────────────────────────┴────┘
   Colonne 1   2ème         Colonne centrale       Dernière
   (fixe)    colonne                               colonne
            (1/2h)                                  (1/2h)
```

**Clarification** :
- `MARGIN_LEFT = HOUR_WIDTH / 2` : Espace avant la première heure
- `MARGIN_RIGHT = HOUR_WIDTH / 2` : Espace après la dernière heure
- `totalWidth` : Largeur totale incluant les deux marges

---

## 📊 **Exemples de transformation des types**

### **Types avec underscores**

| Valeur en base | Affiché avant | Affiché après |
|----------------|---------------|---------------|
| `main` | `Main` | `Main` ✓ |
| `secondary` | `Secondary` | `Secondary` ✓ |
| `club` | `Club` | `Club` ✓ |
| `open_air` | `open_air` ❌ | `Open Air` ✅ |
| `main_stage` | `main_stage` ❌ | `Main Stage` ✅ |
| `vip_area` | `vip_area` ❌ | `Vip Area` ✅ |
| `workshop_tent` | `workshop_tent` ❌ | `Workshop Tent` ✅ |

### **Transformation CSS**
```tsx
className="capitalize"
```

**Effet** : Première lettre de **chaque mot** en majuscule.

- `open air` → `Open Air`
- `main stage` → `Main Stage`
- `vip area` → `Vip Area`

---

## 🎨 **Résultat visuel complet**

```
┌─────────────────────────┬────┬──────────────────────────────────┬────┐
│ VENDREDI 31 octobre 2025│    │ 15:00  16:00  17:00  18:00      │    │
├─────────────────────────┼────┼──────────────────────────────────┼────┤
│ ● Scène Principale      │    │ ║║[██ Perf ██]                 ║║│    │
│   Main                  │0.5h│ ║║                             ║║│0.5h│
├─────────────────────────┼────┼──────────────────────────────────┼────┤
│ ● Scène Extérieure      │    │ ║║         [██ Perf ██]        ║║│    │
│   Open Air              │0.5h│ ║║                             ║║│0.5h│
├─────────────────────────┼────┼──────────────────────────────────┼────┤
│ ● Scène Club            │    │ ║║    [██ Perf ██]             ║║│    │
│   Club                  │0.5h│ ║║                             ║║│0.5h│
└─────────────────────────┴────┴──────────────────────────────────┴────┘
      Colonne 1            2ème         Timeline                 Dernière
      (240px)             colonne                                colonne
                          (0.5h)                                  (0.5h)
```

---

## 📐 **Structure des colonnes détaillée**

### **Colonne 1 : Scènes + Dates (240px)**
- Largeur : **Fixe** (240px)
- Contenu :
  - Jour (ex: "VENDREDI")
  - Date (ex: "31 octobre 2025")
  - Nom de la scène (ex: "Scène Principale")
  - **Type de la scène** (ex: "Open Air")

### **Colonne 2 : Marge avant (dynamique)**
- Largeur : **HOUR_WIDTH / 2** (≈ 60-65px)
- Contenu : Espace vide (respiration)
- Rôle : Sépare la colonne fixe du contenu dynamique

### **Colonne 3 : Timeline (dynamique)**
- Largeur : **totalHours × HOUR_WIDTH** (≈ 1200-1500px)
- Contenu :
  - Heures affichées
  - Grille verticale
  - Cartes de performances
  - Lignes d'amplitude

### **Colonne 4 : Marge après (dynamique)**
- Largeur : **HOUR_WIDTH / 2** (≈ 60-65px)
- Contenu : Espace vide (respiration)
- Rôle : Équilibre visuel à la fin de la timeline

---

## 🔧 **Code technique**

### **Remplacement des underscores**
```tsx
{stage.type && (
  <div className="text-xs text-gray-500 dark:text-gray-400 capitalize mt-0.5">
    {stage.type.replace(/_/g, ' ')}
    {/* Regex: /_/g = tous les underscores, remplacés par des espaces */}
  </div>
)}
```

**Regex expliquée** :
- `_` : Le caractère underscore
- `/g` : Global (toutes les occurrences, pas juste la première)
- `' '` : Remplacé par un espace

**Exemple d'exécution** :
```js
'open_air'.replace(/_/g, ' ')  // → 'open air'
'main_stage'.replace(/_/g, ' ')  // → 'main stage'
'club'.replace(/_/g, ' ')  // → 'club' (inchangé)
```

### **Marges symétriques**
```tsx
// Marge avant (2ème colonne)
const MARGIN_LEFT = HOUR_WIDTH / 2;

// Marge après (dernière colonne)
const MARGIN_RIGHT = HOUR_WIDTH / 2;

// Largeur totale
const totalWidth = MARGIN_LEFT + (totalHours * HOUR_WIDTH) + MARGIN_RIGHT;
```

**Exemple de calcul** :
```
HOUR_WIDTH = 130px
MARGIN_LEFT = 130 / 2 = 65px
MARGIN_RIGHT = 130 / 2 = 65px
totalHours = 12h

totalWidth = 65 + (12 × 130) + 65
           = 65 + 1560 + 65
           = 1690px
```

---

## ✅ **Tests d'acceptation**

### Test 1 : Underscores remplacés
1. Ouvrir la timeline
2. Observer les types de scènes (sous le nom)
3. ✅ **Vérifier** : Pas d'underscores visibles
4. ✅ **Vérifier** : Espaces entre les mots (ex: "Open Air")
5. ✅ **Vérifier** : Capitalisation appliquée (ex: "Open Air", pas "open air")

### Test 2 : Marge de droite = 1/2 heure
1. Ouvrir la timeline
2. Observer l'espace après la dernière heure affichée
3. ✅ **Vérifier** : Espace ≈ HOUR_WIDTH / 2
4. ✅ **Vérifier** : Espace symétrique avec la marge de gauche

### Test 3 : Symétrie visuelle
1. Comparer la marge de gauche et la marge de droite
2. ✅ **Vérifier** : Les deux marges sont **identiques**
3. ✅ **Vérifier** : Timeline bien centrée et équilibrée

### Test 4 : Types sans underscores fonctionnent toujours
1. Créer ou observer des scènes avec types simples (ex: "main", "club")
2. ✅ **Vérifier** : Les types s'affichent normalement
3. ✅ **Vérifier** : Pas d'erreur JavaScript

### Test 5 : Capitalisation CSS
1. Observer les types de scènes
2. ✅ **Vérifier** : Chaque mot commence par une majuscule
3. ✅ **Vérifier** : "open air" → "Open Air" (pas "Open air")

---

## 🚀 **Résultat final**

### ✅ **Underscores supprimés**
- Remplacement par des espaces avec `replace(/_/g, ' ')`
- Capitalisation CSS avec `capitalize`
- Résultat : "Open Air", "Main Stage", etc.

### ✅ **Marges symétriques**
- Marge gauche : `MARGIN_LEFT = HOUR_WIDTH / 2`
- Marge droite : `MARGIN_RIGHT = HOUR_WIDTH / 2`
- Timeline équilibrée et aérée

### ✅ **Structure finale**
```
┌─────────────┬────┬──────────────────────┬────┐
│             │    │                      │    │
│   Scènes    │0.5h│     Timeline         │0.5h│
│   + Dates   │    │                      │    │
│   (240px)   │    │                      │    │
└─────────────┴────┴──────────────────────┴────┘
   Colonne 1   2ème       Contenu        Dernière
   (fixe)    colonne                     colonne
            (1/2h)                        (1/2h)
```

**Les types de scènes sont maintenant lisibles et la timeline est parfaitement équilibrée ! 🎭📏✨**

