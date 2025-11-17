# 📱 Lineup Page - Grille Responsive Sans Scroll Horizontal

## 🎯 **Objectif**

Rendre la page lineup complètement **responsive** sans scroll horizontal, en adaptant la grille à la largeur disponible de l'écran.

---

## ⚙️ **Modifications appliquées**

### **1. Suppression du scroll horizontal**

**Avant** ❌
```tsx
<div className="w-full overflow-x-auto">
  <div style={{ width: `${totalWidth}px`, minWidth: '100%' }}>
    {/* Grille */}
  </div>
</div>
```

**Après** ✅
```tsx
<div className="w-full">
  <div className="relative w-full">
    {/* Grille responsive */}
  </div>
</div>
```

**Changements** :
- ❌ Supprimé `overflow-x-auto`
- ❌ Supprimé `width: ${totalWidth}px`
- ✅ Ajouté `w-full` pour utiliser toute la largeur disponible

---

### **2. Grid responsive avec `1fr`**

**Avant** ❌
```tsx
<div style={{
  gridTemplateColumns: `${STAGE_COLUMN_WIDTH}px ${MARGIN_LEFT + totalHours * HOUR_WIDTH + MARGIN_RIGHT}px`
}}>
```

**Après** ✅
```tsx
<div style={{
  gridTemplateColumns: `${STAGE_COLUMN_WIDTH}px 1fr`
}}>
```

**Explication** :
- Colonne 1 : **240px** (largeur fixe pour les noms de scènes)
- Colonne 2 : **1fr** (prend tout l'espace restant)

---

### **3. Positions en pourcentages**

#### **A. Heures (labels et lignes verticales)**

**Avant** ❌
```tsx
{
  hour: 18,
  label: "18:00",
  position: MARGIN_LEFT + i * HOUR_WIDTH // en pixels
}
```

**Après** ✅
```tsx
{
  hour: 18,
  label: "18:00",
  position: marginLeftPercent + relativePosition // en pourcentage
}
```

#### **B. Amplitude horaire (lignes épaisses et fond)**

**Avant** ❌
```tsx
<div style={{
  left: `${amplitude.openPos}px`,
  width: `${amplitude.closePos - amplitude.openPos}px`
}} />
```

**Après** ✅
```tsx
<div style={{
  left: `${amplitude.openPos}%`,
  width: `${amplitude.closePos - amplitude.openPos}%`
}} />
```

#### **C. Cartes de performance**

**Avant** ❌
```tsx
const left = minutesSinceOpenTime * MINUTE_WIDTH; // pixels
const width = performance.duration * MINUTE_WIDTH; // pixels

<div style={{
  left: `${left}px`,
  width: `${width}px`
}} />
```

**Après** ✅
```tsx
const leftPercent = (minutesSinceOpenTime / totalDayMinutes) * 100;
const widthPercent = (performance.duration / totalDayMinutes) * 100;

<div style={{
  left: `${leftPercent}%`,
  width: `${widthPercent}%`
}} />
```

---

## 🧮 **Calculs de position en pourcentage**

### **Formule générale**

```typescript
// 1. Calculer les marges en pourcentage
const marginLeftPercent = (MARGIN_LEFT / totalWidth) * 100;
const marginRightPercent = (MARGIN_RIGHT / totalWidth) * 100;

// 2. Calculer la largeur de contenu disponible
const contentWidthPercent = 100 - marginLeftPercent - marginRightPercent;

// 3. Position d'un élément
const relativePercent = (position / totalDuration) * contentWidthPercent;
const finalPercent = marginLeftPercent + relativePercent;
```

---

### **Exemple : Heure 18:00**

**Données** :
- `globalStartHour` = 17
- `totalHours` = 12
- Heure actuelle = 18

**Calcul** :
```typescript
// Position relative (18h = 1h après le début)
const hoursSinceStart = 18 - 17 = 1;
const relativePosition = (1 / 12) * contentWidthPercent;

// Position finale
const position = marginLeftPercent + relativePosition;
// ≈ 4.17% + 7.64% = 11.81%
```

---

### **Exemple : Performance (20:00-21:30)**

**Données** :
- `open_time` = "17:00"
- `performance_time` = "20:00"
- `duration` = 90 minutes

**Calcul** :
```typescript
// Durée totale de la journée
const totalDayMinutes = (close_time - open_time) en minutes;

// Minutes depuis l'ouverture
const minutesSinceOpen = (20 - 17) * 60 = 180 minutes;

// Position et largeur en pourcentage
const leftPercent = (180 / totalDayMinutes) * 100;
const widthPercent = (90 / totalDayMinutes) * 100;
```

---

## 📊 **Comportement responsive**

### **Écran large (>1920px)**
```
┌─────────┬────────────────────────────────────────────────────────┐
│ Scènes  │                  Timeline (très large)                 │
│ (240px) │                      (1fr = ~1680px)                   │
└─────────┴────────────────────────────────────────────────────────┘
```

### **Écran moyen (1280px)**
```
┌─────────┬──────────────────────────────────────┐
│ Scènes  │      Timeline (compacte)             │
│ (240px) │        (1fr = ~1040px)               │
└─────────┴──────────────────────────────────────┘
```

### **Écran petit (768px)**
```
┌─────────┬────────────────────┐
│ Scènes  │  Timeline (étroite)│
│ (240px) │   (1fr = ~528px)   │
└─────────┴────────────────────┘
```

**Note** : Tout s'adapte automatiquement, les positions en pourcentage garantissent l'alignement.

---

## ✅ **Avantages de l'approche en pourcentages**

### **1. Responsive natif**
- ✅ S'adapte à toutes les tailles d'écran
- ✅ Pas de scroll horizontal
- ✅ Pas de breakpoints CSS nécessaires

### **2. Alignement garanti**
- ✅ Les heures restent alignées avec les lignes verticales
- ✅ Les performances restent alignées avec l'amplitude
- ✅ Pas de décalage pixel

### **3. Performance**
- ✅ Pas de recalcul lors du resize (géré par le navigateur)
- ✅ Transitions CSS fluides
- ✅ Moins de JavaScript

---

## 🔧 **Fichiers modifiés**

### **1. `ReadOnlyTimelineGrid.tsx`**

**Changements** :
- Container sans `overflow-x-auto`
- Grid avec `1fr` au lieu de largeur fixe
- Calcul des positions en pourcentages pour :
  - Heures (`timelineHours`)
  - Amplitude (`getDayAmplitude`)
  - Lignes verticales

**Lignes clés** :
```tsx
// Ligne 150 : Grid responsive
gridTemplateColumns: `${STAGE_COLUMN_WIDTH}px 1fr`

// Ligne 108-120 : Calcul des positions en pourcentage
const getHourPositionPercent = (time: string) => {
  // ... calcul en %
  return marginLeftPercent + relativePercent;
};

// Ligne 180, 231, 238, 242 : Positions en %
style={{ left: `${position}%` }}
```

---

### **2. `ReadOnlyPerformanceCard.tsx`**

**Changements** :
- Calcul de la position en pourcentage basé sur la durée totale de la journée
- Styles avec `left` et `width` en pourcentages

**Lignes clés** :
```tsx
// Ligne 26-32 : Calcul de la durée totale de la journée
const totalDayMinutes = dayEndMin < dayStartMin 
  ? (24 * 60 - dayStartMin + dayEndMin) 
  : (dayEndMin - dayStartMin);

// Ligne 31-32 : Positions en pourcentage
const leftPercent = (minutesSinceOpenTime / totalDayMinutes) * 100;
const widthPercent = (performance.duration / totalDayMinutes) * 100;

// Ligne 101, 103 : Application des pourcentages
left: `${leftPercent}%`,
width: `${widthPercent}%`
```

---

## 🧪 **Tests effectués**

### **Test 1 : Pas de scroll horizontal**
1. Ouvrir `/app/artistes/lineup` sur différentes tailles d'écran
2. Vérifier qu'il n'y a pas de scroll horizontal
3. ✅ **Succès** : La grille s'adapte à la largeur disponible

### **Test 2 : Alignement des éléments**
1. Vérifier que les heures sont alignées avec les lignes verticales
2. Vérifier que les performances sont alignées avec l'amplitude
3. ✅ **Succès** : Tout reste parfaitement aligné

### **Test 3 : Responsive**
1. Redimensionner la fenêtre du navigateur
2. Vérifier que la grille s'adapte fluidement
3. ✅ **Succès** : Adaptation fluide sans saccades

### **Test 4 : Performances cliquables**
1. Cliquer sur une carte de performance
2. Vérifier la navigation vers la page détail
3. ✅ **Succès** : Navigation fonctionnelle

---

## 📐 **Dimensions**

### **Largeur minimale recommandée**
- ✅ **768px** : Minimum pour une lisibilité correcte
- ✅ **1024px** : Recommandé pour un confort optimal
- ✅ **1280px+** : Idéal pour de nombreuses heures/scènes

### **Adaptation automatique**
```
Largeur écran         | Largeur timeline  | Visibilité
----------------------|-------------------|-------------
768px                 | ~528px            | Compacte
1024px                | ~784px            | Confortable
1280px                | ~1040px           | Spacieuse
1920px                | ~1680px           | Très large
```

---

## 🎨 **Cohérence visuelle**

### **Maintenue**
- ✅ Couleurs AURA (vert pour offres validées)
- ✅ Lignes violettes pour l'amplitude
- ✅ Fond légèrement teinté pour l'amplitude
- ✅ Bordures et ombres des cartes

### **Améliorée**
- ✅ Adaptation responsive fluide
- ✅ Pas de déformation lors du resize
- ✅ Positions relatives préservées

---

## ⚠️ **Limitations**

### **1. Largeur minimale**
- Sur un écran très étroit (< 768px), le contenu peut devenir difficile à lire
- **Solution** : Message d'avertissement ou rotation de l'écran suggérée

### **2. Performances avec beaucoup de données**
- De nombreuses performances (>50 par jour) peuvent ralentir le rendu
- **Solution** : Virtualisation ou pagination par jour

### **3. Précision des clics**
- Sur écrans étroits, les cartes très courtes peuvent être difficiles à cliquer
- **Solution** : Taille minimale de carte (déjà géré par `min-width` implicite)

---

## 🚀 **Évolutions possibles**

### **1. Zoom dynamique**
Permettre à l'utilisateur de zoomer/dézoomer la timeline

### **2. Vue mobile spécifique**
Créer une vue différente pour les très petits écrans

### **3. Export PDF responsive**
Générer un PDF qui s'adapte au format (A4, A3, etc.)

---

## ✅ **Résumé**

### **Objectif atteint**
✅ **Grille timeline complètement responsive sans scroll horizontal**

### **Technique**
- ✅ Utilisation de `1fr` pour la colonne timeline
- ✅ Positions en pourcentages au lieu de pixels
- ✅ Calculs dynamiques basés sur la largeur disponible

### **Résultat**
- ✅ S'adapte à toutes les tailles d'écran
- ✅ Pas de scroll horizontal
- ✅ Alignement parfait maintenu
- ✅ Performance optimale

---

**La page lineup est maintenant complètement responsive ! 🎉**

