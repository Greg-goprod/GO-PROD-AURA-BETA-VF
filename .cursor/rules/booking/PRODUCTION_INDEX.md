# INDEX DE LA DOCUMENTATION - MODULE PRODUCTION

## Table des Matières

### 📚 Documentation Principale

1. **[PRODUCTION_SYSTEM_ARCHITECTURE.md](./PRODUCTION_SYSTEM_ARCHITECTURE.md)**
   - Vue d'ensemble du module Production
   - Structure des 7 sous-modules
   - Composants et pages principales
   - Dashboard et navigation
   - Principes architecturaux

2. **[PRODUCTION_SYSTEM_WORKFLOW.md](./PRODUCTION_SYSTEM_WORKFLOW.md)**
   - Workflows complets par sous-module
   - Cas d'usage détaillés
   - Synchronisations et intégrations
   - Gestion des erreurs
   - Exports et rapports

3. **[PRODUCTION_SYSTEM_RELATIONS.md](./PRODUCTION_SYSTEM_RELATIONS.md)**
   - Schéma relationnel complet
   - Tables SQL détaillées
   - Contraintes et validations
   - Index de performance
   - Fonctions et triggers
   - Migrations historiques

---

## 📂 Navigation par Sous-Module

### 1. TOURING PARTY
**Fichiers** :
- `src/pages/TouringPartyPage.tsx` - Page principale
- `src/types/index.ts` - Types TypeScript

**Base de données** :
- Table : `artist_touring_party`

**Documentation** :
- Architecture : [Section Touring Party](./PRODUCTION_SYSTEM_ARCHITECTURE.md#1-touring-party---gestion-des-équipes)
- Workflow : [Workflow Touring Party](./PRODUCTION_SYSTEM_WORKFLOW.md#2-touring-party---workflow-de-configuration)
- BDD : [Table artist_touring_party](./PRODUCTION_SYSTEM_RELATIONS.md#1-artist_touring_party)

**Fonctionnalités clés** :
- ✅ Gestion du nombre de personnes par artiste
- ✅ Configuration des véhicules requis
- ✅ Statuts automatiques (todo/incomplete/completed)
- ✅ Dashboard récapitulatif par jour
- ✅ Vue accordéon par jour d'événement

---

### 2. TRAVELS
**Fichiers** :
- `src/pages/TravelsPage.tsx` - Page principale
- `src/components/travels/TravelList.tsx`
- `src/components/travels/TravelVehicleForm.tsx`
- `src/components/travels/PlaneTrainForm.tsx`
- `src/components/travels/TravelStepper.tsx`

**Base de données** :
- Table principale : `travels`
- Table complémentaire : `travel_details`

**Migrations** :
- `20250607160000_fix_travels_structure.sql`
- `20250601_add_passenger_count_to_travels.sql`
- `20250630000000_add_status_column_travels.sql`

**Documentation** :
- Architecture : [Section Travels](./PRODUCTION_SYSTEM_ARCHITECTURE.md#2-travels---gestion-des-voyages)
- Workflow : [Workflow Travels](./PRODUCTION_SYSTEM_WORKFLOW.md#3-travels---workflow-de-gestion-des-voyages)
- BDD : [Tables travels](./PRODUCTION_SYSTEM_RELATIONS.md#2-travels)

**Fonctionnalités clés** :
- ✅ Création voyages (Avion, Train, Véhicule)
- ✅ Stepper guidé
- ✅ Vue Liste/Grille
- ✅ Synchronisation temps réel avec Missions
- ✅ Lien artistes/contacts

---

### 3. GROUND

#### 3.1 MISSIONS
**Fichiers** :
- `src/pages/MissionsPage.tsx`
- `src/components/missions/MissionListItem.tsx`
- `src/components/missions/MissionPlanningModal.tsx`
- `src/components/missions/MissionDispatchModal.tsx`

**Base de données** :
- Table principale : `missions`
- Table complémentaire : `waiting_time`

**Migrations** :
- `20250129_mission_smart_v2_schema.sql`

**Documentation** :
- Architecture : [Section Missions](./PRODUCTION_SYSTEM_ARCHITECTURE.md#31-missions---transferts-et-transports)
- Workflow : [Workflow Missions](./PRODUCTION_SYSTEM_WORKFLOW.md#4-missions---workflow-de-dispatch)
- BDD : [Table missions](./PRODUCTION_SYSTEM_RELATIONS.md#4-missions)

**Fonctionnalités clés** :
- ✅ Synchronisation automatique avec Travels
- ✅ Calcul automatique des horaires (start_at)
- ✅ Dispatch chauffeur + véhicule
- ✅ Estimation coût et distance
- ✅ Notifications WhatsApp (prévu)
- ✅ Statuts : DRAFT → ASSIGNED → IN_PROGRESS → COMPLETED

---

#### 3.2 DRIVERS
**Fichiers** :
- `src/pages/DriversPage.tsx`
- `src/components/drivers/DriverForm.tsx`
- `src/components/drivers/DriverTable.tsx`
- `src/components/drivers/DriverGrid.tsx`

**Base de données** :
- Table principale : `drivers` (ressource globale)
- Table de liaison : `staff_assignments`

**Migrations** :
- `20250207_fix_drivers_table.sql`
- `20250122_setup_driver_photos_complete.sql`

**Documentation** :
- Architecture : [Section Drivers](./PRODUCTION_SYSTEM_ARCHITECTURE.md#32-drivers---gestion-des-chauffeurs)
- Workflow : [Workflow Drivers](./PRODUCTION_SYSTEM_WORKFLOW.md#7-véhicules--chauffeurs---workflow-dassignation)
- BDD : [Table drivers](./PRODUCTION_SYSTEM_RELATIONS.md#6-drivers)

**Fonctionnalités clés** :
- ✅ CRUD chauffeurs
- ✅ Gestion permis et langues
- ✅ Photo de profil
- ✅ Statuts disponibilité
- ✅ Assignation aux événements
- ✅ Vue Grille/Liste

---

#### 3.3 VEHICLES
**Fichiers** :
- `src/pages/VehiclesPage.tsx`
- `src/components/vehicles/VehicleForm.tsx`
- `src/components/vehicles/VehicleTable.tsx`
- `src/components/vehicles/VehicleCards.tsx`

**Base de données** :
- Table : `vehicles` (par événement)

**Documentation** :
- Architecture : [Section Vehicles](./PRODUCTION_SYSTEM_ARCHITECTURE.md#33-vehicles---gestion-de-la-flotte)
- BDD : [Table vehicles](./PRODUCTION_SYSTEM_RELATIONS.md#8-vehicles)

**Fonctionnalités clés** :
- ✅ CRUD véhicules
- ✅ Caractéristiques détaillées
- ✅ Gestion statuts
- ✅ Vue Cartes/Liste
- ✅ Équipements additionnels

---

#### 3.4 SHIFTS
**Fichiers** :
- `src/pages/ShiftsPage.tsx`
- `src/components/shifts/ImprovedShiftForm.tsx`
- `src/components/shifts/ShiftDriverAssignment.tsx`
- `src/components/shifts/ShiftTable.tsx`
- `src/components/shifts/ShiftGrid.tsx`
- `src/components/shifts/ShiftGantt.tsx`

**Base de données** :
- Table principale : `shifts`
- Table M2M : `shift_drivers`

**Documentation** :
- Architecture : [Section Shifts](./PRODUCTION_SYSTEM_ARCHITECTURE.md#34-shifts---planification-des-équipes)
- Workflow : [Workflow Shifts](./PRODUCTION_SYSTEM_WORKFLOW.md#8-shifts---workflow-de-planification)
- BDD : [Tables shifts](./PRODUCTION_SYSTEM_RELATIONS.md#9-shifts)

**Fonctionnalités clés** :
- ✅ Création plages horaires
- ✅ Assignation multiple chauffeurs
- ✅ Vue Grille/Liste/Gantt
- ✅ Couleurs personnalisables
- ✅ Détection chevauchements

---

### 4. HOSPITALITY

#### 4.1 HOTELS
**Fichiers** :
- `src/pages/HotelsPage.tsx`
- `src/components/hotels/HotelDashboard.tsx`
- `src/components/hotels/HotelReservationTableSimple.tsx`

**Base de données** :
- `hotels`, `hotel_rooms`, `hotel_room_prices`, `hotel_reservations`

**Migrations** :
- `20250120_cleanup_hotel_structure.sql`
- `20250130_hotel_category_room_types_refactor.sql`
- `20250626112356_add_currency_to_hotel_reservations.sql`
- Et 8 autres migrations

**Documentation** :
- Architecture : [Section Hotels](./PRODUCTION_SYSTEM_ARCHITECTURE.md#41-hotels---réservations-hôtelières)
- Workflow : [Workflow Hotels](./PRODUCTION_SYSTEM_WORKFLOW.md#6-hotels---workflow-de-réservation)
- BDD : [Tables hotels](./PRODUCTION_SYSTEM_RELATIONS.md#12-hotels---structure-simplifiée)

**Fonctionnalités clés** :
- ✅ Gestion réservations
- ✅ Dashboard récapitulatif
- ✅ Tarification multi-devises
- ✅ Catégories de chambres
- ✅ Vouchers

---

#### 4.2 BACKSTAGE
**Fichiers** :
- `src/pages/BackstagePage.tsx`

**État** : En développement

**Documentation** :
- Architecture : [Section Backstage](./PRODUCTION_SYSTEM_ARCHITECTURE.md#42-backstage---gestion-des-loges)

**Fonctionnalités prévues** :
- 🚧 Plan des loges
- 🚧 Équipement des loges

---

#### 4.3 CATERING
**Fichiers** :
- `src/pages/CateringPage.tsx`
- `src/pages/catering/ScanVoucherPage.tsx`
- `src/components/artist-catering/CateringDashboard.tsx`
- `src/components/artist-catering/CateringPrintManager.tsx`
- `src/components/catering/VoucherModal.tsx`

**Base de données** :
- `diet_types`
- `artist_catering`
- `artist_diet`
- `special_diet_guests`
- `catering_vouchers`

**Migrations** :
- `20250121_create_catering_vouchers_table.sql`
- `20250121_fix_catering_vouchers_constraints.sql`

**Documentation** :
- Architecture : [Section Catering](./PRODUCTION_SYSTEM_ARCHITECTURE.md#43-catering---restauration-artistes)
- Workflow : [Workflow Catering](./PRODUCTION_SYSTEM_WORKFLOW.md#5-catering---workflow-de-configuration)
- BDD : [Tables catering](./PRODUCTION_SYSTEM_RELATIONS.md#11-catering---tables-principales)

**Fonctionnalités clés** :
- ✅ Gestion repas par jour/artiste
- ✅ Régimes alimentaires spéciaux
- ✅ Quantités par repas
- ✅ After-show (catering/buyout)
- ✅ Génération vouchers
- ✅ Scan vouchers sur site
- ✅ Export/Impression

---

#### 4.4 ACCRED-INVITS
**Fichiers** :
- `src/pages/AccredInvitsPage.tsx`

**État** : À documenter

---

### 5. TECHNIQUE
**Fichiers** :
- `src/pages/TechniquePage.tsx`

**État** : Page placeholder en développement

**Documentation** :
- Architecture : [Section Technique](./PRODUCTION_SYSTEM_ARCHITECTURE.md#5-technique---aspects-techniques)

---

### 6. TIMETABLE
**Fichiers** :
- `src/pages/TimetablePage.tsx`

**État** : Page placeholder en développement

**Documentation** :
- Architecture : [Section Timetable](./PRODUCTION_SYSTEM_ARCHITECTURE.md#6-timetable---planning-temporel)

---

### 7. PARTY CREW & STAFF
**Fichiers** :
- `src/pages/PartyCrewPage.tsx`
- `src/pages/StaffPage.tsx`

**Documentation** :
- Architecture : [Section Party Crew & Staff](./PRODUCTION_SYSTEM_ARCHITECTURE.md#7-party-crew--staff)

---

## 🔧 Composants Communs

### Navigation
- `src/components/common/ProductionNavigation.tsx` - Navigation principale
- `src/components/common/GroundNavigation.tsx` - Sous-navigation Ground
- `src/components/common/HospitalityNavigation.tsx` - Sous-navigation Hospitality

### Page Hub
- `src/pages/ProductionPage.tsx` - Dashboard global Production

---

## 🗄️ Tables de Base de Données (Liste Complète)

### Module Touring Party
1. `artist_touring_party` - Équipes d'artistes

### Module Travels
2. `travels` - Voyages
3. `travel_details` - Détails voyages

### Module Ground
4. `missions` - Missions de transport
5. `waiting_time` - Temps d'attente par lieu
6. `drivers` - Chauffeurs (ressource globale)
7. `staff_assignments` - Assignations staff aux événements
8. `vehicles` - Véhicules (par événement)
9. `shifts` - Plages horaires
10. `shift_drivers` - Liaison shifts-chauffeurs (M2M)

### Module Hospitality
11. `hotels` - Hôtels
12. `hotel_rooms` - Chambres d'hôtel
13. `hotel_room_prices` - Tarifs chambres
14. `hotel_reservations` - Réservations hôtel
15. `diet_types` - Types de régimes alimentaires
16. `artist_catering` - Besoins catering par artiste
17. `artist_diet` - Régimes par artiste (M2M)
18. `special_diet_guests` - Invités avec régimes spéciaux
19. `catering_vouchers` - Vouchers de catering

---

## 📊 Diagrammes et Schémas

### Schéma Relationnel Global
Voir : [PRODUCTION_SYSTEM_RELATIONS.md - Schéma Relationnel](./PRODUCTION_SYSTEM_RELATIONS.md#schéma-relationnel-global)

### Workflows
Voir : [PRODUCTION_SYSTEM_WORKFLOW.md](./PRODUCTION_SYSTEM_WORKFLOW.md)

---

## 🔍 Index par Concept

### Synchronisation Temps Réel
- **Travels → Missions** : [Workflow Section 9](./PRODUCTION_SYSTEM_WORKFLOW.md#9-intégrations-et-synchronisations)
- Implémentation Supabase Realtime
- Auto-création des missions

### Calculs Automatiques
- **Statuts** : Touring Party, Catering
- **Horaires (start_at)** : Missions
- **Coûts estimés** : Missions

### Gestion des Statuts
- **Touring Party** : `todo` → `incomplete` → `completed`
- **Catering** : `todo` → `incomplete` → `completed`
- **Missions** : `DRAFT` → `ASSIGNED` → `IN_PROGRESS` → `COMPLETED`
- **Travels** : `planned` → `confirmed` → `in_transit` → `completed`
- **Vouchers** : `issued` → `used` / `cancelled`

### Ressources Globales vs Événement
- **Globales** : Drivers (+ staff_assignments)
- **Par Événement** : Vehicles, Travels, Missions, Hotels, Catering

---

## 🚀 Fonctionnalités Avancées

### Exports
- PDF : Catering, Missions, Hotels
- Excel : Tous les modules
- Vouchers : Impression, QR codes

### Scan & Validation
- Scan vouchers catering
- Validation temps réel
- Historique des scans

### Notifications (Prévu)
- WhatsApp pour drivers
- Rappels automatiques
- Confirmations

---

## 📝 Conventions de Code

### Nommage
- **Tables** : `snake_case` pluriel
- **Champs** : `snake_case`
- **Types TS** : `PascalCase`
- **Interfaces** : `PascalCase`
- **Fonctions** : `camelCase`

### Patterns
- **Upsert** : Utilisé pour Touring Party, Catering
- **XOR** : Travels (artist_id OU contact_id)
- **M2M** : Shifts-Drivers, Artist-Diets
- **JSONB** : Structures flexibles (vehicles, diet_requirements)

---

## 🔗 Liens Rapides

### Documentation
- [Architecture](./PRODUCTION_SYSTEM_ARCHITECTURE.md)
- [Workflow](./PRODUCTION_SYSTEM_WORKFLOW.md)
- [Relations BDD](./PRODUCTION_SYSTEM_RELATIONS.md)

### Documentation Booking (Référence)
- [Booking Architecture](./BOOKING_SYSTEM_ARCHITECTURE.md)
- [Booking Workflow](./BOOKING_SYSTEM_WORKFLOW.md)
- [Booking API](./BOOKING_SYSTEM_API.md)
- [Booking PDF](./BOOKING_SYSTEM_PDF.md)
- [Booking Relations](./BOOKING_SYSTEM_RELATIONS.md)

### Index Principal
- [START HERE](./START_HERE.md)
- [Documentation Overview](./DOCUMENTATION_OVERVIEW.md)

---

## 📅 État d'Avancement

### ✅ Fonctionnel (Production Ready)
- Touring Party
- Travels
- Missions
- Drivers
- Vehicles
- Shifts
- Hotels (partiellement)
- Catering

### 🚧 En Développement
- Backstage
- Accred-Invits

### 📋 Prévu
- Technique
- Timetable
- Party Crew (détails)

---

## 🆘 Support et Maintenance

### Migrations Importantes à Retenir
- Travels : Structure refactorée en juin 2025
- Missions : Smart V2 (janvier 2025)
- Hotels : Refonte complète (janvier-juin 2025)
- Drivers : Corrections multiples (février 2025)

### Points d'Attention
- ⚠️ RLS désactivé sur la plupart des tables (à activer en prod)
- ⚠️ Notifications WhatsApp non implémentées
- ⚠️ Détection conflits à améliorer
- ⚠️ Audit trail à implémenter

---

## 📚 Pour Aller Plus Loin

### Prochaines Étapes de Développement
1. Implémenter RLS complet
2. Ajouter notifications WhatsApp
3. Améliorer détection conflits
4. Workflows d'approbation
5. Historique et audit trail
6. Intégration GPS/Maps
7. Dashboards temps réel avancés
8. Exports multiformats améliorés

### Optimisations Potentielles
- Vues matérialisées pour dashboards
- Cache Redis pour requêtes fréquentes
- WebSockets pour updates temps réel
- Background jobs pour notifications
- API rate limiting

---

**Dernière mise à jour** : Novembre 2025

**Auteur** : Documentation générée par analyse complète du code source

**Contact** : Voir README principal du projet


