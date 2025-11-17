# 🎨 Timeline - Améliorations UI/UX

## ✅ **Modifications appliquées**

### 1. **Suppression du texte "HORAIRES"**
**Avant** : Texte "HORAIRES" affiché dans la colonne de gauche du header
**Après** : Colonne vide (plus épuré)

```
AVANT                          APRÈS
┌──────────┬─────────────┐    ┌─────────┬─────────────┐
│ HORAIRES │ 17:00 18:00 │    │         │ 17:00 18:00 │
└──────────┴─────────────┘    └─────────┴─────────────┘
```

---

### 2. **Date à côté du jour (sur une seule ligne)**
**Avant** : Jour et date sur 2 lignes séparées
**Après** : Jour et date côte à côte sur une seule ligne

```jsx
// Avant
<div>
  <div>VENDREDI</div>
  <div>31 octobre 2025</div>
</div>

// Après
<div className="flex items-center gap-2">
  <div>VENDREDI</div>
  <div>31 octobre 2025</div>
</div>
```

**Visuel** :
```
AVANT
┌────────────────────────┐
│ VENDREDI               │
│ 31 octobre 2025        │
└────────────────────────┘

APRÈS
┌────────────────────────┐
│ VENDREDI 31 octobre... │
└────────────────────────┘
```

---

### 3. **Première colonne élargie**
**Avant** : `STAGE_COLUMN_WIDTH = 192px` (w-48)
**Après** : `STAGE_COLUMN_WIDTH = 240px`

**Raison** : Permet d'afficher confortablement :
- Nom de la scène
- Type de la scène
- Capacité

---

### 4. **Ligne date/jour réduite**
**Avant** : `py-3` (padding vertical 12px)
**Après** : `py-2` (padding vertical 8px)

**Résultat** : Ligne plus compacte, moins d'espace perdu

---

### 5. **Type de scène ajouté**
**Avant** : Affichage uniquement du nom et de la capacité
**Après** : Affichage de `Nom + Type + Capacité`

```jsx
// Affichage
<div className="text-sm font-semibold">Scène Principale</div>
<div className="text-xs text-gray-500">
  {stage.type && <span className="capitalize">{stage.type}</span>}
  {stage.type && stage.capacity && <span>•</span>}
  {stage.capacity && <span>{stage.capacity} pers.</span>}
</div>
```

**Exemple visuel** :
```
┌─────────────────────────┐
│ Scène Principale        │
│ main • 5000 pers.       │
└─────────────────────────┘

┌─────────────────────────┐
│ Scène Secondaire        │
│ secondary • 2000 pers.  │
└─────────────────────────┘

┌─────────────────────────┐
│ Club                    │
│ club • 800 pers.        │
└─────────────────────────┘
```

**Police** : `text-xs` (même taille que la date du jour)

---

## 🎨 **Résultat final**

```
┌───────────────────────────────────────────────────────────────┐
│               │  17:00  18:00  19:00  20:00  21:00  22:00... │ ← Header sticky (sans "HORAIRES")
├───────────────┴───────────────────────────────────────────────┤
│ VENDREDI 31 octobre 2025  │ 18:00 → 02:00                    │ ← Date + jour (1 ligne, réduit)
├────────────────────────────┬──────────────────────────────────┤
│ Scène Principale           │ [██ Perf ██]                     │
│ main • 5000 pers.          │                                  │ ← Type ajouté
├────────────────────────────┼──────────────────────────────────┤
│ Scène Secondaire           │        [██ Perf ██]              │
│ secondary • 2000 pers.     │                                  │ ← Type ajouté
├────────────────────────────┼──────────────────────────────────┤
│ Club                       │  [██ Perf ██]                    │
│ club • 800 pers.           │                                  │ ← Type ajouté
└────────────────────────────┴──────────────────────────────────┘
```

---

## 📊 **Détails techniques**

### **Constantes**
```tsx
const STAGE_COLUMN_WIDTH = 240; // Élargie de 192px → 240px (+48px)
const ROW_HEIGHT = 72; // Inchangé
```

### **Header sticky**
```tsx
<div className="sticky top-0 z-20">
  {/* Colonne vide (sans "HORAIRES") */}
  <div style={{ width: STAGE_COLUMN_WIDTH }} />
  
  {/* Labels d'heures */}
  <div>
    {timelineHours.map(({ hour, label, left }) => (
      <div style={{ left: left - 24, width: 48 }}>
        {label}
      </div>
    ))}
  </div>
</div>
```

### **Ligne du jour**
```tsx
<div className="flex py-2"> {/* py-2 au lieu de py-3 */}
  <div className="flex items-center gap-2" style={{ width: STAGE_COLUMN_WIDTH }}>
    <div className="text-sm font-bold uppercase">VENDREDI</div>
    <div className="text-xs">31 octobre 2025</div>
  </div>
  <div className="text-xs">{day.open_time} → {day.close_time}</div>
</div>
```

### **Cellule scène**
```tsx
<div style={{ width: STAGE_COLUMN_WIDTH, height: ROW_HEIGHT }}>
  <div className="w-1 h-8 bg-violet-400 rounded-full mr-3" /> {/* Barre violette */}
  
  <div>
    <div className="text-sm font-semibold">{stage.name}</div>
    
    {/* Type + Capacité */}
    <div className="flex items-center gap-2 text-xs text-gray-500">
      {stage.type && <span className="capitalize">{stage.type}</span>}
      {stage.type && stage.capacity && <span>•</span>}
      {stage.capacity && <span>{stage.capacity} pers.</span>}
    </div>
  </div>
</div>
```

---

## 🎯 **Avantages**

### **1. Plus épuré**
- ❌ Texte "HORAIRES" supprimé (inutile, évident)
- ✅ Espace visuel mieux utilisé

### **2. Plus compact**
- ✅ Ligne date/jour réduite (`py-2` au lieu de `py-3`)
- ✅ Date à côté du jour (1 ligne au lieu de 2)
- ✅ Plus de contenu visible sans scroll

### **3. Plus informatif**
- ✅ Type de scène visible (`main`, `secondary`, `club`, etc.)
- ✅ Hiérarchie visuelle claire (nom + détails)
- ✅ Format cohérent (police `text-xs` pour type et capacité)

### **4. Plus lisible**
- ✅ Colonne élargie (240px au lieu de 192px)
- ✅ Type avec `capitalize` (première lettre en majuscule)
- ✅ Séparateur `•` entre type et capacité

---

## ✅ **Tests d'acceptation**

### Test 1 : Header épuré
1. Ouvrir la timeline
2. ✅ **Vérifier** : Pas de texte "HORAIRES" dans la colonne de gauche du header

### Test 2 : Date sur une ligne
1. Observer la ligne du jour
2. ✅ **Vérifier** : "VENDREDI 31 octobre 2025" sur une seule ligne

### Test 3 : Ligne réduite
1. Comparer la hauteur de la ligne du jour
2. ✅ **Vérifier** : Plus compacte qu'avant

### Test 4 : Colonne élargie
1. Observer la largeur de la première colonne
2. ✅ **Vérifier** : Plus large (240px au lieu de 192px)

### Test 5 : Type de scène
1. Observer les informations de chaque scène
2. ✅ **Vérifier** : Affichage de "Type • Capacité pers." en `text-xs`
3. ✅ **Vérifier** : Type avec première lettre en majuscule (`capitalize`)

---

## 🚀 **Résultat**

✅ **Header épuré** : Pas de texte "HORAIRES"
✅ **Date compacte** : Jour et date sur 1 ligne
✅ **Ligne réduite** : `py-2` au lieu de `py-3`
✅ **Colonne élargie** : 240px au lieu de 192px
✅ **Type visible** : Affiché sous le nom de la scène avec la même police que la date

**La timeline est maintenant plus épurée, compacte et informative ! 🎨✨**

