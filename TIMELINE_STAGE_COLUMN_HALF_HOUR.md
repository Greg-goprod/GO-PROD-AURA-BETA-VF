# 📏 Timeline - Colonne Scènes = 1/2 Heure

## ✅ **Modification appliquée**

La première colonne (jour/date + noms des scènes) a maintenant une largeur équivalente à **1/2 heure** de la timeline au lieu d'une largeur fixe de 240px.

---

## 🔧 **Implémentation**

### **Avant**
```tsx
const STAGE_COLUMN_WIDTH = 240; // Largeur fixe en pixels
```

**Problème** : Largeur fixe, ne s'adapte pas à la timeline.

### **Après**
```tsx
// HOUR_WIDTH est calculé dynamiquement
const HOUR_WIDTH = useMemo(() => {
  const estimatedStageWidth = 65;
  const availableWidth = containerWidth - estimatedStageWidth - 32;
  const calculatedWidth = Math.max(availableWidth / totalHours, 80);
  return calculatedWidth;
}, [containerWidth, totalHours]);

// STAGE_COLUMN_WIDTH = 1/2 heure
const STAGE_COLUMN_WIDTH = useMemo(() => {
  return HOUR_WIDTH / 2;
}, [HOUR_WIDTH]);
```

**Avantage** : Largeur proportionnelle à la timeline, gain d'espace.

---

## 📊 **Calcul**

### **Exemple 1 : Écran large**
- Largeur conteneur : 1920px
- Total heures : 12h
- `HOUR_WIDTH` ≈ 150px
- **`STAGE_COLUMN_WIDTH` = 150 / 2 = 75px**

### **Exemple 2 : Écran moyen**
- Largeur conteneur : 1280px
- Total heures : 12h
- `HOUR_WIDTH` ≈ 100px
- **`STAGE_COLUMN_WIDTH` = 100 / 2 = 50px**

### **Exemple 3 : Écran petit**
- Largeur conteneur : 1024px
- Total heures : 10h
- `HOUR_WIDTH` ≈ 90px (min 80px)
- **`STAGE_COLUMN_WIDTH` = 90 / 2 = 45px**

---

## 🎨 **Résultat visuel**

### **Avant (240px fixe)**
```
┌─────────────────────────────────┬───────────────────────┐
│ VENDREDI 31 octobre 2025        │ 15:00  16:00  17:00  │
│ (240px - trop large)            │                      │
├─────────────────────────────────┼──────────────────────┤
│ Scène Principale                │ [██ Perf ██]         │
│ main • 5000 pers.               │                      │
└─────────────────────────────────┴──────────────────────┘
```

### **Après (1/2 heure ≈ 65-75px)**
```
┌──────────────┬──────────────────────────────────────┐
│ VENDREDI     │ 15:00  16:00  17:00  18:00  19:00   │
│ 31 oct. 2025 │                                      │
├──────────────┼──────────────────────────────────────┤
│ Scène Princ. │ [██ Perf ██]                         │
│ main • 5000  │                                      │
└──────────────┴──────────────────────────────────────┘
```

**Gain d'espace** : **~165-175px récupérés** → Plus d'espace pour les performances !

---

## 📐 **Ajustements automatiques**

### **Texte du jour/date**
La date passe de `"31 octobre 2025"` à `"31 oct. 2025"` (format court) pour s'adapter à la largeur réduite.

```tsx
// Dans EventForm.tsx et autres
new Date(day.date).toLocaleDateString('fr-FR', { 
  day: 'numeric',
  month: 'short',  // 'short' au lieu de 'long'
  year: 'numeric'
})
```

**Résultat** : "31 oct. 2025" au lieu de "31 octobre 2025"

### **Nom des scènes**
Les noms longs sont tronqués avec `truncate` (CSS `text-overflow: ellipsis`).

```tsx
<div className="text-sm font-semibold truncate">
  {stage.name}  {/* Ex: "Scène Principale" → "Scène Princ..." */}
</div>
```

### **Type et capacité**
Format compact avec séparateur `•`.

```tsx
<div className="text-xs text-gray-500">
  {stage.type && <span className="capitalize">{stage.type}</span>}
  {stage.type && stage.capacity && <span>•</span>}
  {stage.capacity && <span>{stage.capacity} pers.</span>}
</div>
```

**Résultat** : "main • 5000 pers."

---

## 🎯 **Avantages**

### ✅ **Gain d'espace**
- **~165px récupérés** (240px → 75px)
- Plus d'espace pour afficher les performances
- Timeline plus large et plus lisible

### ✅ **Proportionnel**
- La colonne s'adapte à la largeur de la timeline
- Si `HOUR_WIDTH` change, la colonne aussi
- Cohérence visuelle : 1/2 heure = repère visuel clair

### ✅ **Responsive**
- S'adapte automatiquement à la taille de l'écran
- Écran large → colonne plus large
- Écran petit → colonne plus petite

### ✅ **Épuré**
- Colonne plus compacte = interface plus moderne
- Texte essentiel uniquement
- Moins de "bruit" visuel

---

## 📏 **Comparaison des largeurs**

| Élément | Largeur avant | Largeur après | Gain |
|---------|---------------|---------------|------|
| **Colonne scènes** | 240px (fixe) | 65-75px (1/2h) | **-165px** |
| **Zone performances** | Reste | + 165px | **+165px** |
| **Total conteneur** | 1920px | 1920px | = |

**Rapport** : La colonne occupe maintenant **~4%** de la largeur au lieu de **~12%**.

---

## 🎨 **Impact sur le design**

### **Cartes KPI (DailySummaryCards)**
Les cartes restent inchangées (grille 8 colonnes).

### **Timeline Grid**
```
┌───┬────────────────────────────────────────────────────┐
│ J │ ════════════════ TIMELINE ════════════════════════│
│ O │                                                    │
│ U │                [██ Performances ██]                │
│ R │            [██ Plus d'espace ██]                   │
│   │        [██ Meilleure lisibilité ██]                │
└───┴────────────────────────────────────────────────────┘
  ↑
1/2 heure
(~4% largeur)
```

### **Ligne du jour**
```
┌──────────────┬──────────────────────────────────────┐
│ VENDREDI     │ 15:00  16:00  17:00  18:00  19:00   │
│ 31 oct. 2025 │                                      │
└──────────────┴──────────────────────────────────────┘
     ↑
   Compact
```

### **Ligne de scène**
```
┌──────────────┬──────────────────────────────────────┐
│ Scène Princ. │ ║║[██ Perf ██]         [██ Perf ██]║║│
│ main • 5000  │ ║║                                  ║║│
└──────────────┴──────────────────────────────────────┘
     ↑
   Essentiel
```

---

## ⚠️ **Considérations**

### **Texte tronqué**
Les noms de scènes très longs seront tronqués.

**Solution** : Utiliser `title` attribute pour afficher le nom complet au survol.

```tsx
<div className="truncate" title={stage.name}>
  {stage.name}
</div>
```

### **Largeur minimale**
Si `HOUR_WIDTH` est très petit (< 80px), la colonne sera aussi très petite (< 40px).

**Solution actuelle** : `HOUR_WIDTH` a un minimum de 80px, donc la colonne a un minimum de 40px.

---

## ✅ **Tests d'acceptation**

### Test 1 : Largeur 1/2 heure
1. Ouvrir la timeline
2. Mesurer la largeur de la colonne scènes
3. Mesurer la largeur d'une heure dans la timeline
4. ✅ **Vérifier** : Colonne = 1/2 largeur d'une heure

### Test 2 : Adaptation responsive
1. Redimensionner la fenêtre
2. Observer la largeur de la colonne scènes
3. ✅ **Vérifier** : La colonne s'adapte proportionnellement

### Test 3 : Texte compact
1. Observer la date du jour
2. ✅ **Vérifier** : "31 oct. 2025" (format court)
3. Observer les noms de scènes
4. ✅ **Vérifier** : Texte tronqué avec `...` si trop long

### Test 4 : Plus d'espace pour performances
1. Comparer avec l'ancienne version
2. ✅ **Vérifier** : Zone de performances plus large
3. ✅ **Vérifier** : Plus de performances visibles sans scroll

---

## 🚀 **Résultat**

✅ **Colonne scènes** : 1/2 heure au lieu de 240px fixe
✅ **Gain d'espace** : ~165px récupérés
✅ **Proportionnel** : S'adapte à la timeline
✅ **Responsive** : S'adapte à l'écran
✅ **Épuré** : Interface plus moderne et compacte

**La timeline utilise maintenant l'espace de manière optimale ! 📏✨**

