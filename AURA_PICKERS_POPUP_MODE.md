# ✅ Date/Time Pickers AURA en mode Popup

## 🎯 Objectif

Transformer les `DatePickerAura` et `TimePickerCircular24` en composants qui s'ouvrent en **popup/modal** au lieu d'être affichés directement dans le formulaire, comme des date/time pickers standards.

## 📦 Nouveaux composants créés

### 1. DatePickerPopup (`src/components/ui/pickers/DatePickerPopup.tsx`)

**Comportement** :
- Affiche un input cliquable avec icône calendrier
- Au clic : ouvre un modal avec `DatePickerAura`
- Sélection d'une date → ferme automatiquement le modal
- Affiche la date formatée (ex: "15 août 2026")

**Props** :
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

**Usage avec react-hook-form** :
```tsx
<Controller
  name="start_date"
  control={control}
  render={({ field }) => (
    <DatePickerPopup
      label="Date de début"
      value={field.value ? new Date(field.value) : null}
      onChange={(date) => field.onChange(date ? date.toISOString().split('T')[0] : '')}
      disabled={saving}
    />
  )}
/>
```

### 2. TimePickerPopup (`src/components/ui/pickers/TimePickerPopup.tsx`)

**Comportement** :
- Affiche un input cliquable avec icône horloge
- Au clic : ouvre un modal avec `TimePickerCircular24`
- Bouton "Valider" pour fermer le modal
- Affiche l'heure au format HH:MM (ex: "11:00")

**Props** :
```typescript
type TimePickerPopupProps = {
  value?: string | null
  onChange: (time: string | null) => void
  label?: string
  placeholder?: string
  error?: string
  disabled?: boolean
  className?: string
}
```

**Usage avec react-hook-form** :
```tsx
<Controller
  name="open_time"
  control={control}
  render={({ field }) => (
    <TimePickerPopup
      label="Heure d'ouverture"
      value={field.value}
      onChange={(time) => field.onChange(time)}
      placeholder="Ex: 11:00"
      disabled={saving}
    />
  )}
/>
```

## 🎨 Interface utilisateur

### DatePickerPopup

**Input fermé** :
```
┌────────────────────────────────────┐
│ Date de début                      │
├────────────────────────────────────┤
│ 15 août 2026                  📅  │
└────────────────────────────────────┘
```

**Popup ouvert** :
```
┌─────────────────────────────────────┐
│ Sélectionner une date          ✕   │
├─────────────────────────────────────┤
│  ◀  Août 2026  ▶                   │
│                                     │
│  Lu Ma Me Je Ve Sa Di               │
│              1  2  3  4             │
│  5  6  7  8  9 10 11               │
│ 12 13 14 (15) 16 17 18             │  ← Jour sélectionné
│ 19 20 21 22 23 24 25               │
│ 26 27 28 29 30 31                  │
│                                     │
│ [Aujourd'hui] [-7j] [+7j]          │
└─────────────────────────────────────┘
```

### TimePickerPopup

**Input fermé** :
```
┌────────────────────────────────────┐
│ Heure d'ouverture                  │
├────────────────────────────────────┤
│ 11:00                         🕐  │
└────────────────────────────────────┘
```

**Popup ouvert** :
```
┌─────────────────────────────────────┐
│ Sélectionner une heure         ✕   │
├─────────────────────────────────────┤
│ [Heures] [Minutes]                  │
│                                     │
│     11  :  00                      │
│                                     │
│          ╱────╲                    │
│         │  (11) │  ← Horloge      │
│         │ 12  1 │     circulaire   │
│         │10   2 │     24h          │
│         │ 9   3 │                  │
│         │  8  4 │                  │
│          ╲────╱                    │
│                                     │
│ [Réinitialiser] [Maintenant] [23:59]│
│                        [Valider]    │
└─────────────────────────────────────┘
```

## 🔧 Modifications apportées

### EventForm.tsx

**AVANT** (composants intégrés) :
```tsx
<div>
  <label>Date de début</label>
  <Controller>
    <DatePickerAura />  ← Affichage direct du calendrier
  </Controller>
</div>
```

**APRÈS** (composants popup) :
```tsx
<Controller
  name="start_date"
  control={control}
  render={({ field }) => (
    <DatePickerPopup    ← Input cliquable + modal
      label="Date de début"
      value={field.value ? new Date(field.value) : null}
      onChange={(date) => field.onChange(date ? date.toISOString().split('T')[0] : '')}
      disabled={saving}
    />
  )}
/>
```

### Exports (src/components/ui/pickers/index.ts)

```typescript
export { DatePickerPopup } from './DatePickerPopup'
export { TimePickerPopup } from './TimePickerPopup'
```

## ✅ Avantages du mode Popup

### 1. Économie d'espace
- **AVANT** : Calendrier/horloge prend toute la largeur du formulaire
- **APRÈS** : Input compact, popup à la demande

### 2. UX familière
- Comportement standard des date/time pickers
- Click → ouvre le picker
- Sélection → ferme le picker

### 3. Formulaires plus lisibles
- Layout grid simple (2 colonnes)
- Pas de décalage visuel entre champs
- Meilleure hiérarchie visuelle

### 4. Compatibilité mobile
- Modal centré et responsive
- Pas de scroll horizontal
- Touch-friendly

## 🧪 Tests de validation

### Test 1 : DatePickerPopup - Ouverture/Fermeture
1. Ouvrir le modal EventForm
2. **Cliquer** sur l'input "Date de début"
3. **Vérifier** : Modal s'ouvre avec calendrier
4. **Cliquer** sur une date
5. **Vérifier** : Modal se ferme automatiquement
6. **Vérifier** : Date affichée dans l'input (ex: "15 août 2026")

### Test 2 : TimePickerPopup - Ouverture/Fermeture
1. Aller dans l'onglet "Jours"
2. **Cliquer** sur l'input "Heure d'ouverture"
3. **Vérifier** : Modal s'ouvre avec horloge
4. **Sélectionner** une heure (ex: 11:00)
5. **Cliquer** sur "Valider"
6. **Vérifier** : Modal se ferme
7. **Vérifier** : Heure affichée dans l'input (ex: "11:00")

### Test 3 : Disabled state
1. Pendant la sauvegarde (saving=true)
2. **Vérifier** : Input désactivé (opacité 0.5)
3. **Cliquer** sur l'input
4. **Vérifier** : Modal ne s'ouvre pas
5. **Vérifier** : Curseur "not-allowed"

### Test 4 : Validation erreurs
1. Essayer de soumettre sans date
2. **Vérifier** : Message d'erreur sous l'input (si validation)
3. **Vérifier** : Input affiche l'erreur en rouge

### Test 5 : Persistance des données
1. Créer un événement avec dates/heures
2. **Enregistrer**
3. **Réouvrir** en mode édition
4. **Vérifier** : Inputs affichent les bonnes valeurs
5. **Cliquer** sur un input
6. **Vérifier** : Picker affiche la valeur sélectionnée

### Test 6 : Format d'affichage
1. **DatePicker** : Format long français (ex: "15 août 2026")
2. **TimePicker** : Format HH:MM (ex: "11:00")
3. **Vérifier** : Cohérent avec le reste de l'app

### Test 7 : Layout responsive
1. Réduire la fenêtre (mobile)
2. **Cliquer** sur un input
3. **Vérifier** : Modal centré et adapté
4. **Vérifier** : Calendrier/horloge responsive

## 📊 Comparaison Avant/Après

### Avant (intégré)
```
┌─────────────────────────────────────────────┐
│ Nom: Festival 2026                          │
├─────────────────────────────────────────────┤
│ Date de début:                              │
│ ┌──────────────────────────────────────┐   │
│ │   ◀  Août 2026  ▶                    │   │
│ │  Lu Ma Me Je Ve Sa Di                │   │
│ │              1  2  3  4              │   │
│ │  5  6  7  8  9 10 11                │   │
│ │ 12 13 14 (15) 16 17 18              │   │
│ │ [Aujourd'hui] [-7j] [+7j]           │   │
│ └──────────────────────────────────────┘   │
│                                             │
│ Date de fin:                                │
│ ┌──────────────────────────────────────┐   │
│ │   ◀  Août 2026  ▶                    │   │
│ │  Lu Ma Me Je Ve Sa Di                │   │
│ │              1  2  3  4              │   │
│ │  5  6  7  8  9 10 11                │   │
│ │ 12 13 14 15 (16) 17 18              │   │
│ │ [Aujourd'hui] [-7j] [+7j]           │   │
│ └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
   ↑ Beaucoup d'espace vertical
   ↑ Formulaire très long
```

### Après (popup)
```
┌─────────────────────────────────────────────┐
│ Nom: Festival 2026                          │
├─────────────────────────────────────────────┤
│ Date de début:            Date de fin:      │
│ 15 août 2026  📅        16 août 2026  📅  │
├─────────────────────────────────────────────┤
│ Couleur:                                    │
│ [#3b82f6]                                   │
└─────────────────────────────────────────────┘
   ↑ Compact
   ↑ Grid 2 colonnes simple
```

## 📝 Règle SAAS (rappel)

Pour **TOUT le SAAS Go-Prod** :

✅ **Utiliser UNIQUEMENT** :
- `DatePickerPopup` pour les dates
- `TimePickerPopup` pour les heures

❌ **NE JAMAIS utiliser** :
- `<input type="date">` natif
- `<input type="time">` natif
- `DatePickerAura` directement (réservé à l'usage interne de DatePickerPopup)
- `TimePickerCircular24` directement (réservé à l'usage interne de TimePickerPopup)

## ✅ Résultat

**Les date/time pickers AURA fonctionnent maintenant en mode popup !** 🎉

- ✅ `DatePickerPopup` : Input cliquable + modal calendrier
- ✅ `TimePickerPopup` : Input cliquable + modal horloge
- ✅ Fermeture automatique après sélection (date) ou manuelle (time)
- ✅ Format d'affichage français
- ✅ Économie d'espace dans les formulaires
- ✅ UX standard et familière
- ✅ Responsive et mobile-friendly
- ✅ Design 100% AURA

Testez en ouvrant `http://localhost:5180/app/settings/events` et en cliquant sur "Ajouter un évènement" !


