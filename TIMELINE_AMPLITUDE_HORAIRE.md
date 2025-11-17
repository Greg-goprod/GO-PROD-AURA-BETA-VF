# ⏰ Timeline - Amplitude Horaire Visuellement Marquée

## ✅ **Modifications appliquées**

### 1. **Première heure supprimée** ✓
La première heure de la timeline n'est plus affichée (14:00 dans l'exemple).

**Code** :
```tsx
// Boucle commence à 1 au lieu de 0
for (let i = 1; i <= totalHours; i++) {
  const hour = (globalStartHour + i) % 24;
  hours.push({ hour, label: `${hour}:00`, left: i * HOUR_WIDTH });
}
```

### 2. **Lignes épaisses pour open_time et close_time** ✓
Deux lignes verticales épaisses (violet) marquent le début et la fin de l'amplitude horaire de chaque jour.

**Code** :
```tsx
{/* Ligne épaisse pour open_time */}
<div
  className="absolute top-0 h-full border-r-2 border-violet-500 dark:border-violet-400"
  style={{ left: getHourPosition(day.open_time) }}
/>

{/* Ligne épaisse pour close_time */}
<div
  className="absolute top-0 h-full border-r-2 border-violet-500 dark:border-violet-400"
  style={{ left: getHourPosition(day.close_time) }}
/>
```

**Visuel** :
```
│       15:00      16:00      17:00  ║ 18:00      19:00 ║  20:00
│                                     ║                   ║
│                                     ║                   ║
└─────────────────────────────────────║═══════════════════║──────
                                      ↑                   ↑
                                   open_time          close_time
                                   (ligne épaisse)    (ligne épaisse)
```

### 3. **Zone d'amplitude contrastée** ✓
La zone entre `open_time` et `close_time` a un fond légèrement contrasté (violet très clair) pour faciliter la lecture.

**Code** :
```tsx
{/* Zone d'amplitude horaire (fond contrasté) */}
{(() => {
  const amplitude = getDayAmplitude(day);
  return (
    <div
      className="absolute top-0 h-full bg-violet-50/30 dark:bg-violet-900/10"
      style={{ 
        left: amplitude.left, 
        width: amplitude.width 
      }}
    />
  );
})()}
```

**Couleurs AURA** :
- Light mode : `bg-violet-50/30` (violet très clair, 30% opacité)
- Dark mode : `bg-violet-900/10` (violet foncé, 10% opacité)

---

## 🎨 **Résultat visuel**

```
┌─────────────────────────────────────────────────────────────────────────┐
│ MARDI 14 avril 2026  │ 15:00  16:00  17:00 ║18:00  19:00  20:00 ║ 21:00│
├──────────────────────┴─────────────────────║═══════════════════════║─────┤
│ MASCENE              │                      ║[██ Perf ██]         ║     │
│                      │                      ║                     ║     │
├──────────────────────┼──────────────────────║─────────────────────║─────┤
│ TASCENE              │                      ║    [██ Perf ██]     ║     │
│                      │                      ║                     ║     │
├──────────────────────┼──────────────────────║─────────────────────║─────┤
│ SASCENE              │                      ║        [██ Perf ██] ║     │
└──────────────────────┴──────────────────────║═════════════════════║─────┘
                                              ↑                     ↑
                                          open_time            close_time
                                          (18:00)              (20:00)
                                              
                                          Zone contrastée (violet clair)
```

**Légende** :
- `║` = Ligne épaisse (violet-500, border-r-2)
- `═` = Zone contrastée (bg-violet-50/30)
- `│` = Ligne fine normale (violet-200, border-r)

---

## 🔧 **Implémentation technique**

### **Calcul de la position d'une heure**

```tsx
const getHourPosition = (timeString: string) => {
  const hour = parseInt(timeString.split(':')[0]);
  const minutes = parseInt(timeString.split(':')[1] || '0');
  
  let hoursSinceStart = hour - globalStartHour;
  
  // Si après minuit (ex: close_time = 02:00 et globalStartHour = 15)
  if (hour < globalStartHour) {
    hoursSinceStart = (24 - globalStartHour) + hour;
  }
  
  const minutesSinceStart = hoursSinceStart * 60 + minutes;
  return minutesSinceStart * MINUTE_WIDTH;
};
```

**Exemple** :
- `globalStartHour = 15` (début de la timeline)
- `open_time = 18:00`
- `close_time = 02:00` (lendemain)

**Calculs** :
- Position `18:00` : `(18 - 15) * 60 * MINUTE_WIDTH = 180 * MINUTE_WIDTH`
- Position `02:00` : `((24 - 15) + 2) * 60 * MINUTE_WIDTH = 660 * MINUTE_WIDTH`

### **Calcul de l'amplitude horaire**

```tsx
const getDayAmplitude = (day: EventDay) => {
  const openPos = getHourPosition(day.open_time || '18:00:00');
  const closePos = getHourPosition(day.close_time || '02:00:00');
  
  return {
    left: openPos,
    width: closePos - openPos,
  };
};
```

**Résultat** :
- `left` : Position de début (open_time)
- `width` : Largeur de la zone (close_time - open_time)

### **Structure de rendu**

```tsx
{days.map((day) => (
  <div key={day.id}>
    {/* Ligne du jour avec heures */}
    <div className="flex bg-violet-50">
      <div>{/* Jour/Date */}</div>
      
      <div className="relative flex-1">
        {/* 1. Fond contrasté (en arrière-plan) */}
        <div className="bg-violet-100/50" style={{ left, width }} />
        
        {/* 2. Lignes épaisses (open_time et close_time) */}
        <div className="border-r-2 border-violet-500" style={{ left: openPos }} />
        <div className="border-r-2 border-violet-500" style={{ left: closePos }} />
        
        {/* 3. Labels d'heures (au premier plan) */}
        {timelineHours.map(({ hour, label, left }) => (
          <div style={{ left }}>{label}</div>
        ))}
      </div>
    </div>
    
    {/* Lignes de scènes */}
    {sortedStages.map((stage) => (
      <div className="flex">
        <div>{/* Nom scène */}</div>
        
        <div className="relative flex-1">
          {/* 1. Fond contrasté (en arrière-plan) */}
          <div className="bg-violet-50/30" style={{ left, width }} />
          
          {/* 2. Lignes épaisses (open_time et close_time) */}
          <div className="border-r-2 border-violet-400" style={{ left: openPos }} />
          <div className="border-r-2 border-violet-400" style={{ left: closePos }} />
          
          {/* 3. Grille verticale normale (heures) */}
          {timelineHours.map(({ left }) => (
            <div className="border-r border-violet-200" style={{ left }} />
          ))}
          
          {/* 4. Performances (au premier plan) */}
          {performances.map((perf) => (
            <PerformanceCard ... />
          ))}
        </div>
      </div>
    ))}
  </div>
))}
```

---

## 🎯 **Ordre de superposition (z-index)**

### **Ligne du jour (header)**
1. **Arrière-plan** : Fond violet-50 (base)
2. **Couche 1** : Zone contrastée (`bg-violet-100/50`)
3. **Couche 2** : Lignes épaisses (`border-r-2 border-violet-500`)
4. **Premier plan** : Labels d'heures (texte)

### **Lignes de scènes**
1. **Arrière-plan** : Fond blanc/gris (base)
2. **Couche 1** : Zone contrastée (`bg-violet-50/30`)
3. **Couche 2** : Lignes épaisses (`border-r-2 border-violet-400`)
4. **Couche 3** : Grille verticale normale (`border-r border-violet-200`)
5. **Premier plan** : Performances (cartes)

**Toutes les couches utilisent `position: absolute`** avec les mêmes coordonnées, donc l'ordre dans le DOM détermine l'ordre de superposition.

---

## 🎨 **Palette de couleurs AURA**

### **Light mode**
| Élément | Classe Tailwind | Couleur | Opacité |
|---------|----------------|---------|---------|
| Zone contrastée (header) | `bg-violet-100/50` | #EDE9FE | 50% |
| Zone contrastée (scène) | `bg-violet-50/30` | #F5F3FF | 30% |
| Ligne épaisse (header) | `border-violet-500` | #8B5CF6 | 100% |
| Ligne épaisse (scène) | `border-violet-400` | #A78BFA | 100% |
| Ligne fine normale | `border-violet-200` | #DDD6FE | 100% |

### **Dark mode**
| Élément | Classe Tailwind | Couleur | Opacité |
|---------|----------------|---------|---------|
| Zone contrastée (header) | `bg-violet-800/20` | #5B21B6 | 20% |
| Zone contrastée (scène) | `bg-violet-900/10` | #4C1D95 | 10% |
| Ligne épaisse (header) | `border-violet-400` | #A78BFA | 100% |
| Ligne épaisse (scène) | `border-violet-500` | #8B5CF6 | 100% |
| Ligne fine normale | `border-violet-800/50` | #5B21B6 | 50% |

**Principe** : Contraste léger, mais suffisant pour marquer visuellement l'amplitude horaire sans être trop agressif.

---

## ✅ **Tests d'acceptation**

### Test 1 : Première heure supprimée
1. Ouvrir la timeline
2. ✅ **Vérifier** : La première heure (ex: 14:00) n'est pas affichée
3. ✅ **Vérifier** : Les heures commencent à partir de la deuxième (ex: 15:00)

### Test 2 : Lignes épaisses visibles
1. Observer les lignes verticales
2. ✅ **Vérifier** : Une ligne épaisse violette à `open_time` (ex: 18:00)
3. ✅ **Vérifier** : Une ligne épaisse violette à `close_time` (ex: 02:00)
4. ✅ **Vérifier** : Les lignes épaisses sont plus visibles que les lignes normales

### Test 3 : Zone contrastée
1. Observer la zone entre `open_time` et `close_time`
2. ✅ **Vérifier** : Fond légèrement violet (plus foncé que le reste)
3. ✅ **Vérifier** : Contraste visible mais pas trop agressif
4. ✅ **Vérifier** : Zone contrastée présente dans le header ET dans chaque ligne de scène

### Test 4 : Adaptation par jour
1. Créer un événement avec des horaires différents par jour
   - Jour 1 : 18:00 → 02:00
   - Jour 2 : 16:00 → 03:00
2. ✅ **Vérifier** : Les lignes épaisses et zones contrastées s'adaptent à chaque jour

### Test 5 : Dark mode
1. Activer le dark mode
2. ✅ **Vérifier** : Zone contrastée visible (violet foncé léger)
3. ✅ **Vérifier** : Lignes épaisses visibles (violet clair)

---

## 🚀 **Avantages**

### ✅ **Lecture améliorée**
- On voit immédiatement l'amplitude horaire de chaque jour
- Les limites (open_time / close_time) sont clairement marquées
- La zone "active" est visuellement distincte

### ✅ **Cohérence AURA**
- Palette de couleurs violettes cohérente
- Opacités légères (30%, 50%, 10%, 20%)
- Contraste suffisant sans être agressif

### ✅ **Adaptation dynamique**
- Les lignes épaisses s'adaptent automatiquement à chaque jour
- Si un jour a 18:00 → 02:00 et un autre 16:00 → 03:00, chaque jour a ses propres limites visuelles
- Amplitude calculée dynamiquement

### ✅ **Performance**
- Calculs simples (position = heures * MINUTE_WIDTH)
- Pas de re-calculs complexes
- Rendu optimisé avec `useMemo`

---

## 🎯 **Résultat final**

```
┌─────────────────────────────────────────────────────────────────┐
│ MARDI 14 avril 2026  │ 15:00  16:00  17:00 ║18:00 ... 20:00 ║  │ ← Zone violet clair
├──────────────────────┴─────────────────────║════════════════║──┤
│ MASCENE              │                      ║[██ Perf ██]    ║  │ ← Zone violet très clair
│ TASCENE              │                      ║   [██ Perf ██] ║  │
│ SASCENE              │                      ║       [██ Perf]║  │
└──────────────────────┴──────────────────────║════════════════║──┘
                                              ↑                ↑
                                          open_time      close_time
                                          (ligne épaisse violet-500)
```

**Légende** :
- `║` = Ligne épaisse (border-r-2)
- `═` = Zone contrastée (bg-violet-XX)
- Zone entre les deux `║` = Amplitude horaire du jour

**La timeline est maintenant visuellement claire et respecte la charte AURA ! 🎨✨**

