# 📏 Timeline - Marges de 1/2 Heure Avant et Après

## ✅ **Modifications appliquées**

### 1. **Colonne scènes/dates rétablie à 240px** ✓
La première colonne (jour/date + noms des scènes) est revenue à sa largeur originale de 240px.

### 2. **Marge de 1/2 heure au début** ✓
Un espace vide équivalent à **1/2 heure** a été ajouté entre la colonne scènes et la première heure affichée.

### 3. **Marge de 1/2 heure à la fin** ✓
Un espace vide équivalent à **1/2 heure** a été ajouté après la dernière heure affichée.

---

## 🎨 **Résultat visuel**

### **Structure**
```
┌────────────────┬────┬───────────────────────────────────────┬────┐
│ VENDREDI       │    │ 15:00  16:00  17:00  18:00  19:00    │    │
│ 31 octobre 2025│ 0.5│                                       │ 0.5│
├────────────────┼────┼───────────────────────────────────────┼────┤
│ Scène Princ.   │    │ ║║[██ Perf ██]         [██ Perf ██]║║│    │
│ main • 5000    │    │ ║║                                  ║║│    │
└────────────────┴────┴───────────────────────────────────────┴────┘
     240px       0.5h            Timeline content            0.5h
  (Colonne scènes) (Marge)                                (Marge)
```

### **Avantages visuels**
- ✅ **Respiration** : Espace avant/après la zone horaire
- ✅ **Clarté** : Séparation visuelle entre la colonne et le contenu
- ✅ **Équilibre** : Timeline mieux centrée et proportionnée

---

## 🔧 **Implémentation technique**

### **1. Colonne scènes rétablie**
```tsx
const STAGE_COLUMN_WIDTH = 240; // Largeur fixe rétablie
```

### **2. Calcul de la marge**
```tsx
const MARGIN_LEFT = HOUR_WIDTH / 2; // Marge de 0.5 heure
```

### **3. Largeur totale avec marges**
```tsx
const totalWidth = MARGIN_LEFT + (totalHours * HOUR_WIDTH) + MARGIN_LEFT;
//                 ↑            ↑                           ↑
//              Marge avant   Contenu timeline          Marge après
//               (0.5h)                                  (0.5h)
```

### **4. HOUR_WIDTH ajusté**
```tsx
const HOUR_WIDTH = useMemo(() => {
  const availableWidth = containerWidth - STAGE_COLUMN_WIDTH - 32;
  
  // +1 heure pour les marges (0.5h avant + 0.5h après)
  const totalHoursWithMargins = totalHours + 1;
  
  const calculatedWidth = Math.max(availableWidth / totalHoursWithMargins, 80);
  
  return calculatedWidth;
}, [containerWidth, totalHours]);
```

**Explication** : On divise l'espace disponible par `totalHours + 1` pour réserver de la place pour les marges.

---

## 📐 **Calculs de position**

### **Position des heures**
```tsx
const timelineHours = useMemo(() => {
  const hours = [];
  for (let i = 1; i <= totalHours; i++) {
    hours.push({
      hour: (globalStartHour + i) % 24,
      label: `${hour}:00`,
      left: MARGIN_LEFT + (i * HOUR_WIDTH), // Décalage de 0.5h
    });
  }
  return hours;
}, [globalStartHour, totalHours, HOUR_WIDTH, MARGIN_LEFT]);
```

**Exemple** :
- `MARGIN_LEFT = 65px` (0.5h à 130px/h)
- Heure 1 (15:00) : `left = 65 + (1 × 130) = 195px`
- Heure 2 (16:00) : `left = 65 + (2 × 130) = 325px`
- etc.

### **Position des performances**
```tsx
const getPerformancePosition = (performance: Performance, day: EventDay) => {
  const minutesSinceStart = hoursSinceStart * 60 + perfMin;
  const left = MARGIN_LEFT + (minutesSinceStart * MINUTE_WIDTH); // Avec marge
  const width = performance.duration * MINUTE_WIDTH;
  
  return { left, width };
};
```

**Exemple** :
- Performance à 18:00 (3h après le début 15:00)
- `left = 65 + (180 × MINUTE_WIDTH)`

### **Position des lignes d'amplitude**
```tsx
const getHourPosition = (timeString: string) => {
  const minutesSinceStart = hoursSinceStart * 60 + minutes;
  return MARGIN_LEFT + (minutesSinceStart * MINUTE_WIDTH); // Avec marge
};
```

### **Click sur une cellule**
```tsx
const handleCellClick = (day: EventDay, stage: EventStage, event: React.MouseEvent) => {
  const clientX = event.clientX - rect.left;
  const minutesSinceStart = (clientX - MARGIN_LEFT) / MINUTE_WIDTH; // Soustraire la marge
  const defaultTime = minToHHMM(snappedMinutes);
  // ...
};
```

**Important** : On soustrait `MARGIN_LEFT` pour calculer le temps correct par rapport au début de la timeline (sans la marge).

---

## 📊 **Exemple de calcul complet**

### **Données**
- Largeur conteneur : `1920px`
- Largeur colonne scènes : `240px`
- Padding : `32px`
- Total heures : `12h`
- Heures avec marges : `12 + 1 = 13h`

### **Calcul HOUR_WIDTH**
```
availableWidth = 1920 - 240 - 32 = 1648px
HOUR_WIDTH = 1648 / 13 ≈ 127px
```

### **Calcul MARGIN_LEFT**
```
MARGIN_LEFT = 127 / 2 ≈ 63.5px
```

### **Calcul totalWidth**
```
totalWidth = 63.5 + (12 × 127) + 63.5
           = 63.5 + 1524 + 63.5
           = 1651px
```

### **Position des heures**
```
Heure 1 (15:00) : 63.5 + (1 × 127) = 190.5px
Heure 2 (16:00) : 63.5 + (2 × 127) = 317.5px
Heure 3 (17:00) : 63.5 + (3 × 127) = 444.5px
...
Heure 12 (02:00): 63.5 + (12 × 127) = 1587.5px
```

### **Marges**
```
Marge avant : 0px → 63.5px (espace vide)
Contenu : 63.5px → 1587.5px (heures + performances)
Marge après : 1587.5px → 1651px (espace vide)
```

---

## 🎯 **Avantages**

### ✅ **Respiration visuelle**
- Espace avant et après la timeline
- Meilleure séparation entre la colonne et le contenu
- Interface moins "collée"

### ✅ **Alignement**
- Toutes les positions (heures, performances, lignes d'amplitude) sont décalées de la même marge
- Cohérence visuelle parfaite

### ✅ **Flexibilité**
- Les marges s'adaptent dynamiquement à `HOUR_WIDTH`
- Si la timeline est plus large, les marges aussi
- Si la timeline est plus étroite, les marges aussi

### ✅ **Colonne scènes confortable**
- 240px permet d'afficher :
  - Jour complet : "VENDREDI"
  - Date complète : "31 octobre 2025"
  - Nom de scène : "Scène Principale"
  - Type + Capacité : "main • 5000 pers."

---

## 📏 **Comparaison Avant/Après**

### **Avant (sans marges)**
```
┌────────────────┬───────────────────────────────────────────┐
│ VENDREDI       │15:00  16:00  17:00  18:00  19:00  20:00  │
│ 31 octobre 2025│                                           │
├────────────────┼───────────────────────────────────────────┤
│ Scène Princ.   │[██ Perf ██]                               │
└────────────────┴───────────────────────────────────────────┘
     240px                  Timeline collée à la colonne
```

### **Après (avec marges 0.5h)**
```
┌────────────────┬────┬───────────────────────────────┬────┐
│ VENDREDI       │    │15:00  16:00  17:00  18:00    │    │
│ 31 octobre 2025│0.5h│                               │0.5h│
├────────────────┼────┼───────────────────────────────┼────┤
│ Scène Princ.   │    │[██ Perf ██]                   │    │
└────────────────┴────┴───────────────────────────────┴────┘
     240px       Marge        Timeline séparée       Marge
```

**Différence** : Espace de respiration avant et après, timeline mieux équilibrée.

---

## ✅ **Tests d'acceptation**

### Test 1 : Colonne scènes à 240px
1. Ouvrir la timeline
2. Mesurer la largeur de la colonne scènes
3. ✅ **Vérifier** : Largeur = 240px

### Test 2 : Marge avant
1. Observer l'espace entre la colonne scènes et la première heure
2. Mesurer cet espace
3. ✅ **Vérifier** : Espace ≈ HOUR_WIDTH / 2

### Test 3 : Marge après
1. Observer l'espace après la dernière heure
2. Mesurer cet espace
3. ✅ **Vérifier** : Espace ≈ HOUR_WIDTH / 2

### Test 4 : Position des performances
1. Observer les performances
2. ✅ **Vérifier** : Les performances sont décalées de la marge
3. ✅ **Vérifier** : Les performances sont bien alignées avec les heures

### Test 5 : Click pour créer une performance
1. Cliquer dans une cellule
2. ✅ **Vérifier** : L'heure proposée correspond au clic (sans la marge)

---

## 🚀 **Résultat**

✅ **Colonne scènes** : 240px (rétablie)
✅ **Marge avant** : 0.5 heure (HOUR_WIDTH / 2)
✅ **Marge après** : 0.5 heure (HOUR_WIDTH / 2)
✅ **Toutes les positions** : Ajustées avec MARGIN_LEFT
✅ **Timeline** : Mieux équilibrée et plus aérée

**La timeline a maintenant des marges de respiration avant et après ! 📏✨**

