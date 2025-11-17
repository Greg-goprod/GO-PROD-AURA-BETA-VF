# RELATIONS ET SCHÉMA DE BASE DE DONNÉES - MODULE PRODUCTION

## Vue d'ensemble

Ce document décrit en détail toutes les tables, relations, contraintes et index du module Production de GO-PROD. Il inclut les schémas SQL complets, les migrations historiques, et les patterns d'utilisation.

---

## SCHÉMA RELATIONNEL GLOBAL

```
┌──────────────────────────────────────────────────────────────────┐
│                    ENTITÉS CENTRALES                             │
└──────────────────────────────────────────────────────────────────┘

                         ┌─────────────┐
                         │   EVENTS    │
                         │-------------|
                         │ id (PK)     │
                         │ name        │
                         │ start_date  │
                         │ end_date    │
                         │ company_id  │
                         └──────┬──────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
         ┌──────▼──────┐ ┌─────▼─────┐  ┌─────▼─────┐
         │ EVENT_DAYS  │ │EVENT_ARTIST│  │ CONTACTS  │
         │-------------│ │------------│  │-----------│
         │ id (PK)     │ │ id (PK)    │  │ id (PK)   │
         │ event_id FK │ │ event_id FK│  │ event_id  │
         │ date        │ │ artist_id FK│  │ first_name│
         │ day_type    │ └────────────┘  │ last_name │
         └──────┬──────┘                  │ email     │
                │                         └───────────┘
                │
         ┌──────▼────────────┐
         │ ARTIST_PERFORMANCES│
         │--------------------|
         │ id (PK)            │
         │ artist_id FK       │
         │ event_day_id FK    │
         │ stage_id FK        │
         │ time               │
         └────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    MODULE TOURING PARTY                          │
└──────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────┐
        │  ARTIST_TOURING_PARTY       │
        │-----------------------------|
        │ id (PK)                     │
        │ event_id FK → events        │
        │ artist_id FK → artists      │
        │ performance_date DATE       │
        │ group_size INTEGER          │
        │ vehicles JSONB              │
        │ notes TEXT                  │
        │ special_requirements TEXT   │
        │ status TEXT                 │
        │ created_at TIMESTAMPTZ      │
        │ updated_at TIMESTAMPTZ      │
        └─────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    MODULE TRAVELS                                │
└──────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────┐
        │         TRAVELS             │
        │-----------------------------|
        │ id (PK)                     │
        │ event_id FK → events        │
        │ artist_id FK → artists (⊻)  │
        │ contact_id FK → contacts(⊻) │
        │ travel_type TEXT            │
        │ is_arrival BOOLEAN          │
        │ scheduled_datetime TIMESTAMPTZ│
        │ actual_datetime TIMESTAMPTZ │
        │ passenger_count INTEGER     │
        │ status TEXT                 │
        │ notes TEXT                  │
        │ created_at TIMESTAMPTZ      │
        │ updated_at TIMESTAMPTZ      │
        └──────────┬──────────────────┘
                   │
                   │ 1:1
                   ▼
        ┌─────────────────────────────┐
        │      TRAVEL_DETAILS         │
        │-----------------------------|
        │ id (PK)                     │
        │ travel_id FK → travels      │
        │ reference_number TEXT       │
        │ departure_location TEXT     │
        │ arrival_location TEXT       │
        │ created_at TIMESTAMPTZ      │
        └─────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    MODULE GROUND - MISSIONS                      │
└──────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────┐
        │         MISSIONS            │
        │-----------------------------|
        │ id (PK)                     │
        │ event_id FK → events        │
        │ travel_id FK → travels      │
        │ base_id FK → bases          │
        │                             │
        │ -- Lieux                    │
        │ pickup_location TEXT        │
        │ pickup_latitude DECIMAL     │
        │ pickup_longitude DECIMAL    │
        │ pickup_type VARCHAR(32)     │
        │ dropoff_location TEXT       │
        │ dropoff_latitude DECIMAL    │
        │ dropoff_longitude DECIMAL   │
        │ drop_type VARCHAR(32)       │
        │                             │
        │ -- Passagers                │
        │ passenger_id UUID           │
        │ passenger_count INTEGER     │
        │ luggage_count INTEGER       │
        │                             │
        │ -- Timing                   │
        │ flight_arrival_time TIMESTAMPTZ│
        │ start_at TIMESTAMPTZ        │
        │ duration_min INTEGER        │
        │ distance_km INTEGER         │
        │ cost_estimate NUMERIC(10,2) │
        │                             │
        │ -- Assignation              │
        │ driver_id FK → drivers      │
        │ vehicle_id FK → vehicles    │
        │                             │
        │ -- Statut & Notifications   │
        │ status TEXT                 │
        │ whatsapp_sent BOOLEAN       │
        │ whatsapp_sent_at TIMESTAMPTZ│
        │ reminder_scheduled BOOLEAN  │
        │                             │
        │ notes TEXT                  │
        │ created_at TIMESTAMPTZ      │
        │ updated_at TIMESTAMPTZ      │
        └──────┬───────┬──────────────┘
               │       │
               │       │
        ┌──────▼───┐   │
        │ DRIVERS  │   │
        └──────────┘   │
                       │
                 ┌─────▼──────┐
                 │  VEHICLES  │
                 └────────────┘

        ┌─────────────────────────────┐
        │      WAITING_TIME           │
        │-----------------------------|
        │ place_type VARCHAR(32) PK   │
        │ minutes SMALLINT            │
        │ description TEXT            │
        │ created_at TIMESTAMPTZ      │
        └─────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    MODULE GROUND - DRIVERS                       │
└──────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────┐
        │         DRIVERS             │
        │-----------------------------│ (RESSOURCE GLOBALE)
        │ id (PK)                     │
        │ first_name TEXT             │
        │ last_name TEXT              │
        │ email TEXT                  │
        │ phone TEXT                  │
        │                             │
        │ -- Adresse                  │
        │ street TEXT                 │
        │ postal_code TEXT            │
        │ city TEXT                   │
        │                             │
        │ -- Infos personnelles       │
        │ birth_date DATE             │
        │ photo_url TEXT              │
        │                             │
        │ -- Compétences              │
        │ languages TEXT[]            │
        │ permits TEXT[]              │
        │                             │
        │ -- Travail                  │
        │ hired_year INTEGER          │
        │ t_shirt_size TEXT           │
        │                             │
        │ -- Statuts                  │
        │ availability_status TEXT    │
        │ work_status TEXT            │
        │                             │
        │ notes TEXT                  │
        │ created_at TIMESTAMPTZ      │
        │ updated_at TIMESTAMPTZ      │
        └──────────┬──────────────────┘
                   │
                   │ M:N (via staff_assignments)
                   ▼
        ┌─────────────────────────────┐
        │    STAFF_ASSIGNMENTS        │
        │-----------------------------|
        │ id (PK)                     │
        │ driver_id FK → drivers      │
        │ event_id FK → events        │
        │ role TEXT                   │
        │ status TEXT                 │
        │ assigned_date DATE          │
        │ notes TEXT                  │
        └─────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    MODULE GROUND - VEHICLES                      │
└──────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────┐
        │        VEHICLES             │
        │-----------------------------│ (PAR ÉVÉNEMENT)
        │ id (PK)                     │
        │ event_id FK → events        │
        │                             │
        │ -- Identification           │
        │ brand TEXT                  │
        │ model TEXT                  │
        │ type TEXT                   │
        │ registration_number TEXT    │
        │ engagement_number TEXT      │
        │                             │
        │ -- Caractéristiques         │
        │ color TEXT                  │
        │ passenger_capacity INTEGER  │
        │ luggage_capacity INTEGER    │
        │ fuel_type TEXT              │
        │                             │
        │ -- Fournisseur              │
        │ supplier TEXT               │
        │ additional_equipment TEXT[] │
        │                             │
        │ -- Statut                   │
        │ status TEXT                 │
        │                             │
        │ created_at TIMESTAMPTZ      │
        │ updated_at TIMESTAMPTZ      │
        └─────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    MODULE GROUND - SHIFTS                        │
└──────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────┐
        │          SHIFTS             │
        │-----------------------------|
        │ id (PK)                     │
        │ event_id FK → events        │
        │ name TEXT                   │
        │ start_datetime TIMESTAMPTZ  │
        │ end_datetime TIMESTAMPTZ    │
        │ color TEXT                  │
        │ created_at TIMESTAMPTZ      │
        └──────────┬──────────────────┘
                   │
                   │ M:N
                   ▼
        ┌─────────────────────────────┐
        │      SHIFT_DRIVERS          │
        │-----------------------------|
        │ id (PK)                     │
        │ shift_id FK → shifts        │
        │ driver_id FK → drivers      │
        │ created_at TIMESTAMPTZ      │
        │ UNIQUE(shift_id, driver_id) │
        └─────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    MODULE HOSPITALITY - HOTELS                   │
└──────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────┐
        │          HOTELS             │
        │-----------------------------|
        │ id (PK)                     │
        │ name TEXT                   │
        │ address TEXT                │
        │ city TEXT                   │
        │ postal_code TEXT            │
        │ country TEXT                │
        │ phone TEXT                  │
        │ email TEXT                  │
        │ website TEXT                │
        │ stars INTEGER               │
        │ notes TEXT                  │
        └──────────┬──────────────────┘
                   │
                   │ 1:N
                   ▼
        ┌─────────────────────────────┐
        │       HOTEL_ROOMS           │
        │-----------------------------|
        │ id (PK)                     │
        │ hotel_id FK → hotels        │
        │ room_type TEXT              │
        │ capacity INTEGER            │
        │ description TEXT            │
        └──────────┬──────────────────┘
                   │
                   │ 1:N
                   ▼
        ┌─────────────────────────────┐
        │   HOTEL_ROOM_PRICES         │
        │-----------------------------|
        │ id (PK)                     │
        │ hotel_room_id FK            │
        │ event_id FK → events        │
        │ price_per_night NUMERIC     │
        │ currency TEXT               │
        │ valid_from DATE             │
        │ valid_to DATE               │
        └─────────────────────────────┘

        ┌─────────────────────────────┐
        │   HOTEL_RESERVATIONS        │
        │-----------------------------|
        │ id (PK)                     │
        │ event_id FK → events        │
        │ hotel_id FK → hotels        │
        │ contact_id FK → contacts    │
        │ artist_id FK → artists      │
        │ check_in DATE               │
        │ check_out DATE              │
        │ room_type TEXT              │
        │ number_of_rooms INTEGER     │
        │ price_per_night NUMERIC     │
        │ total_price NUMERIC         │
        │ currency TEXT               │
        │ status TEXT                 │
        │ confirmation_number TEXT    │
        │ notes TEXT                  │
        │ created_at TIMESTAMPTZ      │
        │ updated_at TIMESTAMPTZ      │
        └─────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                 MODULE HOSPITALITY - CATERING                    │
└──────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────┐
        │       DIET_TYPES            │
        │-----------------------------|
        │ code TEXT PK                │
        │ label TEXT                  │
        │ description TEXT            │
        │ icon TEXT                   │
        └─────────────────────────────┘

        ┌─────────────────────────────┐
        │    ARTIST_CATERING          │
        │-----------------------------|
        │ id (PK)                     │
        │ artist_id FK → artists      │
        │ event_day_id FK → event_days│
        │ breakfast_qty INTEGER       │
        │ lunch_qty INTEGER           │
        │ dinner_qty INTEGER          │
        │ after_show_type TEXT        │
        │ after_show_note TEXT        │
        │ headcount_total INTEGER     │
        │ remarks TEXT                │
        │ status TEXT                 │
        │ created_at TIMESTAMPTZ      │
        │ updated_at TIMESTAMPTZ      │
        └─────────────────────────────┘

        ┌─────────────────────────────┐
        │       ARTIST_DIET           │
        │-----------------------------|
        │ artist_id FK → artists PK   │
        │ diet_code FK → diet_types PK│
        │ quantity INTEGER            │
        └─────────────────────────────┘

        ┌─────────────────────────────┐
        │  SPECIAL_DIET_GUESTS        │
        │-----------------------------|
        │ id (PK)                     │
        │ artist_id FK → artists      │
        │ event_day_id FK → event_days│
        │ guest_number INTEGER        │
        │ diet_requirements JSONB     │
        │ created_at TIMESTAMPTZ      │
        └─────────────────────────────┘

        ┌─────────────────────────────┐
        │    CATERING_VOUCHERS        │
        │-----------------------------|
        │ id (PK)                     │
        │ event_id FK → events        │
        │ event_day_id FK → event_days│
        │ artist_id FK → artists      │
        │ meal_type TEXT              │
        │ ticket_number TEXT UNIQUE   │
        │ issued_at TIMESTAMPTZ       │
        │ used_at TIMESTAMPTZ         │
        │ status TEXT                 │
        │ created_at TIMESTAMPTZ      │
        └─────────────────────────────┘
```

---

## TABLES DÉTAILLÉES

### 1. ARTIST_TOURING_PARTY

**Objectif** : Stocker la taille des équipes d'artistes et leurs besoins en véhicules.

```sql
CREATE TABLE IF NOT EXISTS artist_touring_party (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  performance_date DATE NOT NULL,
  group_size INTEGER DEFAULT 0,
  vehicles JSONB DEFAULT '[]'::jsonb,
  notes TEXT,
  special_requirements TEXT,
  status TEXT CHECK (status IN ('todo', 'incomplete', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour performance
CREATE INDEX IF NOT EXISTS idx_touring_party_event 
  ON artist_touring_party(event_id);
  
CREATE INDEX IF NOT EXISTS idx_touring_party_artist 
  ON artist_touring_party(artist_id);
  
CREATE INDEX IF NOT EXISTS idx_touring_party_date 
  ON artist_touring_party(performance_date);
  
CREATE INDEX IF NOT EXISTS idx_touring_party_status 
  ON artist_touring_party(status);

-- Contrainte d'unicité
CREATE UNIQUE INDEX IF NOT EXISTS uq_touring_party_artist_date_event 
  ON artist_touring_party(artist_id, performance_date, event_id);
```

**Structure du JSONB `vehicles`** :

```json
[
  {
    "type": "CAR",
    "count": 2
  },
  {
    "type": "VAN",
    "count": 1
  },
  {
    "type": "TOURBUS",
    "count": 1
  }
]
```

**Trigger pour updated_at** :

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_update_touring_party_updated_at
  BEFORE UPDATE ON artist_touring_party
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### 2. TRAVELS

**Objectif** : Enregistrer tous les déplacements des artistes et contacts.

```sql
CREATE TABLE IF NOT EXISTS travels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  
  -- XOR: soit artist, soit contact
  artist_id UUID REFERENCES artists(id) ON DELETE CASCADE,
  contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
  
  travel_type TEXT NOT NULL CHECK (
    travel_type IN ('PLANE', 'TRAIN', 'CAR', 'VAN', 'BUS', 'TAXI', 'OTHER')
  ),
  
  is_arrival BOOLEAN DEFAULT false,
  
  scheduled_datetime TIMESTAMPTZ NOT NULL,
  actual_datetime TIMESTAMPTZ,
  
  passenger_count INTEGER DEFAULT 1,
  
  status TEXT CHECK (status IN ('planned', 'confirmed', 'in_transit', 'completed', 'cancelled')),
  
  notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Contrainte : exactement un de artist_id ou contact_id doit être non-null
  CONSTRAINT chk_travels_person CHECK (
    (artist_id IS NOT NULL AND contact_id IS NULL) OR
    (artist_id IS NULL AND contact_id IS NOT NULL)
  )
);

-- Index
CREATE INDEX idx_travels_event ON travels(event_id);
CREATE INDEX idx_travels_datetime ON travels(scheduled_datetime);
CREATE INDEX idx_travels_artist ON travels(artist_id);
CREATE INDEX idx_travels_contact ON travels(contact_id);
CREATE INDEX idx_travels_type ON travels(travel_type);
```

**Migrations historiques importantes** :
- `20250607160000_fix_travels_structure.sql` : Renommage `departure_datetime` → `scheduled_datetime`
- `20250601_add_passenger_count_to_travels.sql` : Ajout de `passenger_count`
- `20250630000000_add_status_column_travels.sql` : Ajout du statut

---

### 3. TRAVEL_DETAILS

**Objectif** : Détails spécifiques au type de transport (numéro de vol, gares, etc.).

```sql
CREATE TABLE IF NOT EXISTS travel_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  travel_id UUID NOT NULL REFERENCES travels(id) ON DELETE CASCADE,
  
  reference_number TEXT,        -- Numéro de vol, train, réservation
  departure_location TEXT,      -- Aéroport, gare de départ
  arrival_location TEXT,        -- Aéroport, gare d'arrivée
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_travel_details_travel ON travel_details(travel_id);
```

**Relation** : 1:1 avec `travels` (optionnelle)

---

### 4. MISSIONS

**Objectif** : Planification et dispatch des transferts/transports.

```sql
CREATE TABLE IF NOT EXISTS missions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  travel_id UUID REFERENCES travels(id) ON DELETE SET NULL,
  base_id UUID REFERENCES bases(id),
  
  -- Lieux
  pickup_location TEXT NOT NULL,
  pickup_latitude DECIMAL(10, 8),
  pickup_longitude DECIMAL(11, 8),
  pickup_type VARCHAR(32) DEFAULT 'other' CHECK (
    pickup_type IN ('airport', 'hotel', 'train_station', 'venue', 'other')
  ),
  
  dropoff_location TEXT NOT NULL,
  dropoff_latitude DECIMAL(10, 8),
  dropoff_longitude DECIMAL(11, 8),
  drop_type VARCHAR(32) DEFAULT 'other' CHECK (
    drop_type IN ('airport', 'hotel', 'train_station', 'venue', 'other')
  ),
  
  -- Passagers
  passenger_id UUID, -- Peut référencer artist ou contact (polymorphique)
  passenger_count INTEGER DEFAULT 1,
  luggage_count INTEGER DEFAULT 0,
  
  -- Timing (Smart V2)
  flight_arrival_time TIMESTAMPTZ,
  start_at TIMESTAMPTZ,              -- Calculé automatiquement
  duration_min INTEGER,
  distance_km INTEGER,
  cost_estimate NUMERIC(10,2),
  
  -- Assignation
  driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
  vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL,
  
  -- Statut
  status TEXT DEFAULT 'DRAFT' CHECK (
    status IN ('DRAFT', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')
  ),
  
  -- Notifications
  whatsapp_sent BOOLEAN DEFAULT false,
  whatsapp_sent_at TIMESTAMPTZ,
  reminder_scheduled BOOLEAN DEFAULT false,
  
  notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour performance
CREATE INDEX idx_missions_event ON missions(event_id);
CREATE INDEX idx_missions_travel ON missions(travel_id);
CREATE INDEX idx_missions_driver ON missions(driver_id);
CREATE INDEX idx_missions_vehicle ON missions(vehicle_id);
CREATE INDEX idx_missions_status ON missions(status);
CREATE INDEX idx_missions_start_at ON missions(start_at);
CREATE INDEX idx_missions_pickup_type ON missions(pickup_type);
CREATE INDEX idx_missions_drop_type ON missions(drop_type);
```

**Fonction RPC pour Dispatch** :

```sql
CREATE OR REPLACE FUNCTION assign_mission_driver(
  p_mission_id UUID,
  p_vehicle_id UUID,
  p_driver_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE missions 
  SET 
    vehicle_id = p_vehicle_id,
    driver_id = p_driver_id,
    status = 'ASSIGNED',
    updated_at = NOW()
  WHERE id = p_mission_id AND status = 'DRAFT';
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;
```

**Migration** : `20250129_mission_smart_v2_schema.sql`

---

### 5. WAITING_TIME

**Objectif** : Temps d'attente standard par type de lieu.

```sql
CREATE TABLE IF NOT EXISTS waiting_time (
  place_type VARCHAR(32) PRIMARY KEY,
  minutes SMALLINT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Données initiales
INSERT INTO waiting_time (place_type, minutes, description) VALUES
  ('airport', 45, 'Temps d''attente standard pour aéroports'),
  ('hotel', 10, 'Temps d''attente standard pour hôtels'),
  ('train_station', 15, 'Temps d''attente standard pour gares'),
  ('venue', 10, 'Temps d''attente lieu événement'),
  ('other', 10, 'Temps d''attente par défaut')
ON CONFLICT (place_type) DO UPDATE SET
  minutes = EXCLUDED.minutes,
  description = EXCLUDED.description;
```

**Fonction Helper** :

```sql
CREATE OR REPLACE FUNCTION get_waiting_time(p_place_type VARCHAR)
RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT minutes 
    FROM waiting_time 
    WHERE place_type = p_place_type
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN 10; -- Fallback
END;
$$ LANGUAGE plpgsql;
```

---

### 6. DRIVERS

**Objectif** : Ressource globale des chauffeurs.

```sql
CREATE TABLE IF NOT EXISTS drivers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Identité
  first_name TEXT,
  last_name TEXT,
  email TEXT UNIQUE,
  phone TEXT,
  
  -- Adresse
  street TEXT,
  postal_code TEXT,
  city TEXT,
  
  -- Infos personnelles
  birth_date DATE,
  photo_url TEXT,
  
  -- Compétences
  languages TEXT[] DEFAULT '{}',
  permits TEXT[] DEFAULT '{}', -- ['B', 'C', 'D', 'BE', 'CE']
  
  -- Travail
  hired_year INTEGER,
  t_shirt_size TEXT CHECK (t_shirt_size IN ('XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL')),
  
  -- Statuts
  availability_status TEXT DEFAULT 'AVAILABLE' CHECK (
    availability_status IN ('AVAILABLE', 'BUSY', 'OFF', 'VACATION')
  ),
  work_status TEXT DEFAULT 'ACTIVE' CHECK (
    work_status IN ('ACTIVE', 'INACTIVE', 'ARCHIVED')
  ),
  
  notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_drivers_email ON drivers(email);
CREATE INDEX idx_drivers_availability ON drivers(availability_status);
CREATE INDEX idx_drivers_work_status ON drivers(work_status);
CREATE INDEX idx_drivers_name ON drivers(last_name, first_name);
```

**Migration** : `20250207_fix_drivers_table.sql`

---

### 7. STAFF_ASSIGNMENTS

**Objectif** : Lier les chauffeurs (ressources globales) aux événements.

```sql
CREATE TABLE IF NOT EXISTS staff_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'driver',
  status TEXT DEFAULT 'assigned' CHECK (
    status IN ('assigned', 'confirmed', 'cancelled')
  ),
  assigned_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(driver_id, event_id, role)
);

CREATE INDEX idx_staff_assignments_driver ON staff_assignments(driver_id);
CREATE INDEX idx_staff_assignments_event ON staff_assignments(event_id);
```

---

### 8. VEHICLES

**Objectif** : Flotte de véhicules par événement.

```sql
CREATE TABLE IF NOT EXISTS vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  
  -- Identification
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  type TEXT CHECK (type IN ('CAR', 'VAN', 'BUS', 'TRUCK', 'MOTORCYCLE')),
  registration_number TEXT,
  engagement_number TEXT,
  
  -- Caractéristiques
  color TEXT,
  passenger_capacity INTEGER,
  luggage_capacity INTEGER,
  fuel_type TEXT CHECK (fuel_type IN ('PETROL', 'DIESEL', 'ELECTRIC', 'HYBRID')),
  
  -- Fournisseur
  supplier TEXT,
  additional_equipment TEXT[] DEFAULT '{}',
  
  -- Statut
  status TEXT DEFAULT 'available' CHECK (
    status IN ('available', 'in_use', 'maintenance', 'returned', 'unavailable')
  ),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vehicles_event ON vehicles(event_id);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_type ON vehicles(type);
```

---

### 9. SHIFTS

**Objectif** : Plages horaires de travail.

```sql
CREATE TABLE IF NOT EXISTS shifts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  start_datetime TIMESTAMPTZ NOT NULL,
  end_datetime TIMESTAMPTZ NOT NULL,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT chk_shifts_dates CHECK (end_datetime > start_datetime)
);

CREATE INDEX idx_shifts_event ON shifts(event_id);
CREATE INDEX idx_shifts_start ON shifts(start_datetime);
```

---

### 10. SHIFT_DRIVERS (Many-to-Many)

```sql
CREATE TABLE IF NOT EXISTS shift_drivers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
  driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(shift_id, driver_id)
);

CREATE INDEX idx_shift_drivers_shift ON shift_drivers(shift_id);
CREATE INDEX idx_shift_drivers_driver ON shift_drivers(driver_id);
```

---

### 11. CATERING - Tables Principales

#### DIET_TYPES

```sql
CREATE TABLE IF NOT EXISTS diet_types (
  code TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  description TEXT,
  icon TEXT
);

-- Seed data
INSERT INTO diet_types (code, label, description, icon) VALUES
  ('vegan', 'Vegan', 'Aucun produit animal', '🌱'),
  ('vegetarian', 'Végétarien', 'Pas de viande ni poisson', '🥗'),
  ('gluten_free', 'Sans gluten', 'Sans gluten', '🌾'),
  ('lactose_free', 'Sans lactose', 'Sans produits laitiers', '🥛'),
  ('halal', 'Halal', 'Conforme aux règles islamiques', '☪️'),
  ('kosher', 'Casher', 'Conforme aux règles juives', '✡️')
ON CONFLICT (code) DO NOTHING;
```

#### ARTIST_CATERING

```sql
CREATE TABLE IF NOT EXISTS artist_catering (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  event_day_id UUID NOT NULL REFERENCES event_days(id) ON DELETE CASCADE,
  
  breakfast_qty INTEGER DEFAULT 0,
  lunch_qty INTEGER DEFAULT 0,
  dinner_qty INTEGER DEFAULT 0,
  
  after_show_type TEXT CHECK (
    after_show_type IN ('catering', 'buyout', 'none')
  ),
  after_show_note TEXT,
  
  headcount_total INTEGER,
  remarks TEXT,
  
  status TEXT CHECK (status IN ('todo', 'incomplete', 'completed')),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(artist_id, event_day_id)
);

CREATE INDEX idx_artist_catering_artist ON artist_catering(artist_id);
CREATE INDEX idx_artist_catering_day ON artist_catering(event_day_id);
CREATE INDEX idx_artist_catering_status ON artist_catering(status);
```

#### ARTIST_DIET (Many-to-Many)

```sql
CREATE TABLE IF NOT EXISTS artist_diet (
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  diet_code TEXT NOT NULL REFERENCES diet_types(code) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 1,
  PRIMARY KEY (artist_id, diet_code)
);

CREATE INDEX idx_artist_diet_artist ON artist_diet(artist_id);
CREATE INDEX idx_artist_diet_code ON artist_diet(diet_code);
```

#### SPECIAL_DIET_GUESTS

```sql
CREATE TABLE IF NOT EXISTS special_diet_guests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  event_day_id UUID NOT NULL REFERENCES event_days(id) ON DELETE CASCADE,
  guest_number INTEGER NOT NULL,
  diet_requirements JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_special_diet_guests_artist ON special_diet_guests(artist_id);
CREATE INDEX idx_special_diet_guests_day ON special_diet_guests(event_day_id);
```

**Structure JSONB `diet_requirements`** :

```json
[
  {
    "diet_code": "vegan",
    "diet_type": {
      "code": "vegan",
      "label": "Vegan",
      "icon": "🌱"
    }
  },
  {
    "diet_code": "gluten_free",
    "diet_type": {
      "code": "gluten_free",
      "label": "Sans gluten",
      "icon": "🌾"
    }
  }
]
```

#### CATERING_VOUCHERS

```sql
CREATE TABLE IF NOT EXISTS catering_vouchers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  event_day_id UUID REFERENCES event_days(id) ON DELETE CASCADE,
  artist_id UUID REFERENCES artists(id) ON DELETE CASCADE,
  
  meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'aftershow')),
  ticket_number TEXT UNIQUE NOT NULL,
  
  issued_at TIMESTAMPTZ DEFAULT NOW(),
  used_at TIMESTAMPTZ,
  
  status TEXT DEFAULT 'issued' CHECK (status IN ('issued', 'used', 'cancelled')),
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_catering_vouchers_event ON catering_vouchers(event_id);
CREATE INDEX idx_catering_vouchers_artist ON catering_vouchers(artist_id);
CREATE INDEX idx_catering_vouchers_ticket ON catering_vouchers(ticket_number);
CREATE INDEX idx_catering_vouchers_status ON catering_vouchers(status);
```

**Migration** : `20250121_create_catering_vouchers_table.sql`

---

### 12. HOTELS - Structure Simplifiée

Les tables d'hôtels ont une structure complexe avec plusieurs migrations. Voici l'essentiel :

```sql
-- Table principale
CREATE TABLE IF NOT EXISTS hotels (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  postal_code TEXT,
  country TEXT,
  phone TEXT,
  email TEXT,
  website TEXT,
  stars INTEGER,
  notes TEXT
);

-- Chambres
CREATE TABLE IF NOT EXISTS hotel_rooms (
  id UUID PRIMARY KEY,
  hotel_id UUID REFERENCES hotels(id),
  room_type TEXT,
  capacity INTEGER,
  description TEXT
);

-- Tarification
CREATE TABLE IF NOT EXISTS hotel_room_prices (
  id UUID PRIMARY KEY,
  hotel_room_id UUID REFERENCES hotel_rooms(id),
  event_id UUID REFERENCES events(id),
  price_per_night NUMERIC(10,2),
  currency TEXT,
  valid_from DATE,
  valid_to DATE
);

-- Réservations
CREATE TABLE IF NOT EXISTS hotel_reservations (
  id UUID PRIMARY KEY,
  event_id UUID REFERENCES events(id),
  hotel_id UUID REFERENCES hotels(id),
  contact_id UUID REFERENCES contacts(id),
  artist_id UUID REFERENCES artists(id),
  check_in DATE,
  check_out DATE,
  room_type TEXT,
  number_of_rooms INTEGER,
  price_per_night NUMERIC(10,2),
  total_price NUMERIC(10,2),
  currency TEXT,
  status TEXT,
  confirmation_number TEXT,
  notes TEXT
);
```

**Migrations importantes** :
- `20250120_cleanup_hotel_structure.sql`
- `20250130_hotel_category_room_types_refactor.sql`
- `20250626112356_add_currency_to_hotel_reservations.sql`

---

## CONTRAINTES ET VALIDATIONS

### Contraintes CHECK Importantes

```sql
-- Travels : XOR artist_id ou contact_id
ALTER TABLE travels ADD CONSTRAINT chk_travels_person CHECK (
  (artist_id IS NOT NULL AND contact_id IS NULL) OR
  (artist_id IS NULL AND contact_id IS NOT NULL)
);

-- Shifts : Dates cohérentes
ALTER TABLE shifts ADD CONSTRAINT chk_shifts_dates CHECK (
  end_datetime > start_datetime
);

-- Missions : Types de lieux valides
ALTER TABLE missions ADD CONSTRAINT chk_missions_pickup_type CHECK (
  pickup_type IN ('airport', 'hotel', 'train_station', 'venue', 'other')
);
```

### Contraintes d'Unicité

```sql
-- Touring Party : Unique par artist + date + event
CREATE UNIQUE INDEX uq_touring_party_artist_date_event 
  ON artist_touring_party(artist_id, performance_date, event_id);

-- Catering : Unique par artist + jour
ALTER TABLE artist_catering 
  ADD CONSTRAINT uq_artist_catering_artist_day 
  UNIQUE(artist_id, event_day_id);

-- Vouchers : Ticket unique
ALTER TABLE catering_vouchers 
  ADD CONSTRAINT uq_catering_voucher_ticket 
  UNIQUE(ticket_number);

-- Staff Assignments : Un driver ne peut avoir qu'une assignation par événement
ALTER TABLE staff_assignments 
  ADD CONSTRAINT uq_staff_assignment_driver_event 
  UNIQUE(driver_id, event_id, role);
```

---

## INDEX DE PERFORMANCE

### Index par Module

```sql
-- TOURING PARTY
CREATE INDEX idx_touring_party_event ON artist_touring_party(event_id);
CREATE INDEX idx_touring_party_status ON artist_touring_party(status);

-- TRAVELS
CREATE INDEX idx_travels_event ON travels(event_id);
CREATE INDEX idx_travels_datetime ON travels(scheduled_datetime);
CREATE INDEX idx_travels_type ON travels(travel_type);

-- MISSIONS
CREATE INDEX idx_missions_event ON missions(event_id);
CREATE INDEX idx_missions_status ON missions(status);
CREATE INDEX idx_missions_start_at ON missions(start_at);
CREATE INDEX idx_missions_driver ON missions(driver_id);
CREATE INDEX idx_missions_vehicle ON missions(vehicle_id);

-- DRIVERS
CREATE INDEX idx_drivers_availability ON drivers(availability_status);
CREATE INDEX idx_drivers_work_status ON drivers(work_status);

-- VEHICLES
CREATE INDEX idx_vehicles_event ON vehicles(event_id);
CREATE INDEX idx_vehicles_status ON vehicles(status);

-- CATERING
CREATE INDEX idx_artist_catering_artist ON artist_catering(artist_id);
CREATE INDEX idx_artist_catering_day ON artist_catering(event_day_id);
CREATE INDEX idx_catering_vouchers_ticket ON catering_vouchers(ticket_number);
```

---

## FONCTIONS SQL UTILITAIRES

### 1. Calcul du Start At (Missions)

```sql
CREATE OR REPLACE FUNCTION calculate_mission_start_at(
  p_flight_arrival TIMESTAMPTZ,
  p_base_to_pickup_duration INTEGER
)
RETURNS TIMESTAMPTZ AS $$
BEGIN
  IF p_flight_arrival IS NULL OR p_base_to_pickup_duration IS NULL THEN
    RETURN NULL;
  END IF;
  
  RETURN p_flight_arrival - (p_base_to_pickup_duration || ' minutes')::INTERVAL;
END;
$$ LANGUAGE plpgsql;
```

### 2. Création Mission Draft (RPC)

```sql
CREATE OR REPLACE FUNCTION create_mission_draft(
  p_base_id UUID,
  p_pickup_location TEXT,
  p_pickup_latitude DECIMAL,
  p_pickup_longitude DECIMAL,
  p_pickup_type VARCHAR,
  p_dropoff_location TEXT,
  p_dropoff_latitude DECIMAL,
  p_dropoff_longitude DECIMAL,
  p_drop_type VARCHAR,
  p_passenger_count INTEGER DEFAULT 1,
  p_luggage_count INTEGER DEFAULT 0,
  p_notes TEXT DEFAULT NULL,
  p_passenger_id UUID DEFAULT NULL,
  p_flight_arrival_time TIMESTAMPTZ DEFAULT NULL,
  p_duration_min INTEGER DEFAULT NULL,
  p_distance_km INTEGER DEFAULT NULL,
  p_cost_estimate NUMERIC DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  mission_id UUID;
  calculated_start_at TIMESTAMPTZ;
BEGIN
  IF p_flight_arrival_time IS NOT NULL AND p_duration_min IS NOT NULL THEN
    calculated_start_at := calculate_mission_start_at(p_flight_arrival_time, p_duration_min);
  END IF;

  INSERT INTO missions (
    base_id, pickup_location, pickup_latitude, pickup_longitude, pickup_type,
    dropoff_location, dropoff_latitude, dropoff_longitude, drop_type,
    passenger_count, luggage_count, notes, passenger_id,
    flight_arrival_time, start_at, duration_min, distance_km, cost_estimate, status
  ) VALUES (
    p_base_id, p_pickup_location, p_pickup_latitude, p_pickup_longitude, p_pickup_type,
    p_dropoff_location, p_dropoff_latitude, p_dropoff_longitude, p_drop_type,
    p_passenger_count, p_luggage_count, p_notes, p_passenger_id,
    p_flight_arrival_time, calculated_start_at, p_duration_min, p_distance_km, p_cost_estimate, 'DRAFT'
  )
  RETURNING id INTO mission_id;
  
  RETURN mission_id;
END;
$$ LANGUAGE plpgsql;
```

### 3. Triggers Updated At

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer à toutes les tables avec updated_at
CREATE TRIGGER tr_update_artist_touring_party_updated_at
  BEFORE UPDATE ON artist_touring_party
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_update_travels_updated_at
  BEFORE UPDATE ON travels
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_update_missions_updated_at
  BEFORE UPDATE ON missions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- etc...
```

---

## MIGRATIONS CLÉS

### Historique des Migrations Production

```
20250121_update_travels_vehicles_simplified.sql
20250121_fix_travels_vehicles_structure.sql
20250129_add_travel_fields_back.sql
20250601_fix_travels_constraints.sql
20250601_add_passenger_count_to_travels.sql
20250607160000_fix_travels_structure.sql
20250630000000_add_status_column_travels.sql

20250129_mission_smart_v2_schema.sql

20250207_fix_drivers_table.sql
20250122_setup_driver_photos_complete.sql

20250121_create_catering_vouchers_table.sql
20250121_fix_catering_vouchers_constraints.sql

20250120_cleanup_hotel_structure.sql
20250130_hotel_category_room_types_refactor.sql
20250131133000_fix_hotel_reservations_structure.sql
20250131140000_refactor_hotel_reservations_complete.sql
20250131150000_fix_create_hotel_reservation_function.sql
20250201_fix_hotel_reservations_null_constraint.sql
20250205_fix_create_hotel_reservation_function_types.sql
20250206_fix_hotel_reservations_null_and_incomplete.sql
20250206_update_hotel_reservations_complete_view.sql
20250619_migrate_old_prices_to_hotel_room_prices.sql
20250626112356_add_currency_to_hotel_reservations.sql
```

---

## ROW LEVEL SECURITY (RLS)

**État actuel** : RLS **désactivé** sur la plupart des tables Production pour faciliter le développement.

**À implémenter en production** :

```sql
-- Exemple générique pour toutes les tables liées aux événements
CREATE POLICY "event_access"
  ON {table_name}
  USING (
    event_id IN (
      SELECT event_id 
      FROM user_event_access 
      WHERE user_id = auth.uid()
    )
  );

-- Pour les ressources globales (drivers)
CREATE POLICY "company_access"
  ON drivers
  USING (
    company_id IN (
      SELECT company_id 
      FROM user_company_access 
      WHERE user_id = auth.uid()
    )
  );
```

---

## BEST PRACTICES

### 1. Nommage des Tables

- **snake_case** pour tous les noms
- Pluriel pour les tables de données (`travels`, `missions`, `drivers`)
- Singulier pour les tables de configuration (`waiting_time`)
- `_` pour les liaisons many-to-many (`shift_drivers`, `staff_assignments`)

### 2. Clés Étrangères

- Toujours avec `ON DELETE CASCADE` ou `ON DELETE SET NULL` selon le contexte
- Index automatique créé sur les FK

### 3. Timestamps

- `created_at` : Toujours `DEFAULT NOW()`
- `updated_at` : Avec trigger `update_updated_at_column()`

### 4. JSONB

- Utiliser pour structures flexibles (vehicles, diet_requirements)
- Toujours avec valeur par défaut : `DEFAULT '[]'::jsonb` ou `DEFAULT '{}'::jsonb`

### 5. Enums vs CHECK

- **CHECK** utilisé pour flexibilité (pas de types enum custom)
- Permet ajout facile de nouvelles valeurs

---

## REQUÊTES COMMUNES

### Récupérer tous les travels avec détails

```sql
SELECT 
  t.*,
  td.reference_number,
  td.departure_location,
  td.arrival_location,
  a.name as artist_name,
  c.first_name || ' ' || c.last_name as contact_name
FROM travels t
LEFT JOIN travel_details td ON t.id = td.travel_id
LEFT JOIN artists a ON t.artist_id = a.id
LEFT JOIN contacts c ON t.contact_id = c.id
WHERE t.event_id = :event_id
ORDER BY t.scheduled_datetime;
```

### Missions avec chauffeur et véhicule

```sql
SELECT 
  m.*,
  d.first_name || ' ' || d.last_name as driver_name,
  v.brand || ' ' || v.model as vehicle_info
FROM missions m
LEFT JOIN drivers d ON m.driver_id = d.id
LEFT JOIN vehicles v ON m.vehicle_id = v.id
WHERE m.event_id = :event_id
ORDER BY m.start_at;
```

### Catering par jour avec régimes

```sql
SELECT 
  ac.*,
  a.name as artist_name,
  ed.date as performance_date,
  ad.diet_code,
  ad.quantity as diet_quantity,
  dt.label as diet_label
FROM artist_catering ac
JOIN artists a ON ac.artist_id = a.id
JOIN event_days ed ON ac.event_day_id = ed.id
LEFT JOIN artist_diet ad ON ac.artist_id = ad.artist_id
LEFT JOIN diet_types dt ON ad.diet_code = dt.code
WHERE ed.event_id = :event_id
ORDER BY ed.date, a.name;
```

### Chauffeurs disponibles pour un événement

```sql
SELECT 
  d.*,
  sa.status as assignment_status
FROM drivers d
LEFT JOIN staff_assignments sa ON d.id = sa.driver_id AND sa.event_id = :event_id
WHERE d.work_status = 'ACTIVE'
  AND d.availability_status = 'AVAILABLE'
  AND (sa.id IS NULL OR sa.status = 'assigned')
ORDER BY d.last_name, d.first_name;
```

---

## CONCLUSION

Le module Production utilise un schéma relationnel bien structuré avec :
- ✅ **Normalisation appropriée** (3NF pour la plupart des tables)
- ✅ **Contraintes d'intégrité** (FK, CHECK, UNIQUE)
- ✅ **Index de performance** sur les requêtes fréquentes
- ✅ **Flexibilité JSONB** pour structures variables
- ✅ **Triggers** pour automatisation (updated_at)
- ✅ **Fonctions RPC** pour logique métier complexe
- ⚠️ **RLS à implémenter** pour sécurité production

**Prochaines étapes** :
- Activer RLS sur toutes les tables
- Ajouter audit trails (history tables)
- Implémenter soft deletes
- Ajouter vues matérialisées pour dashboards

---

**Voir aussi** :
- [Architecture Production](./PRODUCTION_SYSTEM_ARCHITECTURE.md)
- [Workflow Production](./PRODUCTION_SYSTEM_WORKFLOW.md)
- [Index](./PRODUCTION_INDEX.md)


