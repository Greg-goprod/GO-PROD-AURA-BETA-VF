# 🖥️ Timeline - Mode Full-Width (Sans Sidebar)

## 🎯 Objectif

La Timeline a été transformée en **page spéciale** qui s'ouvre en **pleine largeur** sans sidebar, optimisée pour afficher le maximum d'informations sur un seul écran.

---

## ✅ Modifications effectuées

### 1. **Pas de sidebar** 🚫

La page `LineupTimelinePage` a maintenant son **propre layout** :

```tsx
<div className="min-h-screen flex flex-col bg-gray-50 dark:bg-gray-900">
  {/* TopBar globale uniquement */}
  <TopBar />
  
  {/* Header Timeline avec bouton retour */}
  <div className="bg-white dark:bg-gray-800 border-b ...">
    {/* Header content */}
  </div>
  
  {/* Contenu principal - FULL WIDTH */}
  <div className="flex-1 p-6 space-y-4 overflow-hidden">
    {/* Timeline */}
  </div>
</div>
```

✅ **Avantages** :
- Gain d'espace : ~280px (largeur sidebar)
- Plus de place pour afficher les heures
- Interface épurée pour focus booking

---

### 2. **Bouton "Retour Booking"** ◀️

Bouton en haut à gauche pour retourner à la page Booking :

```tsx
<Button
  variant="secondary"
  size="sm"
  onClick={() => navigate('/app/administration/booking')}
  className="flex items-center gap-2"
>
  <ArrowLeft className="w-4 h-4" />
  Retour Booking
</Button>
```

**Route** : `/app/administration/booking`

---

### 3. **Timeline 100% Responsive** 📐

La Timeline calcule maintenant **dynamiquement** la largeur des heures pour s'adapter à la taille de l'écran.

#### Avant (fixe)
```tsx
const HOUR_WIDTH = 130; // Fixe
const totalWidth = totalHours * HOUR_WIDTH; // Pouvait dépasser l'écran
```

#### Après (dynamique)
```tsx
// 1. Mesurer la largeur du container
const containerRef = useRef<HTMLDivElement>(null);
const [containerWidth, setContainerWidth] = useState(0);

useEffect(() => {
  const updateWidth = () => {
    if (containerRef.current) {
      setContainerWidth(containerRef.current.offsetWidth);
    }
  };
  
  updateWidth();
  window.addEventListener('resize', updateWidth);
  return () => window.removeEventListener('resize', updateWidth);
}, []);

// 2. Calculer la largeur d'une heure
const HOUR_WIDTH = useMemo(() => {
  if (containerWidth === 0 || totalHours === 0) return 130;
  
  const availableWidth = containerWidth - STAGE_COLUMN_WIDTH - 32;
  const calculatedWidth = Math.max(availableWidth / totalHours, 80); // Min 80px
  
  return calculatedWidth;
}, [containerWidth, totalHours]);
```

#### Résultat
- ✅ **Pas de scroll horizontal**
- ✅ **S'adapte à toutes les tailles d'écran**
- ✅ **Largeur minimale garantie** (80px/heure)
- ✅ **Responsive en temps réel** (resize)

---

## 📊 Formule de calcul

```
HOUR_WIDTH = (Largeur écran - Largeur colonne scènes - Padding) / Nombre d'heures
```

**Exemple** :
- Écran : 1920px
- Colonne scènes : 192px
- Padding : 32px
- Nombre d'heures : 10

```
HOUR_WIDTH = (1920 - 192 - 32) / 10 = 169.6px
```

---

## 🎨 Structure visuelle

```
┌────────────────────────────────────────────────────────────┐
│ TopBar (Event Selector, Search, Notifications, Theme)     │
├────────────────────────────────────────────────────────────┤
│ [◀ Retour Booking] Timeline Booking  [Mode démo] [+ Perf] │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  [Cartes KPI - responsive grid]                           │
│  Vendredi | Samedi | ... | Taux de change                 │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │ Timeline Grid (100% width, no scroll)               │ │
│  │                                                      │ │
│  │ Horaires  18:00  19:00  20:00  ...  04:00          │ │
│  │ ────────────────────────────────────────────────── │ │
│  │ Vendredi                                            │ │
│  │   Scène 1  [Performance 1] [Performance 2]         │ │
│  │   Scène 2       [Performance 3]                    │ │
│  │ Samedi                                              │ │
│  │   Scène 1  [Performance 4]                         │ │
│  │   Scène 2            [Performance 5]               │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 🔧 Paramètres techniques

### Constantes
```tsx
STAGE_COLUMN_WIDTH = 192px  // Largeur colonne scènes (w-48)
ROW_HEIGHT = 72px           // Hauteur ligne scène
MIN_HOUR_WIDTH = 80px       // Largeur minimale par heure
DEFAULT_HOUR_WIDTH = 130px  // Largeur par défaut (fallback)
```

### Calculs dynamiques
```tsx
availableWidth = containerWidth - STAGE_COLUMN_WIDTH - PADDING
HOUR_WIDTH = max(availableWidth / totalHours, MIN_HOUR_WIDTH)
MINUTE_WIDTH = HOUR_WIDTH / 60
totalWidth = totalHours * HOUR_WIDTH
```

---

## 📱 Support des écrans

### Desktop (1920x1080)
- ✅ HOUR_WIDTH ≈ 170px
- ✅ Toutes les heures visibles
- ✅ Cartes performances lisibles

### Laptop (1366x768)
- ✅ HOUR_WIDTH ≈ 120px
- ✅ Toutes les heures visibles
- ✅ Cartes performances compactes

### Tablet (1024x768)
- ✅ HOUR_WIDTH ≈ 80px (minimum)
- ✅ Toutes les heures visibles
- ⚠️ Cartes performances très compactes

### Mobile
- ❌ **Non supporté** (comme spécifié)
- Largeur minimale requise : 800px

---

## 🚀 Avantages

### Avant (avec sidebar)
```
Largeur utile = 1920px - 280px (sidebar) = 1640px
10 heures × 130px = 1300px
→ Scroll horizontal sur petits écrans
```

### Après (sans sidebar)
```
Largeur utile = 1920px - 192px (scènes) = 1728px
10 heures × (1728 / 10) = 172.8px par heure
→ Pas de scroll, tout visible
```

**Gain d'espace** : +280px (17% de largeur en plus)

---

## 🔄 Gestion du resize

Le composant écoute les événements `resize` pour recalculer automatiquement :

```tsx
useEffect(() => {
  const updateWidth = () => {
    if (containerRef.current) {
      setContainerWidth(containerRef.current.offsetWidth);
    }
  };
  
  updateWidth();
  window.addEventListener('resize', updateWidth);
  
  // Retry après 100ms pour être sûr que le DOM est prêt
  setTimeout(updateWidth, 100);
  
  return () => window.removeEventListener('resize', updateWidth);
}, []);
```

---

## 🎯 Tests recommandés

### Responsive
- [ ] Tester sur écran 1920x1080 (Desktop)
- [ ] Tester sur écran 1366x768 (Laptop)
- [ ] Tester resize de fenêtre en temps réel
- [ ] Vérifier qu'il n'y a **jamais** de scroll horizontal

### Navigation
- [ ] Cliquer "Retour Booking" → Retour à `/app/administration/booking`
- [ ] TopBar fonctionne (Event Selector, Search, etc.)
- [ ] Changement d'événement → Timeline se met à jour

### Timeline
- [ ] Toutes les heures visibles sans scroll
- [ ] Performances positionnées correctement
- [ ] Drag & Drop fonctionne
- [ ] Cartes lisibles (texte, montants, icônes)

### Performance
- [ ] Pas de lag lors du resize
- [ ] Recalcul rapide (< 100ms)
- [ ] Pas de flickering

---

## 📁 Fichiers modifiés

### `src/pages/LineupTimelinePage.tsx`
✅ Layout full-width sans sidebar  
✅ Bouton "Retour Booking"  
✅ TopBar intégrée  
✅ Header custom  

### `src/features/timeline/components/TimelineGrid.tsx`
✅ Calcul dynamique HOUR_WIDTH  
✅ useRef pour mesurer container  
✅ useEffect pour écouter resize  
✅ Suppression overflow-x-auto  
✅ Largeurs fixes → largeurs dynamiques  

---

## 💡 Notes importantes

### Pourquoi pas de scroll horizontal ?

L'objectif est d'avoir une **vue d'ensemble complète** de la timeline sans avoir à scroller. Cela permet :
- Vision globale de tous les créneaux horaires
- Comparaison facile entre jours/scènes
- Meilleure UX pour le booking

### Largeur minimale par heure

La largeur minimale de **80px par heure** garantit que :
- Les cartes de performances restent lisibles
- Le nom de l'artiste est visible
- Les icônes d'actions sont cliquables

### Fallback

Si `containerWidth` n'est pas encore calculé (premier render), la valeur par défaut de **130px** est utilisée.

---

## 🔮 Améliorations futures

1. **Mode zoom** : Boutons +/- pour ajuster manuellement HOUR_WIDTH
2. **Mode compact** : Réduire ROW_HEIGHT pour voir plus de scènes
3. **Fullscreen** : Mode plein écran (F11) pour encore plus d'espace
4. **Print-friendly** : Export PDF avec layout optimisé

---

## 🎉 Résultat

✅ **Pas de sidebar** : +280px d'espace  
✅ **Bouton retour** : Navigation fluide  
✅ **100% responsive** : S'adapte à tous les écrans  
✅ **Pas de scroll horizontal** : Vue d'ensemble complète  
✅ **Layout full-width** : Timeline optimisée  

**Page spéciale dédiée au booking visuel ! 🎨✨**

