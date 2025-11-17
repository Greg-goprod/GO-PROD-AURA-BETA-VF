# WORKFLOW DU SYSTÈME PRODUCTION

## Vue d'ensemble

Ce document décrit les workflows et processus métier du module Production de GO-PROD. Il couvre les cas d'usage principaux, les interactions entre modules, et les séquences d'opérations typiques.

---

## 1. WORKFLOW GLOBAL - Cycle de Vie d'un Événement (Production)

```
┌─────────────────────────────────────────────────────────────────┐
│                    CYCLE DE VIE - PRODUCTION                    │
└─────────────────────────────────────────────────────────────────┘

1️⃣ PLANIFICATION INITIALE
   └─> Création événement
   └─> Définition des jours (event_days)
   └─> Configuration des artistes (event_artist)

2️⃣ TOURING PARTY
   └─> Définir taille équipe par artiste
   └─> Spécifier besoins en véhicules

3️⃣ TRAVELS
   └─> Créer arrivées/départs artistes
   └─> Saisir détails vols/trains

4️⃣ GROUND - AUTO-GÉNÉRATION
   └─> Missions créées automatiquement depuis Travels
   └─> Assignation véhicules et chauffeurs
   └─> Planification des shifts

5️⃣ HOSPITALITY
   └─> Réservations hôtel
   └─> Configuration catering + régimes
   └─> Attribution loges

6️⃣ EXÉCUTION
   └─> Suivi temps réel des missions
   └─> Scan vouchers catering
   └─> Validation réservations

7️⃣ CLÔTURE
   └─> Retour véhicules
   └─> Exports finaux
   └─> Archivage
```

---

## 2. TOURING PARTY - Workflow de Configuration

### Cas d'Usage : Configurer une Touring Party

**Acteurs** : Production Manager

**Prérequis** :
- Événement créé
- Artistes associés à l'événement (event_artist)
- Performances planifiées (artist_performances)

**Étapes** :

```
┌─────────────────────────────────────────────────┐
│ 1. Navigation vers Touring Party                │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 2. Sélection d'un jour d'événement              │
│    - Vue par accordéons (un par jour)           │
│    - Expansion du jour souhaité                 │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 3. Pour chaque artiste du jour                  │
│    a. Saisir le nombre de personnes (group_size)│
│    b. Ajouter les véhicules requis              │
│       - Sélectionner type (CAR, VAN, BUS...)    │
│       - Indiquer quantité                       │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 4. Sauvegarde automatique (debounce)            │
│    - Upsert dans artist_touring_party           │
│    - Calcul automatique du statut               │
│    - Mise à jour du dashboard                   │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 5. Validation visuelle                          │
│    ✅ completed : Personnes + Véhicules OK      │
│    ⚠️ incomplete : Données partielles           │
│    ⭕ todo : Aucune donnée                      │
└─────────────────────────────────────────────────┘
```

### Code : Calcul du Statut

```typescript
const calculateStatus = (artist: ArtistTouringPartyWithDay): Status => {
  const hasPersons = artist.group_size > 0;
  const hasVehicles = artist.vehicles.some(v => v.count > 0);
  
  if (hasPersons && hasVehicles) return 'completed';
  if (hasPersons || hasVehicles) return 'incomplete';
  return 'todo';
};
```

### Fonction de Sauvegarde

```typescript
const handleSave = async (artistId: string, dayDate: string, data: any) => {
  // 1. Vérifier si l'entrée existe
  const existing = await supabase
    .from('artist_touring_party')
    .select('id')
    .eq('artist_id', artistId)
    .eq('performance_date', dayDate)
    .eq('event_id', currentEvent.id)
    .single();

  // 2. Calculer le statut
  const status = calculateStatus(data);

  // 3. Upsert
  const payload = {
    event_id: currentEvent.id,
    artist_id: artistId,
    performance_date: dayDate,
    group_size: data.group_size,
    vehicles: data.vehicles,
    status: status,
    notes: data.notes,
    special_requirements: data.special_requirements
  };

  if (existing?.id) {
    await supabase
      .from('artist_touring_party')
      .update(payload)
      .eq('id', existing.id);
  } else {
    await supabase
      .from('artist_touring_party')
      .insert(payload);
  }

  // 4. Recharger les données
  await fetchData();
};
```

---

## 3. TRAVELS - Workflow de Gestion des Voyages

### Cas d'Usage : Créer un Voyage (Avion)

**Acteurs** : Travel Coordinator

**Étapes** :

```
┌─────────────────────────────────────────────────┐
│ 1. Clic "Ajouter un voyage"                     │
│    - Sélection du type : PLANE                  │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 2. Modal PlaneTrainForm                         │
│    - Type personne : Artist ou Contact          │
│    - Sélection personne                         │
│    - Direction : Arrivée ou Départ              │
│    - Date et heure                              │
│    - Lieu départ (ex: GVA Geneva)               │
│    - Lieu arrivée (ex: Paris CDG)               │
│    - Numéro de vol                              │
│    - Nombre de passagers                        │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 3. Validation et sauvegarde                     │
│    a. Insertion dans travels                    │
│       - travel_type = 'PLANE'                   │
│       - is_arrival = true/false                 │
│       - scheduled_datetime                      │
│       - artist_id OU contact_id                 │
│    b. Insertion dans travel_details             │
│       - reference_number (vol)                  │
│       - departure_location                      │
│       - arrival_location                        │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 4. TRIGGER AUTOMATIQUE                          │
│    - Supabase Realtime détecte INSERT           │
│    - Event postgres_changes diffusé             │
│    - MissionsPage écoute et recharge            │
│    - Nouvelle mission générée automatiquement   │
└─────────────────────────────────────────────────┘
```

### Code : Création d'un Travel

```typescript
const handleSubmit = async (formData: PlaneTrainFormData) => {
  try {
    // 1. Insérer le travel principal
    const { data: travelData, error: travelError } = await supabase
      .from('travels')
      .insert({
        event_id: currentEventId,
        artist_id: formData.personType === 'ARTIST' ? formData.personId : null,
        contact_id: formData.personType === 'CONTACT' ? formData.personId : null,
        travel_type: formData.travelType, // 'PLANE' ou 'TRAIN'
        is_arrival: formData.isArrival,
        scheduled_datetime: formData.scheduledDatetime,
        passenger_count: formData.passengerCount || 1,
        notes: formData.notes
      })
      .select()
      .single();

    if (travelError) throw travelError;

    // 2. Insérer les détails
    const { error: detailsError } = await supabase
      .from('travel_details')
      .insert({
        travel_id: travelData.id,
        reference_number: formData.referenceNumber, // Numéro de vol/train
        departure_location: formData.departureLocation,
        arrival_location: formData.arrivalLocation
      });

    if (detailsError) throw detailsError;

    // 3. Recharger la liste
    await fetchTravels();

    // Note : La synchronisation avec Missions se fait automatiquement
    // via Supabase Realtime dans MissionsPage
  } catch (error) {
    console.error('Erreur création travel:', error);
  }
};
```

### Synchronisation Temps Réel

**Dans MissionsPage.tsx** :

```typescript
useEffect(() => {
  if (!currentEventId) return;

  // Écouter les insertions dans travels
  const subscription = supabase
    .channel('travels-changes')
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'travels',
      filter: `event_id=eq.${currentEventId}`
    }, async (payload) => {
      console.log('🆕 Nouveau travel détecté:', payload.new);
      
      // Recharger automatiquement
      await loadMissions();
    })
    .subscribe();

  return () => {
    subscription.unsubscribe();
  };
}, [currentEventId]);
```

**Résultat** : Dès qu'un travel est créé, la page Missions se met à jour automatiquement !

---

## 4. MISSIONS - Workflow de Dispatch

### Cas d'Usage : Dispatcher une Mission

**Acteurs** : Dispatcher, Production Manager

**Prérequis** :
- Mission créée (manuellement ou depuis travel)
- Chauffeurs disponibles
- Véhicules disponibles

**Étapes** :

```
┌─────────────────────────────────────────────────┐
│ 1. Mission en statut DRAFT                      │
│    - Créée automatiquement depuis travel        │
│    - Ou créée manuellement                      │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 2. Clic "Dispatch" sur la mission               │
│    - Ouverture MissionDispatchModal             │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 3. Sélection des ressources                     │
│    a. Choisir un véhicule                       │
│       - Liste filtrée par capacité              │
│       - Vérification disponibilité              │
│    b. Choisir un chauffeur                      │
│       - Liste filtrée par status                │
│       - Vérification conflits horaires          │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 4. Calcul automatique start_at                  │
│    - Si mission liée à un travel (vol)          │
│    - start_at = flight_arrival - travel_time    │
│    - Inclut temps d'attente (waiting_time)      │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 5. Assignation (RPC Backend)                    │
│    - Appel assign_mission_driver()              │
│    - UPDATE missions SET                        │
│      vehicle_id, driver_id, status='ASSIGNED'   │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 6. Notification (optionnel)                     │
│    - Envoi WhatsApp au chauffeur                │
│    - whatsapp_sent = true                       │
│    - whatsapp_sent_at = NOW()                   │
└─────────────────────────────────────────────────┘
```

### Code : Fonction SQL de Dispatch

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
  WHERE id = p_mission_id 
    AND status = 'DRAFT';
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;
```

### Code Frontend : Dispatch

```typescript
const handleDispatch = async (missionId: string, vehicleId: string, driverId: string) => {
  try {
    // Appeler la fonction RPC
    const { data, error } = await supabase
      .rpc('assign_mission_driver', {
        p_mission_id: missionId,
        p_vehicle_id: vehicleId,
        p_driver_id: driverId
      });

    if (error) throw error;

    if (!data) {
      alert('Mission déjà assignée ou statut incorrect');
      return;
    }

    // Optionnel : Envoyer notification WhatsApp
    if (shouldSendWhatsApp) {
      await sendWhatsAppNotification(missionId, driverId);
      
      await supabase
        .from('missions')
        .update({
          whatsapp_sent: true,
          whatsapp_sent_at: new Date().toISOString()
        })
        .eq('id', missionId);
    }

    // Recharger
    await loadMissions();
    
    alert('Mission dispatchée avec succès !');
  } catch (error) {
    console.error('Erreur dispatch:', error);
  }
};
```

---

## 5. CATERING - Workflow de Configuration

### Cas d'Usage : Configurer le Catering pour un Artiste

**Acteurs** : Hospitality Manager

**Étapes** :

```
┌─────────────────────────────────────────────────┐
│ 1. Navigation Catering                          │
│    - Affichage dashboard par jour               │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 2. Expansion d'un jour d'événement              │
│    - Liste des artistes du jour                 │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 3. Configuration par artiste                    │
│    a. Saisir headcount (ou récup auto TP)       │
│    b. Définir quantités repas                   │
│       - Breakfast: X personnes                  │
│       - Lunch: X personnes                      │
│       - Dinner: X personnes                     │
│    c. Sélectionner type After-Show              │
│       - Catering normal                         │
│       - Buyout (montant)                        │
│       - Non applicable                          │
│    d. Ajouter remarques                         │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 4. Gestion régimes spéciaux (optionnel)         │
│    a. Définir régimes pour l'artiste            │
│       - Vegan, Végétarien, Sans gluten, etc.    │
│       - Quantité par régime                     │
│    b. Ajouter invités avec régimes              │
│       - Guest #1 : Vegan + Sans lactose         │
│       - Guest #2 : Halal                        │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 5. Calcul automatique du statut                 │
│    - todo : Aucune donnée                       │
│    - incomplete : Données partielles            │
│    - completed : Toutes données renseignées     │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 6. Génération vouchers (si nécessaire)          │
│    - Création tickets numérotés                 │
│    - Association artiste + repas + jour         │
│    - Statut 'issued'                            │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 7. Export et impression                         │
│    - PDF récapitulatif par jour                 │
│    - Export Excel                               │
│    - Impression vouchers                        │
└─────────────────────────────────────────────────┘
```

### Code : Sauvegarde Catering

```typescript
const saveCateringRequirement = async (
  artistId: string, 
  eventDayId: string, 
  data: CateringRequirement
) => {
  try {
    // Calcul du statut
    const hasQuantities = 
      (data.breakfast_qty || 0) > 0 ||
      (data.lunch_qty || 0) > 0 ||
      (data.dinner_qty || 0) > 0;
    
    const hasAfterShow = data.after_show_type && data.after_show_type !== 'none';
    
    let status: 'todo' | 'incomplete' | 'completed' = 'todo';
    if (hasQuantities && hasAfterShow) {
      status = 'completed';
    } else if (hasQuantities || hasAfterShow) {
      status = 'incomplete';
    }

    // Upsert
    const { error } = await supabase
      .from('artist_catering')
      .upsert({
        artist_id: artistId,
        event_day_id: eventDayId,
        breakfast_qty: data.breakfast_qty || 0,
        lunch_qty: data.lunch_qty || 0,
        dinner_qty: data.dinner_qty || 0,
        after_show_type: data.after_show_type,
        after_show_note: data.after_show_note,
        headcount_total: data.headcount_total,
        remarks: data.remarks,
        status: status
      }, {
        onConflict: 'artist_id,event_day_id'
      });

    if (error) throw error;
  } catch (error) {
    console.error('Erreur sauvegarde catering:', error);
  }
};
```

### Workflow Scan Voucher

```
┌─────────────────────────────────────────────────┐
│ 1. Page dédiée: ScanVoucherPage                 │
│    - Scanner QR/Barcode                         │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 2. Scan du code                                 │
│    - Extraction ticket_number                   │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 3. Vérification base de données                 │
│    - SELECT * FROM catering_vouchers            │
│      WHERE ticket_number = ?                    │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 4. Validation                                   │
│    ✅ Status = 'issued' → OK                    │
│    ❌ Status = 'used' → Déjà utilisé            │
│    ❌ Not found → Invalide                      │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 5. Marquage comme utilisé                       │
│    UPDATE catering_vouchers SET                 │
│      status = 'used',                           │
│      used_at = NOW()                            │
│    WHERE ticket_number = ?                      │
└─────────────────────────────────────────────────┘
```

---

## 6. HOTELS - Workflow de Réservation

### Cas d'Usage : Créer une Réservation Hôtel

**Acteurs** : Hospitality Manager

**Étapes** :

```
┌─────────────────────────────────────────────────┐
│ 1. Page Hotels                                  │
│    - Affichage HotelDashboard                   │
│    - Tableau HotelReservationTableSimple        │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 2. Clic "Nouvelle réservation"                  │
│    - Ouverture formulaire modal                 │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 3. Saisie des informations                      │
│    a. Sélection hôtel                           │
│    b. Sélection contact/artiste                 │
│    c. Dates (check-in / check-out)              │
│    d. Type de chambre                           │
│    e. Nombre de chambres                        │
│    f. Prix et devise                            │
│    g. Notes spéciales                           │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 4. Création réservation                         │
│    - INSERT hotel_reservations                  │
│    - Calcul nombre de nuits                     │
│    - Calcul montant total                       │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 5. Confirmation et notifications                │
│    - Email confirmation                         │
│    - Export PDF voucher                         │
└─────────────────────────────────────────────────┘
```

**Note** : Le système d'hôtels est complexe avec gestion des catégories de chambres, tarifs variables, devises multiples. Voir migrations `hotel_*.sql` pour détails.

---

## 7. VÉHICULES & CHAUFFEURS - Workflow d'Assignation

### Cas d'Usage : Assigner un Chauffeur à un Événement

**Acteurs** : Production Manager

**Étapes** :

```
┌─────────────────────────────────────────────────┐
│ 1. Page Drivers (ressources globales)           │
│    - Liste de tous les chauffeurs              │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 2. Sélection d'un chauffeur                     │
│    - Vérification disponibilité                 │
│    - Vérification permis requis                 │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 3. Assignation à l'événement                    │
│    INSERT INTO staff_assignments (              │
│      driver_id,                                 │
│      event_id,                                  │
│      role = 'driver',                           │
│      status = 'assigned',                       │
│      assigned_date                              │
│    )                                            │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 4. Création des shifts (optionnel)              │
│    - Définir plages horaires                    │
│    - Assigner chauffeur aux shifts              │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 5. Dispatch missions                            │
│    - Chauffeur maintenant disponible            │
│    - Peut être assigné aux missions             │
└─────────────────────────────────────────────────┘
```

---

## 8. SHIFTS - Workflow de Planification

### Cas d'Usage : Créer et Assigner des Shifts

**Acteurs** : Ground Manager

**Étapes** :

```
┌─────────────────────────────────────────────────┐
│ 1. Page Shifts                                  │
│    - Vue Grille/Liste/Gantt                     │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 2. Création d'un shift                          │
│    - Nom du shift (ex: "Matin J1")              │
│    - Horaires (start → end)                     │
│    - Couleur (pour visualisation)               │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 3. Sauvegarde                                   │
│    INSERT INTO shifts (...)                     │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 4. Assignation des chauffeurs                   │
│    - Sélection multiple                         │
│    - Vérification conflits horaires             │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 5. Création des liaisons                        │
│    INSERT INTO shift_drivers (                  │
│      shift_id,                                  │
│      driver_id                                  │
│    ) VALUES ...                                 │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│ 6. Visualisation                                │
│    - Vue Gantt : Timeline des shifts            │
│    - Détection chevauchements                   │
└─────────────────────────────────────────────────┘
```

---

## 9. INTÉGRATIONS ET SYNCHRONISATIONS

### Synchronisation Travels → Missions

**Déclencheur** : INSERT dans `travels`

**Processus** :

```typescript
// Dans MissionsPage - Realtime Subscription
useEffect(() => {
  const subscription = supabase
    .channel('travels-changes')
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'travels',
      filter: `event_id=eq.${currentEventId}`
    }, async (payload) => {
      // Auto-création mission draft
      await syncTravelsToMissions();
      await loadMissions();
    })
    .subscribe();

  return () => subscription.unsubscribe();
}, [currentEventId]);
```

**Fonction de synchronisation** :

```typescript
const syncTravelsToMissions = async () => {
  // 1. Récupérer tous les travels de l'événement
  const { data: travels } = await supabase
    .from('travels')
    .select('*')
    .eq('event_id', currentEventId);

  // 2. Pour chaque travel sans mission
  for (const travel of travels) {
    // Vérifier si mission existe déjà
    const { data: existingMission } = await supabase
      .from('missions')
      .select('id')
      .eq('travel_id', travel.id)
      .single();

    if (!existingMission) {
      // Créer mission draft
      await createMissionFromTravel(travel);
    }
  }
};
```

### Propagation Touring Party → Catering

**Déclencheur** : Sauvegarde dans `artist_touring_party`

**Impact** : Le `headcount_total` dans catering peut être pré-rempli avec `group_size` du touring party.

**Implémentation** :

```typescript
// Dans CateringPage - useEffect
useEffect(() => {
  const fetchTouringParty = async () => {
    const { data: touringParty } = await supabase
      .from('artist_touring_party')
      .select('*')
      .eq('event_id', currentEventId)
      .eq('performance_date', selectedDay);

    // Pré-remplir headcount si vide
    touringParty.forEach(tp => {
      setCateringDefaults(tp.artist_id, {
        headcount_total: tp.group_size
      });
    });
  };

  fetchTouringParty();
}, [selectedDay]);
```

---

## 10. GESTION DES ERREURS ET CAS LIMITES

### Conflit de Disponibilité Chauffeur

**Problème** : Un chauffeur est assigné à 2 missions en même temps.

**Solution** :

```typescript
const checkDriverAvailability = async (
  driverId: string, 
  startTime: Date, 
  endTime: Date
) => {
  const { data: conflicts } = await supabase
    .from('missions')
    .select('*')
    .eq('driver_id', driverId)
    .or(`start_at.gte.${startTime},start_at.lte.${endTime}`)
    .neq('status', 'COMPLETED')
    .neq('status', 'CANCELLED');

  if (conflicts && conflicts.length > 0) {
    throw new Error('Chauffeur déjà assigné à une autre mission');
  }
};
```

### Double Réservation Véhicule

**Problème** : Même véhicule assigné à 2 missions simultanées.

**Solution** : Même logique que chauffeurs.

### Travel sans Mission

**Problème** : Un travel est créé mais aucune mission n'est générée.

**Solution** : Bouton manuel "Synchroniser Travels" dans MissionsPage.

```typescript
const handleSyncTravels = async () => {
  setIsSyncing(true);
  await syncTravelsToMissions();
  await loadMissions();
  setIsSyncing(false);
  alert('Synchronisation terminée !');
};
```

---

## 11. EXPORTS ET RAPPORTS

### Export Catering

**Formats supportés** :
- PDF récapitulatif
- Excel détaillé
- Vouchers imprimables

**Workflow** :

```typescript
const exportCatering = async (format: 'pdf' | 'excel') => {
  // 1. Récupérer toutes les données
  const data = await fetchAllCateringData();

  // 2. Générer selon format
  if (format === 'pdf') {
    await generateCateringPDF(data);
  } else {
    await generateCateringExcel(data);
  }

  // 3. Télécharger
  downloadFile(generatedFile);
};
```

### Export Missions

**Formats** :
- PDF par chauffeur (feuille de route)
- Excel global

### Export Réservations Hôtel

**Formats** :
- PDF vouchers individuels
- Excel récapitulatif

---

## 12. PERMISSIONS ET SÉCURITÉ

### Row Level Security (RLS)

**Important** : Les tables Production **n'ont PAS de RLS activé** actuellement (pour simplification développement).

**À implémenter en production** :

```sql
-- Exemple pour travels
ALTER TABLE travels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view travels for their events"
  ON travels FOR SELECT
  USING (
    event_id IN (
      SELECT event_id FROM user_event_access
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert travels for their events"
  ON travels FOR INSERT
  WITH CHECK (
    event_id IN (
      SELECT event_id FROM user_event_access
      WHERE user_id = auth.uid()
    )
  );
```

---

## Conclusion

Le module Production suit des workflows bien définis avec de nombreuses automatisations :
- ✅ Synchronisation temps réel (Travels → Missions)
- ✅ Calculs automatiques (statuts, horaires, coûts)
- ✅ Validations et vérifications de conflits
- ✅ Exports multiformats
- ✅ Gestion d'erreurs robuste

**Prochaines étapes** :
- Implémenter RLS complet
- Ajouter notifications WhatsApp
- Améliorer détection conflits
- Workflows d'approbation
- Historique et audit trail

---

**Voir aussi** :
- [Architecture Production](./PRODUCTION_SYSTEM_ARCHITECTURE.md)
- [Relations BDD](./PRODUCTION_SYSTEM_RELATIONS.md)
- [Index](./PRODUCTION_INDEX.md)


