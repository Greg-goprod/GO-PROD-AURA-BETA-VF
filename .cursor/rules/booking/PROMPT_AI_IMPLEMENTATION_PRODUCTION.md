# 🤖 PROMPT IA - IMPLÉMENTATION MODULE PRODUCTION

> Prompt structuré pour IA afin d'implémenter le module Production dans le nouveau SaaS

**Date** : 14 novembre 2025  
**Cible** : Nouveau SaaS  
**Type** : Instructions IA (Claude, ChatGPT, etc.)  
**Prérequis** : Accès au code du nouveau SaaS  

---

## 📋 INSTRUCTIONS PRÉLIMINAIRES OBLIGATOIRES

**AVANT TOUTE MODIFICATION, TU DOIS EXÉCUTER CES VÉRIFICATIONS** :

### ÉTAPE 0 : ANALYSE DE L'EXISTANT (CRITIQUE)

```
1. LISTE toutes les pages existantes dans src/pages/
2. IDENTIFIE si ProductionPage.tsx existe déjà
3. IDENTIFIE quelles pages Production existent :
   - TouringPartyPage.tsx
   - TravelsPage.tsx
   - MissionsPage.tsx
   - DriversPage.tsx
   - VehiclesPage.tsx
   - ShiftsPage.tsx
   - HotelsPage.tsx
   - BackstagePage.tsx
   - CateringPage.tsx
   - AccredInvitsPage.tsx
   - TechniquePage.tsx
   - TimetablePage.tsx
   - PartyCrewPage.tsx
   - StaffPage.tsx

4. VÉRIFIE les tables BDD existantes :
   - Exécute : SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%touring%';
   - Exécute : SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%travel%';
   - Exécute : SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%mission%';
   - Exécute : SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('drivers', 'vehicles', 'shifts', 'hotels', 'party_crew');

5. CRÉE un rapport de l'existant :
   ✅ Pages existantes : [liste]
   ❌ Pages manquantes : [liste]
   ✅ Tables existantes : [liste]
   ❌ Tables manquantes : [liste]

6. PRÉSENTE CE RAPPORT À L'UTILISATEUR ET ATTENDS SA VALIDATION AVANT DE CONTINUER
```

**🚨 NE COMMENCE AUCUNE IMPLÉMENTATION SANS AVOIR PRÉSENTÉ CE RAPPORT 🚨**

---

## 🎯 OBJECTIF GLOBAL

Implémenter le **Module Production complet** dans le nouveau SaaS avec ses **7 sous-modules** :

1. **TOURING PARTY** (Effectifs artistes)
2. **TRAVELS** (Voyages artistes)
3. **MISSIONS** (Coordination transport)
4. **GROUND** (Drivers, Vehicles, Shifts)
5. **HOSPITALITY** (Hotels, Backstage, Catering, AccredInvits)
6. **TECHNIQUE** (Placeholder)
7. **TIMETABLE** (Placeholder)
8. **PARTY CREW & STAFF** (Personnel)

**Source de référence** : `docs/PRODUCTION_MODULE_AUDIT_COMPLET.md` (1000+ lignes)

---

## 📖 DOCUMENTATION DE RÉFÉRENCE

**TU DOIS LIRE CES FICHIERS AVANT D'IMPLÉMENTER** :

1. `docs/PRODUCTION_MODULE_AUDIT_COMPLET.md` (architecture complète)
2. `docs/PROMPT_IMPLEMENTATION_MODULE_PRODUCTION.md` (guide technique)

**SI CES FICHIERS N'EXISTENT PAS** :
→ ARRÊTE et demande à l'utilisateur de les fournir.

---

## 🗄️ PHASE 1 : BASE DE DONNÉES (PRIORITÉ ABSOLUE)

### ÉTAPE 1.1 : CRÉATION DES TABLES (ORDRE STRICT)

**⚠️ IMPÉRATIF : RESPECTER CET ORDRE EXACT (Foreign Keys)**

```sql
-- ============================================================================
-- 1. TABLES FONDAMENTALES (vérifier si existent déjà)
-- ============================================================================
-- events, event_days, stages, artists, contacts
-- → SI EXISTENT DÉJÀ : SKIP
-- → SINON : CRÉER

-- ============================================================================
-- 2. TOURING PARTY
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

CREATE INDEX IF NOT EXISTS idx_artist_touring_party_event_id ON artist_touring_party(event_id);
CREATE INDEX IF NOT EXISTS idx_artist_touring_party_artist_id ON artist_touring_party(artist_id);

-- ============================================================================
-- 3. TRAVELS
-- ============================================================================
CREATE TABLE IF NOT EXISTS travels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

CREATE INDEX IF NOT EXISTS idx_travels_event_id ON travels(event_id);
CREATE INDEX IF NOT EXISTS idx_travels_artist_id ON travels(artist_id);
CREATE INDEX IF NOT EXISTS idx_travels_scheduled_datetime ON travels(scheduled_datetime);

-- ============================================================================
-- 4. BASES
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
-- 5. MISSIONS
-- ============================================================================
CREATE TABLE IF NOT EXISTS missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    
    UNIQUE(travel_id)
);

CREATE INDEX IF NOT EXISTS idx_missions_event_id ON missions(event_id);
CREATE INDEX IF NOT EXISTS idx_missions_travel_id ON missions(travel_id);
CREATE INDEX IF NOT EXISTS idx_missions_driver_id ON missions(driver_id);
CREATE INDEX IF NOT EXISTS idx_missions_vehicle_id ON missions(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_missions_pickup_datetime ON missions(pickup_datetime);
CREATE INDEX IF NOT EXISTS idx_missions_status ON missions(status);

-- ============================================================================
-- 6. DRIVERS (vérifier si existe déjà - table critique)
-- ============================================================================
-- SI EXISTE : Vérifier les colonnes requises
-- SINON : CRÉER

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
-- 7. STAFF_ASSIGNMENTS
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
-- 8. VEHICLES (vérifier si existe déjà)
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

CREATE INDEX IF NOT EXISTS idx_vehicles_event_id ON vehicles(event_id);

-- ============================================================================
-- 9. VEHICLE_CHECK_LOGS
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

CREATE INDEX IF NOT EXISTS idx_vehicle_check_logs_vehicle_id ON vehicle_check_logs(vehicle_id);

-- ============================================================================
-- 10. SHIFTS
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

CREATE INDEX IF NOT EXISTS idx_shifts_event_id ON shifts(event_id);

-- ============================================================================
-- 11. SHIFT_DRIVERS
-- ============================================================================
CREATE TABLE IF NOT EXISTS shift_drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(shift_id, driver_id)
);

CREATE INDEX IF NOT EXISTS idx_shift_drivers_shift_id ON shift_drivers(shift_id);
CREATE INDEX IF NOT EXISTS idx_shift_drivers_driver_id ON shift_drivers(driver_id);

-- ============================================================================
-- 12. HOTELS
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
-- 13. HOTEL_ROOM_TYPES
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

CREATE INDEX IF NOT EXISTS idx_hotel_room_types_hotel_id ON hotel_room_types(hotel_id);

-- ============================================================================
-- 14. HOTEL_RESERVATIONS
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

CREATE INDEX IF NOT EXISTS idx_hotel_reservations_event_id ON hotel_reservations(event_id);

-- ============================================================================
-- 15. CATERING_REQUIREMENTS
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

CREATE INDEX IF NOT EXISTS idx_catering_requirements_event_id ON catering_requirements(event_id);
CREATE INDEX IF NOT EXISTS idx_catering_requirements_artist_id ON catering_requirements(artist_id);

-- ============================================================================
-- 16. CATERING_VOUCHERS
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
    scanned_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_catering_vouchers_event_id ON catering_vouchers(event_id);
CREATE INDEX IF NOT EXISTS idx_catering_vouchers_code ON catering_vouchers(code);

-- ============================================================================
-- 17. PARTY_CREW
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

-- Appliquer triggers (liste complète)
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
-- RLS POLICIES (À ADAPTER)
-- ============================================================================
-- Pour développement : policies permissives
-- À ADAPTER selon système auth du nouveau SaaS

ALTER TABLE artist_touring_party ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON artist_touring_party FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE travels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON travels FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE missions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON missions FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON drivers FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON vehicles FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON shifts FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE hotels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON hotels FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE hotel_reservations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON hotel_reservations FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE catering_requirements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON catering_requirements FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE catering_vouchers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON catering_vouchers FOR ALL USING (auth.role() = 'authenticated');

ALTER TABLE party_crew ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated" ON party_crew FOR ALL USING (auth.role() = 'authenticated');
```

**APRÈS CRÉATION DE CHAQUE TABLE** :
```
✅ Vérifier que la table existe : SELECT * FROM [table_name] LIMIT 1;
✅ Vérifier les indexes : SELECT indexname FROM pg_indexes WHERE tablename = '[table_name]';
✅ Vérifier les triggers : SELECT tgname FROM pg_trigger WHERE tgrelid = '[table_name]'::regclass;
```

---

## 🎨 PHASE 2 : IMPLÉMENTATION FRONTEND (MODULE PAR MODULE)

### RÈGLE D'OR : VÉRIFIER L'EXISTANT AVANT CHAQUE MODULE

**POUR CHAQUE MODULE** :

```
1. VÉRIFIER si la page existe déjà
   → Chercher : src/pages/[ModuleName]Page.tsx
   
2. SI EXISTE :
   a) LIRE le code existant
   b) COMPARER avec la spécification (docs/PRODUCTION_MODULE_AUDIT_COMPLET.md)
   c) LISTER les différences
   d) PRÉSENTER à l'utilisateur :
      ✅ Fonctionnalités existantes : [liste]
      ❌ Fonctionnalités manquantes : [liste]
      ⚠️ Différences d'implémentation : [liste]
   e) DEMANDER : "Veux-tu que je complète/modifie cette page ou que je la laisse telle quelle ?"
   f) ATTENDRE la réponse AVANT de modifier

3. SI N'EXISTE PAS :
   a) CRÉER la page complète selon la spécification
   b) CRÉER tous les composants nécessaires

4. APRÈS CHAQUE MODULE :
   ✅ Tester CRUD complet
   ✅ Vérifier les relations BDD
   ✅ Tester les workflows
```

---

### MODULE 1 : TOURING PARTY

**SI `src/pages/TouringPartyPage.tsx` N'EXISTE PAS** :

1. **CRÉER** `src/pages/TouringPartyPage.tsx` (857 lignes - référence complète dans docs)

**Fonctionnalités OBLIGATOIRES** :
```typescript
✅ Dashboard accordéon (collapsible)
✅ Statistiques globales (personnes, véhicules, statuts)
✅ Groupement artistes par jour (performance_date)
✅ Fiches artistes en grille 2 colonnes
✅ Input group_size
✅ 8 inputs véhicules (CAR, VAN, VAN_TRAILER, TOURBUS, TOURBUS_TRAILER, TRUCK, TRUCK_TRAILER, SEMI_TRAILER)
✅ Textarea notes
✅ Badge statut cliquable (cycle: todo → incomplete → completed)
✅ Calcul automatique statut :
   - hasPersons && hasVehicles → 'completed'
   - hasPersons || hasVehicles → 'incomplete'
   - else → 'todo'
✅ Sauvegarde auto onBlur (upsert)
✅ Debounce valeurs temporaires
```

**Code clé à implémenter** :
```typescript
const calculateStatus = (artist: ArtistTouringPartyWithDay): 'todo' | 'incomplete' | 'completed' => {
  const hasPersons = artist.group_size > 0;
  const hasVehicles = artist.vehicles.some(v => v.count > 0);
  
  if (hasPersons && hasVehicles) return 'completed';
  else if (hasPersons || hasVehicles) return 'incomplete';
  else return 'todo';
};
```

**VÉRIFIER** :
- [ ] Table `artist_touring_party` existe
- [ ] Page charge les artistes par jour
- [ ] Calcul statut fonctionne
- [ ] Sauvegarde auto fonctionne
- [ ] Dashboard affiche les bonnes stats

---

### MODULE 2 : TRAVELS

**SI `src/pages/TravelsPage.tsx` N'EXISTE PAS** :

1. **CRÉER** `src/pages/TravelsPage.tsx`
2. **CRÉER** `src/components/travels/TravelStepper.tsx` (4 étapes)
3. **CRÉER** `src/components/travels/PlaneTrainForm.tsx`
4. **CRÉER** `src/components/travels/TravelVehicleForm.tsx`
5. **CRÉER** `src/components/travels/TravelList.tsx`

**Fonctionnalités OBLIGATOIRES** :
```typescript
✅ TravelStepper avec 4 étapes :
   1. Type de voyage (PLANE, TRAIN, CAR, VAN, VAN_TRAILER, TOURBUS, TOURBUS_TRAILER, TRUCK, TRUCK_TRAILER, SEMI_TRAILER)
   2. Personne (ARTIST multi-select OU CONTACT single-select)
   3. Direction (ARRIVAL ou DEPARTURE)
   4. Détails (form selon type)
✅ PlaneTrainForm : reference_number, departure/arrival_location, scheduled_datetime, passenger_count
✅ TravelVehicleForm : departure/arrival_location, scheduled_datetime, passenger_count
✅ TravelList en vue Grid et List
✅ Filtrage/recherche
✅ Actions Edit/Delete
```

**VÉRIFIER** :
- [ ] Table `travels` existe
- [ ] Stepper fonctionne (4 étapes)
- [ ] XOR artist_id/contact_id validé
- [ ] Création travel déclenche mission (voir MODULE 3)

---

### MODULE 3 : MISSIONS (LE PLUS CRITIQUE)

**SI `src/pages/MissionsPage.tsx` N'EXISTE PAS** :

1. **CRÉER** `src/pages/MissionsPage.tsx` (993 lignes)
2. **CRÉER** `src/components/missions/MissionListItem.tsx`
3. **CRÉER** `src/components/missions/MissionPlanningModal.tsx`
4. **CRÉER** `src/components/missions/MissionDispatchModal.tsx`

**Fonctionnalités OBLIGATOIRES** :
```typescript
✅ Écoute Realtime Supabase sur table travels
✅ Fonction syncTravelsToMissions() :
   - Filtrage codes suisses (GVA, Geneva, ZUR, Zurich, BSL, Basel, Lausanne, gare, etc.)
   - Vérification missions existantes
   - Création auto missions :
     * Travel ARRIVAL → Mission PICKUP
     * Travel DEPARTURE → Mission DROPOFF
   - Protection doublons (3 niveaux)
✅ Fonction cleanupDuplicateMissions()
✅ MissionListItem : affichage mission avec statut coloré
✅ MissionPlanningModal :
   - Autocomplete pickup_location (API Nominatim)
   - Autocomplete dropoff_location (API Nominatim)
   - Bouton "Calculer durée" (API OpenRouteService)
   - Auto-remplissage dropoff_datetime
✅ MissionDispatchModal : assignation driver + vehicle
✅ Vue 2 colonnes :
   - Colonne 1 : Missions à planifier (tous statuts)
   - Colonne 2 : Missions à dispatcher (statut 'planned' ou 'dispatched')
✅ Bouton sync manuel
```

**Code clé CRITIQUE : Écoute Realtime** :
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
      console.log('🆕 Nouveau travel:', payload.new);
      await loadMissions();
    })
    .subscribe();

  return () => {
    travelsSubscription.unsubscribe();
  };
}, [currentEventId]);
```

**Code clé CRITIQUE : syncTravelsToMissions** :
```typescript
const syncTravelsToMissions = async () => {
  if (isSyncing) return;
  setIsSyncing(true);
  
  try {
    // 1. Cleanup doublons
    await cleanupDuplicateMissions();
    
    // 2. Récupérer travels suisses
    const swissCodes = ['GVA', 'Geneva', 'Genève', 'ZUR', 'Zurich', 'BSL', 'Basel', 'Bâle', 'Lausanne', 'gare', 'Vallorbe'];
    
    const { data: travels } = await supabase
      .from('travels')
      .select('*')
      .eq('event_id', currentEventId);
    
    const swissTravels = travels.filter(travel => {
      if (travel.is_arrival) {
        return swissCodes.some(code => 
          travel.arrival_location?.toUpperCase().includes(code.toUpperCase())
        );
      } else {
        return swissCodes.some(code => 
          travel.departure_location?.toUpperCase().includes(code.toUpperCase())
        );
      }
    });
    
    // 3. Vérifier missions existantes
    const { data: existingMissions } = await supabase
      .from('missions')
      .select('travel_id')
      .not('travel_id', 'is', null);
    
    const existingTravelIds = new Set(existingMissions?.map(m => m.travel_id) || []);
    
    // 4. Créer missions manquantes
    for (const travel of swissTravels) {
      if (existingTravelIds.has(travel.id)) continue;
      
      // Double vérification (race condition)
      const { data: check } = await supabase
        .from('missions')
        .select('id')
        .eq('travel_id', travel.id)
        .limit(1);
      
      if (check && check.length > 0) continue;
      
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
  } finally {
    setIsSyncing(false);
  }
};
```

**APIs EXTERNES à intégrer** :

**Nominatim (Geocoding)** :
```typescript
const geocodeLocation = async (query: string) => {
  const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=3&countrycodes=ch&accept-language=fr`;
  const response = await fetch(url);
  return await response.json();
};
```

**OpenRouteService (Routing)** :
```typescript
const calculateRoute = async (startLat: number, startLon: number, endLat: number, endLon: number) => {
  const API_KEY = '5b3ce3597851110001cf6248a77a8a7fa3b54de5b7af4b8b9e3b8b0f';
  const url = `https://api.openrouteservice.org/v2/directions/driving-car?api_key=${API_KEY}&start=${startLon},${startLat}&end=${endLon},${endLat}`;
  const response = await fetch(url);
  const data = await response.json();
  
  return {
    duration: Math.ceil(data.features[0].properties.summary.duration / 60), // minutes
    distance: Math.round(data.features[0].properties.summary.distance / 1000 * 10) / 10 // km
  };
};
```

**VÉRIFIER** :
- [ ] Tables `missions`, `bases` existent
- [ ] Écoute Realtime fonctionne
- [ ] Sync travel→mission fonctionne
- [ ] Cleanup doublons fonctionne
- [ ] API Nominatim accessible
- [ ] API OpenRouteService accessible
- [ ] Planification mission fonctionne
- [ ] Dispatch mission fonctionne

---

### MODULES 4-11 : AUTRES MODULES

**POUR CHAQUE MODULE RESTANT** :

**DRIVERS, VEHICLES, SHIFTS, HOTELS, CATERING, BACKSTAGE, ACCREDITVITS, TECHNIQUE, TIMETABLE, PARTY CREW, STAFF**

**APPLIQUER LA MÊME LOGIQUE** :

```
1. VÉRIFIER si page existe
2. SI EXISTE : comparer et demander
3. SI N'EXISTE PAS : créer selon spécification
4. TESTER CRUD complet
5. PASSER AU SUIVANT
```

**Référence complète** : `docs/PRODUCTION_MODULE_AUDIT_COMPLET.md` sections respectives

---

## 🏠 PHASE 3 : PAGE PARENT PRODUCTION

### ProductionPage.tsx

**SI `src/pages/ProductionPage.tsx` N'EXISTE PAS** :

**CRÉER** avec :
```typescript
✅ Dashboard global accordéon :
   - Section Touring Party (stats par jour + global)
   - Section Catering Dashboard
✅ Navigation onglets (7 onglets) :
   - TOURING PARTY
   - TRAVELS
   - GROUND (dropdown : Missions, Drivers, Vehicles, Shifts)
   - HOSPITALITY (dropdown : Hotels, Backstage, Catering, AccredInvits)
   - TECHNIQUE
   - TIMETABLE
   - PARTYCREW
✅ Statistiques temps réel
✅ Calculs agrégés
```

**SI EXISTE** :
- Comparer avec spécification
- Demander si modifications nécessaires

---

## 🏁 PHASE 4 : TESTS & VALIDATION

**APRÈS IMPLÉMENTATION DE TOUS LES MODULES** :

```
POUR CHAQUE MODULE :
✅ CREATE (insertion BDD)
✅ READ (affichage liste)
✅ UPDATE (modification)
✅ DELETE (suppression)
✅ Filtrage par événement
✅ Recherche/filtrage
✅ Tri colonnes
✅ Relations FK correctes
✅ Validation formulaires
✅ Gestion erreurs
✅ Loading states
✅ Empty states

WORKFLOWS CRITIQUES :
✅ Travel → Mission (sync auto)
✅ Mission planification (APIs)
✅ Mission dispatch (assignation)
✅ Touring Party calcul statut
✅ Hotel réservation
✅ Catering voucher

PERFORMANCE :
✅ Requêtes < 500ms
✅ Indexes utilisés
✅ Pas de N+1 queries
```

---

## 📊 RAPPORT FINAL À PRÉSENTER

**À LA FIN DE L'IMPLÉMENTATION, TU DOIS PRÉSENTER** :

```markdown
# RAPPORT D'IMPLÉMENTATION MODULE PRODUCTION

## Résumé
- Durée totale : [X jours]
- Modules implémentés : [X/11]
- Pages créées : [X]
- Pages modifiées : [X]
- Tables créées : [X]
- Lignes de code : [~X]

## Modules Implémentés
✅ Touring Party
✅ Travels
✅ Missions
✅ Drivers
✅ Vehicles
✅ Shifts
✅ Hotels
✅ Catering
✅ Party Crew
✅ Staff
✅ ProductionPage (parent)

## Tables BDD Créées
✅ artist_touring_party
✅ travels
✅ missions
✅ bases
✅ drivers
✅ staff_assignments
✅ vehicles
✅ vehicle_check_logs
✅ shifts
✅ shift_drivers
✅ hotels
✅ hotel_room_types
✅ hotel_reservations
✅ catering_requirements
✅ catering_vouchers
✅ party_crew

## Tests Validés
✅ CRUD complet sur toutes les tables
✅ Workflow Travel → Mission
✅ Planification missions (APIs externes)
✅ Dispatch missions
✅ Calcul statuts Touring Party
✅ Réservations hôtels
✅ Gestion catering

## Points d'Attention
⚠️ [Liste des points à surveiller]

## Améliorations Suggérées
💡 [Liste des améliorations futures]
```

---

## ⚠️ RÈGLES ABSOLUES

**TU DOIS TOUJOURS** :

1. ✅ **VÉRIFIER L'EXISTANT** avant toute modification
2. ✅ **DEMANDER CONFIRMATION** avant d'écraser du code existant
3. ✅ **PRÉSENTER UN RAPPORT** après chaque module
4. ✅ **TESTER** chaque fonctionnalité après implémentation
5. ✅ **RESPECTER L'ORDRE** des tables (foreign keys)
6. ✅ **CRÉER LES INDEXES** (performance)
7. ✅ **IMPLÉMENTER LES TRIGGERS** (updated_at)
8. ✅ **GÉRER LES ERREURS** proprement
9. ✅ **AFFICHER LOADING/EMPTY STATES**
10. ✅ **VALIDER CÔTÉ CLIENT ET SERVEUR**

**TU NE DOIS JAMAIS** :

1. ❌ Modifier du code existant sans avoir demandé
2. ❌ Créer les tables dans le désordre
3. ❌ Oublier les contraintes UNIQUE/CHECK
4. ❌ Ignorer la synchronisation Travel ↔ Mission
5. ❌ Négliger la protection doublons
6. ❌ Oublier les indexes
7. ❌ Sauter les triggers
8. ❌ Implémenter plusieurs modules en parallèle sans validation
9. ❌ Ignorer les erreurs
10. ❌ Laisser des console.log en production

---

## 🚀 DÉMARRAGE

**COMMENCE PAR** :

```
1. LIS ce prompt entièrement
2. EXÉCUTE l'ÉTAPE 0 (Analyse existant)
3. PRÉSENTE le rapport à l'utilisateur
4. ATTENDS validation
5. COMMENCE par Phase 1 (BDD)
6. PUIS Phase 2 (Frontend) module par module
7. PUIS Phase 3 (Page parent)
8. ENFIN Phase 4 (Tests)
9. PRÉSENTE rapport final
```

**BONNE IMPLÉMENTATION ! 🎉**

---

**FIN DU PROMPT IA**

*Date : 14 novembre 2025*  
*Module : Production complet*  
*Statut : PRÊT POUR UTILISATION*

