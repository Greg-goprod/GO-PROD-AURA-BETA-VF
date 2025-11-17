# 🎯 Implémentation du Socle CRM Go-Prod AURA

## ✅ Ce qui a été créé

### 1. **Base de données SQL** (`supabase/migrations/20251104_140000_crm_core.sql`)

#### Tables de lookup éditables (5 tables)
- `company_types` - Types de sociétés (Label, Maison de disques, Agence, Salle, Festival...)
- `contact_statuses` - Statuts des contacts (Actif, À valider, Blacklist, Archivé...)
- `departments` - Départements (Booking, Transport, Hospitality, Technique, Presse, Finance...)
- `contact_roles` - Rôles (Booker, Tour Manager, Chauffeur, Responsable hôtel...)
- `seniority_levels` - Niveaux de séniorité (Décision, Management, Opérationnel, Assistant...)

#### Tables CRM principales (3 tables)
- `crm_companies` - Sociétés (avec coordonnées, facturation, réseaux sociaux, documents)
- `crm_contacts` - Personnes (identité, coordonnées, rôle, fonction, logistique terrain)
- `crm_contact_company_links` - Relation N-N entre contacts et sociétés

#### Tables bonus métier (3 tables)
- `crm_contact_activity_log` - Logs d'activité des contacts
- `crm_company_activity_log` - Logs d'activité des sociétés
- `crm_artist_contact_links` - Lien entre artistes et contacts

#### Sécurité
- ✅ RLS activé sur toutes les tables
- ✅ Policies multi-tenant (scope par `company_id`)
- ✅ Bypass pour le propriétaire SaaS via `is_owner_admin()`
- ✅ Foreign Keys vers la table `companies` (tenants)
- ✅ Garde-fous tenant pour éviter les incohérences

#### RPCs disponibles
- `upsert_crm_option(table, id, label, active, sort_order)` - Créer/modifier une option
- `disable_crm_option(table, id)` - Désactiver une option
- `v_crm_options` - Vue unifiée pour lister toutes les options

### 2. **Types TypeScript** (`src/types/crm.ts`)

Tous les types pour les tables CRM, incluant :
- Types de base : `CompanyType`, `ContactStatus`, `Department`, `ContactRole`, `SeniorityLevel`
- Types CRM : `CRMCompany`, `CRMContact`, `CRMContactCompanyLink`
- Types enrichis avec relations : `CRMCompanyWithRelations`, `CRMContactWithRelations`
- Types pour formulaires : `CRMCompanyInput`, `CRMContactInput`

### 3. **API Supabase** (3 fichiers)

#### `src/api/crmLookupsApi.ts`
- `fetchCompanyTypes(companyId)` - Récupérer les types de sociétés
- `fetchContactStatuses(companyId)` - Récupérer les statuts
- `fetchDepartments(companyId)` - Récupérer les départements
- `fetchContactRoles(companyId)` - Récupérer les rôles
- `fetchSeniorityLevels(companyId)` - Récupérer les niveaux de séniorité
- `upsertCRMOption(...)` - Créer/modifier une option
- `disableCRMOption(...)` - Désactiver une option
- `fetchActiveCRMLookups(...)` - Récupérer uniquement les options actives

#### `src/api/crmContactsApi.ts`
- `fetchContacts(companyId)` - Récupérer tous les contacts
- `fetchContactById(id)` - Récupérer un contact spécifique
- `createContact(input)` - Créer un contact
- `updateContact(id, input)` - Mettre à jour un contact
- `deleteContact(id)` - Supprimer un contact

#### `src/api/crmCompaniesApi.ts`
- `fetchCRMCompanies(companyId)` - Récupérer toutes les sociétés
- `fetchCRMCompanyById(id)` - Récupérer une société spécifique
- `createCRMCompany(input)` - Créer une société
- `updateCRMCompany(id, input)` - Mettre à jour une société
- `deleteCRMCompany(id)` - Supprimer une société

### 4. **Hooks React** (`src/hooks/useCRMLookups.ts`)

#### `useCRMLookups(table)`
Hook complet pour gérer les lookups avec méthodes CRUD :
- `lookups` - Liste des options
- `loading` - État de chargement
- `error` - Erreur éventuelle
- `create(label, sortOrder)` - Créer une option
- `update(id, label, active, sortOrder)` - Mettre à jour une option
- `disable(id)` - Désactiver une option
- `refresh()` - Recharger les données

#### `useActiveCRMLookups(table)`
Hook simplifié pour récupérer uniquement les options actives (pour les selects dans les formulaires).

### 5. **Pages Frontend**

#### `/app/settings/contacts` - Gestion des options CRM
Page complète pour gérer tous les lookups éditables :
- Interface AURA avec Cards
- Gestion inline des options (ajout, édition, désactivation)
- Tri par ordre (`sort_order`)
- Statut actif/inactif
- 5 sections : Types de sociétés, Départements, Rôles, Séniorité, Statuts

#### `/app/contacts/personnes` - Gestion des Personnes
Page CRUD complète pour les contacts :
- Tableau avec recherche
- Modal de création/édition
- Champs principaux : prénom, nom, emails, téléphones
- Sélection de département, séniorité, statut via les lookups
- LinkedIn, notes internes
- Flags : contact de nuit, contact facturation
- Actions : créer, modifier, supprimer

#### `/app/contacts/entreprises` - Gestion des Entreprises
Page CRUD complète pour les sociétés :
- Tableau avec recherche
- Modal de création/édition
- Champs principaux : nom, marque, type, contact, adresse
- Coordonnées complètes
- Numéro TVA
- Notes d'accès
- Flags : fournisseur, client
- Actions : créer, modifier, supprimer

## 🎨 Design AURA respecté

- ✅ Composants AURA utilisés : `Button`, `Input`, `Modal`, `Card`
- ✅ Cohérence visuelle avec le reste de l'app
- ✅ Même pattern que DriversPage ou VehiclesPage
- ✅ Pickers AURA popup prêts à être utilisés (pour les dates `valid_from`, `valid_to`, `nda_signed_at`)

## 🚀 Comment utiliser

### 1. Configurer les options CRM

1. Aller sur `/app/settings/contacts`
2. Pour chaque catégorie (Types de sociétés, Départements, etc.) :
   - Cliquer sur "Ajouter"
   - Saisir le label
   - Les options peuvent être modifiées ou désactivées

Exemples de configuration :

**Types de sociétés :**
- Label
- Maison de disques
- Agence de booking
- Salle de concert
- Festival
- Agence de presse

**Départements :**
- Booking
- Transport
- Hospitality
- Technique
- Presse
- Finance

**Rôles :**
- Booker
- Tour Manager
- Chauffeur
- Responsable hôtel
- Attaché de presse
- Comptable

**Séniorité :**
- Décision
- Management
- Opérationnel
- Assistant

**Statuts :**
- Actif
- À valider
- Blacklist
- Archivé

### 2. Gérer les Personnes

1. Aller sur `/app/contacts/personnes`
2. Cliquer sur "Ajouter un contact"
3. Remplir le formulaire :
   - Prénom, Nom (obligatoires)
   - Email, téléphones
   - Sélectionner département, séniorité, statut (depuis les options configurées)
   - LinkedIn, notes internes
   - Cocher "Contact de nuit" ou "Contact facturation" si besoin
4. Sauvegarder

### 3. Gérer les Entreprises

1. Aller sur `/app/contacts/entreprises`
2. Cliquer sur "Ajouter une société"
3. Remplir le formulaire :
   - Nom de la société (obligatoire)
   - Type (depuis les options configurées)
   - Coordonnées complètes
   - Adresse
   - Numéro TVA
   - Cocher "Fournisseur" et/ou "Client"
4. Sauvegarder

## 📊 Structure des données

### Tenant (multi-tenant)
Toutes les tables ont une colonne `company_id` qui référence la table `companies` (tenants SaaS). Les données sont automatiquement isolées par tenant grâce au RLS.

### Relations
- Un contact peut avoir un département, une séniorité, un statut
- Un contact peut être lié à une société principale (`main_company_id`)
- Une société peut avoir un type
- Une société peut avoir des référents (contacts) pour différentes fonctions
- La table pivot `crm_contact_company_links` permet de lier plusieurs contacts à plusieurs sociétés avec des attributs spécifiques (fonction, dates de validité, etc.)

### Champs spéciaux
- `display_name` dans `crm_contacts` : généré automatiquement à partir du prénom et nom
- `created_by`, `updated_at` : traçabilité automatique
- `tags` : tableaux de strings pour catégorisation libre

## 🔐 Sécurité

- **RLS activé** sur toutes les tables
- **Policies multi-tenant** : chaque utilisateur ne voit que les données de sa company
- **Bypass owner admin** : le propriétaire SaaS peut accéder à toutes les données via `is_owner_admin()`
- **Foreign Keys** : toutes les relations sont contraintes
- **Garde-fous tenant** : triggers pour éviter les incohérences de tenant

## 🎯 Prochaines étapes possibles

### Extensions
1. **Lien Contact ↔ Société** : utiliser `crm_contact_company_links` pour gérer les relations N-N avec attributs
2. **Activity Logs** : utiliser `crm_contact_activity_log` et `crm_company_activity_log` pour tracer les interactions
3. **Lien Artiste ↔ Contact** : utiliser `crm_artist_contact_links` pour lier vos artistes à des agents, tour managers, etc.
4. **Enrichissement** : ajouter plus de champs selon vos besoins (réseaux sociaux complets, documents, etc.)
5. **Filtres avancés** : ajouter des filtres par type, statut, tags dans les listes
6. **Import/Export** : fonctionnalités pour importer des contacts en masse

### UI à améliorer
1. **Page de détail** : créer une page de détail pour chaque contact/société avec onglets
2. **Vue cartes** : alternative à la vue tableau
3. **Recherche avancée** : filtres multiples, recherche par tags
4. **Statistiques** : dashboard CRM avec métriques

## ⚠️ Important

- Le module Artistes existant n'a **pas été modifié**
- Les pages Contacts et Sociétés ont été **enrichies** (pas réécrites)
- Tous les composants utilisent les **composants AURA** existants
- Cohérence visuelle maintenue avec le reste de l'application
- **Aucun push Git** n'a été fait (selon vos règles)

## 🎉 Résultat

Vous avez maintenant un **socle CRM complet** dans Go-Prod AURA :
- ✅ Base de données multi-tenant avec RLS
- ✅ API TypeScript typée
- ✅ Hooks React réutilisables
- ✅ Interface de gestion des options
- ✅ Pages CRUD complètes pour Contacts et Sociétés
- ✅ Design cohérent avec AURA
- ✅ Prêt à être étendu selon vos besoins métier













