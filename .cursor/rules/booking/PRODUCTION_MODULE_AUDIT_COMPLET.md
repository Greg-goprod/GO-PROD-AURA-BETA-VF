# 🏭 AUDIT COMPLET - MODULE PRODUCTION GO-PROD V3

> Documentation exhaustive du module Production pour implémentation intégrale dans le nouveau SaaS

**Date d'audit** : 14 novembre 2025  
**Version GO-PROD** : V3  
**Module** : Production (Parent de tous les sous-modules logistiques)  
**Analyste** : Senior Developer & Analyst  

---

## 📊 VUE D'ENSEMBLE EXECUTIVE

### Résumé du Module

Le **Module Production** est le module parent qui englobe **TOUTE la logistique** et la gestion opérationnelle d'un événement. C'est le système central de coordination entre les artistes, le transport, le logement, la restauration, l'équipement technique et le personnel.

### Architecture Modulaire

```
PRODUCTION (Parent)
├── TOURING PARTY (Effectifs artistes)
├── TRAVELS (Voyages artistes)
├── GROUND (Transport au sol)
│   ├── MISSIONS (Coordination transport)
│   ├── DRIVERS (Chauffeurs)
│   ├── VEHICLES (Véhicules)
│   └── SHIFTS (Équipes de travail)
├── HOSPITALITY (Accueil & confort)
│   ├── HOTELS (Hébergement)
│   ├── BACKSTAGE (Loges)
│   ├── CATERING (Restauration)
│   └── ACCRED/GUESTS (Accréditations)
├── TECHNIQUE (Technique scénique)
├── TIMETABLE (Horaires performances)
└── PARTY CREW (Personnel événement)
```

### Statistiques Clés

| Métrique | Valeur |
|----------|--------|
| **Pages principales** | 15+ |
| **Sous-modules** | 7 |
| **Tables BDD** | 20+ |
| **Migrations SQL** | 110+ |
| **Composants React** | 50+ |
| **Fonctions SQL** | 10+ |
| **Lignes de code analysées** | ~15,000 |

---

## 🎯 SOUS-MODULES DÉTAILLÉS

### 1. TOURING PARTY (Effectifs Artistes)

#### 📋 Description
Gestion des effectifs de chaque artiste (nombre de personnes + véhicules nécessaires).

#### 📄 Fichiers Principaux
- **Page** : `src/pages/TouringPartyPage.tsx` (857 lignes)
- **SQL** : `sql/create_artist_touring_party_table.sql` (117 lignes)

#### 🗄️ Table Principale : `artist_touring_party`

```sql
CREATE TABLE artist_touring_party (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    group_size INTEGER NOT NULL DEFAULT 1,
    vehicles JSONB DEFAULT '[]'::jsonb, 
    notes TEXT,
    special_requirements TEXT,
    status VARCHAR(50) CHECK (status IN ('todo', 'incomplete', 'completed')),
    performance_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(event_id, artist_id)
);
```

#### 📊 Structure JSONB `vehicles`

```json
[
  {"type": "CAR", "count": 2},
  {"type": "VAN", "count": 1},
  {"type": "TOURBUS", "count": 1}
]
```

#### 🎨 Types de Véhicules Supportés

```typescript
const VEHICLE_TYPES = [
  'CAR',          // Voiture
  'VAN',          // Van
  'VAN_TRAILER',  // Van + Remorque
  'TOURBUS',      // Tourbus
  'TOURBUS_TRAILER', // Tourbus + Remorque
  'TRUCK',        // Camion
  'TRUCK_TRAILER', // Camion + Remorque
  'SEMI_TRAILER'  // Semi-remorque
];
```

#### ⚙️ Fonctionnalités Principales

**1. Dashboard Global**
- Vue synthétique par jour d'événement
- Compteurs : Total personnes, Total véhicules
- Répartition véhicules par type
- Statuts : todo, incomplete, completed

**2. Accordéon par Jour**
- Groupement automatique des artistes par date de performance
- Ouvre/ferme chaque jour
- Vue des artistes en grille (2 colonnes)

**3. Fiche Artiste**
- Champ numérique : Nombre de personnes (touring party)
- 8 champs numériques : Un pour chaque type de véhicule
- Textarea : Notes
- Badge statut cliquable (cycle todo → incomplete → completed)

**4. Calcul Automatique Statut**

```typescript
const calculateStatus = (artist) => {
  const hasPersons = artist.group_size > 0;
  const hasVehicles = artist.vehicles.some(v => v.count > 0);
  
  if (hasPersons && hasVehicles) return 'completed';
  else if (hasPersons || hasVehicles) return 'incomplete';
  else return 'todo';
};
```

**5. Sauvegarde Auto**
- Debounce sur blur des champs
- Upsert automatique (création ou mise à jour)
- Mise à jour statut automatique après changement

#### 📡 Fonctions SQL

**get_artist_touring_party_by_event(event_id)**
```sql
-- Récupère tous les touring parties d'un événement avec les noms artistes
SELECT 
  atp.id,
  atp.artist_id,
  a.name as artist_name,
  atp.group_size,
  atp.vehicles,
  atp.notes,
  atp.special_requirements,
  atp.created_at,
  atp.updated_at
FROM artist_touring_party atp
JOIN artists a ON atp.artist_id = a.id
WHERE atp.event_id = $1
ORDER BY a.name;
```

#### 🔗 Relations Clés

- `event_id` → `events.id` (CASCADE DELETE)
- `artist_id` → `artists.id` (CASCADE DELETE)
- Contrainte unique : (event_id, artist_id)

#### 💡 Points d'Attention

1. ⚠️ **JSONB vehicles** : Doit être un tableau valide JSON
2. ⚠️ **Performance** : Index sur event_id et artist_id
3. ⚠️ **Sync** : Chargement des dates depuis `artist_performances`
4. ⚠️ **Fallback** : Si pas de performances, utilise les jours d'événement

---

### 2. TRAVELS (Voyages Artistes)

#### 📋 Description
Gestion complète des voyages artistes et contacts (avion, train, véhicules).

#### 📄 Fichiers Principaux
- **Page** : `src/pages/TravelsPage.tsx` (377 lignes)
- **Composants** : 10 fichiers (TravelForm, TravelStepper, TravelList, etc.)

#### 🗄️ Table Principale : `travels`

```sql
CREATE TABLE travels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    artist_id UUID REFERENCES artists(id),
    contact_id UUID REFERENCES contacts(id),
    is_arrival BOOLEAN NOT NULL DEFAULT true,
    travel_type VARCHAR(50) NOT NULL, 
    scheduled_datetime TIMESTAMPTZ NOT NULL,
    actual_datetime TIMESTAMPTZ,
    departure_location VARCHAR(500),
    arrival_location VARCHAR(500),
    reference_number VARCHAR(100),
    passenger_count INTEGER DEFAULT 1,
    notes TEXT,
    status VARCHAR(50) DEFAULT 'planned',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 🎨 Types de Voyage

```typescript
const TRAVEL_TYPES = [
  'PLANE',       // Avion
  'TRAIN',       // Train
  'CAR',         // Voiture
  'VAN',         // Van
  'VAN_TRAILER', // Van + Remorque
  'TOURBUS',     // Tourbus
  'TOURBUS_TRAILER', // Tourbus + Remorque
  'TRUCK',       // Camion
  'TRUCK_TRAILER', // Camion + Remorque
  'SEMI_TRAILER' // Semi-remorque
];
```

#### ⚙️ Fonctionnalités Principales

**1. TravelStepper (Modal Création)**

**Étape 1 : Type de voyage**
- Sélection parmi PLANE, TRAIN ou les 8 types de véhicules
- Affichage icône + label

**Étape 2 : Personne**
- Choix entre ARTIST ou CONTACT
- Multi-select pour les artistes
- Select simple pour les contacts

**Étape 3 : Direction**
- Boutons radio : ARRIVAL (Arrivée) ou DEPARTURE (Départ)

**Étape 4 : Détails du voyage**
- **Si PLANE/TRAIN** :
  - Reference number (vol/train)
  - Departure location
  - Arrival location
  - Scheduled datetime
  - Passenger count
  - Notes
  
- **Si VEHICLE** :
  - Departure location
  - Arrival location
  - Scheduled datetime
  - Passenger count
  - Notes

**2. TravelList (Affichage)**

**Vue Grid**
- Cards avec informations voyage
- Icône type de transport
- Date/heure formatée
- Nom personne (artiste ou contact)
- Badge direction (Arrivée/Départ)
- Boutons Edit/Delete

**Vue List**
- Tableau avec colonnes
- Tri par date
- Filtrage par recherche

**3. Formulaires Spécialisés**

**PlaneTrainForm** : Formulaire avion/train avec champs spécifiques
**TravelVehicleForm** : Formulaire véhicules avec champs adaptés

#### 🔄 Synchronisation avec Missions

```typescript
// Les travels créés génèrent automatiquement des missions
// Logique dans MissionsPage : syncTravelsToMissions()

// Travel arrivée en Suisse → Mission PICKUP depuis aéroport
// Travel départ de Suisse → Mission DROPOFF vers aéroport
```

#### 🔗 Relations Clés

- `event_id` → `events.id` (CASCADE DELETE)
- `artist_id` → `artists.id` (NULLABLE)
- `contact_id` → `contacts.id` (NULLABLE)
- Contrainte : artist_id XOR contact_id (un des deux obligatoire)

#### 💡 Points d'Attention

1. ⚠️ **XOR Artist/Contact** : Exactement un des deux doit être renseigné
2. ⚠️ **is_arrival** : Boolean critique pour déterminer le sens
3. ⚠️ **Sync Missions** : Écoute temps réel via Supabase Realtime
4. ⚠️ **Filtrage Suisse** : Codes aéroports GVA, ZUR, BSL, etc.

---

### 3. GROUND (Transport au Sol)

Parent de 4 sous-modules : **MISSIONS**, **DRIVERS**, **VEHICLES**, **SHIFTS**

---

#### 3.1. MISSIONS (Coordination Transport)

##### 📋 Description
Planification et dispatch des missions de transport (pickups, dropoffs, trajets).

##### 📄 Fichiers Principaux
- **Page** : `src/pages/MissionsPage.tsx` (993 lignes)
- **SQL** : `sql/create-missions-table.sql` (69 lignes)

##### 🗄️ Table Principale : `missions`

```sql
CREATE TABLE missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    travel_id UUID REFERENCES travels(id), -- Nouveau : lien vers travel
    driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL,
    base_id UUID REFERENCES bases(id) ON DELETE SET NULL,
    artist_id UUID REFERENCES artists(id),
    contact_id UUID REFERENCES contacts(id),
    
    -- Pickup
    pickup_location TEXT NOT NULL,
    pickup_latitude DECIMAL(10, 8),
    pickup_longitude DECIMAL(11, 8),
    pickup_datetime TIMESTAMPTZ NOT NULL,
    
    -- Dropoff
    dropoff_location TEXT NOT NULL,
    dropoff_latitude DECIMAL(10, 8),
    dropoff_longitude DECIMAL(11, 8),
    dropoff_datetime TIMESTAMPTZ,
    
    -- Passagers
    passenger_count INTEGER NOT NULL DEFAULT 1,
    luggage_count INTEGER DEFAULT 0,
    
    -- Statut
    status VARCHAR(50) DEFAULT 'unplanned' 
      CHECK (status IN ('unplanned', 'draft', 'planned', 'dispatched')),
    
    notes TEXT,
    estimated_duration_minutes INTEGER,
    actual_duration_minutes INTEGER,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

##### 🎨 Statuts Mission

```typescript
const MISSION_STATUS = {
  'unplanned': 'À planifier (rouge)',    // Mission générée depuis travel
  'draft': 'Draft (orange)',              // En cours de planification
  'planned': 'À dispatcher (vert)',       // Prête à être dispatchée
  'dispatched': 'Dispatchée (bleu)'      // Assignée à chauffeur
};
```

##### ⚙️ Fonctionnalités Principales

**1. Synchronisation Automatique Travel → Missions**

```typescript
// Écoute temps réel sur table travels
const travelsSubscription = supabase
  .channel('travels-changes')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'travels',
    filter: `event_id=eq.${currentEventId}`
  }, async (payload) => {
    // Création automatique mission
    await syncTravelsToMissions();
  });
```

**Logique de création automatique** :

```typescript
// Travel ARRIVAL (is_arrival=true) en Suisse 
→ Crée mission PICKUP depuis aéroport/gare

// Travel DEPARTURE (is_arrival=false) de Suisse
→ Crée mission DROPOFF vers aéroport/gare

// Données copiées :
- travel_id (lien)
- scheduled_datetime
- passenger_count
- artist_id ou contact_id
- pickup/dropoff_location (extraction ville depuis arrival/departure_location)
```

**2. Cleanup Doublons**

```typescript
const cleanupDuplicateMissions = async () => {
  // Récupère missions avec même travel_id
  // Garde la plus ancienne, supprime les autres
  // Protection contre race conditions
};
```

**3. MissionListItem (Affichage)**

**Informations affichées** :
- Nom passager (artist ou contact)
- Locations pickup → dropoff
- Date/heure
- Nombre passagers/bagages
- Badge statut coloré
- Icône type véhicule (si assigné)

**Actions disponibles** :
- **Plan** : Ouvre modal planification
- **Edit** : Modifie mission
- **Dispatch** : Assigne chauffeur/véhicule
- **View** : Vue détaillée

**4. MissionPlanningModal**

**Formulaire complet** :
- Pickup location (autocomplete avec API Nominatim)
- Pickup datetime
- Dropoff location (autocomplete)
- Dropoff datetime (auto si durée calculée)
- Passenger count
- Luggage count
- Notes
- Bouton "Calculer durée" (API OpenRouteService)

**Calcul automatique** :
```typescript
// Via API OpenRouteService
const calculateDuration = async (pickupCoords, dropoffCoords) => {
  const response = await fetch(OPENROUTE_API_URL);
  const duration = data.features[0].properties.summary.duration / 60; // minutes
  const distance = data.features[0].properties.summary.distance / 1000; // km
  return { duration, distance };
};
```

**5. MissionDispatchModal**

**Assignation** :
- Select driver (liste chauffeurs disponibles)
- Select vehicle (liste véhicules disponibles)
- Notes dispatch
- Bouton "Dispatcher" (change statut à 'dispatched')

**6. Vue 2 Colonnes**

**Colonne 1** : Missions à planifier (tous statuts)
**Colonne 2** : Missions à dispatcher (statut 'planned' ou 'dispatched')

**Bouton Sync** : Synchronisation manuelle travels → missions

##### 🔗 Relations Clés

- `event_id` → `events.id` (CASCADE DELETE)
- `travel_id` → `travels.id` (NULLABLE, nouveau)
- `driver_id` → `drivers.id` (SET NULL)
- `vehicle_id` → `vehicles.id` (SET NULL)
- `base_id` → `bases.id` (SET NULL)
- `artist_id` → `artists.id` (NULLABLE)
- `contact_id` → `contacts.id` (NULLABLE)

##### 💡 Points d'Attention

1. ⚠️ **travel_id** : Colonne critique pour lien Travel ↔ Mission
2. ⚠️ **Doublons** : Système de cleanup automatique
3. ⚠️ **Race Conditions** : Double vérification avant création
4. ⚠️ **API Externes** : Nominatim (geocoding) + OpenRouteService (routing)
5. ⚠️ **Filtrage Suisse** : Codes aéroports/gares suisses

---

#### 3.2. DRIVERS (Chauffeurs)

##### 📋 Description
Gestion du répertoire global des chauffeurs (ressources multi-événements).

##### 📄 Fichiers Principaux
- **Page** : `src/pages/DriversPage.tsx` (312 lignes)
- **Composants** : DriverForm, DriverTable, DriverGrid

##### 🗄️ Table Principale : `drivers`

```sql
CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    street VARCHAR(255),
    postal_code VARCHAR(20),
    city VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    birth_date DATE,
    languages TEXT[], -- Array de codes langues
    t_shirt_size VARCHAR(10) DEFAULT 'M',
    hired_year INTEGER NOT NULL,
    permits TEXT[], -- Array de types permis
    notes TEXT,
    photo_url TEXT,
    availability_status VARCHAR(50) DEFAULT 'AVAILABLE' 
      CHECK (availability_status IN ('AVAILABLE', 'BUSY', 'OFF')),
    work_status VARCHAR(50) DEFAULT 'ACTIVE'
      CHECK (work_status IN ('ACTIVE', 'INACTIVE', 'SEASONAL')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

##### 🗄️ Table d'Assignation : `staff_assignments`

```sql
CREATE TABLE staff_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'driver',
    status VARCHAR(50) DEFAULT 'confirmed',
    assigned_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(driver_id, event_id, role)
);
```

##### 🎨 Données de Référence

**Langues supportées** :
```typescript
const LANGUAGES = ['fr', 'en', 'de', 'it', 'es', 'pt'];
```

**Tailles T-shirt** :
```typescript
const TSHIRT_SIZES = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
```

**Types de permis** :
```typescript
const PERMITS = ['B', 'C', 'CE', 'D', 'DE'];
```

##### ⚙️ Fonctionnalités Principales

**1. DriverForm (Modal)**

**Informations personnelles** :
- Prénom, Nom
- Rue, Code postal, Ville
- Email, Téléphone
- Date de naissance

**Informations professionnelles** :
- Langues (multi-select)
- Taille T-shirt
- Année d'embauche
- Permis (multi-select)
- Notes
- Photo URL

**Statuts** :
- Availability status (AVAILABLE, BUSY, OFF)
- Work status (ACTIVE, INACTIVE, SEASONAL)

**2. DriverGrid (Vue Grid)**

**Cards** :
- Photo (ou initiales)
- Nom complet
- Badges langues
- Badges permis
- Badges statuts
- Email, téléphone
- Actions (Edit, Delete)

**3. DriverTable (Vue List)**

**Colonnes** :
- Photo
- Nom
- Contact (email, phone)
- Langues
- Permis
- Année embauche
- Statuts
- Actions

**4. Filtrage par Événement**

```typescript
// Récupère UNIQUEMENT les chauffeurs assignés à l'événement actuel
const { data } = await supabase
  .from('drivers')
  .select(`
    *,
    staff_assignments!inner (
      id,
      event_id,
      status
    )
  `)
  .eq('staff_assignments.event_id', currentEventId)
  .eq('staff_assignments.role', 'driver');
```

##### 🔗 Relations Clés

- Relation 1-N avec `missions` via `driver_id`
- Relation 1-N avec `shifts` via `shift_drivers`
- Relation 1-N avec `staff_assignments`

##### 💡 Points d'Attention

1. ⚠️ **hired_year** : Champ obligatoire (INT NOT NULL)
2. ⚠️ **Arrays PostgreSQL** : languages et permits sont des TEXT[]
3. ⚠️ **Multi-événements** : Un chauffeur peut être assigné à plusieurs événements
4. ⚠️ **Filtre événement** : Via staff_assignments (INNER JOIN)

---

#### 3.3. VEHICLES (Véhicules)

##### 📋 Description
Gestion du parc de véhicules (location, réception, retour).

##### 📄 Fichiers Principaux
- **Page** : `src/pages/VehiclesPage.tsx` (314 lignes)
- **Composants** : VehicleForm, VehicleTable, VehicleCards

##### 🗄️ Table Principale : `vehicles`

```sql
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    color VARCHAR(50),
    passenger_capacity INTEGER,
    luggage_capacity INTEGER,
    engagement_number VARCHAR(100), -- Numéro engagement location
    registration_number VARCHAR(50), -- Plaque immatriculation
    fuel_type VARCHAR(50),
    status VARCHAR(50) DEFAULT 'available'
      CHECK (status IN ('available', 'assigned', 'maintenance', 'unavailable')),
    supplier VARCHAR(255),
    additional_equipment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

##### 🗄️ Table Maintenance : `vehicle_check_logs`

```sql
CREATE TABLE vehicle_check_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    type VARCHAR(50) CHECK (type IN ('RECEPTION', 'RETURN')),
    date DATE NOT NULL,
    kilometers INTEGER NOT NULL,
    defects TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

##### 🎨 Types de Véhicules

```typescript
const VEHICLE_TYPES = [
  'CAR',          // Voiture
  'VAN',          // Van
  'VAN_TRAILER',  // Van + Remorque
  'TOURBUS',      // Tourbus
  'TOURBUS_TRAILER', // Tourbus + Remorque
  'TRUCK',        // Camion
  'TRUCK_TRAILER', // Camion + Remorque
  'SEMI_TRAILER'  // Semi-remorque
];
```

##### ⚙️ Fonctionnalités Principales

**1. VehicleForm (Modal)**

**Informations véhicule** :
- Marque
- Modèle
- Type (select parmi VEHICLE_TYPES)
- Couleur
- Capacité passagers
- Capacité bagages

**Informations location** :
- Numéro engagement
- Plaque d'immatriculation
- Type carburant
- Fournisseur
- Équipement additionnel (textarea)
- Statut

**Contrôles (optionnels)** :
- **Réception** :
  - Date réception
  - Kilométrage réception
  - Défauts constatés
  - Notes
- **Retour** :
  - Date retour
  - Kilométrage retour
  - Défauts constatés
  - Notes

**2. VehicleCards (Vue Cards)**

**Card** :
- Icône type véhicule
- Marque + Modèle
- Badge statut coloré
- Capacités (passagers, bagages)
- Plaque immatriculation
- Fournisseur
- Actions (Edit, Delete)

**3. VehicleTable (Vue List)**

**Colonnes** :
- Type (icône)
- Marque/Modèle
- Capacités
- Plaque
- Statut
- Fournisseur
- Actions

##### 🔗 Relations Clés

- `event_id` → `events.id` (CASCADE DELETE)
- Relation 1-N avec `missions` via `vehicle_id`
- Relation 1-N avec `vehicle_check_logs`

##### 💡 Points d'Attention

1. ⚠️ **event_id** : Véhicules liés à un événement spécifique
2. ⚠️ **Check logs** : Enregistrement séparé réception/retour
3. ⚠️ **Status** : Gestion disponibilité pour assignation missions

---

#### 3.4. SHIFTS (Équipes de Travail)

##### 📋 Description
Planification des équipes de chauffeurs (créneaux horaires).

##### 📄 Fichiers Principaux
- **Page** : `src/pages/ShiftsPage.tsx` (340 lignes)
- **Composants** : ImprovedShiftForm, ShiftGrid, ShiftTable, ShiftGantt

##### 🗄️ Tables Principales

**Table `shifts`** :
```sql
CREATE TABLE shifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,
    color VARCHAR(20), -- Code couleur hex pour visualisation
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Table liaison `shift_drivers`** :
```sql
CREATE TABLE shift_drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID REFERENCES shifts(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(shift_id, driver_id)
);
```

##### ⚙️ Fonctionnalités Principales

**1. ImprovedShiftForm (Modal)**

**Champs** :
- Nom du shift
- Date/heure début (DateTimePicker)
- Date/heure fin (DateTimePicker)
- Couleur (ColorPicker)

**2. ShiftDriverAssignment (Component)**

**Bouton assignation** :
- Ouvre popover avec liste chauffeurs
- Multi-select checkboxes
- Sauvegarde dans shift_drivers
- Affichage badges chauffeurs assignés

**3. Vues Multiples**

**Vue Grid** :
- Cards shift avec infos
- Badges chauffeurs assignés
- Barre de couleur
- Actions

**Vue List** :
- Tableau avec colonnes
- Chauffeurs en liste

**Vue Gantt** :
- Timeline visuelle
- Shifts sur axe temporel
- Couleurs personnalisées
- Overlaps visibles

##### 🔗 Relations Clés

- `event_id` → `events.id` (CASCADE DELETE)
- Relation M-N avec `drivers` via `shift_drivers`

##### 💡 Points d'Attention

1. ⚠️ **Color** : Format hex (#RRGGBB)
2. ⚠️ **Overlaps** : Pas de validation automatique chevauchements
3. ⚠️ **Multi-assignation** : Un chauffeur peut être dans plusieurs shifts

---

### 4. HOSPITALITY (Accueil & Confort)

Parent de 4 sous-modules : **HOTELS**, **BACKSTAGE**, **CATERING**, **ACCRED/GUESTS**

---

#### 4.1. HOTELS (Hébergement)

##### 📋 Description
Gestion complète des réservations hôtelières pour artistes et équipes.

##### 📄 Fichiers Principaux
- **Page** : `src/pages/HotelsPage.tsx` (30 lignes - composant parent)
- **Composants** : HotelReservationTableSimple, HotelDashboard

##### 🗄️ Tables Principales

**Table `hotels`** :
```sql
CREATE TABLE hotels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    city VARCHAR(100),
    country VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(255),
    website VARCHAR(255),
    stars INTEGER CHECK (stars >= 0 AND stars <= 5),
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Table `hotel_room_types`** :
```sql
CREATE TABLE hotel_room_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hotel_id UUID REFERENCES hotels(id) ON DELETE CASCADE,
    category VARCHAR(100) NOT NULL, -- ex: 'single', 'double', 'suite'
    price_per_night DECIMAL(10,2),
    capacity INTEGER,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Table `hotel_reservations`** :
```sql
CREATE TABLE hotel_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    hotel_id UUID REFERENCES hotels(id),
    artist_id UUID REFERENCES artists(id),
    contact_id UUID REFERENCES contacts(id),
    room_type_id UUID REFERENCES hotel_room_types(id),
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    number_of_rooms INTEGER DEFAULT 1,
    number_of_guests INTEGER DEFAULT 1,
    total_price DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'pending'
      CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    notes TEXT,
    confirmed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

##### ⚙️ Fonctionnalités Principales

**1. HotelDashboard**

**Statistiques** :
- Total réservations
- Total nuitées
- Occupancy rate (taux d'occupation)
- Répartition par statut
- Coût total
- Par hôtel

**2. HotelReservationTableSimple**

**Colonnes** :
- Hôtel
- Artiste/Contact
- Check-in / Check-out
- Nombre chambres
- Nombre invités
- Type chambre
- Prix total
- Statut (badge coloré)
- Actions

**Fonctionnalités** :
- Tri par colonnes
- Filtrage par recherche
- Filtrage par statut
- Création réservation (modal)
- Édition réservation
- Suppression

##### 🔗 Relations Clés

- `event_id` → `events.id` (CASCADE DELETE)
- `hotel_id` → `hotels.id`
- `artist_id` → `artists.id` (NULLABLE)
- `contact_id` → `contacts.id` (NULLABLE)
- `room_type_id` → `hotel_room_types.id`

##### 💡 Points d'Attention

1. ⚠️ **XOR Artist/Contact** : Un des deux obligatoire
2. ⚠️ **Pricing** : Prix par nuitée dans room_types, total dans reservation
3. ⚠️ **Status workflow** : pending → confirmed → completed

---

#### 4.2. BACKSTAGE (Loges)

##### 📋 Description
Gestion des loges artistes et équipement backstage.

##### 📄 Fichiers Principaux
- **Page** : `src/pages/BackstagePage.tsx` (65 lignes)

##### ⚙️ Fonctionnalités

**1. Plan des loges**
- Navigation vers /backstage/loges
- Gestion visuelle loges
- Assignation artistes (À développer)

**2. Équipement des loges**
- Gestion fournitures
- Inventaire (À venir)

##### 💡 Statut

Module en cours de développement. Structure de base présente.

---

#### 4.3. CATERING (Restauration)

##### 📋 Description
Gestion complète de la restauration artistes (repas, régimes, vouchers).

##### 📄 Fichiers Principaux
- **Page** : `src/pages/CateringPage.tsx` (27,068 tokens - fichier volumineux)
- **Composants** : CateringDashboard, CateringRequirements, VoucherManagement

##### 🗄️ Tables Principales

**Table `catering_requirements`** :
```sql
CREATE TABLE catering_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    artist_id UUID REFERENCES artists(id) ON DELETE CASCADE,
    meal_type VARCHAR(50) NOT NULL
      CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'drinks')),
    count INTEGER DEFAULT 1,
    special_diet TEXT[], -- Array de régimes spéciaux
    notes TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Table `catering_vouchers`** :
```sql
CREATE TABLE catering_vouchers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    code VARCHAR(100) UNIQUE NOT NULL,
    artist_id UUID REFERENCES artists(id),
    contact_id UUID REFERENCES contacts(id),
    meal_type VARCHAR(50),
    value DECIMAL(10,2),
    is_used BOOLEAN DEFAULT false,
    used_at TIMESTAMPTZ,
    scanned_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

##### 🎨 Types de Repas

```typescript
const MEAL_TYPES = {
  'breakfast': 'Petit-déjeuner',
  'lunch': 'Déjeuner',
  'dinner': 'Dîner',
  'snack': 'Collation',
  'drinks': 'Boissons'
};
```

##### ⚙️ Fonctionnalités Principales

**1. CateringDashboard**

**Statistiques** :
- Total repas prévus par type
- Régimes spéciaux (compteurs)
- Vouchers émis/utilisés
- Par jour d'événement

**2. CateringRequirements**

**Gestion par artiste** :
- Multi-select types de repas
- Nombre par type
- Multi-select régimes spéciaux
- Notes spéciales

**3. VoucherManagement**

**Génération vouchers** :
- Code unique auto-généré
- QR Code
- Valeur monétaire
- Type repas associé

**Scan vouchers** :
- Scanner QR code
- Vérification validité
- Marquage utilisé
- Historique scans

##### 🔗 Relations Clés

- `event_id` → `events.id` (CASCADE DELETE)
- `artist_id` → `artists.id` (CASCADE DELETE dans requirements)
- `artist_id` → `artists.id` (NULLABLE dans vouchers)
- `contact_id` → `contacts.id` (NULLABLE)

##### 💡 Points d'Attention

1. ⚠️ **special_diet** : Array TEXT[] pour multi-régimes
2. ⚠️ **Vouchers** : Code unique, ne pas dupliquer
3. ⚠️ **QR Codes** : Génération côté client
4. ⚠️ **Scan tracking** : Timestamp + user qui scanne

---

#### 4.4. ACCRED/GUESTS (Accréditations)

##### 📋 Description
Gestion des accréditations et invitations.

##### 📄 Fichiers Principaux
- **Page** : `src/pages/AccredInvitsPage.tsx` (68 lignes)

##### ⚙️ Fonctionnalités

Module en développement. Page placeholder avec:
- Bouton "Nouvelle accréditation"
- Message "Coming Soon"

##### 💡 Statut

À implémenter. Structure de navigation présente.

---

### 5. TECHNIQUE (Technique Scénique)

##### 📋 Description
Gestion technique scénique (son, lumière, backline).

##### 📄 Fichiers Principaux
- **Page** : `src/pages/TechniquePage.tsx` (11 lignes)

##### ⚙️ Fonctionnalités

Module minimal. Page vide avec PageHeader.

##### 💡 Statut

À développer intégralement.

---

### 6. TIMETABLE (Horaires Performances)

##### 📋 Description
Planning des horaires de performances artistes.

##### 📄 Fichiers Principaux
- **Page** : `src/pages/TimetablePage.tsx` (52 lignes)

##### ⚙️ Fonctionnalités

Page placeholder avec message "En développement".

**Fonctionnalités prévues** :
- Gestion horaires performances
- Planning artistes
- Calendrier événements
- Synchronisation temps réel

##### 💡 Statut

À implémenter.

---

### 7. PARTY CREW (Personnel Événement)

##### 📋 Description
Gestion du personnel événement (techniciens, sécurité, etc.).

##### 📄 Fichiers Principaux
- **Page** : `src/pages/PartyCrewPage.tsx` (462 lignes)

##### 🗄️ Table Principale : `party_crew`

```sql
CREATE TABLE party_crew (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    hourly_rate DECIMAL(10,2),
    currency VARCHAR(10) DEFAULT 'CHF',
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

##### 🎨 Rôles Disponibles

```typescript
const PARTY_CREW_ROLES = [
  'security',            // Sécurité
  'bartender',           // Barman
  'technician',          // Technicien
  'cleaner',             // Agent d'entretien
  'stage_manager',       // Régisseur de scène
  'sound_engineer',      // Ingénieur du son
  'lighting_technician', // Technicien éclairage
  'roadie',              // Roadie
  'photographer',        // Photographe
  'videographer',        // Vidéaste
  'merchandiser',        // Merchandising
  'catering',            // Catering
  'other'                // Autre
];
```

##### ⚙️ Fonctionnalités Principales

**1. Grid View**

**Cards** :
- Nom complet
- Rôle (badge)
- Email (cliquable mailto:)
- Téléphone (cliquable tel:)
- Tarif horaire + devise
- Badge "Inactif" si is_active=false
- Actions (Edit, Delete)

**2. Modal Form**

**Champs** :
- Prénom, Nom
- Rôle (select parmi PARTY_CREW_ROLES)
- Email, Téléphone
- Tarif horaire
- Devise (CHF, EUR, USD)
- Notes
- Checkbox Actif

**3. Filtrage**
- Recherche par nom
- Recherche par rôle
- Recherche par email

##### 🔗 Relations Clés

Ressource globale (pas de event_id). Peut être assignée à plusieurs événements.

##### 💡 Points d'Attention

1. ⚠️ **Ressource globale** : Pas liée à un événement spécifique
2. ⚠️ **Tarifs** : Stockage avec devise
3. ⚠️ **Rôle obligatoire** : Validation côté client et serveur

---

### 8. STAFF (Vue d'Ensemble Personnel)

##### 📋 Description
Vue d'ensemble de toutes les ressources personnel, tous métiers confondus.

##### 📄 Fichiers Principaux
- **Page** : `src/pages/StaffPage.tsx` (365 lignes)

##### ⚙️ Fonctionnalités Principales

**1. Dashboard Global**

**Statistiques agrégées** :
- Total personnel (toutes catégories)
- Actifs
- Assignés (à des événements)
- Disponibles

**2. Catégories de Personnel**

**Cards par catégorie** :
- **Chauffeurs** : Avec vraies statistiques depuis `drivers`
- **Sécurité** : À implémenter
- **Technique** : À implémenter
- **Son** : À implémenter
- **Vidéo** : À implémenter
- **Personnel général** : À implémenter

Chaque card affiche :
- Nom catégorie + icône
- Description
- Compteurs (actifs, assignés, disponibles)
- Bouton "Gérer" (navigation vers page spécifique)

**3. Informations**

Section explicative :
- Vue d'ensemble : Ressources globales indépendantes des événements
- Gestion globale : Statuts personnel
- Assignation spécifique : Dans les pages événements
- Pages spécialisées : Liens vers pages dédiées

##### 💡 Points d'Attention

1. ⚠️ **Vue globale** : Pas de filtrage par événement
2. ⚠️ **Agrégation** : Combine plusieurs tables de personnel
3. ⚠️ **Work in Progress** : Seuls les chauffeurs sont complètement implémentés

---

## 🗄️ SCHÉMA BASE DE DONNÉES COMPLET

### Tables Principales (20+)

#### Module Production Parent

1. **events** : Événements
2. **event_days** : Jours d'événement
3. **stages** : Scènes

#### Touring Party

4. **artist_touring_party** : Effectifs artistes
   - Relations : events, artists
   - JSONB : vehicles

#### Travels

5. **travels** : Voyages artistes/contacts
   - Relations : events, artists, contacts
   - Champs clés : is_arrival, travel_type

#### Missions

6. **missions** : Missions de transport
   - Relations : events, travels, drivers, vehicles, bases, artists, contacts
   - Coords GPS : pickup/dropoff latitude/longitude

7. **bases** : Bases de départ missions

#### Ground

8. **drivers** : Chauffeurs
   - Arrays : languages[], permits[]
   
9. **vehicles** : Véhicules
   - Relations : events
   
10. **vehicle_check_logs** : Contrôles véhicules
    - Relations : vehicles
    - Types : RECEPTION, RETURN

11. **shifts** : Équipes de travail
    - Relations : events

12. **shift_drivers** : Assignation chauffeurs aux shifts
    - Relations : shifts, drivers

13. **staff_assignments** : Assignation personnel aux événements
    - Relations : drivers, events

#### Hospitality

14. **hotels** : Hôtels

15. **hotel_room_types** : Types de chambres
    - Relations : hotels

16. **hotel_reservations** : Réservations hôtelières
    - Relations : events, hotels, artists, contacts, hotel_room_types

17. **catering_requirements** : Besoins restauration
    - Relations : events, artists
    - Array : special_diet[]

18. **catering_vouchers** : Vouchers restauration
    - Relations : events, artists, contacts
    - Unique : code

#### Party Crew

19. **party_crew** : Personnel événement

#### Autres

20. **contacts** : Contacts
21. **artists** : Artistes

### Relations Critiques

```
events (1) ─────────── (N) artist_touring_party
events (1) ─────────── (N) travels
events (1) ─────────── (N) missions
events (1) ─────────── (N) vehicles
events (1) ─────────── (N) shifts
events (1) ─────────── (N) hotel_reservations
events (1) ─────────── (N) catering_requirements
events (1) ─────────── (N) catering_vouchers

travels (1) ─────────── (N) missions (via travel_id)

artists (1) ─────────── (N) artist_touring_party
artists (1) ─────────── (N) travels
artists (1) ─────────── (N) missions
artists (1) ─────────── (N) hotel_reservations
artists (1) ─────────── (N) catering_requirements

drivers (1) ─────────── (N) missions
drivers (M) ─────────── (N) shifts (via shift_drivers)
drivers (M) ─────────── (N) events (via staff_assignments)

vehicles (1) ─────────── (N) missions
vehicles (1) ─────────── (N) vehicle_check_logs

hotels (1) ─────────── (N) hotel_room_types
hotels (1) ─────────── (N) hotel_reservations
```

### Indexes Critiques

```sql
-- Touring Party
CREATE INDEX idx_artist_touring_party_event_id ON artist_touring_party(event_id);
CREATE INDEX idx_artist_touring_party_artist_id ON artist_touring_party(artist_id);

-- Travels
CREATE INDEX idx_travels_event_id ON travels(event_id);
CREATE INDEX idx_travels_artist_id ON travels(artist_id);
CREATE INDEX idx_travels_scheduled_datetime ON travels(scheduled_datetime);

-- Missions
CREATE INDEX idx_missions_event_id ON missions(event_id);
CREATE INDEX idx_missions_travel_id ON missions(travel_id);
CREATE INDEX idx_missions_driver_id ON missions(driver_id);
CREATE INDEX idx_missions_vehicle_id ON missions(vehicle_id);
CREATE INDEX idx_missions_pickup_datetime ON missions(pickup_datetime);
CREATE INDEX idx_missions_status ON missions(status);
CREATE INDEX idx_missions_pickup_coordinates ON missions(pickup_latitude, pickup_longitude);
CREATE INDEX idx_missions_dropoff_coordinates ON missions(dropoff_latitude, dropoff_longitude);

-- Shifts
CREATE INDEX idx_shifts_event_id ON shifts(event_id);
CREATE INDEX idx_shift_drivers_shift_id ON shift_drivers(shift_id);
CREATE INDEX idx_shift_drivers_driver_id ON shift_drivers(driver_id);
```

### Fonctions SQL Critiques

**get_artist_touring_party_by_event(uuid)**
```sql
-- Récupère touring parties avec noms artistes
```

**get_artists_without_touring_party(uuid)**
```sql
-- Trouve artistes sans touring party pour un événement
```

**update_updated_at_column()**
```sql
-- Trigger générique pour mettre à jour updated_at
```

---

## 🔄 WORKFLOWS CRITIQUES

### Workflow 1 : Création Travel → Mission

```
1. Utilisateur crée un travel (TravelStepper)
   ├── Type: PLANE/TRAIN/VEHICLE
   ├── Personne: ARTIST ou CONTACT
   ├── Direction: ARRIVAL ou DEPARTURE
   └── Détails: locations, datetime, passenger_count

2. Travel inséré dans table `travels`
   └── event_id, artist_id/contact_id, is_arrival, travel_type, etc.

3. Supabase Realtime détecte l'INSERT
   └── Channel: 'travels-changes'

4. MissionsPage reçoit l'événement
   └── Appelle syncTravelsToMissions()

5. Fonction syncTravelsToMissions()
   ├── Filtre travels suisses (codes aéroports GVA, ZUR, BSL, etc.)
   ├── Vérifie si mission existe déjà (via travel_id)
   └── Si non :
       ├── Travel ARRIVAL → Mission PICKUP
       │   ├── pickup_location = extractCityFromLocation(arrival_location)
       │   ├── dropoff_location = 'Destination' (à définir)
       │   └── pickup_datetime = scheduled_datetime
       └── Travel DEPARTURE → Mission DROPOFF
           ├── pickup_location = 'Base'
           ├── dropoff_location = extractCityFromLocation(departure_location)
           └── dropoff_datetime = scheduled_datetime

6. Mission créée avec statut 'unplanned'
   └── travel_id renseigné (lien bidirectionnel)

7. Mission apparaît dans colonne "Missions à planifier"
```

### Workflow 2 : Planification Mission

```
1. Utilisateur clique "Plan" sur une mission
   └── Ouvre MissionPlanningModal

2. Modal pré-rempli si travel_id existe
   ├── Récupère travel via travel_id
   └── Affiche données travel

3. Utilisateur complète/modifie
   ├── Pickup location (autocomplete Nominatim)
   ├── Pickup datetime
   ├── Dropoff location (autocomplete Nominatim)
   ├── Bouton "Calculer durée" (API OpenRouteService)
   │   └── Auto-remplit dropoff_datetime
   ├── Passenger count
   ├── Luggage count
   └── Notes

4. Utilisateur clique "Sauvegarder"
   └── UPDATE missions SET
       ├── status = 'planned' (ou 'draft' si incomplet)
       ├── pickup_location, pickup_latitude, pickup_longitude
       ├── dropoff_location, dropoff_latitude, dropoff_longitude
       ├── pickup_datetime, dropoff_datetime
       ├── passenger_count, luggage_count
       └── estimated_duration_minutes

5. Mission passe en statut 'planned'
   └── Apparaît dans colonne "Missions à dispatcher"
```

### Workflow 3 : Dispatch Mission

```
1. Utilisateur clique "Dispatch" sur mission 'planned'
   └── Ouvre MissionDispatchModal

2. Modal affiche
   ├── Résumé mission
   ├── Select driver (liste drivers disponibles)
   ├── Select vehicle (liste vehicles disponibles)
   └── Notes dispatch

3. Utilisateur assigne chauffeur + véhicule
   └── Clique "Dispatcher"

4. UPDATE missions SET
   ├── driver_id = selected_driver.id
   ├── vehicle_id = selected_vehicle.id
   ├── status = 'dispatched'
   └── notes = dispatch_notes

5. Mission complète
   ├── Chauffeur notifié (à implémenter)
   └── Véhicule réservé
```

### Workflow 4 : Gestion Touring Party

```
1. Page TouringPartyPage charge
   ├── Récupère event_days de l'événement
   ├── Récupère artists depuis event_artist
   └── Récupère artist_touring_party existants

2. Pour chaque artiste
   ├── Cherche performance_date dans artist_performances
   ├── Sinon, utilise premier jour d'événement
   └── Groupe par date

3. Affichage par jour (accordéon)
   └── Grille 2 colonnes de fiches artiste

4. Fiche artiste affiche
   ├── Nom artiste
   ├── Input: group_size
   ├── 8 inputs: un par type de véhicule
   ├── Textarea: notes
   └── Badge statut (cycle au clic)

5. Modification champ (onBlur)
   ├── Si artist_touring_party.id existe
   │   └── UPDATE artist_touring_party
   └── Sinon
       └── INSERT artist_touring_party

6. Calcul automatique statut
   ├── Si group_size > 0 ET vehicles > 0 → 'completed'
   ├── Si group_size > 0 OU vehicles > 0 → 'incomplete'
   └── Sinon → 'todo'

7. Dashboard mis à jour en temps réel
   └── Agrégation totaux par jour et global
```

---

## 🚀 POINTS D'IMPLÉMENTATION CRITIQUES

### 1. Architecture Page Parent Production

**ProductionPage.tsx** :
- Dashboard accordéon (Touring Party + Catering)
- Onglets navigation (7 onglets)
- Menus déroulants (Ground, Hospitality)
- Statistiques temps réel
- Calculs agrégés

**ProductionNavigation.tsx** :
- Navigation partagée entre toutes les pages
- Détection URL active
- Sous-menus déroulants
- Navigation cohérente

### 2. Synchronisation Travel ↔ Mission

**Système temps réel** :
```typescript
// Écoute Supabase Realtime
supabase
  .channel('travels-changes')
  .on('postgres_changes', {
    event: 'INSERT',
    table: 'travels',
    filter: `event_id=eq.${currentEventId}`
  }, handleNewTravel)
  .subscribe();
```

**Protection doublons** :
```typescript
// Vérification avant insertion
const { data: existing } = await supabase
  .from('missions')
  .select('id')
  .eq('travel_id', travel.id)
  .limit(1);

if (existing && existing.length > 0) {
  console.log('Mission already exists');
  return;
}
```

**Cleanup automatique** :
```typescript
// Suppression doublons existants
const cleanupDuplicateMissions = async () => {
  // Groupe par travel_id
  // Garde le plus ancien
  // Supprime les autres
};
```

### 3. Gestion États Complexes

**TouringPartyPage** :
- 39 états React
- Calculs mémoïsés (useMemo)
- Callbacks optimisés (useCallback)
- Gestion valeurs temporaires (debounce)

**MissionsPage** :
- État synchronisation (isSyncing)
- État loading par colonne
- États modaux multiples
- Cache travels récupérés

### 4. Composants Réutilisables

**Patterns UI** :
- ViewToggle (Grid/List/Gantt)
- Modal draggable
- DeleteConfirmModal
- EmptyState
- PageHeader avec actions
- Card avec CardHeader/CardContent

**Formulaires** :
- Input avec leftIcon
- Select natif stylé
- DatePicker custom
- DateTimePicker
- ColorPicker
- Autocomplete (Nominatim)

### 5. API Externes

**Nominatim (Geocoding)** :
```typescript
const geocode = async (query) => {
  const url = `https://nominatim.openstreetmap.org/search?q=${query}&format=json&limit=3&countrycodes=ch&accept-language=fr`;
  const results = await fetch(url).then(r => r.json());
  return results[0]; // { lat, lon, display_name }
};
```

**OpenRouteService (Routing)** :
```typescript
const calculateRoute = async (start, end) => {
  const url = `https://api.openrouteservice.org/v2/directions/driving-car?api_key=${API_KEY}&start=${start.lon},${start.lat}&end=${end.lon},${end.lat}`;
  const data = await fetch(url).then(r => r.json());
  return {
    duration: data.features[0].properties.summary.duration / 60, // minutes
    distance: data.features[0].properties.summary.distance / 1000 // km
  };
};
```

### 6. Gestion Permissions (RLS)

**Stratégie actuelle** : RLS permissif pour développement

```sql
-- Politique permissive (à ajuster en production)
CREATE POLICY "Allow all for authenticated users" 
  ON [table] 
  FOR ALL 
  USING (true);
```

**À implémenter en production** :
- Filtrage par company_id
- Filtrage par event_id
- Rôles utilisateurs (admin, manager, viewer)

### 7. Optimisations Performance

**Indexes critiques** :
- Sur tous les event_id (CASCADE queries)
- Sur dates/timestamps (tri, filtrage)
- Sur coordonnées GPS (requêtes géospatiales)
- Sur statuts (filtrage fréquent)

**Requêtes optimisées** :
- Joins limités (max 2-3 niveaux)
- Select explicites (pas de SELECT *)
- Pagination (LIMIT/OFFSET)
- Counts séparés si nécessaire

### 8. Gestion Erreurs

**Patterns** :
```typescript
try {
  // Operation
  const { data, error } = await supabase...;
  if (error) throw error;
  
  // Success
  setData(data);
} catch (error: any) {
  console.error('Error:', error);
  
  // Gestion erreurs RLS
  if (error.code === '42501') {
    setError('Problème de permissions RLS');
  } else {
    setError(error.message);
  }
} finally {
  setLoading(false);
}
```

---

## 📋 CHECKLIST IMPLÉMENTATION

### Phase 1 : Infrastructure BDD (1 semaine)

- [ ] Créer toutes les tables (20+)
- [ ] Créer tous les indexes
- [ ] Créer fonctions SQL
- [ ] Créer triggers updated_at
- [ ] Configurer RLS policies
- [ ] Insérer données de référence
- [ ] Tester relations CASCADE
- [ ] Vérifier contraintes UNIQUE

### Phase 2 : Module Touring Party (3 jours)

- [ ] Page TouringPartyPage
- [ ] Dashboard accordéon
- [ ] Fiches artistes par jour
- [ ] Inputs véhicules (8 types)
- [ ] Calcul automatique statuts
- [ ] Sauvegarde auto (upsert)
- [ ] Tests CRUD complet

### Phase 3 : Module Travels (5 jours)

- [ ] Page TravelsPage
- [ ] TravelStepper (4 étapes)
- [ ] PlaneTrainForm
- [ ] TravelVehicleForm
- [ ] TravelList (Grid + List)
- [ ] Filtrage/recherche
- [ ] Tests CRUD complet

### Phase 4 : Module Missions (1 semaine)

- [ ] Page MissionsPage
- [ ] Synchronisation Travel → Mission
- [ ] Écoute Realtime Supabase
- [ ] Cleanup doublons
- [ ] MissionPlanningModal
- [ ] Autocomplete Nominatim
- [ ] Calcul durée OpenRouteService
- [ ] MissionDispatchModal
- [ ] Vue 2 colonnes
- [ ] Tests workflow complet

### Phase 5 : Module Ground - Drivers (2 jours)

- [ ] Page DriversPage
- [ ] DriverForm (modal)
- [ ] DriverGrid
- [ ] DriverTable
- [ ] ViewToggle
- [ ] Filtrage par événement (staff_assignments)
- [ ] Tests CRUD complet

### Phase 6 : Module Ground - Vehicles (2 jours)

- [ ] Page VehiclesPage
- [ ] VehicleForm (modal)
- [ ] VehicleCards
- [ ] VehicleTable
- [ ] Gestion vehicle_check_logs
- [ ] Tests CRUD complet

### Phase 7 : Module Ground - Shifts (3 jours)

- [ ] Page ShiftsPage
- [ ] ImprovedShiftForm
- [ ] ShiftDriverAssignment
- [ ] ShiftGrid
- [ ] ShiftTable
- [ ] ShiftGantt
- [ ] Table liaison shift_drivers
- [ ] Tests CRUD complet

### Phase 8 : Module Hospitality - Hotels (4 jours)

- [ ] Page HotelsPage
- [ ] HotelReservationTableSimple
- [ ] HotelDashboard
- [ ] Modal réservation
- [ ] Gestion hotels + room_types
- [ ] Calculs prix
- [ ] Tests CRUD complet

### Phase 9 : Module Hospitality - Catering (5 jours)

- [ ] Page CateringPage
- [ ] CateringDashboard
- [ ] CateringRequirements
- [ ] VoucherManagement
- [ ] Génération QR codes
- [ ] Scan vouchers
- [ ] Tests workflow complet

### Phase 10 : Module Hospitality - Backstage (2 jours)

- [ ] Page BackstagePage
- [ ] Plan des loges (à définir)
- [ ] Gestion équipement

### Phase 11 : Module Party Crew (2 jours)

- [ ] Page PartyCrewPage
- [ ] Grid view
- [ ] Modal form
- [ ] Filtrage/recherche
- [ ] Tests CRUD complet

### Phase 12 : Module Staff (2 jours)

- [ ] Page StaffPage
- [ ] Dashboard global
- [ ] Cards par catégorie
- [ ] Statistiques agrégées
- [ ] Liens navigation

### Phase 13 : Module Timetable (À définir)

- [ ] Page TimetablePage
- [ ] Planning performances
- [ ] Calendrier
- [ ] Synchronisation

### Phase 14 : Module Technique (À définir)

- [ ] Page TechniquePage
- [ ] Gestion technique scénique

### Phase 15 : ProductionPage Parent (3 jours)

- [ ] Page ProductionPage
- [ ] Dashboard global
- [ ] Navigation onglets
- [ ] Menus déroulants
- [ ] Statistiques agrégées

### Phase 16 : Tests & Optimisation (1 semaine)

- [ ] Tests end-to-end
- [ ] Tests performance
- [ ] Optimisation requêtes
- [ ] Optimisation indexes
- [ ] Corrections bugs
- [ ] Validation UX

**DURÉE TOTALE ESTIMÉE : 8-10 semaines**

---

## 🎯 RÉSUMÉ EXÉCUTIF

### Ce que ce module fait

Le **Module Production** est le système central de gestion logistique d'un événement. Il coordonne :

1. **Les effectifs artistes** (touring parties)
2. **Les voyages** (avions, trains, véhicules)
3. **Le transport au sol** (missions, chauffeurs, véhicules, équipes)
4. **L'accueil** (hôtels, loges, restauration, accréditations)
5. **La technique** (à développer)
6. **Les horaires** (à développer)
7. **Le personnel** (party crew, staff global)

### Complexité technique

- **20+ tables** interdépendantes
- **110+ migrations SQL** accumulées
- **15+ pages React** avec composants multiples
- **Synchronisation temps réel** (Supabase Realtime)
- **APIs externes** (Nominatim, OpenRouteService)
- **Calculs complexes** (statuts, agrégations, durées)
- **Gestion états** (39 états dans TouringPartyPage)

### Points forts de l'architecture

✅ Modularité (7 sous-modules indépendants)  
✅ Synchronisation automatique (Travel ↔ Mission)  
✅ Protection doublons (cleanup automatique)  
✅ Temps réel (Supabase Realtime)  
✅ Composants réutilisables  
✅ Performance (indexes, mémoïsation)  

### Points d'attention

⚠️ **Volume de code** : ~15,000 lignes à implémenter  
⚠️ **Dépendances externes** : APIs tierces  
⚠️ **Complexité états** : Nombreux états React  
⚠️ **Migrations** : 110+ à rejouer dans l'ordre  
⚠️ **Tests** : Workflows complexes à tester  

### Recommandation

**Implémentation séquentielle par sous-module**, en commençant par :

1. **Touring Party** (fondation)
2. **Travels** (génère missions)
3. **Missions** (cœur transport)
4. **Drivers + Vehicles** (ressources missions)
5. **Shifts** (gestion équipes)
6. **Hotels + Catering** (hospitality prioritaire)
7. **Autres modules** (selon priorité métier)

**Durée estimée : 8-10 semaines** pour implémentation complète et fonctionnelle.

---

**FIN DE L'AUDIT MODULE PRODUCTION**

**Date** : 14 novembre 2025  
**Statut** : ✅ COMPLET  
**Prochaine étape** : Prompt d'implémentation pour nouveau SaaS  

---

*Documentation créée par : Senior Developer & Analyst*  
*Pour : Réimplémentation intégrale dans nouveau SaaS*  
*Basé sur : GO-PROD V3 (production actuelle)*

