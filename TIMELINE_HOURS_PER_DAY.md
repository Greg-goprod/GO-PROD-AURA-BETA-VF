# ⏰ Timeline - Heures répétées par jour

## 🎯 **Problème résolu**

**Problème** : Le header sticky ne fonctionnait pas, les heures n'étaient pas toujours visibles.

**Solution** : Supprimer le header sticky global et afficher les heures **sur chaque ligne de jour**.

---

## 📊 **Structure AVANT (avec sticky)**

```
┌─────────────────────────────────────────────────────────────┐
│ HORAIRES │  17:00  18:00  19:00  20:00  21:00  22:00 ...   │ ← Sticky (ne fonctionnait pas)
├──────────┴──────────────────────────────────────────────────┤
│ VENDREDI 31 octobre 2025  │ 18:00 → 02:00                  │
├───────────────────────────┼────────────────────────────────┤
│ Scène 1                   │ [██ Perf ██]                   │
│ Scène 2                   │     [██ Perf ██]               │
├───────────────────────────┴────────────────────────────────┤
│ SAMEDI 1 novembre 2025    │ 18:00 → 02:00                  │
├───────────────────────────┼────────────────────────────────┤
│ Scène 1                   │         [██ Perf ██]           │
└───────────────────────────┴────────────────────────────────┘
```

**Problème** : Header sticky ne fonctionnait pas, heures non visibles en scrollant.

---

## 📊 **Structure APRÈS (heures répétées)**

```
┌────────────────────────────────────────────────────────────────┐
│ VENDREDI 31 octobre 2025  │ 17:00  18:00  19:00  20:00 ... │ ← Heures du jour
├───────────────────────────┼────────────────────────────────┤
│ Scène 1                   │ [██ Perf ██]                   │
│ Scène 2                   │     [██ Perf ██]               │
├───────────────────────────┴────────────────────────────────┤
│ SAMEDI 1 novembre 2025    │ 17:00  18:00  19:00  20:00 ... │ ← Heures répétées
├───────────────────────────┼────────────────────────────────┤
│ Scène 1                   │         [██ Perf ██]           │
│ Scène 2                   │ [██ Perf ██]                   │
├───────────────────────────┴────────────────────────────────┤
│ DIMANCHE 2 novembre 2025  │ 17:00  18:00  19:00  20:00 ... │ ← Heures répétées
├───────────────────────────┼────────────────────────────────┤
│ Scène 1                   │ [██ Perf ██]                   │
└───────────────────────────┴────────────────────────────────┘
```

**Avantage** : Les heures sont toujours visibles pour chaque jour, pas besoin de sticky.

---

## 🔧 **Implémentation**

### 1. **Suppression du header sticky global**

```tsx
// AVANT
<div className="sticky top-0 bg-white z-20">
  <div className="w-48">HORAIRES</div>
  <div className="flex-1">
    {timelineHours.map(({ hour, label, left }) => (
      <div style={{ left }}>{label}</div>
    ))}
  </div>
</div>

// APRÈS
// ❌ Supprimé complètement
```

### 2. **Ajout des heures sur chaque ligne de jour**

```tsx
{days.map((day) => (
  <div key={day.id}>
    {/* Titre du jour avec heures */}
    <div className="flex bg-violet-50">
      {/* Colonne jour/date */}
      <div style={{ width: STAGE_COLUMN_WIDTH }}>
        <div>VENDREDI</div>
        <div>31 octobre 2025</div>
      </div>
      
      {/* Bande horaire pour CE jour */}
      <div className="relative flex-1" style={{ width: totalWidth }}>
        {timelineHours.map(({ hour, label, left }) => (
          <div
            key={`${day.id}-hour-${hour}`}
            className="absolute text-xs font-bold text-violet-700"
            style={{ left: left - 24, width: 48 }}
          >
            {label}
          </div>
        ))}
      </div>
    </div>
    
    {/* Scènes de ce jour */}
    {sortedStages.map((stage) => (
      <div>
        <div style={{ width: STAGE_COLUMN_WIDTH }}>{stage.name}</div>
        <div>{/* Performances */}</div>
      </div>
    ))}
  </div>
))}
```

---

## 🎨 **Avantages**

### ✅ **Toujours visible**
- Les heures sont répétées pour chaque jour
- Pas besoin de scroller vers le haut pour voir l'heure
- Contexte temporel toujours présent

### ✅ **Plus simple**
- Pas de gestion de sticky
- Pas de problème de z-index
- Pas de conflit avec overflow

### ✅ **Plus clair**
- Chaque jour a son propre contexte temporel
- Amplitude horaire visible par jour
- Facilite la lecture et la navigation

### ✅ **Performance**
- Pas de calcul de position sticky
- Moins de re-renders
- Code plus simple

---

## 📋 **Structure du code**

### **TimelineGrid.tsx**

```tsx
export function TimelineGrid({ days, stages, performances, ... }) {
  // ... (calculs HOUR_WIDTH, timelineHours, etc.)
  
  return (
    <DndContext ...>
      <div ref={containerRef} className="w-full">
        <div className="bg-white rounded-xl">
          
          {/* Pour chaque JOUR */}
          {days.map((day) => (
            <div key={day.id} className="border-b-4 border-violet-200">
              
              {/* Ligne du jour avec heures */}
              <div className="flex bg-violet-50 border-b-2">
                {/* Colonne gauche : Jour + Date */}
                <div style={{ width: STAGE_COLUMN_WIDTH }}>
                  <div className="font-bold uppercase">
                    {new Date(day.date).toLocaleDateString('fr-FR', { weekday: 'long' })}
                  </div>
                  <div className="text-xs">
                    {new Date(day.date).toLocaleDateString('fr-FR', { 
                      day: 'numeric', 
                      month: 'long', 
                      year: 'numeric' 
                    })}
                  </div>
                </div>
                
                {/* Colonne droite : Heures */}
                <div className="relative flex-1" style={{ width: totalWidth, minHeight: '40px' }}>
                  {timelineHours.map(({ hour, label, left }) => (
                    <div
                      key={`${day.id}-hour-${hour}`}
                      className="absolute text-xs font-bold text-violet-700"
                      style={{ left: left - 24, width: 48 }}
                    >
                      {label}
                    </div>
                  ))}
                </div>
              </div>
              
              {/* Scènes de ce jour */}
              {sortedStages.map((stage) => (
                <div key={`${day.id}-${stage.id}`} className="flex">
                  {/* Nom de la scène */}
                  <div style={{ width: STAGE_COLUMN_WIDTH }}>
                    {stage.name}
                    <div className="text-xs">
                      {stage.type && <span>{stage.type}</span>}
                      {stage.capacity && <span>{stage.capacity} pers.</span>}
                    </div>
                  </div>
                  
                  {/* Zone de performances */}
                  <div className="relative" style={{ width: totalWidth, height: ROW_HEIGHT }}>
                    {/* Lignes verticales (heures) */}
                    {timelineHours.map(({ hour, left }) => (
                      <div
                        key={hour}
                        className="absolute h-full border-r"
                        style={{ left }}
                      />
                    ))}
                    
                    {/* Performances */}
                    {performances
                      .filter(p => p.event_day_id === day.id && p.stage_id === stage.id)
                      .map((perf) => (
                        <div
                          key={perf.id}
                          style={{ 
                            left: calculateLeft(perf), 
                            width: calculateWidth(perf) 
                          }}
                        >
                          <PerformanceCard performance={perf} />
                        </div>
                      ))}
                  </div>
                </div>
              ))}
            </div>
          ))}
        </div>
      </div>
    </DndContext>
  );
}
```

---

## 🎯 **Logique de calcul**

### **Amplitude horaire globale**
```tsx
const { globalStartHour, totalHours } = useMemo(() => {
  let minHour = 24;
  let maxHour = 0;

  days.forEach(day => {
    const openHour = parseInt(day.open_time?.split(':')[0] || '18');
    const closeHour = parseInt(day.close_time?.split(':')[0] || '4');
    
    minHour = Math.min(minHour, openHour);
    
    if (closeHour < openHour) {
      maxHour = Math.max(maxHour, closeHour + 24);
    } else {
      maxHour = Math.max(maxHour, closeHour);
    }
  });

  // +1h avant et +1h après
  const startWithMargin = minHour - 1;
  const endWithMargin = maxHour + 1;
  
  return { 
    globalStartHour: startWithMargin, 
    totalHours: endWithMargin - startWithMargin 
  };
}, [days]);
```

**Exemple** :
- Jour 1 : 18:00 → 02:00
- Jour 2 : 16:00 → 03:00
- **Amplitude globale** : 15:00 → 04:00 (15h à 4h du matin)
- **Heures affichées** : 15:00, 16:00, 17:00, ..., 23:00, 00:00, 01:00, 02:00, 03:00, 04:00

### **Génération des heures**
```tsx
const timelineHours = useMemo(() => {
  const hours = [];
  for (let i = 0; i <= totalHours; i++) {
    const hour = (globalStartHour + i) % 24;
    hours.push({
      hour,
      label: `${hour.toString().padStart(2, '0')}:00`,
      left: i * HOUR_WIDTH,
    });
  }
  return hours;
}, [globalStartHour, totalHours, HOUR_WIDTH]);
```

---

## ✅ **Tests d'acceptation**

### Test 1 : Pas de sticky
1. Ouvrir la timeline
2. Scroller vers le bas
3. ✅ **Vérifier** : Pas de header sticky en haut

### Test 2 : Heures par jour
1. Observer la structure
2. ✅ **Vérifier** : Chaque jour a sa propre ligne d'heures

### Test 3 : Heures répétées
1. Comparer les lignes de jours
2. ✅ **Vérifier** : Mêmes heures affichées pour chaque jour

### Test 4 : Alignement
1. Observer les heures et les lignes verticales
2. ✅ **Vérifier** : Heures centrées sur les lignes verticales

### Test 5 : Amplitude dynamique
1. Créer un événement avec différents horaires par jour
2. ✅ **Vérifier** : Amplitude = min(open_time) - 1h → max(close_time) + 1h

---

## 🚀 **Résultat**

✅ **Header sticky supprimé** : Plus de problèmes de sticky
✅ **Heures par jour** : Affichées sur chaque ligne de jour
✅ **Heures répétées** : Contexte temporel toujours visible
✅ **Code simplifié** : Moins de complexité, plus de clarté
✅ **Performance** : Meilleure performance, pas de calculs sticky

**La timeline est maintenant plus simple et plus claire ! 🎨✨**

