# 📅 Standards des Pickers AURA

## 🎯 Vue d'ensemble

Ce document définit les **3 pickers standard** à utiliser dans toute l'application Go-Prod AURA.

### ✅ Pickers Standard (À UTILISER)

| Composant | Usage | Dimensions | Fichier |
|-----------|-------|------------|---------|
| **DatePickerPopup** | Sélection de date | 330×380px | `src/components/ui/pickers/DatePickerPopup.tsx` |
| **TimePickerPopup** | Sélection d'heure (24h) | 300×380px | `src/components/ui/pickers/TimePickerPopup.tsx` |
| **DateTimePickerPopup** | Sélection date + heure | 630×380px | `src/components/ui/pickers/DateTimePickerPopup.tsx` |

### ⚠️ Composants de base (Usage avancé uniquement)

| Composant | Statut | Usage |
|-----------|--------|-------|
| `DatePickerAura` | `@deprecated` | Utilisé en interne par `DatePickerPopup` |
| `TimePickerCircular24` | `@deprecated` | Utilisé en interne par `TimePickerPopup` |
| `DateTimePickerAura` | `@deprecated` | Utilisé en interne par `DateTimePickerPopup` |

---

## 📦 Import

```typescript
// ✅ RECOMMANDÉ - Import depuis le barrel
import { DatePickerPopup, TimePickerPopup, DateTimePickerPopup } from '@/components/ui/pickers'

// ❌ À ÉVITER - Import direct des composants de base
import { DatePickerAura } from '@/components/ui/DatePickerAura'
import { TimePickerCircular24 } from '@/components/ui/TimePickerCircular24'
```

---

## 🎨 Caractéristiques AURA

### Design

- **Mode dark-first** : Optimisé pour le mode sombre
- **Light mode** : Support complet du mode clair
- **Top bar violet** : Couleur `var(--color-primary)`
- **Footer violet** : Boutons "Annuler", "Effacer", "OK"
- **Ombre portée** : `0 25px 60px rgba(0, 0, 0, 0.6)` + contour blanc 10%
- **Coins arrondis** : `0.75rem` (12px)
- **Pas de scrollbar** : Contenu fixe et centré

### Comportement

- **Popup modal** : Ouvre au-dessus du contenu
- **Clic extérieur** : Ferme le picker
- **Escape** : Ferme le picker
- **Scroll bloqué** : Empêche le scroll de la page quand ouvert
- **Validation** : Seulement au clic sur "OK"
- **Effacer** : Bouton pour réinitialiser la sélection
- **Annuler** : Ferme sans valider

---

## 📝 API des Composants

### DatePickerPopup

```typescript
type DatePickerPopupProps = {
  value?: Date | null
  onChange: (date: Date | null) => void
  label?: string
  placeholder?: string
  error?: string
  disabled?: boolean
  className?: string
}
```

**Exemple standalone** :
```tsx
<DatePickerPopup
  label="Date de début"
  value={startDate}
  onChange={setStartDate}
  placeholder="Sélectionner une date"
  disabled={loading}
/>
```

**Exemple avec react-hook-form** :
```tsx
<Controller
  name="start_date"
  control={control}
  render={({ field }) => (
    <DatePickerPopup
      label="Date de début"
      value={field.value ? new Date(field.value) : null}
      onChange={(date) => field.onChange(date ? date.toISOString().split('T')[0] : null)}
      disabled={saving}
    />
  )}
/>
```

### TimePickerPopup

```typescript
type TimePickerPopupProps = {
  value?: string | null  // Format "HH:mm"
  onChange: (time: string | null) => void
  label?: string
  placeholder?: string
  error?: string
  disabled?: boolean
  className?: string
}
```

**Exemple standalone** :
```tsx
<TimePickerPopup
  label="Heure de début"
  value={startTime}
  onChange={setStartTime}
  placeholder="Sélectionner une heure"
  disabled={loading}
/>
```

**Exemple avec react-hook-form** :
```tsx
<Controller
  name="start_time"
  control={control}
  render={({ field }) => (
    <TimePickerPopup
      label="Heure de début"
      value={field.value}
      onChange={field.onChange}
      disabled={saving}
    />
  )}
/>
```

### DateTimePickerPopup

```typescript
type DateTimePickerPopupProps = {
  value?: Date | null
  onChange: (date: Date | null) => void
  label?: string
  placeholder?: string
  error?: string
  disabled?: boolean
  className?: string
}
```

**Exemple standalone** :
```tsx
<DateTimePickerPopup
  label="Date et heure de l'évènement"
  value={eventDateTime}
  onChange={setEventDateTime}
  placeholder="Sélectionner date et heure"
  disabled={loading}
/>
```

**Exemple avec react-hook-form** :
```tsx
<Controller
  name="event_datetime"
  control={control}
  render={({ field }) => (
    <DateTimePickerPopup
      label="Date et heure"
      value={field.value ? new Date(field.value) : null}
      onChange={(date) => field.onChange(date ? date.toISOString() : null)}
      disabled={saving}
    />
  )}
/>
```

---

## 🔄 Migration depuis anciens pickers

### Depuis `<input type="date">`

**Avant** :
```tsx
<Input
  label="Date de début"
  type="date"
  value={startDate}  // string "YYYY-MM-DD"
  onChange={(e) => setStartDate(e.target.value)}
/>
```

**Après** :
```tsx
<DatePickerPopup
  label="Date de début"
  value={startDate ? new Date(startDate) : null}  // Date | null
  onChange={(date) => setStartDate(date ? date.toISOString().split('T')[0] : '')}
/>
```

### Depuis `<input type="time">`

**Avant** :
```tsx
<Input
  label="Heure de début"
  type="time"
  value={startTime}  // string "HH:mm"
  onChange={(e) => setStartTime(e.target.value)}
/>
```

**Après** :
```tsx
<TimePickerPopup
  label="Heure de début"
  value={startTime}  // string "HH:mm" | null
  onChange={setStartTime}
/>
```

### Depuis `DatePickerAura` (inline)

**Avant** :
```tsx
<DatePickerAura
  value={date}
  onChange={setDate}
  className="w-full"
/>
```

**Après** :
```tsx
<DatePickerPopup
  value={date}
  onChange={setDate}
  label="Date"
/>
```

---

## 📊 Comparaison des formats

| Type | Format entrée | Format sortie | Exemple |
|------|--------------|---------------|---------|
| **DatePickerPopup** | `Date \| null` | `Date \| null` | `new Date('2026-06-15')` |
| **TimePickerPopup** | `string \| null` | `string \| null` | `"14:30"` |
| **DateTimePickerPopup** | `Date \| null` | `Date \| null` | `new Date('2026-06-15T14:30:00')` |

### Conversions utiles

```typescript
// Date → ISO string (YYYY-MM-DD)
const isoDate = date ? date.toISOString().split('T')[0] : null

// ISO string → Date
const dateObj = isoString ? new Date(isoString) : null

// Date → "HH:mm"
const timeStr = date 
  ? `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}` 
  : null

// "HH:mm" → Date (aujourd'hui)
const timeToDate = (time: string) => {
  const [hours, minutes] = time.split(':').map(Number)
  const date = new Date()
  date.setHours(hours, minutes, 0, 0)
  return date
}
```

---

## 🎯 Guidelines d'usage

### ✅ À FAIRE

- ✅ Utiliser **DatePickerPopup** pour toutes les sélections de date
- ✅ Utiliser **TimePickerPopup** pour toutes les sélections d'heure
- ✅ Utiliser **DateTimePickerPopup** quand date ET heure sont nécessaires ensemble
- ✅ Intégrer avec `react-hook-form` via `Controller`
- ✅ Gérer les valeurs `null` pour les champs optionnels
- ✅ Ajouter un `label` descriptif
- ✅ Gérer l'état `disabled` pendant les requêtes

### ❌ À ÉVITER

- ❌ N'utilisez **pas** `<input type="date">`
- ❌ N'utilisez **pas** `<input type="time">`
- ❌ N'utilisez **pas** `<input type="datetime-local">`
- ❌ N'utilisez **pas** `DatePickerAura` directement (sauf cas avancé)
- ❌ N'utilisez **pas** `TimePickerCircular24` directement (sauf cas avancé)
- ❌ N'importez **pas** de librairies externes (`react-datepicker`, `@mui/pickers`, etc.)

---

## 🧪 Tests de validation

### Test 1 : Popup ouvre/ferme
1. Cliquer sur le champ
2. **Vérifier** : Popup s'ouvre
3. Cliquer sur "OK"
4. **Vérifier** : Popup se ferme et valeur est mise à jour
5. Cliquer à nouveau, appuyer sur **Escape**
6. **Vérifier** : Popup se ferme sans mise à jour

### Test 2 : Mode clair/dark
1. Basculer en mode **dark**
2. **Vérifier** : Top bar violet visible, ombre marquée
3. Basculer en mode **clair**
4. **Vérifier** : Design propre, pas de coins blancs

### Test 3 : Validation formulaire
1. Utiliser le picker dans un formulaire `react-hook-form`
2. Sélectionner une date/heure
3. Soumettre le formulaire
4. **Vérifier** : Valeur correcte reçue (format attendu)
5. **Vérifier** : Validation fonctionne (champ requis)

### Test 4 : Accessibilité
1. Utiliser **Tab** pour naviguer
2. **Vérifier** : Focus visible sur le champ
3. **Vérifier** : Enter ouvre le picker
4. **Vérifier** : Escape ferme le picker
5. **Vérifier** : Labels associés (screen readers)

---

## 📁 Structure des fichiers

```
src/components/ui/
├── pickers/
│   ├── index.ts                     # Exports centralisés
│   ├── DatePickerPopup.tsx          # ✅ Standard Date
│   ├── TimePickerPopup.tsx          # ✅ Standard Time
│   └── DateTimePickerPopup.tsx      # ✅ Standard DateTime
├── DatePickerAura.tsx               # 🔧 Base (deprecated)
├── TimePickerCircular24.tsx         # 🔧 Base (deprecated)
└── DateTimePickerAura.tsx           # 🔧 Base (deprecated)
```

---

## 🚀 Checklist Migration

Avant de merger une PR qui modifie des formulaires :

- [ ] Tous les `<input type="date">` sont remplacés par `DatePickerPopup`
- [ ] Tous les `<input type="time">` sont remplacés par `TimePickerPopup`
- [ ] Les imports viennent de `@/components/ui/pickers`
- [ ] Les valeurs sont converties correctement (Date ↔ string)
- [ ] `react-hook-form` est intégré via `Controller` si applicable
- [ ] Les tests passent en mode clair et dark
- [ ] L'accessibilité fonctionne (Tab, Enter, Escape)
- [ ] Pas de régression visuelle ou fonctionnelle

---

## 📞 Support

Pour toute question ou problème avec les pickers :

1. Vérifier cette documentation
2. Consulter les exemples dans :
   - `src/features/settings/events/EventForm.tsx` (référence complète)
   - `src/features/settings/events/EventQuickAddModal.tsx` (usage simple)
3. Vérifier les props disponibles dans les fichiers source

---

## ✅ Résumé

| Besoin | Composant | Import |
|--------|-----------|--------|
| **Date uniquement** | `DatePickerPopup` | `import { DatePickerPopup } from '@/components/ui/pickers'` |
| **Heure uniquement** | `TimePickerPopup` | `import { TimePickerPopup } from '@/components/ui/pickers'` |
| **Date + Heure** | `DateTimePickerPopup` | `import { DateTimePickerPopup } from '@/components/ui/pickers'` |

**Les 3 pickers popup sont maintenant le standard unique de Go-Prod AURA !** 🎉


