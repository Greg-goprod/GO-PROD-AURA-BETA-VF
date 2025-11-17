# Timeline Booking - Documentation complète

## 🎯 Vue d'ensemble

Le système Timeline Booking permet de visualiser et gérer les performances artistes dans une interface temporelle intuitive avec drag & drop.

### Fonctionnalités principales
- **Timeline visuelle** : Grille jours × scènes avec bande horaire
- **Drag & Drop** : Déplacement des performances avec snapping 5 minutes
- **Modaux AURA** : Création/édition/suppression des performances
- **Mode démo** : Fonctionne sans event_id avec données fictives
- **Synchronisation** : Écoute des changements d'offres depuis BookingPage

## 📁 Architecture

```
src/
├── features/timeline/
│   ├── timelineApi.ts              # API Supabase + helpers
│   └── components/
│       ├── TimelineGrid.tsx        # Grille principale
│       ├── PerformanceCard.tsx     # Cartes draggables
│       ├── DailySummaryCards.tsx   # Résumé quotidien
│       └── CustomTimePicker.tsx    # Sélecteur temps plein écran
├── pages/
│   └── LineupTimelinePage.tsx      # Page principale
└── components/aura/
    ├── EmptyState.tsx              # État vide
    └── Input.tsx                   # Input AURA
```

## 🔧 API Timeline

### Fonctions principales
- `fetchEventDays(eventId)` → Jours de l'événement
- `fetchEventStages(eventId)` → Scènes ordonnées
- `fetchPerformances(eventId)` → Performances (exclut rejetées)
- `fetchOffersLight(eventId)` → Map statuts pour couleurs
- `updatePerformance(data)` → Mise à jour position/temps
- `createPerformance(data)` → Création nouvelle performance
- `deletePerformance(id)` → Suppression

### Helpers
- `minToHHMM(minutes)` → Format "HH:MM"
- `hhmmToMin(time)` → Minutes depuis minuit
- `snapTo5(minutes)` → Arrondi 5 minutes
- `minutesSinceOpen(time, openTime)` → Minutes depuis ouverture
- `calculateDayDuration(open, close)` → Durée jour (gère overnight)

## 🎨 Composants UI

### TimelineGrid
- **Responsabilités** : Grille principale avec DnD
- **Props** : days, stages, performances + handlers
- **Fonctionnalités** :
  - Header avec jours et heures
  - Colonne scènes à gauche
  - Zones de drop par cellule jour/scène
  - Calcul positionnement absolu des cartes

### PerformanceCard
- **Responsabilités** : Carte draggable individuelle
- **Props** : performance, day, stage + handlers
- **Fonctionnalités** :
  - Positionnement calculé (left, top, width)
  - Couleurs selon booking_status
  - Actions : horloge (time picker), poubelle (suppression)
  - Tooltip avec infos complètes

### DailySummaryCards
- **Responsabilités** : Résumé statistiques par jour
- **Props** : days, performances
- **Fonctionnalités** :
  - Compteur performances par jour
  - Total cachets par devise
  - Barre progression (max 10 performances)
  - Horaires ouverture/fermeture

### CustomTimePicker
- **Responsabilités** : Sélecteur temps plein écran
- **Props** : performance, handlers
- **Fonctionnalités** :
  - Inputs heure et durée
  - Snapping automatique 5 minutes
  - Aperçu temps de fin
  - Validation (5-480 minutes)

## 🚀 Page principale

### LineupTimelinePage
- **Mode Safe** : EmptyState si pas d'event_id
- **Mode Démo** : Données fictives en mémoire
- **Mode Production** : Chargement Supabase
- **Écoute** : offer-status-changed → reload
- **Handlers** : CRUD complet + DnD

### États
- `demoMode` : Toggle mode démo/production
- `days`, `stages`, `performances` : Données principales
- `showPerformanceModal`, `showTimePicker` : États modaux
- `selectedPerformance` : Performance en cours d'édition

## 🎯 Workflow utilisateur

### 1. Accès
- **Depuis BookingPage** : Bouton "📅 Ouvrir la timeline"
- **URL directe** : `/app/lineup/timeline`
- **Nouvel onglet** : `window.open('/app/lineup/timeline', '_blank')`

### 2. Mode sans événement
- EmptyState avec bouton "Activer le mode démo"
- Chargement données fictives
- Toutes les fonctionnalités disponibles

### 3. Création performance
- **Clic cellule vide** → Modal préremplie
- **Bouton "+ Performance"** → Modal vierge
- **Sauvegarde** → Ajout à la timeline

### 4. Édition performance
- **Clic carte** → Modal avec données
- **Icône horloge** → Time picker plein écran
- **Modification** → Mise à jour immédiate

### 5. Déplacement performance
- **Drag & Drop** → Nouvelle position
- **Snapping 5min** → Alignement automatique
- **Sauvegarde** → Persistance en base

## 🎨 Design AURA

### Couleurs statuts
- **offre_a_faire** : Ambre (`bg-amber-100`, `border-amber-300`)
- **offre_envoyee/sent** : Bleu (`bg-blue-100`, `border-blue-300`)
- **offre_validee/accepted** : Vert (`bg-green-100`, `border-green-300`)

### Composants utilisés
- `Card` : Conteneurs principaux
- `Button` : Actions (primary, secondary, ghost)
- `Badge` : Statuts et compteurs
- `Modal` : Fenêtres modales
- `Toast` : Notifications (success, error)
- `EmptyState` : État vide
- `Input` : Champs de saisie

### Responsive
- **Desktop** : Grille complète avec scroll horizontal
- **Mobile** : Adaptation des colonnes et cartes
- **Tablet** : Optimisation des tailles

## 🔒 Sécurité

### Guards
- `noEventGuard(eventId)` : Retourne `[]` si pas d'event
- **Mode démo** : Aucun appel Supabase
- **Validation** : Snapping, limites durée, formats

### Multi-tenant
- **Scoping** : Toutes les requêtes par `company_id` + `event_id`
- **RLS** : Politiques Supabase sur toutes les tables
- **Isolation** : Données séparées par entreprise

## 📊 Performance

### Optimisations
- **useMemo** : Calculs coûteux (groupements, positions)
- **Lazy loading** : Chargement parallèle des données
- **Debouncing** : Éviter les appels multiples
- **Local updates** : Mise à jour UI avant sauvegarde

### Limitations
- **Max performances** : 10 par jour (barre progression)
- **Durée max** : 480 minutes (8h)
- **Snapping** : 5 minutes minimum

## 🧪 Tests

### Tests manuels
1. **Mode démo** : Toutes les fonctionnalités sans Supabase
2. **Drag & Drop** : Déplacement avec snapping
3. **Modaux** : Création/édition/suppression
4. **Responsive** : Adaptation mobile/tablet
5. **Mode production** : Avec vraies données

### URLs de test
- **Booking** : `http://localhost:5174/app/booking`
- **Timeline** : `http://localhost:5174/app/lineup/timeline`

## 🚀 Déploiement

### Dépendances
```bash
npm install @dnd-kit/core @dnd-kit/modifiers @dnd-kit/sortable
```

### Variables d'environnement
- **Supabase** : `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`
- **Event ID** : `localStorage.getItem('selected_event_id')`

### Routes
- **Timeline** : `/app/lineup/timeline`
- **Booking** : `/app/booking` (avec bouton timeline)

## 🔮 Évolutions futures

### Fonctionnalités
- **Zoom** : Niveaux de détail temporel
- **Filtres** : Par statut, artiste, scène
- **Export** : PDF/Excel de la timeline
- **Notifications** : Alertes conflits horaires

### Intégrations
- **Contrats** : Synchronisation avec offres acceptées
- **Budget** : Calculs automatiques des cachets
- **Finances** : Facturation des performances
- **Communication** : Notifications aux artistes

### Performance
- **Virtualisation** : Pour gros volumes de données
- **Caching** : Mise en cache des données
- **Real-time** : Synchronisation temps réel
- **Offline** : Mode hors ligne avec sync

## 📞 Support

### Dépannage
- **Console** : Logs détaillés des actions
- **Mode démo** : Test sans dépendances externes
- **Documentation** : `TEST_TIMELINE_GUIDE.md`

### Contact
- **Issues** : Via le système de tickets
- **Documentation** : Guides techniques disponibles
- **Tests** : Scripts automatisés disponibles

