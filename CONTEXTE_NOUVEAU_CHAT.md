# 📋 Contexte pour nouveau chat - Go-Prod AURA

**Date** : 2025-10-28  
**Projet** : Go-Prod AURA - Plateforme SaaS multi-tenant pour gestion d'événements/festivals  
**Stack** : React + TypeScript + Vite + Supabase + Tailwind CSS

---

## 🎯 État actuel du projet

### Architecture générale
- **Multi-tenant** : Supabase RLS avec `auth_company_id()` dans JWT
- **Event-driven** : Event store Zustand (`useEventStore`) + localStorage (`selected_event_id`)
- **Design System** : AURA (dark/light mode, composants standardisés)
- **Routing** : React Router DOM avec routes `/app/*` et `/administration/*`

### Modules implémentés
1. **Artistes** (`/app/artists`) - COMPLET
2. **Booking** (`/app/booking`) - Kanban 5 colonnes, drag&drop, PDF, email
3. **Timeline** (`/app/lineup/timeline`) - Grille horaire, performances, drag&drop
4. **Paramètres** (`/app/settings/*`) - Tabs persistants (general, events, artists, etc.)

### Dernières modifications (ce chat)
- ✅ Standardisation des inputs compacts (36px par défaut)
- ✅ Standardisation des pickers AURA en mode popup
- ✅ Création automatique des jours d'événement
- ✅ Modal "Créer un évènement" avec affichage des jours inline

---

## 🎨 Standards de design AURA à respecter ABSOLUMENT

### 1. Pickers (date/time) - STANDARD OBLIGATOIRE

**⚠️ RÈGLE CRITIQUE** : **TOUJOURS** utiliser les pickers popup AURA, **JAMAIS** d'autres solutions.

#### Composants standard (déjà créés et documentés)

```typescript
// À TOUJOURS utiliser pour les dates
import { DatePickerPopup } from '@/components/ui/pickers/DatePickerPopup';

// À TOUJOURS utiliser pour les heures
import { TimePickerPopup } from '@/components/ui/pickers/TimePickerPopup';

// À utiliser pour date + heure combinées
import { DateTimePickerPopup } from '@/components/ui/pickers/DateTimePickerPopup';
```

#### Caractéristiques des pickers AURA popup

**Dimensions** :
- `DatePickerPopup` : 330x380px
- `TimePickerPopup` : 300x380px
- `DateTimePickerPopup` : 630x380px (horizontal)

**Features** :
- ✅ Popup sur fond semi-transparent avec shadow (pas de blur)
- ✅ Top bar violet avec titre
- ✅ Footer violet avec "Annuler", "Effacer", "OK"
- ✅ Pastilles de sélection pleines et rondes
- ✅ Police Manrope (AURA)
- ✅ Dark/Light mode automatique
- ✅ Pas de scrollbar
- ✅ Fermeture avec Escape ou clic extérieur
- ✅ Navigation mois/années pour DatePicker
- ✅ Cercles heures/minutes pour TimePicker (24h)

**Usage avec react-hook-form** :

```typescript
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

<Controller
  name="start_time"
  control={control}
  render={({ field }) => (
    <TimePickerPopup
      label="Heure de début"
      value={field.value}
      onChange={(time) => field.onChange(time)}
      disabled={saving}
    />
  )}
/>
```

#### Composants dépréciés (NE PLUS UTILISER)

```typescript
// ❌ DEPRECATED - Ne plus utiliser
import { DatePickerAura } from '@/components/ui/DatePickerAura';
import { TimePickerCircular24 } from '@/components/ui/TimePickerCircular24';
import { DateTimePickerAura } from '@/components/ui/DateTimePickerAura';
```

**Documentation** : `PICKERS_STANDARD.md`

---

### 2. Inputs - STANDARD OBLIGATOIRE

#### Taille par défaut : **36px** (compact)

```typescript
import { Input } from '@/components/ui/Input';

// Utilisation standard (36px par défaut)
<Input
  label="Nom"
  placeholder="Entrez le nom..."
  {...register('name')}
/>

// Forcer la taille normale (44px) si nécessaire
<Input
  label="Nom"
  size="default"
  {...register('name')}
/>
```

**CSS** : `.input-sm` dans `src/styles/utilities.css`
- Hauteur : 36px
- Padding : 0.65rem
- Border-radius : 10px
- Font-size : 0.875rem

**Documentation** : `INPUT_SM_DEFAULT_GLOBAL.md`

---

### 3. Modals - STANDARD OBLIGATOIRE

```typescript
import Modal, { ModalFooter, ModalButton } from '@/components/ui/Modal';

<Modal
  isOpen={open}
  onClose={handleClose}
  title="Titre du modal"
  size="lg"  // sm, md, lg, xl
  draggable={true}
  footer={
    <ModalFooter>
      <ModalButton variant="secondary" onClick={handleClose}>
        Annuler
      </ModalButton>
      <ModalButton
        variant="primary"
        onClick={handleSubmit}
        loading={saving}
      >
        <Save className="w-4 h-4 mr-2" />
        Enregistrer
      </ModalButton>
    </ModalFooter>
  }
>
  {/* Contenu */}
</Modal>
```

**Tailles** :
- `sm` : 400px
- `md` : 600px
- `lg` : 800px
- `xl` : 1000px

**Features** :
- ✅ Draggable (si activé)
- ✅ Footer sticky
- ✅ Scrollable content
- ✅ Dark/Light mode
- ✅ Backdrop semi-transparent

---

### 4. Boutons AURA

```typescript
import { Button } from '@/components/ui/Button';

// Variants
<Button variant="primary">Action principale</Button>
<Button variant="secondary">Action secondaire</Button>
<Button variant="ghost">Action discrète</Button>

// Sizes
<Button size="sm">Petit</Button>
<Button size="md">Moyen</Button>
<Button size="lg">Grand</Button>

// States
<Button loading={saving}>Enregistrement...</Button>
<Button disabled={true}>Désactivé</Button>
```

---

### 5. Autres composants AURA standards

```typescript
// Cards
import { Card } from '@/components/ui/Card';

// Select
import { Select } from '@/components/ui/Select';

// Textarea
import { Textarea } from '@/components/ui/Textarea';

// Badge
import { Badge } from '@/components/ui/Badge';

// Toast
import { useToast } from '@/components/aura/ToastProvider';
const { success, error } = useToast();

// EmptyState
import { EmptyState } from '@/components/aura/EmptyState';
```

---

## 🗄️ Gestion des événements

### Event Store (Zustand)

```typescript
import { useEventStore } from '@/store/useEventStore';

// Dans un composant
const currentEvent = useEventStore((state) => state.currentEvent);
const setCurrentEvent = useEventStore((state) => state.setCurrentEvent);
const currentCompanyId = useEventStore((state) => state.currentCompanyId);
```

**Propagation** : Changements propagés via `CustomEvent('event-changed')` + localStorage

### Hooks utilitaires

```typescript
import { useCurrentEvent } from '@/hooks/useCurrentEvent';

const { currentEvent, eventId, companyId, hasEvent, requireEventGuard } = useCurrentEvent();

// No-event safe mode
if (!hasEvent) {
  return <EmptyState title="Aucun événement" />;
}
```

### Création automatique des jours

**Règle métier** : Un jour d'événement commence à sa date mais peut se terminer le lendemain.

**Exemple** : Festival du 30 oct au 1er nov
- J1 = 30/10 (17:00 → 03:00 le 31/10)
- J2 = 31/10 (17:00 → 03:00 le 01/11)
- J3 = 01/11 (17:00 → 03:00 le 02/11)

**Implémentation** : Dans `EventForm.tsx`, `useEffect` surveille `start_date` et `end_date` et génère automatiquement les jours avec horaires par défaut.

**Documentation** : `EVENT_AUTO_DAYS_CREATION.md`

---

## 📁 Structure des fichiers

### Pages principales

```
src/pages/
├── ArtistsPage.tsx              # /app/artists
├── BookingPage.tsx              # /app/booking
├── LineupTimelinePage.tsx       # /app/lineup/timeline
└── settings/
    ├── SettingsLayout.tsx       # Layout avec tabs
    ├── SettingsEventsPage.tsx   # /app/settings/events
    ├── SettingsGeneralPage.tsx  # /app/settings/general
    └── ...
```

### Features

```
src/features/
├── booking/
│   ├── bookingApi.ts            # API Supabase
│   ├── bookingTypes.ts          # Types TypeScript
│   ├── KanbanBoard.tsx          # Kanban drag&drop
│   ├── OffersListView.tsx       # Vue liste
│   └── modals/
│       ├── OfferComposer.tsx    # Modal offre
│       ├── PerformanceModal.tsx # Modal performance
│       ├── SendOfferModal.tsx   # Modal envoi email
│       └── RejectOfferModal.tsx # Modal rejet
├── timeline/
│   ├── timelineApi.ts           # API Supabase
│   └── components/
│       ├── TimelineGrid.tsx     # Grille horaire
│       ├── PerformanceCard.tsx  # Cartes performances
│       └── CustomTimePicker.tsx # Picker temps custom
└── settings/
    └── events/
        ├── EventForm.tsx        # Modal création/édition événement
        └── EventQuickCreateModal.tsx # Modal rapide (depuis header)
```

### Composants UI AURA

```
src/components/
├── ui/
│   ├── Button.tsx
│   ├── Input.tsx                # Default size='sm' (36px)
│   ├── Select.tsx
│   ├── Textarea.tsx
│   ├── Modal.tsx
│   ├── Card.tsx
│   ├── Badge.tsx
│   └── pickers/
│       ├── DatePickerPopup.tsx  # ✅ STANDARD
│       ├── TimePickerPopup.tsx  # ✅ STANDARD
│       └── DateTimePickerPopup.tsx # ✅ STANDARD
└── aura/
    ├── ToastProvider.tsx        # Toast system site-wide
    └── EmptyState.tsx           # État vide
```

---

## 🔧 API Supabase

### Fonctions RPC principales

```typescript
// Events
fn_list_offers(p_company_id, p_event_id)
fn_move_offer(p_offer_id, p_new_status)
fn_send_offer_prepare(p_offer_id)
fn_booking_todo_performances(p_company_id, p_event_id)
fn_booking_rejected_performances(p_company_id, p_event_id)
generate_slug(p_name)

// CRUD
src/api/eventsApi.ts
- createEvent(data)
- updateEvent(id, data)
- loadFullEvent(id)
- replaceEventDays(eventId, days)
- replaceEventStages(eventId, stages)
- generateSlugServerSide(name)
```

### Tables principales

```sql
-- Events
events (id, company_id, name, slug, color_hex, start_date, end_date, notes, status)
event_days (id, event_id, date, open_at, close_at, is_closing_day, display_order, notes)
event_stages (id, event_id, name, type, capacity, display_order, notes)

-- Artists
artists (id, company_id, name, spotify_id, ...)
artist_performances (id, artist_id, event_id, event_day_id, event_stage_id, performance_time, duration, fee_amount, fee_currency, booking_status)

-- Booking
offers (id, company_id, event_id, artist_id, offer_status, pdf_storage_path, ...)
offer_versions (id, offer_id, version_number, ...)
```

---

## 🎯 Règles de développement

### 1. Multi-tenant OBLIGATOIRE

```typescript
// ✅ TOUJOURS passer company_id
const { data } = await supabase
  .from('events')
  .select('*')
  .eq('company_id', companyId);

// ✅ TOUJOURS vérifier company_id avant API call
if (!companyId) {
  toastError('ID de l\'entreprise manquant.');
  return;
}
```

### 2. No-event safe mode

```typescript
// ✅ TOUJOURS gérer l'absence d'événement
const { hasEvent, requireEventGuard } = useCurrentEvent();

if (!hasEvent) {
  return <EmptyState
    title="Aucun événement sélectionné"
    description="Créez ou sélectionnez un événement pour continuer."
    action={<Button onClick={openEventModal}>Créer un événement</Button>}
  />;
}
```

### 3. Toasts AURA

```typescript
import { useToast } from '@/components/aura/ToastProvider';

const { success, error, warning, info } = useToast();

// Dans un try/catch
try {
  await createEvent(data);
  success('Événement créé avec succès');
} catch (err: any) {
  error(err.message || 'Erreur lors de la création');
}
```

### 4. react-hook-form standard

```typescript
import { useForm, useFieldArray, Controller } from 'react-hook-form';

const {
  control,
  register,
  handleSubmit,
  reset,
  formState: { errors },
  setValue,
  watch,
} = useForm<FormData>({
  defaultValues: { ... }
});

// Pour arrays dynamiques
const { fields, append, remove } = useFieldArray({
  control,
  name: 'days',
});

// Pour composants externes (pickers)
<Controller
  name="start_date"
  control={control}
  render={({ field }) => (
    <DatePickerPopup
      value={field.value}
      onChange={field.onChange}
    />
  )}
/>
```

### 5. Dark/Light mode

```typescript
// ✅ Utiliser les variables CSS AURA
<div style={{ color: 'var(--color-text-primary)' }}>
<div style={{ backgroundColor: 'var(--color-bg-surface)' }}>

// ✅ Utiliser les classes Tailwind dark:
<div className="text-gray-900 dark:text-white">
<div className="bg-white dark:bg-gray-900">
```

---

## 📚 Documentation disponible

### Docs techniques
- `PICKERS_STANDARD.md` - Standard pickers popup AURA ⭐
- `INPUT_SM_DEFAULT_GLOBAL.md` - Standard inputs compacts ⭐
- `EVENT_AUTO_DAYS_CREATION.md` - Création auto des jours ⭐
- `AURA_PICKERS_POPUP_MODE.md` - Détails pickers popup
- `EVENT_MANAGEMENT_SYSTEM.md` - Système de gestion événements
- `BOOKING_MODULE.md` - Module Booking complet
- `TIMELINE_BOOKING.md` - Timeline avec drag&drop

### Docs métier
- `START_HERE.md` - Point d'entrée projet
- `DEV_SETUP.md` - Setup développement
- `ROUTES-MAP.md` - Cartographie des routes
- `STRUCTURE-PAGES.md` - Structure des pages

---

## 🚀 Commandes utiles

```bash
# Développement (port 5180)
npm run dev

# Build production
npm run build

# Preview production
npm run preview

# Linter
npm run lint

# Clear cache + restart (si hot reload bloqué)
# Utiliser: clear-cache-and-restart.bat (Windows)
```

---

## ⚠️ Points d'attention

### 1. Pickers : TOUJOURS les popup AURA
- ❌ Ne JAMAIS créer de nouveaux date/time pickers
- ✅ TOUJOURS utiliser `DatePickerPopup`, `TimePickerPopup`, `DateTimePickerPopup`
- 📖 Voir `PICKERS_STANDARD.md` pour tous les détails

### 2. Inputs : 36px par défaut
- ✅ `Input` utilise `size='sm'` par défaut (36px)
- ✅ `DatePickerPopup` et `TimePickerPopup` aussi 36px par défaut
- ✅ Utiliser `size='default'` uniquement si besoin de 44px

### 3. Jours d'événement : Règle du lendemain
- ✅ Un jour commence à sa date mais peut finir le lendemain
- ✅ J1 = 30/10 (17:00 → 03:00 le 31/10)
- ✅ Performances après minuit appartiennent au jour précédent
- 📖 Voir `EVENT_AUTO_DAYS_CREATION.md`

### 4. Event store : Toujours synchroniser
- ✅ Après création/édition event : `setCurrentEvent(fullEvent)`
- ✅ Sauvegarder dans localStorage : `localStorage.setItem('selected_event_id', id)`
- ✅ Propager : `window.dispatchEvent(new CustomEvent('event-changed'))`

### 5. Multi-tenant : JAMAIS oublier company_id
- ✅ Toutes les requêtes Supabase doivent filtrer par `company_id`
- ✅ Vérifier `companyId` avant chaque appel API
- ✅ Toast erreur si `companyId` manquant

---

## 🎬 État du modal "Créer un événement" (dernière version)

### Layout actuel

```
┌─────────────────────────────────────────────────────┐
│ Créer un événement                            [X]   │
├─────────────────────────────────────────────────────┤
│ [Info] [Jours (3)] [Scènes (1)]                    │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Nom de l'événement                                  │
│ [Festival 2026                                 ]    │
│                                                     │
│ Date de début    Date de fin      📅 3 jours       │
│ [29/10/2025]    [31/10/2025]      [Badge 36px]     │
│                                                     │
│ ┌─────────────────────────────────────────────────┐│
│ │ 💡 3 jours créés automatiquement (17:00-03:00)  ││
│ │ Chaque jour commence à sa date et peut se       ││
│ │ terminer le lendemain.                          ││
│ └─────────────────────────────────────────────────┘│
│                                                     │
│ [J1 - 29/10]     [17:00 🕐]      [03:00 🕐]        │
│ [J2 - 30/10]     [17:00 🕐]      [03:00 🕐]        │
│ [J3 - 31/10]     [17:00 🕐]      [03:00 🕐]        │
│                                                     │
│ Notes                                               │
│ [                                              ]    │
│                                                     │
├─────────────────────────────────────────────────────┤
│                         [Annuler] [Enregistrer]    │
└─────────────────────────────────────────────────────┘
```

### Features
- ✅ Tabs : Info / Jours / Scènes
- ✅ Badge "3 jours" aligné avec inputs (36px)
- ✅ Jours affichés directement dans tab "Info" (pas de bascule auto)
- ✅ Layout 3 colonnes : Badge jour | Heure début | Heure fin
- ✅ Génération automatique des jours dès sélection des dates
- ✅ Horaires modifiables via `TimePickerPopup`
- ✅ Hauteur minimale 36px pour tous les champs

---

## 🎯 Convention de nommage

### Composants
```typescript
// Pages : PascalCase + "Page"
ArtistsPage.tsx
BookingPage.tsx
SettingsEventsPage.tsx

// Composants : PascalCase
EventForm.tsx
KanbanBoard.tsx
PerformanceCard.tsx

// Modals : PascalCase + "Modal"
EventQuickCreateModal.tsx
PerformanceModal.tsx
SendOfferModal.tsx
```

### Fichiers API
```typescript
// API : camelCase + "Api"
eventsApi.ts
bookingApi.ts
timelineApi.ts

// Types : camelCase + "Types"
bookingTypes.ts
eventTypes.ts
```

### Hooks
```typescript
// Hooks : camelCase avec "use" prefix
useCurrentEvent.ts
useEventStore.ts
useGlobalSearch.ts
```

---

## 🧪 Tests de validation essentiels

### 1. Pickers popup
- ✅ Clic sur input ouvre popup (330x380 ou 300x380)
- ✅ Sélection valide et ferme popup
- ✅ Escape ferme popup
- ✅ Clic extérieur ferme popup
- ✅ Dark/Light mode cohérent
- ✅ Pas de scrollbar visible

### 2. Création événement
- ✅ Sélection dates génère X jours automatiquement
- ✅ Badge "X jours" affiché et aligné (36px)
- ✅ Liste jours en 3 colonnes (Badge | Début | Fin)
- ✅ Horaires modifiables avec `TimePickerPopup`
- ✅ Validation : end_date >= start_date
- ✅ Enregistrement : RPC Supabase + store + localStorage

### 3. Multi-tenant
- ✅ company_id toujours présent dans queries
- ✅ Toast erreur si company_id manquant
- ✅ Données isolées entre companies

### 4. No-event safe mode
- ✅ EmptyState si pas d'event sélectionné
- ✅ Bouton "Créer événement" visible
- ✅ Pas de crash si eventId null

---

## 🔄 Workflow typique d'ajout d'une nouvelle feature

### 1. Définir les besoins
- Page principale ? Modal ? Composant ?
- CRUD ? Lecture seule ?
- Multi-tenant ? Event-dependent ?

### 2. Créer les types
```typescript
// src/types/myFeature.ts
export interface MyEntity {
  id: string;
  company_id: string;
  event_id?: string;
  name: string;
  // ...
}
```

### 3. Créer l'API
```typescript
// src/api/myFeatureApi.ts
import { supabase } from '@/lib/supabaseClient';

export async function fetchMyEntities(companyId: string, eventId?: string) {
  const { data, error } = await supabase
    .from('my_table')
    .select('*')
    .eq('company_id', companyId)
    .order('created_at', { ascending: false });
  
  if (error) throw new Error(error.message);
  return data;
}
```

### 4. Créer le composant/page
```typescript
// src/pages/MyFeaturePage.tsx
import { useCurrentEvent } from '@/hooks/useCurrentEvent';
import { useToast } from '@/components/aura/ToastProvider';

export function MyFeaturePage() {
  const { companyId, eventId, hasEvent } = useCurrentEvent();
  const { success, error } = useToast();
  
  if (!hasEvent) {
    return <EmptyState title="Aucun événement sélectionné" />;
  }
  
  // ... reste du code
}
```

### 5. Utiliser les composants AURA
- ✅ `Input` (36px par défaut)
- ✅ `DatePickerPopup` / `TimePickerPopup`
- ✅ `Button` (variants: primary, secondary, ghost)
- ✅ `Modal` (sizes: sm, md, lg, xl)
- ✅ `useToast()` pour feedback
- ✅ Dark/Light mode automatique

### 6. Ajouter la route
```typescript
// src/App.tsx
<Route path="/app/my-feature" element={<MyFeaturePage />} />
```

### 7. Ajouter au menu
```typescript
// src/layout/AppLayout.tsx ou src/components/layout/Sidebar.tsx
<NavLink to="/app/my-feature">Ma Feature</NavLink>
```

---

## 📦 Dépendances principales

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.x",
    "react-hook-form": "^7.x",
    "@supabase/supabase-js": "^2.x",
    "zustand": "^4.x",
    "lucide-react": "^0.x",
    "dayjs": "^1.x",
    "@dnd-kit/core": "^6.x",
    "@dnd-kit/sortable": "^7.x",
    "pdf-lib": "^1.x",
    "@emailjs/browser": "^3.x",
    "classnames": "^2.x"
  },
  "devDependencies": {
    "vite": "^5.x",
    "typescript": "^5.x",
    "tailwindcss": "^3.x",
    "eslint": "^8.x"
  }
}
```

---

## 🎓 Philosophie AURA

### 1. Cohérence visuelle
- Toujours utiliser les composants AURA existants
- Ne pas créer de variantes non documentées
- Respecter les tailles et espacements standards

### 2. Accessibilité
- Labels visibles sur tous les inputs
- États disabled/loading clairs
- Navigation au clavier (Tab, Enter, Escape)
- ARIA labels sur composants complexes

### 3. Performance
- Lazy loading des pages lourdes
- Optimistic UI updates
- Debounce sur les recherches
- Pagination sur grandes listes

### 4. UX
- Toasts pour tous les feedbacks
- Loading states explicites
- Empty states descriptifs
- Erreurs compréhensibles

---

## ✅ Checklist avant chaque commit

- [ ] Tous les pickers sont des popup AURA
- [ ] Tous les inputs sont 36px (sauf exception justifiée)
- [ ] company_id présent dans toutes les queries
- [ ] No-event safe mode implémenté
- [ ] Toasts success/error présents
- [ ] Dark/Light mode testé
- [ ] react-hook-form utilisé pour formulaires
- [ ] Types TypeScript définis
- [ ] Pas d'erreurs ESLint
- [ ] Documentation mise à jour si nécessaire

---

## 🚀 Prêt pour nouveau chat !

**Ce fichier contient TOUT le contexte nécessaire pour démarrer un nouveau chat efficacement.**

**Standards à rappeler systématiquement** :
1. **Pickers popup AURA** (`PICKERS_STANDARD.md`)
2. **Inputs 36px par défaut** (`INPUT_SM_DEFAULT_GLOBAL.md`)
3. **Création auto des jours** (`EVENT_AUTO_DAYS_CREATION.md`)
4. **Multi-tenant + No-event safe mode**
5. **Composants AURA uniquement**

**Bon développement ! 🎉**


