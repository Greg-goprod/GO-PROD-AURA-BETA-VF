# 🔧 Timeline - Corrections Type de Scène et Marge

## ✅ **Problèmes résolus**

### 1. **Type de scène invisible** ✓
Le type de scène n'était pas affiché sous le nom car les données n'étaient pas chargées depuis la base de données.

### 2. **Marge de 1/2 heure (pas 1h30)** ✓
L'espace entre la colonne scènes et la première heure affichée était de 1h30 au lieu de 0.5h.

---

## 🔧 **Correction 1 : Type de scène visible**

### **Problème**
Le code d'affichage était correct :
```tsx
{stage.type && (
  <div className="text-xs text-gray-500 capitalize mt-0.5">
    {stage.type}
  </div>
)}
```

Mais les données `stage.type` et `stage.capacity` n'étaient **pas récupérées** depuis la base de données.

### **Cause**
1. **Interface incomplète** : `EventStage` ne contenait pas `type` et `capacity`
2. **Requête SQL incomplète** : `fetchEventStages` ne sélectionnait pas ces champs

### **Solution**

#### **A. Interface mise à jour**
```tsx
// Avant
export interface EventStage {
  id: string;
  name: string;
  display_order: number;
}

// Après
export interface EventStage {
  id: string;
  name: string;
  type: string | null;        // ✅ Ajouté
  capacity: number | null;    // ✅ Ajouté
  display_order: number;
}
```

#### **B. Requête SQL mise à jour**
```tsx
// Avant
.select("id, name, display_order")

// Après
.select("id, name, type, capacity, display_order")  // ✅ type, capacity ajoutés
```

### **Résultat**
```
┌──────────────────────────┐
│ ● Scène Principale       │ ← Nom
│   Main                   │ ← Type visible !
└──────────────────────────┘
```

---

## 🔧 **Correction 2 : Marge de 1/2 heure (pas 1h30)**

### **Problème**
L'espace entre la colonne scènes et la première heure affichée était de **1h30** au lieu de **0.5h**.

```
┌────────────────┬──────────┬──────────────────────┐
│ Scènes         │ 1h30     │ 16:00  17:00  18:00 │
│                │ (trop!)  │                      │
└────────────────┴──────────┴──────────────────────┘
```

### **Cause**
1. **globalStartHour** était calculé avec `minHour - 1` (1h avant l'open_time)
2. **Première heure non affichée** : La boucle commençait à `i=1` pour ne pas afficher `globalStartHour`
3. **Résultat** : Espace = MARGIN_LEFT (0.5h) + Espace pour globalStartHour (1h) = **1.5h**

### **Solution**

#### **A. globalStartHour = minHour (pas minHour - 1)**
```tsx
// Avant
const startWithMargin = minHour - 1;  // ❌ 1h avant

// Après
const startWithMargin = minHour;      // ✅ À partir de open_time
```

#### **B. Afficher toutes les heures (boucle commence à i=0)**
```tsx
// Avant
for (let i = 1; i <= totalHours; i++) {  // ❌ Commence à 1 (skip première heure)
  left: MARGIN_LEFT + (i * HOUR_WIDTH)
}

// Après
for (let i = 0; i < totalHours; i++) {   // ✅ Commence à 0 (toutes les heures)
  left: MARGIN_LEFT + (i * HOUR_WIDTH)
}
```

### **Résultat**
```
┌────────────────┬────┬──────────────────────────────┐
│ Scènes         │0.5h│ 15:00  16:00  17:00  18:00  │
│                │    │                              │
└────────────────┴────┴──────────────────────────────┘
                  ↑
               1/2 heure seulement !
```

---

## 📊 **Comparaison Avant/Après**

### **Avant**
```
┌────────────────┬──────────────┬─────────────────────────┐
│ VENDREDI       │              │ 16:00  17:00  18:00    │
│ 31 octobre     │   1h30       │                         │
├────────────────┼──────────────┼─────────────────────────┤
│ ● Scène Princ. │ (trop large) │ [██ Perf ██]            │
│   (pas de type)│              │                         │
└────────────────┴──────────────┴─────────────────────────┘
```

**Problèmes** :
- ❌ Type de scène non visible
- ❌ Marge de 1h30 (trop large)
- ❌ Première heure (15:00) non affichée

### **Après**
```
┌────────────────┬────┬─────────────────────────────────┐
│ VENDREDI       │    │ 15:00  16:00  17:00  18:00     │
│ 31 octobre     │0.5h│                                 │
├────────────────┼────┼─────────────────────────────────┤
│ ● Scène Princ. │    │ [██ Perf ██]                    │
│   main         │    │                                 │
└────────────────┴────┴─────────────────────────────────┘
```

**Améliorations** :
- ✅ Type de scène visible ("main")
- ✅ Marge de 0.5h (juste)
- ✅ Toutes les heures affichées (à partir de open_time)

---

## 🎯 **Détails techniques**

### **Calcul de l'amplitude**
```tsx
// AVANT : Commencer 1h avant open_time
const startWithMargin = minHour - 1;  // Si open_time = 15:00 → start = 14:00
const totalHrs = endWithMargin - startWithMargin;  // Ex: 14h

// Boucle d'affichage (skip première heure)
for (let i = 1; i <= totalHours; i++) {
  // i=1 → hour = 15:00, left = MARGIN_LEFT + (1 * HOUR_WIDTH) = 0.5h + 1h = 1.5h
}
```

```tsx
// APRÈS : Commencer à open_time
const startWithMargin = minHour;  // Si open_time = 15:00 → start = 15:00
const totalHrs = endWithMargin - startWithMargin;  // Ex: 13h

// Boucle d'affichage (toutes les heures)
for (let i = 0; i < totalHours; i++) {
  // i=0 → hour = 15:00, left = MARGIN_LEFT + (0 * HOUR_WIDTH) = 0.5h
}
```

### **Position de la première heure**

| Version | globalStartHour | Première heure affichée | Position | Espace total |
|---------|-----------------|-------------------------|----------|--------------|
| **Avant** | 14:00 (open-1h) | 15:00 (i=1) | `0.5h + 1h` | **1.5h** |
| **Après** | 15:00 (open) | 15:00 (i=0) | `0.5h + 0h` | **0.5h** |

---

## 📁 **Fichiers modifiés**

### **1. `src/features/timeline/timelineApi.ts`**

#### **Interface `EventStage`**
```diff
export interface EventStage {
  id: string;
  name: string;
+ type: string | null;
+ capacity: number | null;
  display_order: number;
}
```

#### **Fonction `fetchEventStages`**
```diff
const { data, error } = await supabase
  .from("event_stages")
- .select("id, name, display_order")
+ .select("id, name, type, capacity, display_order")
  .eq("event_id", eventId)
  .order("display_order", { ascending: true });
```

### **2. `src/features/timeline/components/TimelineGrid.tsx`**

#### **Calcul de globalStartHour**
```diff
- const startWithMargin = minHour - 1;
+ const startWithMargin = minHour;
  const endWithMargin = maxHour + 1;
```

#### **Génération des heures affichées**
```diff
const timelineHours = useMemo(() => {
  const hours = [];
- for (let i = 1; i <= totalHours; i++) {
+ for (let i = 0; i < totalHours; i++) {
-   const hour = (globalStartHour + i) % 24;
+   const hour = (globalStartHour + i) % 24;
    hours.push({
      hour,
      label: `${hour.toString().padStart(2, '0')}:00`,
-     left: MARGIN_LEFT + (i * HOUR_WIDTH),
+     left: MARGIN_LEFT + (i * HOUR_WIDTH),
      index: i,
    });
  }
  return hours;
}, [globalStartHour, totalHours, HOUR_WIDTH, MARGIN_LEFT]);
```

---

## ✅ **Tests d'acceptation**

### Test 1 : Type de scène visible
1. Ouvrir la timeline
2. Observer la colonne des scènes
3. ✅ **Vérifier** : Le type est affiché sous le nom (ex: "Main", "Club")
4. ✅ **Vérifier** : Le type est capitalisé (première lettre en majuscule)

### Test 2 : Marge de 1/2 heure
1. Ouvrir la timeline
2. Mesurer l'espace entre la colonne scènes et la première heure affichée
3. ✅ **Vérifier** : Espace = HOUR_WIDTH / 2 (environ 60-65px)
4. ✅ **Vérifier** : PAS 1h30 (195px)

### Test 3 : Première heure affichée
1. Observer la première heure affichée
2. ✅ **Vérifier** : Correspond à l'open_time de l'événement (ex: 15:00)
3. ✅ **Vérifier** : Pas 1h après (ex: pas 16:00)

### Test 4 : Performances correctement positionnées
1. Observer les cartes de performances
2. ✅ **Vérifier** : Les performances sont alignées avec les heures affichées
3. ✅ **Vérifier** : Les performances à 15:00 sont visibles

### Test 5 : Lignes d'amplitude correctes
1. Observer les lignes violettes épaisses (open_time, close_time)
2. ✅ **Vérifier** : Elles sont alignées avec les heures correspondantes
3. ✅ **Vérifier** : La zone d'amplitude est correcte

---

## 🚀 **Résultat final**

### ✅ **Type de scène**
- Interface `EventStage` mise à jour
- Requête SQL complète
- Affichage visible sous le nom

### ✅ **Marge de 1/2 heure**
- globalStartHour = open_time (pas open_time - 1h)
- Toutes les heures affichées (i=0)
- Espace = 0.5h (pas 1.5h)

### ✅ **Cohérence visuelle**
```
┌────────────────┬────┬─────────────────────────────────┐
│ VENDREDI       │    │ 15:00  16:00  17:00  18:00     │
│ 31 oct. 2025   │0.5h│                                 │
├────────────────┼────┼─────────────────────────────────┤
│ ● Scène Princ. │    │ ║║[██ Perf ██]                ║║│
│   main         │    │ ║║                            ║║│
├────────────────┼────┼─────────────────────────────────┤
│ ● Scène Club   │    │ ║║         [██ Perf ██]       ║║│
│   club         │    │ ║║                            ║║│
└────────────────┴────┴─────────────────────────────────┘
   Colonne 1      0.5h          Timeline
   (240px)        Marge
```

**La timeline affiche maintenant correctement le type de scène et la marge de 1/2 heure ! 🎭📏✨**

