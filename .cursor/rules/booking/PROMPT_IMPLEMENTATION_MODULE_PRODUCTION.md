# 🎯 PROMPT D'IMPLÉMENTATION - MODULE PRODUCTION COMPLET

> Prompt structuré pour implémenter l'intégralité du module Production dans le nouveau SaaS

**Date** : 14 novembre 2025  
**Module** : Production (7 sous-modules)  
**Complexité** : ⭐⭐⭐⭐⭐ (5/5)  
**Durée estimée** : 8-10 semaines  

---

## ⚠️ INSTRUCTIONS PRÉLIMINAIRES CRITIQUES

### AVANT TOUTE MODIFICATION

**TU DOIS IMPÉRATIVEMENT** :

1. ✅ **ANALYSER** si un module Production existe déjà dans le nouveau SaaS
2. ✅ **LISTER** toutes les fonctionnalités existantes
3. ✅ **COMPARER** avec la spécification ci-dessous
4. ✅ **IDENTIFIER** ce qui manque ou doit être modifié
5. ✅ **PRIORISER** les sous-modules selon les besoins métier

### APPROCHE RECOMMANDÉE

**Implémentation séquentielle par sous-module** :

```
1. TOURING PARTY    (fondation)
2. TRAVELS          (génère missions)
3. MISSIONS         (cœur transport)
4. DRIVERS          (ressources)
5. VEHICLES         (ressources)
6. SHIFTS           (gestion équipes)
7. HOTELS           (priorité hospitality)
8. CATERING         (priorité hospitality)
9. PARTY CREW       (personnel)
10. STAFF           (vue globale)
11. AUTRES MODULES  (selon priorité)
```

**NE JAMAIS** :
- ❌ Implémenter tous les modules en parallèle
- ❌ Ignorer les dépendances entre modules
- ❌ Oublier les migrations SQL
- ❌ Négliger les indexes de performance

---

## 📚 DOCUMENTATION DE RÉFÉRENCE

**Lire OBLIGATOIREMENT avant implémentation** :
- **`docs/PRODUCTION_MODULE_AUDIT_COMPLET.md`** (1000+ lignes, analyse exhaustive)

**Documentation additionnelle** :
- `docs/PRODUCTION_SYSTEM_ARCHITECTURE.md`
- `docs/PRODUCTION_SYSTEM_WORKFLOW.md`
- `docs/PRODUCTION_SYSTEM_RELATIONS.md`

---

## 🏗️ ARCHITECTURE GLOBALE

### Structure Modulaire

```
PRODUCTION (Page Parent)
│
├── ProductionPage.tsx         (Page parent avec dashboard)
├── ProductionNavigation.tsx   (Navigation partagée)
│
├── 1. TOURING PARTY          (Effectifs artistes)
│   ├── TouringPartyPage.tsx
│   └── Table: artist_touring_party
│
├── 2. TRAVELS                (Voyages artistes)
│   ├── TravelsPage.tsx
│   ├── TravelStepper.tsx     (Modal création)
│   ├── TravelList.tsx
│   └── Table: travels
│
├── 3. GROUND (Transport)     
│   ├── 3.1 MISSIONS          (Coordination transport)
│   │   ├── MissionsPage.tsx
│   │   ├── MissionPlanningModal.tsx
│   │   ├── MissionDispatchModal.tsx
│   │   └── Table: missions
│   │
│   ├── 3.2 DRIVERS           (Chauffeurs)
│   │   ├── DriversPage.tsx
│   │   ├── DriverForm.tsx
│   │   └── Tables: drivers, staff_assignments
│   │
│   ├── 3.3 VEHICLES          (Véhicules)
│   │   ├── VehiclesPage.tsx
│   │   ├── VehicleForm.tsx
│   │   └── Tables: vehicles, vehicle_check_logs
│   │
│   └── 3.4 SHIFTS            (Équipes)
│       ├── ShiftsPage.tsx
│       ├── ShiftForm.tsx
│       ├── ShiftDriverAssignment.tsx
│       └── Tables: shifts, shift_drivers
│
├── 4. HOSPITALITY (Accueil)
│   ├── 4.1 HOTELS
│   │   ├── HotelsPage.tsx
│   │   ├── HotelReservationTableSimple.tsx
│   │   └── Tables: hotels, hotel_room_types, hotel_reservations
│   │
│   ├── 4.2 BACKSTAGE
│   │   ├── BackstagePage.tsx
│   │   └── (À développer)
│   │
│   ├── 4.3 CATERING
│   │   ├── CateringPage.tsx
│   │   ├── CateringDashboard.tsx
│   │   ├── VoucherManagement.tsx
│   │   └── Tables: catering_requirements, catering_vouchers
│   │
│   └── 4.4 ACCRED/GUESTS
│       ├── AccredInvitsPage.tsx
│       └── (À développer)
│
├── 5. TECHNIQUE
│   ├── TechniquePage.tsx
│   └── (À développer)
│
├── 6. TIMETABLE
│   ├── TimetablePage.tsx
│   └── (À développer)
│
└── 7. PARTY CREW & STAFF
    ├── PartyCrewPage.tsx
    ├── StaffPage.tsx
    └── Table: party_crew
```

---

## 🗄️ SCHÉMA BASE DE DONNÉES

### Ordre de Création Tables (CRITIQUE)

```sql
-- 1. Tables fondamentales (déjà existantes normalement)
events
event_days
stages
artists
contacts

-- 2. Touring Party
artist_touring_party

-- 3. Travels
travels

-- 4. Bases et Missions
bases
missions

-- 5. Ground - Personnel
drivers
staff_assignments

-- 6. Ground - Véhicules
vehicles
vehicle_check_logs

-- 7. Ground - Shifts
shifts
shift_drivers

-- 8. Hospitality - Hotels
hotels
hotel_room_types
hotel_reservations

-- 9. Hospitality - Catering
catering_requirements
catering_vouchers

-- 10. Party Crew
party_crew
```

### Script SQL Complet de Création

**ATTENTION** : Créer dans l'ordre ci-dessus pour respecter les foreign keys !

```sql
-- ============================================================================
-- TABLE: artist_touring_party
-- ============================================================================
CREATE TABLE IF NOT EXISTS artist_touring_party (
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

CREATE INDEX idx_artist_touring_party_event_id ON artist_touring_party(event_id);
CREATE INDEX idx_artist_touring_party_artist_id ON artist_touring_party(artist_id);

-- ============================================================================
-- TABLE: travels
-- ============================================================================
CREATE TABLE IF NOT EXISTS travels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
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
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (artist_id IS NOT NULL OR contact_id IS NOT NULL)
);

CREATE INDEX idx_travels_event_id ON travels(event_id);
CREATE INDEX idx_travels_artist_id ON travels(artist_id);
CREATE INDEX idx_travels_scheduled_datetime ON travels(scheduled_datetime);

-- ============================================================================
-- TABLE: bases
-- ============================================================================
CREATE TABLE IF NOT EXISTS bases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    city VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- TABLE: missions
-- ============================================================================
CREATE TABLE IF NOT EXISTS missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    travel_id UUID REFERENCES travels(id),
    driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL,
    base_id UUID REFERENCES bases(id) ON DELETE SET NULL,
    artist_id UUID REFERENCES artists(id),
    contact_id UUID REFERENCES contacts(id),
    
    pickup_location TEXT NOT NULL,
    pickup_latitude DECIMAL(10, 8),
    pickup_longitude DECIMAL(11, 8),
    pickup_datetime TIMESTAMPTZ NOT NULL,
    
    dropoff_location TEXT NOT NULL,
    dropoff_latitude DECIMAL(10, 8),
    dropoff_longitude DECIMAL(11, 8),
    dropoff_datetime TIMESTAMPTZ,
    
    passenger_count INTEGER NOT NULL DEFAULT 1,
    luggage_count INTEGER DEFAULT 0,
    
    status VARCHAR(50) DEFAULT 'unplanned' 
      CHECK (status IN ('unplanned', 'draft', 'planned', 'dispatched')),
    
    notes TEXT,
    estimated_duration_minutes INTEGER,
    actual_duration_minutes INTEGER,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(travel_id) -- Un travel = une seule mission
);

CREATE INDEX idx_missions_event_id ON missions(event_id);
CREATE INDEX idx_missions_travel_id ON missions(travel_id);
CREATE INDEX idx_missions_driver_id ON missions(driver_id);
CREATE INDEX idx_missions_vehicle_id ON missions(vehicle_id);
CREATE INDEX idx_missions_pickup_datetime ON missions(pickup_datetime);
CREATE INDEX idx_missions_status ON missions(status);

-- ============================================================================
-- TABLE: drivers
-- ============================================================================
CREATE TABLE IF NOT EXISTS drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    street VARCHAR(255),
    postal_code VARCHAR(20),
    city VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    birth_date DATE,
    languages TEXT[],
    t_shirt_size VARCHAR(10) DEFAULT 'M',
    hired_year INTEGER NOT NULL,
    permits TEXT[],
    notes TEXT,
    photo_url TEXT,
    availability_status VARCHAR(50) DEFAULT 'AVAILABLE' 
      CHECK (availability_status IN ('AVAILABLE', 'BUSY', 'OFF')),
    work_status VARCHAR(50) DEFAULT 'ACTIVE'
      CHECK (work_status IN ('ACTIVE', 'INACTIVE', 'SEASONAL')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- TABLE: staff_assignments
-- ============================================================================
CREATE TABLE IF NOT EXISTS staff_assignments (
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

-- ============================================================================
-- TABLE: vehicles
-- ============================================================================
CREATE TABLE IF NOT EXISTS vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    color VARCHAR(50),
    passenger_capacity INTEGER,
    luggage_capacity INTEGER,
    engagement_number VARCHAR(100),
    registration_number VARCHAR(50),
    fuel_type VARCHAR(50),
    status VARCHAR(50) DEFAULT 'available'
      CHECK (status IN ('available', 'assigned', 'maintenance', 'unavailable')),
    supplier VARCHAR(255),
    additional_equipment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vehicles_event_id ON vehicles(event_id);

-- ============================================================================
-- TABLE: vehicle_check_logs
-- ============================================================================
CREATE TABLE IF NOT EXISTS vehicle_check_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('RECEPTION', 'RETURN')),
    date DATE NOT NULL,
    kilometers INTEGER NOT NULL,
    defects TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vehicle_check_logs_vehicle_id ON vehicle_check_logs(vehicle_id);

-- ============================================================================
-- TABLE: shifts
-- ============================================================================
CREATE TABLE IF NOT EXISTS shifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,
    color VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_shifts_event_id ON shifts(event_id);

-- ============================================================================
-- TABLE: shift_drivers
-- ============================================================================
CREATE TABLE IF NOT EXISTS shift_drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(shift_id, driver_id)
);

CREATE INDEX idx_shift_drivers_shift_id ON shift_drivers(shift_id);
CREATE INDEX idx_shift_drivers_driver_id ON shift_drivers(driver_id);

-- ============================================================================
-- TABLE: hotels
-- ============================================================================
CREATE TABLE IF NOT EXISTS hotels (
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

-- ============================================================================
-- TABLE: hotel_room_types
-- ============================================================================
CREATE TABLE IF NOT EXISTS hotel_room_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hotel_id UUID NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    category VARCHAR(100) NOT NULL,
    price_per_night DECIMAL(10,2),
    capacity INTEGER,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_hotel_room_types_hotel_id ON hotel_room_types(hotel_id);

-- ============================================================================
-- TABLE: hotel_reservations
-- ============================================================================
CREATE TABLE IF NOT EXISTS hotel_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
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
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (artist_id IS NOT NULL OR contact_id IS NOT NULL)
);

CREATE INDEX idx_hotel_reservations_event_id ON hotel_reservations(event_id);

-- ============================================================================
-- TABLE: catering_requirements
-- ============================================================================
CREATE TABLE IF NOT EXISTS catering_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    meal_type VARCHAR(50) NOT NULL
      CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'drinks')),
    count INTEGER DEFAULT 1,
    special_diet TEXT[],
    notes TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_catering_requirements_event_id ON catering_requirements(event_id);
CREATE INDEX idx_catering_requirements_artist_id ON catering_requirements(artist_id);

-- ============================================================================
-- TABLE: catering_vouchers
-- ============================================================================
CREATE TABLE IF NOT EXISTS catering_vouchers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    code VARCHAR(100) UNIQUE NOT NULL,
    artist_id UUID REFERENCES artists(id),
    contact_id UUID REFERENCES contacts(id),
    meal_type VARCHAR(50),
    value DECIMAL(10,2),
    is_used BOOLEAN DEFAULT false,
    used_at TIMESTAMPTZ,
    scanned_by UUID, -- REFERENCES auth.users(id)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_catering_vouchers_event_id ON catering_vouchers(event_id);
CREATE INDEX idx_catering_vouchers_code ON catering_vouchers(code);

-- ============================================================================
-- TABLE: party_crew
-- ============================================================================
CREATE TABLE IF NOT EXISTS party_crew (
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

-- ============================================================================
-- TRIGGERS update_updated_at
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Appliquer trigger sur toutes les tables avec updated_at
CREATE TRIGGER update_artist_touring_party_updated_at 
  BEFORE UPDATE ON artist_touring_party 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_travels_updated_at 
  BEFORE UPDATE ON travels 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_missions_updated_at 
  BEFORE UPDATE ON missions 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_drivers_updated_at 
  BEFORE UPDATE ON drivers 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at 
  BEFORE UPDATE ON vehicles 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shifts_updated_at 
  BEFORE UPDATE ON shifts 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_hotels_updated_at 
  BEFORE UPDATE ON hotels 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_hotel_reservations_updated_at 
  BEFORE UPDATE ON hotel_reservations 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_catering_requirements_updated_at 
  BEFORE UPDATE ON catering_requirements 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_party_crew_updated_at 
  BEFORE UPDATE ON party_crew 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FONCTIONS SQL
-- ============================================================================

-- Fonction: Récupérer touring party avec noms artistes
CREATE OR REPLACE FUNCTION get_artist_touring_party_by_event(event_id_param UUID)
RETURNS TABLE(
    id UUID,
    artist_id UUID,
    artist_name TEXT,
    group_size INTEGER,
    vehicles JSONB,
    notes TEXT,
    special_requirements TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
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
    WHERE atp.event_id = event_id_param
    ORDER BY a.name;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- RLS POLICIES (À ADAPTER EN PRODUCTION)
-- ============================================================================

-- Pour développement: politiques permissives
ALTER TABLE artist_touring_party ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON artist_touring_party FOR ALL USING (true);

ALTER TABLE travels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON travels FOR ALL USING (true);

ALTER TABLE missions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON missions FOR ALL USING (true);

ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON drivers FOR ALL USING (true);

ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON vehicles FOR ALL USING (true);

ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON shifts FOR ALL USING (true);

ALTER TABLE hotels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON hotels FOR ALL USING (true);

ALTER TABLE hotel_reservations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON hotel_reservations FOR ALL USING (true);

ALTER TABLE catering_requirements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON catering_requirements FOR ALL USING (true);

ALTER TABLE catering_vouchers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON catering_vouchers FOR ALL USING (true);

ALTER TABLE party_crew ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON party_crew FOR ALL USING (true);
```

---

## 🚀 IMPLÉMENTATION PAR MODULE

### MODULE 1 : TOURING PARTY

**Durée estimée** : 3 jours

#### Checklist

- [ ] Créer table `artist_touring_party`
- [ ] Créer `TouringPartyPage.tsx`
- [ ] Implémenter dashboard accordéon
- [ ] Implémenter groupement par jour
- [ ] Créer fiches artiste (2 colonnes)
- [ ] Implémenter 8 inputs véhicules
- [ ] Implémenter calcul automatique statut
- [ ] Implémenter sauvegarde auto (upsert)
- [ ] Tester CRUD complet

#### Code Clé : Calcul Statut

```typescript
const calculateStatus = (artist: ArtistTouringPartyWithDay): 'todo' | 'incomplete' | 'completed' => {
  const hasPersons = artist.group_size > 0;
  const hasVehicles = artist.vehicles.some(v => v.count > 0);
  
  if (hasPersons && hasVehicles) return 'completed';
  else if (hasPersons || hasVehicles) return 'incomplete';
  else return 'todo';
};
```

#### Code Clé : Sauvegarde Auto

```typescript
const updateTouringParty = async (artistId: string, field: string, value: any) => {
  const artist = eventDays.flatMap(day => day.artists).find(a => a.artist_id === artistId);
  if (!artist) return;

  const updatedArtist = { ...artist, [field]: value };
  const newStatus = field === 'status' ? value : calculateStatus(updatedArtist);

  const data = {
    event_id: currentEvent.id,
    artist_id: artistId,
    group_size: field === 'group_size' ? value : artist.group_size,
    vehicles: field === 'vehicles' ? value : artist.vehicles,
    notes: field === 'notes' ? value : artist.notes,
    special_requirements: field === 'special_requirements' ? value : artist.special_requirements,
    status: newStatus
  };

  if (artist.id) {
    // UPDATE
    await supabase.from('artist_touring_party').update(data).eq('id', artist.id);
  } else {
    // INSERT
    const { data: newRecord } = await supabase.from('artist_touring_party').insert([data]).select().single();
    // Mettre à jour état local avec nouvel ID
  }
};
```

---

### MODULE 2 : TRAVELS

**Durée estimée** : 5 jours

#### Checklist

- [ ] Créer table `travels`
- [ ] Créer `TravelsPage.tsx`
- [ ] Créer `TravelStepper.tsx` (4 étapes)
- [ ] Créer `PlaneTrainForm.tsx`
- [ ] Créer `TravelVehicleForm.tsx`
- [ ] Créer `TravelList.tsx` (Grid + List)
- [ ] Implémenter filtrage/recherche
- [ ] Tester CRUD complet

#### Code Clé : TravelStepper

```typescript
// Étape 1: Type de voyage
<div>
  {TRAVEL_TYPES.map(type => (
    <button onClick={() => setTravelType(type.value)}>
      {type.icon} {type.label}
    </button>
  ))}
</div>

// Étape 2: Personne
<div>
  <button onClick={() => setPersonType('ARTIST')}>Artiste</button>
  <button onClick={() => setPersonType('CONTACT')}>Contact</button>
  
  {personType === 'ARTIST' && (
    <Select multiple value={selectedArtists} onChange={...} />
  )}
  {personType === 'CONTACT' && (
    <Select value={selectedContact} onChange={...} />
  )}
</div>

// Étape 3: Direction
<div>
  <button onClick={() => setIsArrival(true)}>ARRIVÉE</button>
  <button onClick={() => setIsArrival(false)}>DÉPART</button>
</div>

// Étape 4: Détails
{travelType === 'PLANE' || travelType === 'TRAIN' ? (
  <PlaneTrainForm {...} />
) : (
  <TravelVehicleForm {...} />
)}
```

---

### MODULE 3 : MISSIONS

**Durée estimée** : 7 jours (le plus complexe)

#### Checklist

- [ ] Créer tables `bases` et `missions`
- [ ] Créer `MissionsPage.tsx`
- [ ] Implémenter Supabase Realtime (écoute travels)
- [ ] Implémenter `syncTravelsToMissions()`
- [ ] Implémenter `cleanupDuplicateMissions()`
- [ ] Créer `MissionListItem.tsx`
- [ ] Créer `MissionPlanningModal.tsx`
- [ ] Intégrer API Nominatim (geocoding)
- [ ] Intégrer API OpenRouteService (routing)
- [ ] Créer `MissionDispatchModal.tsx`
- [ ] Implémenter vue 2 colonnes
- [ ] Tester workflow complet

#### Code Clé : Écoute Realtime

```typescript
useEffect(() => {
  if (!currentEventId) return;

  const travelsSubscription = supabase
    .channel('travels-changes')
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'travels',
      filter: `event_id=eq.${currentEventId}`
    }, async (payload) => {
      console.log('🆕 Nouveau travel détecté:', payload.new);
      await loadMissions(); // Recharge pour inclure le nouveau
    })
    .subscribe();

  return () => {
    travelsSubscription.unsubscribe();
  };
}, [currentEventId]);
```

#### Code Clé : syncTravelsToMissions

```typescript
const syncTravelsToMissions = async () => {
  // 1. Cleanup doublons
  await cleanupDuplicateMissions();
  
  // 2. Récupérer travels suisses
  const swissCodes = ['GVA', 'Geneva', 'ZUR', 'Zurich', 'BSL', 'Basel', /* ... */];
  
  const { data: travels } = await supabase
    .from('travels')
    .select('*')
    .eq('event_id', currentEventId);
  
  const swissTravels = travels.filter(travel => {
    if (travel.is_arrival) {
      return swissCodes.some(code => 
        travel.arrival_location.toUpperCase().includes(code.toUpperCase())
      );
    } else {
      return swissCodes.some(code => 
        travel.departure_location.toUpperCase().includes(code.toUpperCase())
      );
    }
  });
  
  // 3. Vérifier quels travels n'ont pas de mission
  const { data: existingMissions } = await supabase
    .from('missions')
    .select('travel_id')
    .not('travel_id', 'is', null);
  
  const existingTravelIds = new Set(existingMissions.map(m => m.travel_id));
  const travelsWithoutMissions = swissTravels.filter(t => !existingTravelIds.has(t.id));
  
  // 4. Créer missions
  for (const travel of travelsWithoutMissions) {
    // Double vérification (race condition)
    const { data: check } = await supabase
      .from('missions')
      .select('id')
      .eq('travel_id', travel.id)
      .limit(1);
    
    if (check && check.length > 0) {
      console.log('Mission déjà créée (race condition évitée)');
      continue;
    }
    
    const isPickupMission = travel.is_arrival;
    
    const missionData = {
      event_id: currentEventId,
      travel_id: travel.id,
      artist_id: travel.artist_id || null,
      contact_id: travel.contact_id || null,
      pickup_location: isPickupMission 
        ? extractCityFromLocation(travel.arrival_location || '')
        : 'Base',
      pickup_datetime: travel.scheduled_datetime,
      dropoff_location: !isPickupMission 
        ? extractCityFromLocation(travel.departure_location || '')
        : 'Destination',
      dropoff_datetime: travel.scheduled_datetime,
      passenger_count: Math.max(1, Math.floor(travel.passenger_count || 1)),
      luggage_count: 0,
      status: 'unplanned',
      notes: ''
    };
    
    await supabase.from('missions').insert([missionData]);
  }
};
```

#### Code Clé : API Nominatim

```typescript
const geocodeLocation = async (query: string) => {
  const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=3&countrycodes=ch&accept-language=fr`;
  const response = await fetch(url);
  const results = await response.json();
  return results; // [{ lat, lon, display_name }]
};
```

#### Code Clé : API OpenRouteService

```typescript
const calculateRoute = async (startLat: number, startLon: number, endLat: number, endLon: number) => {
  const API_KEY = '5b3ce3597851110001cf6248a77a8a7fa3b54de5b7af4b8b9e3b8b0f'; // Clé publique
  const url = `https://api.openrouteservice.org/v2/directions/driving-car?api_key=${API_KEY}&start=${startLon},${startLat}&end=${endLon},${endLat}`;
  const response = await fetch(url);
  const data = await response.json();
  
  const duration = Math.ceil(data.features[0].properties.summary.duration / 60); // minutes
  const distance = Math.round(data.features[0].properties.summary.distance / 1000 * 10) / 10; // km
  
  return { duration, distance };
};
```

---

### MODULES 4-11 : AUTRES MODULES

*Documentation similaire pour chaque module (Drivers, Vehicles, Shifts, Hotels, Catering, etc.)*

**Voir** : `docs/PRODUCTION_MODULE_AUDIT_COMPLET.md` sections respectives pour détails complets de chaque module.

---

## 🎯 POINTS D'ATTENTION CRITIQUES

### 1. ⚠️ Ordre Création Tables

**IMPÉRATIF** : Respecter l'ordre des foreign keys !

```
events → event_days → artist_touring_party
events → travels → missions
events → drivers → staff_assignments
events → vehicles → vehicle_check_logs
events → shifts → shift_drivers
...
```

### 2. ⚠️ Synchronisation Travel ↔ Mission

**3 Protections obligatoires** :

1. Constraint UNIQUE sur `missions.travel_id`
2. Double vérification avant INSERT
3. Cleanup doublons périodique

### 3. ⚠️ Gestion Race Conditions

```typescript
// TOUJOURS faire double vérification
const { data: existing } = await supabase
  .from('missions')
  .select('id')
  .eq('travel_id', travelId)
  .limit(1);

if (existing && existing.length > 0) {
  console.log('Already exists, skip');
  return;
}

// Puis INSERT
```

### 4. ⚠️ Arrays PostgreSQL

```typescript
// Langues (TEXT[])
languages: ['fr', 'en', 'de']

// Permis (TEXT[])
permits: ['B', 'C', 'CE']

// Régimes spéciaux (TEXT[])
special_diet: ['vegan', 'gluten-free']
```

### 5. ⚠️ JSONB vehicles

```json
[
  {"type": "CAR", "count": 2},
  {"type": "TOURBUS", "count": 1}
]
```

**JAMAIS** de format invalide !

### 6. ⚠️ XOR Artist/Contact

```sql
CHECK (artist_id IS NOT NULL OR contact_id IS NOT NULL)
```

**Validation côté client** :

```typescript
if (!data.artist_id && !data.contact_id) {
  throw new Error('Artist or Contact required');
}
```

### 7. ⚠️ Status Enums

**Définir clairement** :

```typescript
// Missions
type MissionStatus = 'unplanned' | 'draft' | 'planned' | 'dispatched';

// Touring Party
type TouringPartyStatus = 'todo' | 'incomplete' | 'completed';

// Hotels
type ReservationStatus = 'pending' | 'confirmed' | 'cancelled' | 'completed';
```

### 8. ⚠️ Indexes Performance

**NE PAS OUBLIER** :

```sql
-- Sur tous les event_id (filtrage fréquent)
CREATE INDEX idx_[table]_event_id ON [table](event_id);

-- Sur dates/timestamps (tri fréquent)
CREATE INDEX idx_[table]_[date_field] ON [table]([date_field]);

-- Sur statuts (filtrage fréquent)
CREATE INDEX idx_[table]_status ON [table](status);
```

---

## ✅ VALIDATION FINALE

### Tests Essentiels

**Pour chaque module** :

- [ ] CREATE (insertion BDD)
- [ ] READ (affichage liste)
- [ ] UPDATE (modification)
- [ ] DELETE (suppression)
- [ ] Filtrage par événement
- [ ] Recherche
- [ ] Tri colonnes (si table)
- [ ] Pagination (si > 50 items)
- [ ] Relations FK (contraintes respectées)
- [ ] Validation formulaires
- [ ] Gestion erreurs
- [ ] Loading states
- [ ] Empty states

**Tests Workflow** :

- [ ] Travel → Mission (sync automatique)
- [ ] Mission planification (API externes)
- [ ] Mission dispatch (assignation)
- [ ] Touring Party calcul statut
- [ ] Hotel réservation (prix)
- [ ] Catering voucher (scan)
- [ ] Shift assignation chauffeurs

### Performance

- [ ] Requêtes < 500ms
- [ ] Indexes efficaces
- [ ] Pas de N+1 queries
- [ ] Pagination grandes listes
- [ ] Mémoïsation calculs
- [ ] Debounce sur recherche

### UX

- [ ] Loading spinners
- [ ] Messages erreur clairs
- [ ] Toasts confirmations
- [ ] Modals draggables
- [ ] Responsive mobile
- [ ] Keyboard navigation
- [ ] A11y (ARIA labels)

---

## 📅 PLANNING RECOMMANDÉ

### Semaine 1 : Infrastructure + Touring Party

- Lundi-Mardi : Créer toutes les tables BDD
- Mercredi-Vendredi : Implémenter Touring Party

### Semaine 2 : Travels + Missions (partie 1)

- Lundi-Mercredi : Implémenter Travels
- Jeudi-Vendredi : Démarrer Missions (tables + sync)

### Semaine 3 : Missions (partie 2) + Drivers

- Lundi-Mercredi : Finir Missions (modals, APIs)
- Jeudi-Vendredi : Implémenter Drivers

### Semaine 4 : Vehicles + Shifts

- Lundi-Mercredi : Implémenter Vehicles
- Jeudi-Vendredi : Implémenter Shifts

### Semaine 5-6 : Hospitality (Hotels + Catering)

- Semaine 5 : Hotels complet
- Semaine 6 : Catering complet

### Semaine 7 : Party Crew + Staff + Divers

- Lundi-Mercredi : Party Crew + Staff
- Jeudi-Vendredi : Backstage, AccredInvits (placeholders)

### Semaine 8 : ProductionPage Parent + Tests

- Lundi-Mercredi : ProductionPage + Navigation
- Jeudi-Vendredi : Tests end-to-end

### Semaine 9-10 : Buffer & Optimisation

- Tests performance
- Corrections bugs
- Optimisations
- Documentation

**TOTAL : 10 semaines**

---

## 🎊 RÉSULTAT ATTENDU

À la fin de l'implémentation, le module Production doit :

✅ Gérer les effectifs artistes (touring parties)  
✅ Gérer les voyages (avion, train, véhicules)  
✅ Synchroniser automatiquement Travels → Missions  
✅ Planifier et dispatcher les missions de transport  
✅ Gérer les chauffeurs (avec assignations événements)  
✅ Gérer les véhicules (avec contrôles réception/retour)  
✅ Gérer les shifts (équipes de travail)  
✅ Gérer les réservations hôtelières  
✅ Gérer la restauration (requirements + vouchers)  
✅ Gérer le personnel événement (party crew)  
✅ Afficher un dashboard global (ProductionPage)  
✅ Naviguer entre tous les modules de façon cohérente  
✅ Calculer automatiquement les statuts  
✅ Intégrer les APIs externes (Nominatim, OpenRouteService)  
✅ Fonctionner en temps réel (Supabase Realtime)  
✅ Être performant (< 500ms par requête)  
✅ Être testable (workflows complets validés)  

**Un module Production complet, robuste et fonctionnel ! 🚀**

---

**FIN DU PROMPT D'IMPLÉMENTATION**

**Date** : 14 novembre 2025  
**Module** : Production (7 sous-modules)  
**Statut** : ✅ PRÊT POUR IMPLÉMENTATION  
**Durée estimée** : 8-10 semaines  

---

*Bon courage pour l'implémentation ! 🎉*

*N'hésite pas à te référer régulièrement à la documentation complète (`PRODUCTION_MODULE_AUDIT_COMPLET.md`) pour les détails de chaque composant.*

