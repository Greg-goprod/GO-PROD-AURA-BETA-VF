# ⏰ Timeline - Heures Sticky et Centrées

## 🎯 **Modifications appliquées**

### 1. ✅ **Bouton "Retour Booking" intelligent**
**Comportement** :
- Si ouvert dans un **nouvel onglet** → **Ferme l'onglet** (`window.close()`)
- Si navigation normale → **Retour à la page précédente** (`navigate(-1)`)

```tsx
<Button
  onClick={() => {
    if (window.history.length <= 1 || document.referrer === '') {
      window.close(); // Fermer l'onglet
    } else {
      navigate(-1); // Retour arrière
    }
  }}
>
  <ArrowLeft /> Retour Booking
</Button>
```

---

### 2. ✅ **Amplitude horaire +1h avant/après**
**Avant** : Timeline de `open_time` à `close_time`
**Après** : Timeline de `open_time - 1h` à `close_time + 1h`

**Exemple** :
- Ouverture : 18:00
- Fermeture : 02:00
- **Amplitude timeline** : **17:00** → **03:00**

```tsx
// Ajouter 1 heure avant et 1 heure après
const startWithMargin = minHour - 1;
const endWithMargin = maxHour + 1;
const totalHrs = endWithMargin - startWithMargin;
```

---

### 3. ✅ **Header des heures : Sticky + Centré sur les lignes**

#### **Avant (❌)**
```
┌────────────────────────────────────────────────┐
│ 17:00 │ 18:00 │ 19:00 │ 20:00 │ 21:00 │       │  ← Scroll avec le contenu
│   |       |       |       |       |             │  ← Labels à gauche
└────────────────────────────────────────────────┘
```

#### **Après (✅)**
```
┌────────────────────────────────────────────────┐
│   17:00   18:00   19:00   20:00   21:00       │  ← STICKY (toujours visible)
│     |       |       |       |       |          │  ← Labels CENTRÉS sur lignes
└────────────────────────────────────────────────┘
│ Scène 1  [██ Perf ██]                          │
│ Scène 2      [██ Perf ██]                      │
│     |       |       |       |       |          │  ← Lignes alignées
```

---

## 🔧 **Implémentation technique**

### **Header Sticky**

```tsx
<div className="sticky top-0 bg-white dark:bg-gray-900 z-20 shadow-sm">
  <div className="relative bg-gray-50 dark:bg-gray-800/50">
    {/* 1. Lignes verticales (border-r-2 violet) */}
    {timelineHours.map(({ hour, left }) => (
      <div
        key={`line-${hour}`}
        className="absolute top-0 h-full border-r-2 border-violet-300 dark:border-violet-700"
        style={{ left }}
      />
    ))}
    
    {/* 2. Labels CENTRÉS sur les lignes */}
    {timelineHours.map(({ hour, label, left }) => (
      <div
        key={`label-${hour}`}
        className="absolute top-0 h-full text-xs font-bold text-violet-700 dark:text-violet-300 flex items-center justify-center"
        style={{ 
          left: left - 24, // Décalage pour centrer (-24px = moitié de 48px)
          width: 48 
        }}
      >
        {label}
      </div>
    ))}
  </div>
</div>
```

### **Lignes verticales alignées dans les cellules**

```tsx
{/* Grille verticale - alignée avec le header */}
{timelineHours.map(({ hour, left }) => (
  <div
    key={hour}
    className="absolute top-0 h-full border-r border-violet-200 dark:border-violet-800/50"
    style={{ left }}
  />
))}
```

---

## 🎨 **Résultat visuel**

### **Header Sticky**
```
┌─────────────────────────────────────────────────────────────┐
│ HORAIRES │   17:00   18:00   19:00   20:00   21:00   22:00 │ ← STICKY
│          │     |       |       |       |       |       |    │   Always visible
├──────────┴─────┼───────┼───────┼───────┼───────┼───────────┤
│ VENDREDI 31 OCT. 2025  (18:00 → 02:00)                      │
├─────────────────────────────────────────────────────────────┤
│ Scène 1  │  [██ Artiste 1 ██]    [██ Artiste 2 ██]         │
│ (5000p.) │     |       |       |       |       |       |    │
├──────────┼─────┼───────┼───────┼───────┼───────┼───────────┤
│ Scène 2  │           [██ Artiste 3 ██]                      │
│ (2000p.) │     |       |       |       |       |       |    │
├──────────┼─────┼───────┼───────┼───────┼───────┼───────────┤
│ Scène 3  │  [██ Artiste 4 ██]                               │
│ (800p.)  │     |       |       |       |       |       |    │
└──────────┴─────┴───────┴───────┴───────┴───────┴───────────┘
│ SAMEDI 1 NOV. 2025  (18:00 → 02:00)                         │
├─────────────────────────────────────────────────────────────┤
│ Scène 1  │              [██ Artiste 5 ██]                   │
│          │     |       |       |       |       |       |    │
└──────────┴─────┴───────┴───────┴───────┴───────┴───────────┘
```

**Scroll vers le bas** → Le header des heures **reste visible en haut** ! 🎉

---

## 🎯 **Points clés**

### 1. **Sticky Header**
- `position: sticky`
- `top: 0`
- `z-index: 20` (au-dessus du contenu)
- `shadow-sm` pour marquer la séparation

### 2. **Labels centrés**
- Calcul du décalage : `left - 24px` (moitié de la largeur du label : 48px / 2)
- `pointer-events: none` pour éviter d'intercepter les clics

### 3. **Lignes verticales renforcées**
- Header : `border-r-2 border-violet-300` (épaisses)
- Cellules : `border-r border-violet-200` (fines, alignées)
- Dark mode : `border-violet-700` / `border-violet-800/50`

### 4. **Alignement parfait**
- Les lignes du header et des cellules utilisent le même `left` calculé
- Les labels sont centrés sur ces lignes
- Cohérence visuelle sur toute la hauteur de la timeline

---

## ✅ **Tests d'acceptation**

### Test 1 : Header Sticky
1. Ouvrir la timeline avec un événement multi-jours
2. Scroller vers le bas
3. ✅ **Vérifier** : Le header des heures reste visible en haut

### Test 2 : Labels centrés
1. Observer l'alignement des heures
2. ✅ **Vérifier** : Chaque label (ex: "17:00") est centré sur sa ligne verticale

### Test 3 : Lignes alignées
1. Observer les lignes verticales du header et des cellules
2. ✅ **Vérifier** : Les lignes sont parfaitement alignées sur toute la hauteur

### Test 4 : Amplitude +1h
1. Créer un événement avec ouverture 18:00, fermeture 02:00
2. ✅ **Vérifier** : La timeline affiche de **17:00** à **03:00**

### Test 5 : Retour Booking
1. Ouvrir la timeline dans un nouvel onglet (Ctrl+Click)
2. Cliquer "Retour Booking"
3. ✅ **Vérifier** : L'onglet se ferme
4. Ouvrir la timeline normalement depuis Booking
5. Cliquer "Retour Booking"
6. ✅ **Vérifier** : Retour à la page Booking

---

## 🚀 **Résultat final**

✅ **Header sticky** : Heures toujours visibles en scrollant
✅ **Labels centrés** : Lecture facile et précise
✅ **Lignes alignées** : Cohérence visuelle parfaite
✅ **Amplitude +1h** : Marge de confort avant/après l'événement
✅ **Retour intelligent** : Ferme l'onglet ou retour arrière selon le contexte

**La timeline est maintenant professionnelle et ergonomique ! 🎨✨**

