# DateRangePicker - Ajout sélecteur de mois/années et dates futures

## 🎯 Objectifs

1. Permettre la sélection des **dates des mois suivants** (dates grisées)
2. Ajouter un **sélecteur de mois et années** en cliquant sur le titre

## ✅ Modifications appliquées

### 1. Dates des mois suivants sélectionnables

**Problème** : Les dates du mois précédent et suivant étaient marquées comme `disabled: true`

**Solution** : Remplacer `disabled` par `isCurrentMonth` pour permettre la sélection tout en les stylisant différemment

#### Avant (getDaysGrid)
```typescript
for (let i = 0; i < startWeekDay; i++) {
  days.push({ date: startOfMonth.subtract(startWeekDay - i, 'day'), disabled: true });
}
// ...
while (days.length % 7 !== 0) {
  const last = days[days.length - 1].date;
  days.push({ date: last.add(1, 'day'), disabled: true });
}
```

#### Après
```typescript
// Jours du mois précédent (sélectionnables)
for (let i = 0; i < startWeekDay; i++) {
  days.push({ date: startOfMonth.subtract(startWeekDay - i, 'day'), isCurrentMonth: false });
}
// Jours du mois courant
for (let i = 1; i <= daysInMonth; i++) {
  days.push({ date: startOfMonth.date(i), isCurrentMonth: true });
}
// Jours du mois suivant (sélectionnables)
while (days.length % 7 !== 0) {
  const last = days[days.length - 1].date;
  days.push({ date: last.add(1, 'day'), isCurrentMonth: false });
}
```

**Style** : Les dates hors du mois courant sont affichées avec une opacité de 0.5 et une couleur grisée, mais restent cliquables.

---

### 2. Sélecteur de mois et années

**Ajout de 3 modes** : `'days' | 'months' | 'years'`

#### États ajoutés
```typescript
const [mode, setMode] = React.useState<'days' | 'months' | 'years'>('days');
const [yearPage, setYearPage] = React.useState(() => Math.floor(dayjs().year() / 12) * 12);
const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
const years = Array.from({ length: 12 }, (_, i) => yearPage + i);
```

#### Handlers ajoutés
```typescript
// Sélection de mois → retourne en mode jours
const handleMonthSelect = (monthIndex: number) => {
  setViewDate(viewDate.month(monthIndex));
  setMode('days');
};

// Sélection d'année → passe en mode mois
const handleYearSelect = (year: number) => {
  setViewDate(viewDate.year(year));
  setMode('months');
};
```

---

### 3. Header dynamique selon le mode

#### Mode 'days' (par défaut)
```tsx
<button onClick={() => setViewDate(prev => prev.subtract(1, 'month'))}>◀</button>
<button onClick={() => setMode('months')}>Novembre 2026</button>  {/* Cliquable */}
<button onClick={() => setViewDate(prev => prev.add(1, 'month'))}>▶</button>
```

#### Mode 'months'
```tsx
<button onClick={() => setViewDate(prev => prev.subtract(1, 'year'))}>◀</button>
<button onClick={() => setMode('years')}>2026</button>  {/* Cliquable */}
<button onClick={() => setViewDate(prev => prev.add(1, 'year'))}>▶</button>
```

#### Mode 'years'
```tsx
<button onClick={() => setYearPage(yearPage - 12)}>◀</button>
<div>2024 - 2035</div>  {/* Non cliquable */}
<button onClick={() => setYearPage(yearPage + 12)}>▶</button>
```

---

### 4. Grilles de sélection

#### Grille de jours (mode 'days')
- **7 colonnes** (jours de la semaine)
- Dates du mois précédent/suivant : opacité 0.5
- Dates sélectionnées : fond violet

#### Grille de mois (mode 'months')
- **3 colonnes**
- 12 mois affichés
- Mois actuel : fond violet
- Autres : hover violet léger

```tsx
<div className="grid grid-cols-3 gap-2">
  {months.map((month, index) => (
    <button
      className={isCurrentMonth ? 'bg-purple-500 text-white' : 'hover:bg-purple-500/10'}
      onClick={() => handleMonthSelect(index)}
    >
      {month}
    </button>
  ))}
</div>
```

#### Grille d'années (mode 'years')
- **3 colonnes**
- 12 années affichées (ex: 2024-2035)
- Année actuelle : fond violet
- Autres : hover violet léger

```tsx
<div className="grid grid-cols-3 gap-2">
  {years.map((year) => (
    <button
      className={isCurrentYear ? 'bg-purple-500 text-white' : 'hover:bg-purple-500/10'}
      onClick={() => handleYearSelect(year)}
    >
      {year}
    </button>
  ))}
</div>
```

---

## 🎨 Flux utilisateur

### Sélection rapide de dates futures

1. **Ouvrir le DateRangePicker**
2. **Cliquer sur "Novembre 2026"** → Mode mois
3. **Sélectionner "Déc"** → Retour mode jours sur Décembre 2026
4. **Cliquer sur la date de début**
5. **Cliquer sur la date de fin**
6. **Cliquer sur "OK"**

### Navigation par années

1. **Ouvrir le DateRangePicker**
2. **Cliquer sur "Novembre 2026"** → Mode mois
3. **Cliquer sur "2026"** → Mode années (2024-2035)
4. **Cliquer sur ◀ ou ▶** pour naviguer (2012-2023, 2036-2047, etc.)
5. **Sélectionner une année** → Retour mode mois
6. **Sélectionner un mois** → Retour mode jours
7. **Sélectionner les dates**

---

## 📊 Impact

### Avant
- ❌ Dates grises non sélectionnables (disabled)
- ❌ Pas de moyen de changer rapidement de mois/année
- ❌ Navigation uniquement mois par mois avec ◀ ▶

### Après
- ✅ **Dates grises sélectionnables** (stylisées avec opacité)
- ✅ **Sélection rapide de mois** (grille 3×4)
- ✅ **Sélection rapide d'années** (grille 3×4)
- ✅ **Navigation fluide** entre modes (jours ↔ mois ↔ années)
- ✅ **UX améliorée** : titre cliquable avec hover violet

---

## 🧪 Tests de validation

### ✅ Sélection de dates du mois suivant
1. Ouvrir le modal "Créer un évènement"
2. Cliquer sur "Dates de l'évènement"
3. **Test** : Cliquer sur une date grise du mois suivant
4. **Résultat attendu** : La date doit être sélectionnée et le calendrier doit passer au mois suivant automatiquement

### ✅ Sélecteur de mois
1. Dans le DateRangePicker
2. **Test** : Cliquer sur "Novembre 2026" (titre)
3. **Résultat attendu** : Afficher la grille de 12 mois
4. **Test** : Cliquer sur "Déc"
5. **Résultat attendu** : Retour en mode jours sur Décembre 2026

### ✅ Sélecteur d'années
1. Dans le DateRangePicker
2. **Test** : Cliquer sur "Novembre 2026" → Cliquer sur "2026"
3. **Résultat attendu** : Afficher la grille de 12 années (2024-2035)
4. **Test** : Cliquer sur ◀ pour voir 2012-2023
5. **Test** : Cliquer sur "2025"
6. **Résultat attendu** : Retour en mode mois sur 2025

### ✅ Sélection de dates sur plusieurs mois
1. **Test** : Sélectionner "30 novembre 2026" comme début
2. **Test** : Cliquer sur ▶ pour passer à décembre
3. **Test** : Sélectionner "15 décembre 2026" comme fin
4. **Résultat attendu** : Les deux dates sont sélectionnées correctement

---

## 📦 Fichiers modifiés

| Fichier | Modifications |
|---------|---------------|
| `src/components/ui/DateRangePickerAura.tsx` | Ajout modes, grilles mois/années, isCurrentMonth |

---

**Date de modification** : 28 octobre 2025  
**Tests** : ✅ Lint OK  
**Statut** : ✅ Prêt pour validation manuelle  
**Impact** : ✅ Amélioration majeure de l'UX du DateRangePicker


