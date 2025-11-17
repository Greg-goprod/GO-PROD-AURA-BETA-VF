# ARCHITECTURE DU SYSTÈME PRODUCTION

## Vue d'ensemble

Le module **PRODUCTION** est le cœur opérationnel de GO-PROD. Il gère l'ensemble de la logistique et de l'organisation nécessaire à la réalisation d'un événement, de l'arrivée des artistes jusqu'à leur départ, en passant par l'hébergement, la restauration, les transports et l'accueil.

## Structure du Module

Le module Production est organisé en **7 sous-modules principaux** :

```
PRODUCTION
├── TOURING PARTY     → Gestion des équipes d'artistes
├── TRAVELS          → Gestion des voyages (avion, train, véhicules)
├── GROUND           → Logistique terrestre (4 sous-modules)
│   ├── MISSIONS     → Transferts et missions de transport
│   ├── DRIVERS      → Gestion des chauffeurs
│   ├── VEHICLES     → Gestion de la flotte
│   └── SHIFTS       → Planification des équipes
├── HOSPITALITY      → Accueil et services (4 sous-modules)
│   ├── HOTELS       → Réservations hôtelières
│   ├── BACKSTAGE    → Gestion des loges
│   ├── CATERING     → Restauration artistes
│   └── ACCRED-INVITS → Accréditations et invitations
├── TECHNIQUE        → Aspects techniques (en développement)
├── TIMETABLE        → Planning temporel (en développement)
└── PARTY CREW       → Équipe festive (en développement)
```

---

## 1. TOURING PARTY - Gestion des Équipes

### Objectif
Gérer la taille et la composition des équipes accompagnant chaque artiste, ainsi que leurs besoins en véhicules.

### Composants Principaux

#### Page : `TouringPartyPage.tsx`
- **Rôle** : Interface principale pour gérer les touring parties par jour d'événement
- **Fonctionnalités** :
  - Vue par jour d'événement (accordéons)
  - Dashboard récapitulatif (stats globales)
  - Édition en ligne du nombre de personnes
  - Gestion des véhicules requis par type
  - Calcul automatique du statut (`todo`, `incomplete`, `completed`)

#### Base de Données : `artist_touring_party`

```sql
CREATE TABLE artist_touring_party (
  id UUID PRIMARY KEY,
  event_id UUID REFERENCES events(id),
  artist_id UUID REFERENCES artists(id),
  performance_date DATE,
  group_size INTEGER DEFAULT 0,
  vehicles JSONB DEFAULT '[]', -- Array de {type, count}
  notes TEXT,
  special_requirements TEXT,
  status TEXT CHECK (status IN ('todo', 'incomplete', 'completed')),
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

**Champs clés** :
- `group_size` : Nombre total de personnes dans l'équipe
- `vehicles` : Structure JSON : `[{type: 'CAR', count: 2}, {type: 'VAN', count: 1}]`
- `performance_date` : Date de la performance associée
- `status` : Calculé automatiquement selon les données renseignées

#### Types de Véhicules Supportés

```typescript
const VEHICLE_TYPES = [
  { value: 'CAR', label: 'Voiture' },
  { value: 'VAN', label: 'Van' },
  { value: 'VAN_TRAILER', label: 'Van + Remorque' },
  { value: 'TOURBUS', label: 'Tourbus' },
  { value: 'TOURBUS_TRAILER', label: 'Tourbus + Remorque' },
  { value: 'TRUCK', label: 'Camion' },
  { value: 'TRUCK_TRAILER', label: 'Camion + Remorque' },
  { value: 'SEMI_TRAILER', label: 'Semi-remorque' }
];
```

#### Workflow du Statut

```
┌─────────────────────────────────────────┐
│ Logique de calcul automatique du statut│
└─────────────────────────────────────────┘

IF (group_size > 0 AND au moins 1 véhicule avec count > 0)
  → status = 'completed' ✅

ELSE IF (group_size > 0 OR au moins 1 véhicule avec count > 0)
  → status = 'incomplete' ⚠️

ELSE
  → status = 'todo' ⭕
```

#### Dashboard Statistiques

Le dashboard affiche en temps réel :
- **Total personnes** par jour et global
- **Total véhicules** par jour et global
- **Répartition par type de véhicule**
- **Statuts** : compteurs todo/incomplete/completed

---

## 2. TRAVELS - Gestion des Voyages

### Objectif
Centraliser tous les déplacements des artistes et contacts (arrivées/départs) par avion, train ou autres moyens de transport.

### Composants Principaux

#### Page : `TravelsPage.tsx`
- **Rôle** : Interface CRUD pour gérer les voyages
- **Fonctionnalités** :
  - Création rapide par type de transport (Avion, Train, Véhicule)
  - Vue Liste/Grille
  - Stepper modal pour création guidée
  - Filtrage et recherche
  - Synchronisation automatique avec les missions (via Realtime Supabase)

#### Base de Données : `travels`

```sql
CREATE TABLE travels (
  id UUID PRIMARY KEY,
  event_id UUID REFERENCES events(id) NOT NULL,
  artist_id UUID REFERENCES artists(id),
  contact_id UUID REFERENCES contacts(id),
  travel_type TEXT NOT NULL, -- 'PLANE', 'TRAIN', 'CAR', 'VAN', 'BUS'
  is_arrival BOOLEAN DEFAULT false,
  scheduled_datetime TIMESTAMPTZ NOT NULL,
  actual_datetime TIMESTAMPTZ,
  passenger_count INTEGER DEFAULT 1,
  notes TEXT,
  status TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  
  -- Contraintes
  CHECK ((artist_id IS NOT NULL AND contact_id IS NULL) OR 
         (artist_id IS NULL AND contact_id IS NOT NULL))
);

-- Index pour performance
CREATE INDEX idx_travels_datetime ON travels(scheduled_datetime);
CREATE INDEX idx_travels_event ON travels(event_id);
CREATE INDEX idx_travels_type ON travels(travel_type);
```

**Relations** :
- Un travel peut être associé à **soit** un artiste **soit** un contact (XOR)
- Un travel peut générer automatiquement une **mission** de transport

#### Table Complémentaire : `travel_details`

```sql
CREATE TABLE travel_details (
  id UUID PRIMARY KEY,
  travel_id UUID REFERENCES travels(id) ON DELETE CASCADE,
  reference_number TEXT,      -- Numéro de vol/train
  departure_location TEXT,    -- Lieu de départ
  arrival_location TEXT,      -- Lieu d'arrivée
  created_at TIMESTAMPTZ
);
```

**Pourquoi cette séparation ?**
- `travels` : Informations essentielles et communes
- `travel_details` : Détails spécifiques selon le type de transport

#### Synchronisation Temps Réel

```typescript
// Écoute des insertions dans la table travels
const travelsSubscription = supabase
  .channel('travels-changes')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'travels',
    filter: `event_id=eq.${currentEventId}`
  }, (payload) => {
    // Recharger automatiquement les missions
    loadMissions();
  })
  .subscribe();
```

**Impact** : Création d'un travel → Création automatique d'une mission dans `MissionsPage`

---

## 3. GROUND - Logistique Terrestre

Le module GROUND regroupe **4 sous-modules** interdépendants pour gérer l'ensemble de la logistique terrestre.

### 3.1 MISSIONS - Transferts et Transports

#### Objectif
Planifier et dispatcher les missions de transport (transferts aéroport, hôtel, etc.).

#### Page : `MissionsPage.tsx`
- **Rôle** : Création, planification et dispatch des missions
- **Fonctionnalités** :
  - **Synchronisation automatique** avec les travels (Realtime)
  - Création manuelle ou automatique depuis un travel
  - Calcul automatique des horaires de départ (avec temps d'attente)
  - Estimation de coût et distance
  - Dispatch : assignation chauffeur + véhicule
  - Statuts : `DRAFT` → `ASSIGNED` → `IN_PROGRESS` → `COMPLETED`

#### Base de Données : `missions`

```sql
CREATE TABLE missions (
  id UUID PRIMARY KEY,
  event_id UUID REFERENCES events(id),
  travel_id UUID REFERENCES travels(id),
  base_id UUID REFERENCES bases(id),
  
  -- Lieux
  pickup_location TEXT NOT NULL,
  pickup_latitude DECIMAL,
  pickup_longitude DECIMAL,
  pickup_type VARCHAR(32) DEFAULT 'other', -- airport, hotel, train_station, other
  
  dropoff_location TEXT NOT NULL,
  dropoff_latitude DECIMAL,
  dropoff_longitude DECIMAL,
  drop_type VARCHAR(32) DEFAULT 'other',
  
  -- Passagers
  passenger_id UUID,
  passenger_count INTEGER DEFAULT 1,
  luggage_count INTEGER DEFAULT 0,
  
  -- Timing (Smart V2)
  flight_arrival_time TIMESTAMPTZ,
  start_at TIMESTAMPTZ,          -- Calculé automatiquement
  duration_min INTEGER,
  distance_km INTEGER,
  cost_estimate NUMERIC(10,2),
  
  -- Assignation
  driver_id UUID REFERENCES drivers(id),
  vehicle_id UUID REFERENCES vehicles(id),
  
  -- Statut
  status TEXT DEFAULT 'DRAFT',
  
  -- Notifications
  whatsapp_sent BOOLEAN DEFAULT false,
  whatsapp_sent_at TIMESTAMPTZ,
  reminder_scheduled BOOLEAN DEFAULT false,
  
  notes TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

#### Table : `waiting_time`

```sql
CREATE TABLE waiting_time (
  place_type VARCHAR(32) PRIMARY KEY,
  minutes SMALLINT NOT NULL,
  description TEXT
);

-- Seed data
INSERT INTO waiting_time VALUES
  ('airport', 45, 'Temps d''attente aéroport'),
  ('hotel', 10, 'Temps d''attente hôtel'),
  ('train_station', 15, 'Temps d''attente gare'),
  ('other', 10, 'Temps par défaut');
```

#### Calcul Automatique du `start_at`

```sql
CREATE FUNCTION calculate_mission_start_at(
  p_flight_arrival TIMESTAMPTZ,
  p_base_to_pickup_duration INTEGER -- en minutes
)
RETURNS TIMESTAMPTZ AS $$
BEGIN
  RETURN p_flight_arrival - (p_base_to_pickup_duration || ' minutes')::INTERVAL;
END;
$$ LANGUAGE plpgsql;
```

**Exemple** :
- Vol arrive à 14h00
- Trajet base → aéroport = 20 minutes
- Temps d'attente aéroport = 45 minutes
- **start_at calculé** = 14h00 - 20min = **13h40**

#### Workflow Mission

```
DRAFT → (dispatch) → ASSIGNED → (driver start) → IN_PROGRESS → (completed) → COMPLETED
```

---

### 3.2 DRIVERS - Gestion des Chauffeurs

#### Objectif
Gérer la base de données des chauffeurs, leurs compétences, disponibilités et assignations.

#### Page : `DriversPage.tsx`
- **Rôle** : CRUD des chauffeurs
- **Fonctionnalités** :
  - Vue Grille/Liste
  - Gestion des permis et langues
  - Statut de disponibilité
  - Photo de profil
  - Assignation aux événements via `staff_assignments`

#### Base de Données : `drivers`

```sql
CREATE TABLE drivers (
  id UUID PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  phone TEXT,
  
  -- Adresse
  street TEXT,
  postal_code TEXT,
  city TEXT,
  
  -- Infos personnelles
  birth_date DATE,
  photo_url TEXT,
  
  -- Compétences
  languages TEXT[],
  permits TEXT[],          -- ['B', 'C', 'D', 'BE']
  
  -- Travail
  hired_year INTEGER,
  t_shirt_size TEXT,
  
  -- Statuts
  availability_status TEXT DEFAULT 'AVAILABLE', -- AVAILABLE, BUSY, OFF
  work_status TEXT DEFAULT 'ACTIVE',            -- ACTIVE, INACTIVE, ARCHIVED
  
  notes TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

#### Table de Liaison : `staff_assignments`

```sql
CREATE TABLE staff_assignments (
  id UUID PRIMARY KEY,
  driver_id UUID REFERENCES drivers(id),
  event_id UUID REFERENCES events(id),
  role TEXT DEFAULT 'driver',
  status TEXT DEFAULT 'assigned',
  assigned_date DATE,
  notes TEXT
);
```

**Important** : Les chauffeurs sont des **ressources globales** (non limitées à un événement) mais sont **assignés** à des événements spécifiques via `staff_assignments`.

---

### 3.3 VEHICLES - Gestion de la Flotte

#### Objectif
Gérer l'inventaire des véhicules disponibles pour l'événement.

#### Page : `VehiclesPage.tsx`
- **Rôle** : CRUD des véhicules
- **Fonctionnalités** :
  - Vue Cartes/Liste
  - Gestion des caractéristiques (capacité, équipement)
  - Suivi de l'état (statut, maintenance)
  - Réception/Retour

#### Base de Données : `vehicles`

```sql
CREATE TABLE vehicles (
  id UUID PRIMARY KEY,
  event_id UUID REFERENCES events(id) NOT NULL,
  
  -- Identification
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  type TEXT,                      -- CAR, VAN, BUS, TRUCK
  registration_number TEXT,
  engagement_number TEXT,         -- Numéro d'engagement
  
  -- Caractéristiques
  color TEXT,
  passenger_capacity INTEGER,
  luggage_capacity INTEGER,
  fuel_type TEXT,
  
  -- Fournisseur
  supplier TEXT,
  additional_equipment TEXT[],
  
  -- Statut
  status TEXT DEFAULT 'available',  -- available, in_use, maintenance, returned
  
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);

CREATE INDEX idx_vehicles_event ON vehicles(event_id);
CREATE INDEX idx_vehicles_status ON vehicles(status);
```

**Note** : Les véhicules sont **spécifiques à un événement** (contrairement aux chauffeurs).

---

### 3.4 SHIFTS - Planification des Équipes

#### Objectif
Créer des plages horaires (shifts) et y assigner des chauffeurs.

#### Page : `ShiftsPage.tsx`
- **Rôle** : Gestion des shifts
- **Fonctionnalités** :
  - Création de shifts avec plage horaire
  - Assignation multiple de chauffeurs
  - Vue Grille/Liste/Gantt
  - Couleurs personnalisables

#### Base de Données : `shifts`

```sql
CREATE TABLE shifts (
  id UUID PRIMARY KEY,
  event_id UUID REFERENCES events(id) NOT NULL,
  name TEXT NOT NULL,
  start_datetime TIMESTAMPTZ NOT NULL,
  end_datetime TIMESTAMPTZ NOT NULL,
  color TEXT,
  created_at TIMESTAMPTZ
);

-- Table de liaison many-to-many
CREATE TABLE shift_drivers (
  id UUID PRIMARY KEY,
  shift_id UUID REFERENCES shifts(id) ON DELETE CASCADE,
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ,
  
  UNIQUE(shift_id, driver_id)
);
```

**Relation** : Un shift peut avoir **plusieurs chauffeurs**, et un chauffeur peut être assigné à **plusieurs shifts**.

---

## 4. HOSPITALITY - Accueil et Services

Le module HOSPITALITY gère l'accueil et le confort des artistes avec **4 sous-modules**.

### 4.1 HOTELS - Réservations Hôtelières

#### Objectif
Gérer les réservations d'hôtel pour artistes et contacts.

#### Page : `HotelsPage.tsx`
- **Rôle** : Interface de gestion des réservations
- **Composants** :
  - `HotelDashboard` : Vue d'ensemble des réservations
  - `HotelReservationTableSimple` : Tableau des réservations

#### Base de Données (Simplifié)

**Tables principales** :
- `hotels` : Informations sur les hôtels
- `hotel_rooms` : Chambres disponibles
- `hotel_reservations` : Réservations
- `hotel_room_prices` : Tarification

**Structure complexe** avec plusieurs migrations pour gérer les catégories de chambres, les prix, et les devises.

**Voir** : `20250120_cleanup_hotel_structure.sql` et migrations suivantes

---

### 4.2 BACKSTAGE - Gestion des Loges

#### Objectif
Gérer l'attribution et l'équipement des loges artistes.

#### Page : `BackstagePage.tsx`
- **Rôle** : Page hub vers les fonctionnalités backstage
- **Fonctionnalités** :
  - Plan des loges (en développement)
  - Équipement des loges (à venir)

**État** : En développement

---

### 4.3 CATERING - Restauration Artistes

#### Objectif
Gérer les besoins alimentaires des artistes et équipes, incluant les régimes spéciaux.

#### Page : `CateringPage.tsx`
- **Rôle** : Gestion complète du catering par jour et par artiste
- **Fonctionnalités** :
  - Dashboard récapitulatif par jour
  - Gestion des régimes alimentaires spéciaux
  - Quantités par repas (breakfast, lunch, dinner)
  - Types d'after-show
  - Génération de vouchers
  - Scan de vouchers (page dédiée)
  - Export/Impression

#### Base de Données : Système Complexe

**Tables principales** :
```sql
-- Régimes disponibles
CREATE TABLE diet_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  description TEXT,
  icon TEXT
);

-- Besoins catering par artiste et jour
CREATE TABLE artist_catering (
  id UUID PRIMARY KEY,
  artist_id UUID REFERENCES artists(id),
  event_day_id UUID REFERENCES event_days(id),
  breakfast_qty INTEGER DEFAULT 0,
  lunch_qty INTEGER DEFAULT 0,
  dinner_qty INTEGER DEFAULT 0,
  after_show_type TEXT,
  after_show_note TEXT,
  headcount_total INTEGER,
  remarks TEXT,
  status TEXT -- 'todo', 'incomplete', 'completed'
);

-- Régimes spéciaux par artiste
CREATE TABLE artist_diet (
  artist_id UUID,
  diet_code TEXT REFERENCES diet_types(code),
  quantity INTEGER,
  PRIMARY KEY (artist_id, diet_code)
);

-- Invités avec régimes spéciaux
CREATE TABLE special_diet_guests (
  id UUID PRIMARY KEY,
  artist_id UUID,
  event_day_id UUID,
  guest_number INTEGER,
  diet_requirements JSONB -- Array de {diet_code, diet_type}
);

-- Vouchers de catering
CREATE TABLE catering_vouchers (
  id UUID PRIMARY KEY,
  event_id UUID,
  event_day_id UUID,
  artist_id UUID,
  meal_type TEXT,          -- 'breakfast', 'lunch', 'dinner'
  ticket_number TEXT UNIQUE,
  issued_at TIMESTAMPTZ,
  used_at TIMESTAMPTZ,
  status TEXT              -- 'issued', 'used', 'cancelled'
);
```

#### Workflow Catering

```
1. Configuration → Définir les besoins (qty, régimes, after-show)
2. Validation → Statut calculé (todo/incomplete/completed)
3. Génération → Création des vouchers si nécessaire
4. Distribution → Impression/Export
5. Consommation → Scan des vouchers sur site
```

#### Fonctionnalité de Scan

Page dédiée : `catering/ScanVoucherPage.tsx`
- Scan de QR codes/codes-barres
- Validation temps réel
- Historique des scans

---

### 4.4 ACCRED-INVITS - Accréditations et Invitations

#### Objectif
Gérer les accréditations et invitations pour l'événement.

#### Page : `AccredInvitsPage.tsx`

**État** : À documenter (non exploré en détail dans cette session)

---

## 5. TECHNIQUE - Aspects Techniques

#### Page : `TechniquePage.tsx`

**État** : Page placeholder en développement

**Fonctionnalités prévues** :
- Gestion des fiches techniques artistes
- Riders techniques
- Besoins en matériel
- Plans de scène

---

## 6. TIMETABLE - Planning Temporel

#### Page : `TimetablePage.tsx`

**État** : Page placeholder en développement

**Fonctionnalités prévues** :
- Horaires de performance
- Planning des artistes
- Calendrier des événements
- Synchronisation temps réel

---

## 7. PARTY CREW & STAFF

### PARTY CREW

#### Page : `PartyCrewPage.tsx`

**État** : À documenter

### STAFF

#### Page : `StaffPage.tsx`

**Rôle** : Page hub pour toutes les catégories de staff

**Catégories** :
- Chauffeurs (drivers)
- Sécurité (security)
- Technique (technical)
- Son (sound)
- Vidéo (video)
- Général (general)

**Note** : Affiche des statistiques **globales** (tous événements confondus) pour les ressources humaines.

---

## Navigation et Structure UI

### Composant : `ProductionNavigation.tsx`

Navigation principale avec 7 onglets :

```typescript
const PRODUCTION_TABS = [
  { id: 'touringparty', label: 'TOURING PARTY', icon: <Users /> },
  { id: 'travels', label: 'TRAVELS', icon: <Navigation /> },
  { id: 'ground', label: 'GROUND', icon: <Building /> },
  { id: 'hospitality', label: 'HOSPITALITY', icon: <Coffee /> },
  { id: 'technique', label: 'TECHNIQUE', icon: <Wrench /> },
  { id: 'timetable', label: 'TIMETABLE', icon: <Clock /> },
  { id: 'partycrew', label: 'PARTYCREW', icon: <PartyPopper /> }
];
```

### Sous-Navigations

- **GroundNavigation.tsx** : Pour MISSIONS, DRIVERS, VEHICLES, SHIFTS
- **HospitalityNavigation.tsx** : Pour HOTELS, BACKSTAGE, CATERING, ACCRED-INVITS

---

## Page Hub : `ProductionPage.tsx`

**Rôle** : Page d'accueil du module Production avec dashboard global

**Fonctionnalités** :
- **Dashboard récapitulatif** : stats de toutes les sections
- **Navigation rapide** : accès direct aux sous-modules
- **Vue par jour** : résumé des tâches et statuts par jour d'événement

---

## Principes Architecturaux

### 1. **Séparation des Préoccupations**
Chaque sous-module a sa propre responsabilité claire et ses propres tables.

### 2. **Interdépendance**
Les modules sont liés mais restent indépendants :
- **Travels** génère des **Missions**
- **Missions** utilisent **Drivers** et **Vehicles**
- **Touring Party** informe les besoins en **Vehicles**
- **Catering** utilise les données de **Touring Party** (headcount)

### 3. **Ressources Globales vs Événement-Spécifiques**

| Ressource       | Scope        | Table de Liaison      |
|-----------------|--------------|-----------------------|
| **Drivers**     | Global       | `staff_assignments`   |
| **Vehicles**    | Événement    | N/A                   |
| **Hotels**      | Global       | N/A                   |
| **Travels**     | Événement    | N/A                   |
| **Missions**    | Événement    | N/A                   |

### 4. **Temps Réel**
Utilisation de **Supabase Realtime** pour synchroniser automatiquement certaines données :
- Travels → Missions
- Catering updates

### 5. **Calculs Automatiques**
De nombreux champs sont calculés automatiquement côté frontend ou backend :
- Statuts (todo/incomplete/completed)
- Horaires de départ (start_at)
- Coûts estimés
- Comptages (personnes, véhicules, repas)

---

## Schéma de Relations Globales

```
                        ┌──────────────┐
                        │   EVENTS     │
                        └──────┬───────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
        ┌─────▼─────┐    ┌────▼─────┐    ┌────▼─────┐
        │  ARTISTS  │    │ CONTACTS │    │EVENT_DAYS│
        └─────┬─────┘    └────┬─────┘    └────┬─────┘
              │               │                │
    ┌─────────┼───────┬───────┼─────┐          │
    │         │       │       │     │          │
┌───▼───┐ ┌──▼──┐┌───▼──┐┌───▼───┐ │    ┌─────▼─────┐
│TOURING│ │HOTEL││TRAVEL││CATERING│ │    │ARTIST_PERF│
│PARTY  │ │RESER││      ││        │ │    │           │
└───────┘ └─────┘└───┬──┘└────────┘ │    └───────────┘
                     │               │
                 ┌───▼────┐     ┌────▼────┐
                 │MISSIONS│     │STAFF    │
                 │        │     │ASSIGN   │
                 └───┬────┘     └────┬────┘
                     │               │
              ┌──────┼───────┐       │
              │              │       │
        ┌─────▼─────┐  ┌────▼────┐  │
        │ VEHICLES  │  │ DRIVERS │◄─┘
        └───────────┘  └─────┬───┘
                             │
                        ┌────▼────┐
                        │ SHIFTS  │
                        │ (M2M)   │
                        └─────────┘
```

---

## Prochaines Étapes de Développement

### Priorités Court Terme
1. ✅ TOURING PARTY : Fonctionnel
2. ✅ TRAVELS : Fonctionnel
3. ✅ GROUND : Fonctionnel (4 sous-modules)
4. ✅ HOSPITALITY : Partiellement fonctionnel (Hotels et Catering complets)
5. 🚧 BACKSTAGE : En développement
6. 🚧 TECHNIQUE : À développer
7. 🚧 TIMETABLE : À développer
8. 🚧 PARTY CREW : À développer

### Améliorations Futures
- Intégration GPS/Maps pour calculs automatiques de distance
- Notifications WhatsApp automatiques pour drivers
- Système de rappels automatiques
- Export PDF/Excel multi-formats
- Dashboards temps réel avancés
- Gestion des conflits (double-booking véhicules/chauffeurs)

---

**Voir aussi** :
- [Workflow Production](./PRODUCTION_SYSTEM_WORKFLOW.md)
- [Relations BDD](./PRODUCTION_SYSTEM_RELATIONS.md)
- [Index](./PRODUCTION_INDEX.md)


