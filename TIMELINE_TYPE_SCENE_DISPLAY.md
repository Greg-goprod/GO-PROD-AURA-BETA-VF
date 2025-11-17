# 🎭 Timeline - Affichage du Type de Scène

## ✅ **Modifications appliquées**

### 1. **Type de scène affiché sous le nom** ✓
Le type de scène est maintenant affiché sur une ligne séparée, directement sous le nom de la scène.

### 2. **2ème colonne = 1/2 heure** ✓
La marge avant (2ème colonne) a une largeur équivalente à **1/2 heure** de la timeline.

---

## 🎨 **Résultat visuel**

### **Structure de la colonne scènes**

#### **Avant**
```
┌──────────────────────────┐
│ ● Scène Principale       │
│   main • 5000 pers.      │ ← Type et capacité sur 1 ligne
└──────────────────────────┘
```

#### **Après**
```
┌──────────────────────────┐
│ ● Scène Principale       │ ← Nom
│   main                   │ ← Type seul
└──────────────────────────┘
```

### **Structure complète de la timeline**

```
┌──────────────────────────┬─────┬──────────────────────────────────┐
│ VENDREDI 31 octobre 2025 │     │ 15:00  16:00  17:00  18:00      │
├──────────────────────────┼─────┼──────────────────────────────────┤
│ ● Scène Principale       │     │ ║║[██ Perf ██]                ║║│
│   main                   │ 0.5h│ ║║                            ║║│
├──────────────────────────┼─────┼──────────────────────────────────┤
│ ● Scène Club             │     │ ║║         [██ Perf ██]       ║║│
│   club                   │ 0.5h│ ║║                            ║║│
└──────────────────────────┴─────┴──────────────────────────────────┘
    1ère colonne (240px)    2ème col          Timeline content
    (Scènes + Dates)        (1/2h)
```

---

## 🔧 **Implémentation**

### **Affichage du type de scène**

#### **Code avant**
```tsx
<div className="overflow-hidden flex-1">
  <div className="text-sm font-semibold truncate">
    {stage.name}
  </div>
  <div className="flex items-center gap-2 text-xs text-gray-500">
    {stage.type && <span className="capitalize">{stage.type}</span>}
    {stage.type && stage.capacity && <span>•</span>}
    {stage.capacity && <span>{stage.capacity} pers.</span>}
  </div>
</div>
```

**Problème** : Type et capacité mélangés sur la même ligne.

#### **Code après**
```tsx
<div className="overflow-hidden flex-1">
  <div className="text-sm font-semibold text-gray-800 dark:text-gray-200 truncate">
    {stage.name}
  </div>
  {stage.type && (
    <div className="text-xs text-gray-500 dark:text-gray-400 capitalize mt-0.5">
      {stage.type}
    </div>
  )}
</div>
```

**Avantage** : Type seul, clairement séparé du nom.

### **2ème colonne (marge avant)**

```tsx
// 2ème colonne : Marge de 0.5 heure au début (équivalent 1/2 heure)
const MARGIN_LEFT = HOUR_WIDTH / 2;
```

**Explication** : Cette "colonne" est en fait une marge invisible de 1/2 heure entre la colonne scènes et le contenu de la timeline.

---

## 📊 **Structure des colonnes**

### **Colonne 1 : Scènes + Dates (240px fixe)**

Contenu :
- Jour de la semaine (ex: "VENDREDI")
- Date complète (ex: "31 octobre 2025")
- Nom de la scène (ex: "Scène Principale")
- **Type de scène (ex: "main")**

### **Colonne 2 : Marge (1/2 heure = dynamique)**

Largeur :
- `MARGIN_LEFT = HOUR_WIDTH / 2`
- Exemple : Si `HOUR_WIDTH = 130px`, alors `MARGIN_LEFT = 65px`

Rôle :
- Espace de respiration entre la colonne scènes et la timeline
- Sépare visuellement les informations fixes (scènes) du contenu dynamique (performances)

### **Colonne 3 : Timeline (dynamique)**

Largeur :
- `totalWidth = MARGIN_LEFT + (totalHours * HOUR_WIDTH) + MARGIN_LEFT`
- Exemple : Pour 12h, `totalWidth = 65 + (12 × 130) + 65 = 1690px`

Contenu :
- Heures (15:00, 16:00, etc.)
- Performances (cartes)
- Lignes d'amplitude (open_time, close_time)
- Grille verticale (heures)

---

## 🎯 **Avantages**

### ✅ **Type de scène visible**
- **Clarté** : Le type est affiché directement sous le nom
- **Simplicité** : Type seul, sans mélange avec la capacité
- **Lisibilité** : Police plus petite (`text-xs`) mais bien distincte

### ✅ **Hiérarchie visuelle**
```
Scène Principale  ← Gros, gras (font-semibold)
main              ← Petit, grisé (text-xs text-gray-500)
```

### ✅ **Capitalisation automatique**
```tsx
<div className="capitalize">
  {stage.type}
</div>
```

**Résultat** :
- `"main"` → "Main"
- `"club"` → "Club"
- `"secondary"` → "Secondary"

### ✅ **Responsive**
- Si le nom de la scène est trop long, il est tronqué avec `truncate` (`...`)
- Le type reste toujours visible en dessous

### ✅ **Marge proportionnelle**
- La 2ème colonne (marge) s'adapte à la largeur d'une heure
- Si `HOUR_WIDTH` change, la marge aussi
- Cohérence visuelle : 1/2 heure = repère visuel clair

---

## 📐 **Exemple complet**

### **Configuration**
- Largeur conteneur : `1920px`
- Colonne scènes : `240px`
- Total heures : `12h`
- `HOUR_WIDTH` : `≈ 127px`
- `MARGIN_LEFT` : `≈ 63.5px` (1/2 heure)

### **Affichage**

```
┌─────────────────────────────┬──────┬────────────────────────────────────┐
│ VENDREDI 31 octobre 2025    │      │ 15:00  16:00  17:00  18:00  19:00 │
├─────────────────────────────┼──────┼────────────────────────────────────┤
│ ● Scène Principale          │      │ ║║[██ Artist 1 - 100€ ██]        ║║│
│   Main                      │ 63px │ ║║                               ║║│
├─────────────────────────────┼──────┼────────────────────────────────────┤
│ ● Scène Club                │      │ ║║      [██ Artist 2 - 50€ ██]   ║║│
│   Club                      │ 63px │ ║║                               ║║│
├─────────────────────────────┼──────┼────────────────────────────────────┤
│ ● Scène Extérieure          │      │ ║║            [██ Artist 3 ██]   ║║│
│   Outdoor                   │ 63px │ ║║                               ║║│
└─────────────────────────────┴──────┴────────────────────────────────────┘
       240px                   63.5px           Timeline (1524px)
```

---

## 🎨 **Styles appliqués**

### **Nom de la scène**
```tsx
className="text-sm font-semibold text-gray-800 dark:text-gray-200 truncate"
```

- `text-sm` : Taille standard (14px)
- `font-semibold` : Gras moyen (600)
- `text-gray-800` : Gris foncé (mode clair)
- `dark:text-gray-200` : Gris clair (mode sombre)
- `truncate` : Tronquer avec `...` si trop long

### **Type de scène**
```tsx
className="text-xs text-gray-500 dark:text-gray-400 capitalize mt-0.5"
```

- `text-xs` : Taille petite (12px)
- `text-gray-500` : Gris moyen (mode clair)
- `dark:text-gray-400` : Gris moyen-clair (mode sombre)
- `capitalize` : Première lettre en majuscule
- `mt-0.5` : Marge top de 2px (espacement avec le nom)

---

## 📋 **Types de scènes supportés**

Liste des types par défaut (définis dans la base de données) :

1. **Main** (Principal)
2. **Secondary** (Secondaire)
3. **Club** (Club)
4. **Outdoor** (Extérieur)
5. **Tent** (Chapiteau)
6. **Workshop** (Atelier)
7. **VIP** (VIP)
8. **Other** (Autre)

**Affichage** : Tous capitalisés automatiquement.

---

## ✅ **Tests d'acceptation**

### Test 1 : Type de scène visible
1. Ouvrir la timeline
2. Observer la colonne des scènes
3. ✅ **Vérifier** : Le type est affiché sous le nom (ex: "Main" sous "Scène Principale")

### Test 2 : Type seul (sans capacité)
1. Observer la 2ème ligne de chaque scène
2. ✅ **Vérifier** : Seul le type est affiché (ex: "Main")
3. ✅ **Vérifier** : La capacité n'est pas affichée

### Test 3 : Capitalisation
1. Observer le type de scène
2. ✅ **Vérifier** : Première lettre en majuscule (ex: "Main", "Club")

### Test 4 : Marge de 1/2 heure
1. Mesurer l'espace entre la colonne scènes et la première heure
2. Mesurer la largeur d'une heure
3. ✅ **Vérifier** : Marge = Largeur d'1 heure ÷ 2

### Test 5 : Responsive
1. Redimensionner la fenêtre
2. ✅ **Vérifier** : La marge s'adapte proportionnellement

---

## 🚀 **Résultat**

✅ **Type de scène** : Affiché sous le nom, seul sur sa ligne
✅ **Hiérarchie** : Nom en gras, type en petit gris
✅ **Capitalisation** : Automatique (première lettre en majuscule)
✅ **2ème colonne** : Marge de 1/2 heure (HOUR_WIDTH / 2)
✅ **Séparation visuelle** : Claire entre scènes et timeline

**Le type de scène est maintenant parfaitement visible et la marge de 1/2 heure est en place ! 🎭✨**

