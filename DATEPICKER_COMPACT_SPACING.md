# DatePicker - Réduction espacement et taille des pastilles

## 🎯 Objectif
Réduire l'espacement vertical des dates et la taille des pastilles de sélection pour éviter les problèmes de débordement et améliorer la compacité.

## ✅ Modifications appliquées

### 1. Taille des pastilles (src/styles/pickers.css)

**Avant :**
```css
.calendar-day-round {
  width: 32px;
  height: 32px;
  font-size: 11px;
}
```

**Après :**
```css
.calendar-day-round {
  width: 26px;
  height: 26px;
  font-size: 10px;
}
```

**Réduction :** 32px → 26px (18.75% plus petit)

---

### 2. Effets de survol et sélection

**Avant :**
```css
.calendar-day-round:hover {
  transform: scale(1.08);
}

.calendar-day-round.selected {
  transform: scale(1.12);
  box-shadow: 0 0 10px color-mix(in srgb, var(--color-primary) 60%, transparent);
}
```

**Après :**
```css
.calendar-day-round:hover {
  transform: scale(1.05);
}

.calendar-day-round.selected {
  transform: scale(1.08);
  box-shadow: 0 0 8px color-mix(in srgb, var(--color-primary) 50%, transparent);
}
```

**Optimisations :**
- Scale hover : 1.08 → 1.05 (effet plus subtil)
- Scale selected : 1.12 → 1.08 (moins d'agrandissement)
- Box-shadow : 10px + 60% → 8px + 50% (plus discret)

---

### 3. Espacement vertical dans les grilles

#### DateRangePickerAura.tsx

**Avant :**
```tsx
<div className="grid grid-cols-7 gap-0.5 mb-1">
  {/* En-têtes des jours */}
</div>
<div className="grid grid-cols-7 gap-0.5">
  {/* Grille des dates */}
</div>
```

**Après :**
```tsx
<div className="grid grid-cols-7 gap-0 mb-0.5">
  {/* En-têtes des jours */}
</div>
<div className="grid grid-cols-7 gap-0">
  {/* Grille des dates */}
</div>
```

#### DatePickerAura.tsx

**Même modification appliquée pour cohérence**

**Optimisations :**
- Gap entre colonnes : `gap-0.5` (2px) → `gap-0` (0px)
- Marge bottom : `mb-1` (4px) → `mb-0.5` (2px)

---

## 📊 Impact visuel

### Avant
- **Pastilles** : 32x32px
- **Espacement horizontal** : 2px entre les colonnes
- **Espacement vertical** : 2px entre les lignes
- **Total hauteur grille (6 lignes)** : ~240px

### Après
- **Pastilles** : 26x26px
- **Espacement horizontal** : 0px (pastilles côte à côte)
- **Espacement vertical** : 0px (pastilles côte à côte)
- **Total hauteur grille (6 lignes)** : ~156px

**Réduction totale de hauteur : ~35%**

---

## 🎨 Avantages

✅ **Compacité** : Le calendrier prend moins de place verticalement  
✅ **Lisibilité** : Taille de police ajustée (10px reste lisible)  
✅ **Cohérence** : Même style dans DatePickerAura et DateRangePickerAura  
✅ **Performance** : Effets de hover/scale plus légers  
✅ **Responsive** : Moins de risque de débordement sur petits écrans  

---

## 📦 Fichiers modifiés

| Fichier | Modifications |
|---------|--------------|
| `src/styles/pickers.css` | Taille pastilles, scale, shadow |
| `src/components/ui/DateRangePickerAura.tsx` | Gap et marges |
| `src/components/ui/DatePickerAura.tsx` | Gap et marges |

---

**Date de modification** : 28 octobre 2025  
**Tests** : ✅ Lint OK  
**Statut** : ✅ Prêt pour test visuel


