# Ajout des champs d'heures globales pour les événements

## 🎯 Objectif
Permettre l'édition des heures de début et de fin globales d'un événement dans le modal d'édition (`EventForm`).

---

## 📊 Modifications apportées

### 1. **Types TypeScript** (`src/types/event.ts`)

#### Ajout de `starts_at` et `ends_at`

**`EventRow`** :
```typescript
export interface EventRow {
  // ... champs existants
  start_date: string | null;
  end_date: string | null;
  starts_at: string | null;  // ✅ Nouveau
  ends_at: string | null;    // ✅ Nouveau
  notes: string | null;
  // ...
}
```

**`CreateEventPayload`** :
```typescript
export interface CreateEventPayload {
  // ... champs existants
  start_date?: string | null;
  end_date?: string | null;
  starts_at?: string | null;  // ✅ Nouveau
  ends_at?: string | null;    // ✅ Nouveau
  // ...
}
```

**`UpdateEventPayload`** :
```typescript
export interface UpdateEventPayload {
  // ... champs existants
  start_date?: string | null;
  end_date?: string | null;
  starts_at?: string | null;  // ✅ Nouveau
  ends_at?: string | null;    // ✅ Nouveau
  // ...
}
```

---

### 2. **Formulaire d'événement** (`src/features/settings/events/EventForm.tsx`)

#### Interface `FormData`
```typescript
interface FormData {
  name: string;
  color_hex: string;
  start_date: string;
  end_date: string;
  start_time: string;  // ✅ Nouveau
  end_time: string;    // ✅ Nouveau
  notes: string;
  days: EventDayInput[];
  stages: EventStageInput[];
}
```

#### Valeurs par défaut
```typescript
defaultValues: {
  name: '',
  color_hex: '#3b82f6',
  start_date: '',
  end_date: '',
  start_time: '10:00',  // ✅ Nouveau (par défaut: 10h00)
  end_time: '23:59',    // ✅ Nouveau (par défaut: 23h59)
  notes: '',
  // ...
}
```

#### Chargement des données (mode édition)
```typescript
// Extraire l'heure de starts_at et ends_at (format ISO: "2025-10-31T10:00:00+00:00")
let startTime = '10:00';
let endTime = '23:59';

if (full.event.starts_at) {
  const startsDate = new Date(full.event.starts_at);
  startTime = `${String(startsDate.getHours()).padStart(2, '0')}:${String(startsDate.getMinutes()).padStart(2, '0')}`;
}

if (full.event.ends_at) {
  const endsDate = new Date(full.event.ends_at);
  endTime = `${String(endsDate.getHours()).padStart(2, '0')}:${String(endsDate.getMinutes()).padStart(2, '0')}`;
}

reset({
  // ...
  start_time: startTime,
  end_time: endTime,
  // ...
});
```

#### Sauvegarde des données
```typescript
// Combiner date + heure en timestamp ISO
let starts_at: string | null = null;
let ends_at: string | null = null;

if (data.start_date && data.start_time) {
  starts_at = `${data.start_date}T${data.start_time}:00+00:00`;
}

if (data.end_date && data.end_time) {
  ends_at = `${data.end_date}T${data.end_time}:00+00:00`;
}

// Mode édition
await updateEvent(editingEventId, {
  name: data.name,
  color_hex: data.color_hex || '#3b82f6',
  start_date: data.start_date || null,
  end_date: data.end_date || null,
  starts_at,  // ✅ Nouveau
  ends_at,    // ✅ Nouveau
  notes: data.notes || null,
});

// Mode création
eventId = await createEvent({
  company_id: companyId,
  name: data.name,
  slug,
  color_hex: data.color_hex || '#3b82f6',
  start_date: data.start_date || null,
  end_date: data.end_date || null,
  starts_at,  // ✅ Nouveau
  ends_at,    // ✅ Nouveau
  notes: data.notes || null,
  status: 'planned',
});
```

#### Interface utilisateur
```tsx
{/* Heures de début et de fin de l'événement */}
<div className="grid grid-cols-2 gap-3">
  <Controller
    name="start_time"
    control={control}
    render={({ field }) => (
      <TimePickerPopup
        label="Heure de début"
        value={field.value}
        onChange={(time) => field.onChange(time)}
        disabled={saving}
        placeholder="10:00"
      />
    )}
  />

  <Controller
    name="end_time"
    control={control}
    render={({ field }) => (
      <TimePickerPopup
        label="Heure de fin"
        value={field.value}
        onChange={(time) => field.onChange(time)}
        disabled={saving}
        placeholder="23:59"
      />
    )}
  />
</div>
```

---

## 🎨 Interface utilisateur

Le formulaire d'édition affiche maintenant :

```
┌─────────────────────────────────────────────────┐
│  📋 Informations générales                      │
├─────────────────────────────────────────────────┤
│                                                  │
│  Nom de l'évènement                             │
│  [FESTIVAL TEST 2026.........................]  │
│                                                  │
│  Dates de l'évènement        [📅 3 jours]       │
│  [31/10/2025 - 02/11/2025..................]    │
│                                                  │
│  ┌────────────────────┬────────────────────────┐ │
│  │ Heure de début     │ Heure de fin           │ │
│  │ [10:00 🕐]         │ [23:59 🕐]             │ │
│  └────────────────────┴────────────────────────┘ │
│                                                  │
│  💡 3 jours créés automatiquement (17:00-03:00) │
│                                                  │
│  [VENDREDI 31 OCTOBRE 2025] [17:00] [03:00]     │
│  [SAMEDI 01 NOVEMBRE 2025]  [17:00] [03:00]     │
│  [DIMANCHE 02 NOVEMBRE 2025][17:00] [03:00]     │
│                                                  │
│  Notes                                           │
│  [........................................]      │
│                                                  │
│                              [Annuler] [Enregistrer]  │
└─────────────────────────────────────────────────┘
```

**Positionnement** :
- Les champs d'heures sont placés **juste après** le sélecteur de dates
- En **2 colonnes** : "Heure de début" | "Heure de fin"
- Chaque champ utilise le composant `TimePickerPopup` (horloge circulaire AURA)

---

## 🔄 Format des données

### Base de données
```sql
-- Table events
CREATE TABLE events (
  id UUID PRIMARY KEY,
  company_id UUID NOT NULL,
  name TEXT NOT NULL,
  start_date DATE,
  end_date DATE,
  starts_at TIMESTAMPTZ,  -- ✅ Timestamp avec timezone (ex: "2025-10-31T10:00:00+00:00")
  ends_at TIMESTAMPTZ,    -- ✅ Timestamp avec timezone (ex: "2025-11-02T23:59:00+00:00")
  -- ...
);
```

### Formulaire → Base de données
```typescript
// Formulaire
start_date: "2025-10-31"
start_time: "10:00"

// → Combiné en timestamp ISO
starts_at: "2025-10-31T10:00:00+00:00"
```

### Base de données → Formulaire
```typescript
// Base de données
starts_at: "2025-10-31T10:00:00+00:00"

// → Extrait en date et heure
start_date: "2025-10-31"
start_time: "10:00"
```

---

## 🧪 Tests à effectuer

### Test 1 : Création d'événement avec heures
1. Aller sur `/app/settings/events`
2. Cliquer sur "Ajouter un évènement"
3. Remplir :
   - Nom : "Festival Test 2026"
   - Dates : 31 octobre - 2 novembre 2025
   - **Heure de début** : 10:00 ✅
   - **Heure de fin** : 23:59 ✅
4. Cliquer sur "Enregistrer"
5. ✅ **Résultat attendu** : Événement créé avec `starts_at` et `ends_at` correctement enregistrés

### Test 2 : Édition des heures d'un événement existant
1. Cliquer sur le bouton "✏️" d'un événement
2. ✅ **Résultat attendu** : Les champs d'heures affichent les valeurs actuelles (ex: 10:00 et 23:59)
3. Modifier les heures :
   - Heure de début : 09:00
   - Heure de fin : 02:00
4. Cliquer sur "Enregistrer"
5. ✅ **Résultat attendu** : Les heures sont mises à jour dans la base de données

### Test 3 : Valeurs par défaut en création
1. Créer un nouvel événement sans modifier les heures
2. ✅ **Résultat attendu** : 
   - Heure de début par défaut : 10:00
   - Heure de fin par défaut : 23:59

---

## 📝 Différence avec les heures des jours

| Type | Champ | Description | Exemple |
|------|-------|-------------|---------|
| **Événement global** | `starts_at` / `ends_at` | Timestamp global de l'événement entier | "2025-10-31T10:00:00+00:00" |
| **Jours individuels** | `open_time` / `close_time` | Heures d'ouverture/fermeture de chaque jour | "17:00" / "03:00" |

**Cas d'usage** :
- **Heures globales** (`starts_at`/`ends_at`) : Pour la durée totale du festival (ex: du 31 octobre 10h au 2 novembre 23h59)
- **Heures des jours** (`open_time`/`close_time`) : Pour les horaires d'ouverture de chaque journée (ex: J1 de 17h à 03h, J2 de 17h à 03h, J3 de 17h à 03h)

---

## 🔍 Détails techniques

### Gestion du timezone
- **Format stocké** : ISO 8601 avec timezone UTC (`+00:00`)
- **Format affiché** : HH:MM (24h)
- **Extraction** : Utilisation de `Date.getHours()` et `Date.getMinutes()` sur l'objet `Date` JavaScript
- **Combinaison** : Concaténation manuelle `${date}T${time}:00+00:00`

### Composant utilisé
- **`TimePickerPopup`** : Horloge circulaire AURA (format 24h)
- **`Controller`** : Intégration avec `react-hook-form` pour la validation

### Règles de validation
- **Aucune** : Les champs sont optionnels
- **Note** : Si `start_date` ou `start_time` manquent, `starts_at` sera `null`

---

## ✅ Résultat

Avant les modifications, seules les **dates** pouvaient être éditées dans le formulaire.

Maintenant, l'utilisateur peut éditer **dates ET heures** pour :
- ✅ Définir l'heure de début de l'événement (ex: 10:00)
- ✅ Définir l'heure de fin de l'événement (ex: 23:59)
- ✅ Différencier l'horaire global de l'événement des horaires d'ouverture quotidiens

---

**Date de modification** : 30 octobre 2025  
**Status** : ✅ Implémenté et prêt pour tests  
**Fichiers modifiés** :
- `src/types/event.ts`
- `src/features/settings/events/EventForm.tsx`


