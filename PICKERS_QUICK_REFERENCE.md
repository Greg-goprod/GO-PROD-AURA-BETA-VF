# 🎯 Pickers AURA - Référence Rapide

## 📦 Import unique

```typescript
import { DatePickerPopup, TimePickerPopup, DateTimePickerPopup } from '@/components/ui/pickers'
```

---

## 📅 DatePickerPopup

### Utilisation

```tsx
<DatePickerPopup
  label="Date de début"
  value={startDate}  // Date | null
  onChange={setStartDate}
  disabled={loading}
/>
```

### react-hook-form

```tsx
<Controller
  name="start_date"
  control={control}
  render={({ field }) => (
    <DatePickerPopup
      value={field.value ? new Date(field.value) : null}
      onChange={(date) => field.onChange(date ? date.toISOString().split('T')[0] : null)}
      label="Date"
    />
  )}
/>
```

### Caractéristiques

- **Dimensions** : 330×380px
- **Format** : `Date | null`
- **Navigation** : Jours, mois, années
- **Validation** : Au clic "OK"

---

## ⏰ TimePickerPopup

### Utilisation

```tsx
<TimePickerPopup
  label="Heure de début"
  value={startTime}  // "HH:mm" | null
  onChange={setStartTime}
  disabled={loading}
/>
```

### react-hook-form

```tsx
<Controller
  name="start_time"
  control={control}
  render={({ field }) => (
    <TimePickerPopup
      value={field.value}
      onChange={field.onChange}
      label="Heure"
    />
  )}
/>
```

### Caractéristiques

- **Dimensions** : 300×380px
- **Format** : `string "HH:mm" | null`
- **Mode** : Circulaire 24h (0-23)
- **Cercles** : Intérieur (0-11), Extérieur (12-23)

---

## 📅⏰ DateTimePickerPopup

### Utilisation

```tsx
<DateTimePickerPopup
  label="Date et heure"
  value={eventDateTime}  // Date | null
  onChange={setEventDateTime}
  disabled={loading}
/>
```

### react-hook-form

```tsx
<Controller
  name="event_datetime"
  control={control}
  render={({ field }) => (
    <DateTimePickerPopup
      value={field.value ? new Date(field.value) : null}
      onChange={(date) => field.onChange(date ? date.toISOString() : null)}
      label="Date et heure"
    />
  )}
/>
```

### Caractéristiques

- **Dimensions** : 630×380px (330+300)
- **Format** : `Date | null` (avec heure)
- **Layout** : Horizontal (Date | Time)
- **Validation** : Combinée au clic "OK"

---

## 🔄 Migration rapide

### Depuis `<input type="date">`

```tsx
// ❌ AVANT
<Input type="date" value={date} onChange={(e) => setDate(e.target.value)} />

// ✅ APRÈS
<DatePickerPopup 
  value={date ? new Date(date) : null} 
  onChange={(d) => setDate(d ? d.toISOString().split('T')[0] : '')} 
/>
```

### Depuis `<input type="time">`

```tsx
// ❌ AVANT
<Input type="time" value={time} onChange={(e) => setTime(e.target.value)} />

// ✅ APRÈS
<TimePickerPopup value={time} onChange={setTime} />
```

---

## 🎨 Design AURA

### Couleurs

- **Top bar** : Violet `var(--color-primary)`
- **Footer** : Violet `var(--color-primary)`
- **Boutons** : "Annuler", "Effacer", "OK" (blanc sur violet)

### Ombre

- **Mode dark** : `0 25px 60px rgba(0, 0, 0, 0.6)` + contour blanc 10%
- **Mode clair** : `0 25px 60px rgba(0, 0, 0, 0.6)` (pas de contour)

### Comportement

- ✅ Popup modal centré
- ✅ Clic extérieur → Ferme
- ✅ Escape → Ferme
- ✅ Scroll bloqué quand ouvert
- ✅ Validation non-immédiate

---

## 📊 Comparaison

| Picker | Dimensions | Format | Usage |
|--------|-----------|--------|-------|
| DatePickerPopup | 330×380px | `Date \| null` | Date uniquement |
| TimePickerPopup | 300×380px | `"HH:mm" \| null` | Heure uniquement |
| DateTimePickerPopup | 630×380px | `Date \| null` | Date + Heure |

---

## ⚠️ Ne PAS utiliser

- ❌ `<input type="date">`
- ❌ `<input type="time">`
- ❌ `<input type="datetime-local">`
- ❌ `DatePickerAura` (sauf interne)
- ❌ `TimePickerCircular24` (sauf interne)
- ❌ Librairies externes

---

## 📖 Documentation complète

- **Guide complet** : `PICKERS_STANDARD.md`
- **Suivi migrations** : `PICKERS_MIGRATION_STATUS.md`
- **Résumé** : `PICKERS_STANDARDIZATION_COMPLETE.md`

---

**Go-Prod AURA - Pickers Popup Standard** 🚀


