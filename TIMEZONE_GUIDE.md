# 🌍 Guide des fuseaux horaires - Go-Prod AURA

**Date** : 28 octobre 2025  
**Fuseau horaire cible** : **Europe/Paris (UTC+1/+2)**

---

## ⚠️ RÈGLE ABSOLUE

**TOUJOURS utiliser les helpers de `src/config/timezone.ts`**

```typescript
// ✅ BON
import { parseDateLocal, formatDateLocal } from '@/config/timezone';
const date = parseDateLocal('2025-10-30');

// ❌ INTERDIT
const date = new Date('2025-10-30');  // Bug timezone UTC !
```

---

## 🎯 Configuration globale

### Fuseau horaire principal

```typescript
export const APP_TIMEZONE = 'Europe/Paris';
export const APP_LOCALE = 'fr-FR';
```

**Impact** :
- Toutes les dates sont parsées en fuseau Paris
- Tous les affichages sont en français
- Pas de décalage UTC

---

## 📖 Fonctions disponibles

### 1. Parser une date (string → Date)

```typescript
import { parseDateLocal } from '@/config/timezone';

// ✅ BON - Parse en fuseau Paris
const date = parseDateLocal('2025-10-30');
// → Date locale (30 octobre 2025 00:00:00 à Paris)

// ❌ MAUVAIS - Parse en UTC
const date = new Date('2025-10-30');
// → Date UTC (peut donner 29 octobre en fuseau Paris !)
```

---

### 2. Formater une date (Date → string)

```typescript
import { formatDateLocal } from '@/config/timezone';

const date = new Date();
const dateStr = formatDateLocal(date);  // "2025-10-30"

// ❌ MAUVAIS
const dateStr = date.toISOString().split('T')[0];  // Bug UTC !
```

---

### 3. Formater en français

```typescript
import { formatDateFr } from '@/config/timezone';

// Format long
formatDateFr('2025-10-30');
// → "vendredi 30 octobre 2025"

// Format long en majuscules
formatDateFr('2025-10-30', { uppercase: true });
// → "VENDREDI 30 OCTOBRE 2025"

// Format court
formatDateFr('2025-10-30', { weekday: 'short' });
// → "ven 30 octobre 2025"
```

---

### 4. Format court français

```typescript
import { formatDateShortFr } from '@/config/timezone';

formatDateShortFr('2025-10-30');  // "30/10/2025"
```

---

### 5. Récupérer le jour de la semaine

```typescript
import { getWeekdayFr } from '@/config/timezone';

getWeekdayFr('2025-10-30');            // "vendredi"
getWeekdayFr('2025-10-30', 'short');   // "ven"
getWeekdayFr('2025-10-30', 'narrow');  // "V"
```

---

### 6. Opérations sur les dates

```typescript
import { 
  getTodayLocal, 
  addDays, 
  diffDays, 
  getDateRange 
} from '@/config/timezone';

// Aujourd'hui
const today = getTodayLocal();  // "2025-10-30"

// Ajouter des jours
addDays('2025-10-30', 2);   // "2025-11-01"
addDays('2025-10-30', -1);  // "2025-10-29"

// Différence en jours
diffDays('2025-10-30', '2025-11-01');  // 2

// Range de dates
getDateRange('2025-10-30', '2025-11-01');
// ["2025-10-30", "2025-10-31", "2025-11-01"]
```

---

### 7. Validation des heures

```typescript
import { isValidTime, formatTime } from '@/config/timezone';

isValidTime('17:00');   // true
isValidTime('25:00');   // false
isValidTime('17:60');   // false

formatTime('9:30');     // "09:30"
formatTime('17:00');    // "17:00"
```

---

## 🔧 Utilisation dans les composants

### Exemple 1 : EventForm (génération des jours)

**❌ AVANT (bug timezone)** :
```typescript
const start = new Date(startDate);
const end = new Date(endDate);

while (currentDate <= end) {
  days.push({
    date: currentDate.toISOString().split('T')[0],  // ❌ Bug UTC !
    // ...
  });
  currentDate.setDate(currentDate.getDate() + 1);
}
```

**✅ APRÈS (avec helpers)** :
```typescript
import { parseDateLocal, formatDateLocal } from '@/config/timezone';

const start = parseDateLocal(startDate);
const end = parseDateLocal(endDate);

while (currentDate <= end) {
  days.push({
    date: formatDateLocal(currentDate),  // ✅ Correct !
    // ...
  });
  currentDate.setDate(currentDate.getDate() + 1);
}
```

---

### Exemple 2 : Affichage des badges de jours

**❌ AVANT (bug timezone)** :
```typescript
const formattedDate = field.date 
  ? new Date(field.date).toLocaleDateString('fr-FR', { ... })  // ❌ Bug !
  : '';
```

**✅ APRÈS (avec helpers)** :
```typescript
import { formatDateFr } from '@/config/timezone';

const formattedDate = field.date 
  ? formatDateFr(field.date, { uppercase: true })  // ✅ Correct !
  : '';
```

---

### Exemple 3 : DatePicker

**❌ AVANT** :
```typescript
<Controller
  name="start_date"
  control={control}
  render={({ field }) => (
    <DatePickerPopup
      value={field.value ? new Date(field.value) : null}  // ❌ Bug !
      onChange={(date) => field.onChange(date?.toISOString().split('T')[0])}  // ❌ Bug !
    />
  )}
/>
```

**✅ APRÈS** :
```typescript
import { parseDateLocal, formatDateLocal } from '@/config/timezone';

<Controller
  name="start_date"
  control={control}
  render={({ field }) => (
    <DatePickerPopup
      value={field.value ? parseDateLocal(field.value) : null}  // ✅ Correct !
      onChange={(date) => field.onChange(date ? formatDateLocal(date) : '')}  // ✅ Correct !
    />
  )}
/>
```

---

## 📊 Format des données en base Supabase

### Tables : events, event_days

**Colonnes dates** :
```sql
start_date    DATE        -- Format: 'YYYY-MM-DD' (pas de timezone)
end_date      DATE        -- Format: 'YYYY-MM-DD' (pas de timezone)
date          DATE        -- Format: 'YYYY-MM-DD' (pas de timezone)
```

**Colonnes heures** :
```sql
open_time     TIME        -- Format: 'HH:MM:SS' (pas de timezone)
close_time    TIME        -- Format: 'HH:MM:SS' (pas de timezone)
performance_time TIME     -- Format: 'HH:MM:SS' (pas de timezone)
```

**⚠️ RÈGLES** :
1. ✅ Utiliser le type `DATE` pour les dates (pas `TIMESTAMP`)
2. ✅ Utiliser le type `TIME` pour les heures (pas `TIMESTAMP`)
3. ✅ Ne JAMAIS mélanger date et heure dans une seule colonne
4. ✅ Pas de conversion timezone côté base

---

## 🎯 Checklist de migration

### Pour chaque fichier qui manipule des dates :

- [ ] Importer les helpers : `import { ... } from '@/config/timezone'`
- [ ] Remplacer `new Date(dateString)` par `parseDateLocal(dateString)`
- [ ] Remplacer `date.toISOString().split('T')[0]` par `formatDateLocal(date)`
- [ ] Remplacer `toLocaleDateString('fr-FR', ...)` par `formatDateFr(...)`
- [ ] Vérifier que les dates sont au format `YYYY-MM-DD` en base
- [ ] Vérifier que les heures sont au format `HH:MM` en base
- [ ] Tester dans différents fuseaux horaires

---

## 🐛 Problèmes courants et solutions

### Problème 1 : "La date affichée est décalée d'un jour"

**Cause** : Utilisation de `new Date(dateString)` qui parse en UTC

**Solution** :
```typescript
// ❌ Bug
const date = new Date('2025-10-30');

// ✅ Fix
import { parseDateLocal } from '@/config/timezone';
const date = parseDateLocal('2025-10-30');
```

---

### Problème 2 : "Le jour de la semaine est incorrect"

**Cause** : Date parsée en UTC au lieu de fuseau Paris

**Solution** :
```typescript
// ❌ Bug
new Date('2025-10-30').toLocaleDateString('fr-FR', { weekday: 'long' });

// ✅ Fix
import { getWeekdayFr } from '@/config/timezone';
getWeekdayFr('2025-10-30');
```

---

### Problème 3 : "Les dates changent quand je change de fuseau horaire"

**Cause** : Utilisation de timestamps ou ISO strings avec timezone

**Solution** :
- ✅ Stocker les dates au format `YYYY-MM-DD` (string, pas timestamp)
- ✅ Utiliser les helpers pour parser/formater
- ✅ Ne jamais utiliser `Date.getTime()` pour les dates simples

---

## 📝 Configuration Supabase

### Vérification de la timezone PostgreSQL

```sql
-- Vérifier la timezone actuelle
SHOW timezone;

-- Devrait afficher : 'UTC' (c'est normal, on gère côté client)
```

**⚠️ Important** :
- La base Supabase est en UTC (par défaut et c'est bien)
- On stocke les dates au format `DATE` (pas de timezone)
- On stocke les heures au format `TIME` (pas de timezone)
- La conversion fuseau Paris se fait **côté client** avec nos helpers

---

## ✅ Exemples complets

### Créer un événement

```typescript
import { getTodayLocal, addDays, formatDateFr } from '@/config/timezone';

// Dates de l'événement
const startDate = getTodayLocal();  // "2025-10-30"
const endDate = addDays(startDate, 2);  // "2025-11-01"

// Générer les jours
const days = getDateRange(startDate, endDate).map(date => ({
  date,
  open_time: '17:00',
  close_time: '03:00',
  display_label: formatDateFr(date, { uppercase: true }),
}));

// Résultat :
// [
//   { date: "2025-10-30", open_time: "17:00", close_time: "03:00", display_label: "MERCREDI 30 OCTOBRE 2025" },
//   { date: "2025-10-31", open_time: "17:00", close_time: "03:00", display_label: "JEUDI 31 OCTOBRE 2025" },
//   { date: "2025-11-01", open_time: "17:00", close_time: "03:00", display_label: "VENDREDI 01 NOVEMBRE 2025" },
// ]
```

---

### Afficher un calendrier

```typescript
import { parseDateLocal, formatDateLocal, formatDateFr } from '@/config/timezone';

const eventDays = [
  { date: '2025-10-30', open_time: '17:00', close_time: '03:00' },
  { date: '2025-10-31', open_time: '17:00', close_time: '03:00' },
  { date: '2025-11-01', open_time: '17:00', close_time: '03:00' },
];

eventDays.forEach(day => {
  const displayDate = formatDateFr(day.date, { uppercase: true });
  console.log(`${displayDate} : ${day.open_time} → ${day.close_time}`);
});

// Résultat :
// MERCREDI 30 OCTOBRE 2025 : 17:00 → 03:00
// JEUDI 31 OCTOBRE 2025 : 17:00 → 03:00
// VENDREDI 01 NOVEMBRE 2025 : 17:00 → 03:00
```

---

## 🚀 Migration du code existant

### Fichiers à migrer (priorité haute)

1. ✅ `src/features/settings/events/EventForm.tsx` - FAIT
2. ⏳ `src/components/ui/pickers/DatePickerPopup.tsx`
3. ⏳ `src/components/ui/pickers/TimePickerPopup.tsx`
4. ⏳ `src/features/timeline/components/TimelineGrid.tsx`
5. ⏳ `src/features/booking/KanbanBoard.tsx`
6. ⏳ Tous les fichiers qui manipulent des dates

### Script de migration

Rechercher tous les patterns dangereux :
```bash
# Trouver les new Date(string)
grep -r "new Date(" src/ | grep -v "new Date()" | grep -v "timezone.ts"

# Trouver les toISOString()
grep -r "toISOString()" src/ | grep -v "timezone.ts"

# Trouver les toLocaleDateString()
grep -r "toLocaleDateString" src/ | grep -v "timezone.ts"
```

---

## 📚 Ressources

- **Fichier config** : `src/config/timezone.ts`
- **Ce guide** : `TIMEZONE_GUIDE.md`
- **Fixes appliqués** : `FIX_MODAL_EVENT_DATES_TEXTAREA.md`

---

## ✅ Résumé des règles

| ❌ À NE JAMAIS FAIRE | ✅ À TOUJOURS FAIRE |
|---------------------|-------------------|
| `new Date('2025-10-30')` | `parseDateLocal('2025-10-30')` |
| `date.toISOString().split('T')[0]` | `formatDateLocal(date)` |
| `date.toLocaleDateString('fr-FR', ...)` | `formatDateFr(dateString, ...)` |
| Stocker des timestamps | Stocker des strings 'YYYY-MM-DD' |
| Mélanger date + heure | Séparer date (DATE) et heure (TIME) |

---

**🌍 Fuseau horaire unifié : Europe/Paris partout !**


