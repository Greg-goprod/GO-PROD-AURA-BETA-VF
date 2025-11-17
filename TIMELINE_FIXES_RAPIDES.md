# 🔧 Timeline - Corrections rapides

## 🐛 Problèmes identifiés et corrigés

### 1. **Import TopBar incorrect**

#### Erreur
```tsx
import { TopBar } from "../components/topbar/TopBar"; // ❌
```

**Message d'erreur** : `The requested module '/src/components/topbar/TopBar.tsx' does not provide an export named 'TopBar'`

#### Cause
`TopBar` est un **export par défaut** (`export default function TopBar()`), pas un export nommé.

#### Correction
```tsx
import TopBar from "../components/topbar/TopBar"; // ✅
```

---

### 2. **JSX incomplet (balise non fermée)**

#### Erreur
```tsx
<div className="flex-1 p-6 space-y-4 overflow-hidden">
  {/* Résumé quotidien */}
  <DailySummaryCards ... />
  
  {/* Grille timeline */}
  <Card>...</Card>

{/* Modaux */}  // ❌ Pas de fermeture </div>
```

**Message d'erreur** : `Unterminated JSX contents. (547:10)`

#### Cause
Le `<div>` du "Contenu principal" n'était jamais fermé avant les modaux.

#### Correction
```tsx
<div className="flex-1 p-6 space-y-4 overflow-hidden">
  {/* Résumé quotidien */}
  <DailySummaryCards ... />
  
  {/* Grille timeline */}
  <Card>...</Card>
</div>  // ✅ Fermeture ajoutée

{/* Modaux */}
```

---

### 3. **HOUR_WIDTH référencé avant définition**

#### Erreur
```tsx
const MINUTE_WIDTH = HOUR_WIDTH / 60;  // ❌ HOUR_WIDTH pas encore défini
const totalWidth = totalHours * HOUR_WIDTH;  // ❌

const timelineHours = useMemo(() => {
  // ... utilise HOUR_WIDTH
}, [globalStartHour, totalHours, HOUR_WIDTH]);

const HOUR_WIDTH = useMemo(() => {  // ❌ Défini APRÈS utilisation
  // ...
}, [containerWidth, totalHours]);
```

**Message d'erreur** : `ReferenceError: HOUR_WIDTH is not defined`

#### Cause
`HOUR_WIDTH` était calculé dans un `useMemo`, mais il était référencé dans :
1. `MINUTE_WIDTH = HOUR_WIDTH / 60` (avant la définition)
2. `totalWidth = totalHours * HOUR_WIDTH` (avant la définition)
3. `timelineHours` (dans un autre `useMemo`)

#### Correction
Réorganiser l'ordre pour que `HOUR_WIDTH` soit calculé en PREMIER, puis utilisé :

```tsx
// 1. D'abord calculer HOUR_WIDTH
const HOUR_WIDTH = useMemo(() => {
  if (containerWidth === 0 || totalHours === 0) return 130;
  const availableWidth = containerWidth - STAGE_COLUMN_WIDTH - 32;
  const calculatedWidth = Math.max(availableWidth / totalHours, 80);
  return calculatedWidth;
}, [containerWidth, totalHours]);

// 2. Ensuite calculer timelineHours (dépend de HOUR_WIDTH)
const timelineHours = useMemo(() => {
  const hours = [];
  for (let i = 0; i <= totalHours; i++) {
    const hour = (globalStartHour + i) % 24;
    hours.push({
      hour,
      label: `${hour.toString().padStart(2, '0')}:00`,
      left: i * HOUR_WIDTH,  // ✅ Maintenant défini
    });
  }
  return hours;
}, [globalStartHour, totalHours, HOUR_WIDTH]);

// 3. Enfin calculer les dérivés
const MINUTE_WIDTH = HOUR_WIDTH / 60;  // ✅ Maintenant défini
const totalWidth = totalHours * HOUR_WIDTH;  // ✅ Maintenant défini
```

---

## 📊 Ordre correct des dépendances

### Avant (❌ Erreur)
```
1. MINUTE_WIDTH (utilise HOUR_WIDTH)
2. totalWidth (utilise HOUR_WIDTH)
3. timelineHours (utilise HOUR_WIDTH)
4. HOUR_WIDTH (défini APRÈS)
```

### Après (✅ Correct)
```
1. HOUR_WIDTH (calculé en premier)
2. timelineHours (utilise HOUR_WIDTH)
3. MINUTE_WIDTH (utilise HOUR_WIDTH)
4. totalWidth (utilise HOUR_WIDTH)
```

---

## 🎯 Règles à respecter

### Export/Import
- ✅ Vérifier si c'est un export `default` ou `named`
- ✅ Adapter l'import en conséquence

### JSX
- ✅ Toujours fermer les balises ouvertes
- ✅ Indentation correcte pour détecter les erreurs
- ✅ Vérifier les `{` et `}` qui correspondent

### useMemo/Variables
- ✅ Définir les variables AVANT de les utiliser
- ✅ Les `useMemo` doivent être dans l'ordre de dépendance
- ✅ Si B dépend de A, A doit être défini avant B

---

## ✅ Résultat

Toutes les erreurs ont été corrigées :
- ✅ Import TopBar corrigé
- ✅ JSX complet et valide
- ✅ HOUR_WIDTH dans le bon ordre
- ✅ Pas d'erreurs de lint

**La Timeline est maintenant fonctionnelle ! 🎉**

