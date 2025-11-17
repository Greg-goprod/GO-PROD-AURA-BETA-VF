# 📚 ARCHITECTURE DU SYSTÈME DE BOOKING ET D'OFFRES - GO-PROD V3

## 🎯 Vue d'ensemble

Le système de booking et d'offres de GO-PROD V3 est un système complet de gestion des offres d'artistes pour les événements. Il gère l'ensemble du cycle de vie d'une offre, de la performance à faire jusqu'au contrat signé.

---

## 📊 ARCHITECTURE GLOBALE

### 1. Structure des données principales

```
┌─────────────────────────────────────────────────────────────────┐
│                     CYCLE DE VIE D'UNE OFFRE                    │
└─────────────────────────────────────────────────────────────────┘

1. ARTIST_PERFORMANCES (booking_status: 'offre_a_faire')
   ↓
2. OFFERS (status: 'draft') - Création de l'offre
   ↓
3. OFFERS (status: 'ready_to_send') - PDF généré automatiquement
   ↓
4. OFFERS (status: 'sent') - Email envoyé via EmailJS
   ↓
5. OFFERS (status: 'accepted' | 'rejected')
   ↓
6. CONTRACTS (créé automatiquement si accepté)
```

### 2. États du système

#### A. États des performances (`artist_performances.booking_status`)
- `offre_a_faire` : Performance programmée, offre à créer
- `offre_envoyee` : Offre créée et envoyée
- `offre_acceptee` : Offre acceptée par l'artiste
- `offre_rejetee` : Offre refusée par l'artiste

#### B. États des offres (`offers.status`)
- `draft` : Brouillon en cours de rédaction
- `legal_review` : En révision légale (optionnel)
- `management_review` : En révision management (optionnel)
- `ready_to_send` : Prêt à envoyer (PDF généré automatiquement)
- `sent` : Envoyé à l'artiste/agence
- `negotiating` : En négociation (optionnel)
- `accepted` : Accepté (→ création automatique de contrat)
- `rejected` : Rejeté
- `expired` : Expiré (dépassé la `validity_date`)

---

## 🗂️ SCHÉMA DE BASE DE DONNÉES

### Table principale : `offers`

```sql
offers (
  -- Identifiants
  id UUID PRIMARY KEY,
  company_id UUID NOT NULL,
  event_id UUID NOT NULL,
  
  -- Relations artiste/scène
  artist_id UUID,
  agency_contact_id UUID,  -- Contact booking de l'agence
  stage_id UUID,
  
  -- Informations temporelles
  date_time TIMESTAMPTZ,
  
  -- Versioning (système de modifications)
  version INTEGER DEFAULT 1,
  original_offer_id UUID REFERENCES offers(id),
  
  -- Informations financières principales
  currency currency_code_enum DEFAULT 'EUR',  -- EUR, USD, GBP, CHF
  amount_net NUMERIC(12,2),
  amount_gross NUMERIC(12,2),
  amount_is_net BOOLEAN,  -- Type de montant sélectionné
  amount_gross_is_subject_to_withholding BOOLEAN,
  amount_display NUMERIC(12,2),  -- Montant effectif affiché
  agency_commission_pct NUMERIC(5,2),
  withholding_note TEXT,
  
  -- Frais additionnels
  prod_fee_amount NUMERIC(10,2),
  prod_fee_currency TEXT,
  backline_fee_amount NUMERIC(10,2),
  backline_fee_currency TEXT,
  buyout_hotel_amount NUMERIC(10,2),
  buyout_hotel_currency TEXT,
  buyout_meal_amount NUMERIC(10,2),
  buyout_meal_currency TEXT,
  flight_contribution_amount NUMERIC(10,2),
  flight_contribution_currency TEXT,
  technical_fee_amount NUMERIC(10,2),
  technical_fee_currency TEXT,
  
  -- Méta-données
  validity_date DATE,
  status offer_status_enum DEFAULT 'draft',
  category_id UUID,
  terms_json JSONB,  -- Clauses sélectionnées
  rejection_reason TEXT,
  
  -- Fichiers
  pdf_storage_path TEXT,  -- Chemin du PDF dans Supabase Storage
  
  -- Référence contrat (si accepté)
  contract_id UUID,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
)
```

### Tables liées

#### `offer_extras` (Extras assignés à une offre)
```sql
offer_extras (
  id UUID PRIMARY KEY,
  offer_id UUID NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  extra_id UUID NOT NULL REFERENCES booking_extras(id),
  charge_to TEXT CHECK (charge_to IN ('artist', 'festival'))
)
```

#### `booking_extras` (Catalogue des extras disponibles)
```sql
booking_extras (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
)
```

#### `exclusivity_clauses` (Catalogue des clauses d'exclusivité)
```sql
exclusivity_clauses (
  id UUID PRIMARY KEY,
  text TEXT NOT NULL UNIQUE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
)
```

#### `offer_activity_log` (Journal des activités)
```sql
offer_activity_log (
  id UUID PRIMARY KEY,
  offer_id UUID NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  actor_id UUID,
  action TEXT NOT NULL,  -- created, updated, moved, sent, accepted, rejected, etc.
  meta JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
)
```

#### `email_signatures` (Signatures email pour l'envoi)
```sql
email_signatures (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  content TEXT NOT NULL,  -- Version texte
  html_content TEXT,  -- Version HTML
  is_default BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
)
```

#### `artist_performances` (Performances programmées)
```sql
artist_performances (
  id UUID PRIMARY KEY,
  artist_id UUID NOT NULL,
  event_id UUID NOT NULL,
  event_day_id UUID,
  event_stage_id UUID,
  performance_time TIME,
  duration INTEGER,  -- minutes
  booking_status TEXT,  -- offre_a_faire, offre_envoyee, offre_acceptee, offre_rejetee
  rejection_reason TEXT,
  rejection_date TIMESTAMPTZ,
  fee_amount NUMERIC(12,2),  -- Montant pré-rempli depuis la performance
  fee_currency TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
)
```

---

## 🔄 SYSTÈME DE VERSIONING

### Principe

Le système permet de créer plusieurs versions d'une même offre (modification après envoi).

### Structure

- **Version 1** : Offre originale (`version = 1`, `original_offer_id = NULL`)
- **Version 2+** : Modifications (`version = 2+`, `original_offer_id = UUID de la v1`)

### Fonctions PostgreSQL

```sql
-- Obtenir la prochaine version
get_next_offer_version(offer_id UUID) RETURNS INTEGER

-- Obtenir toutes les versions d'une offre
get_offer_versions(offer_id UUID) 
RETURNS TABLE (id, version, status, created_at, updated_at, amount_display, currency)
```

### Vue `offer_versions_view`

Facilite l'accès aux informations de versioning avec :
- `base_offer_id` : ID de l'offre originale
- `total_versions` : Nombre total de versions
- `is_latest_version` : Indique si c'est la dernière version

---

## 📝 TYPES TYPESCRIPT

### Types principaux

```typescript
// Status de l'offre
type OfferStatus = 
  | 'draft'
  | 'legal_review'
  | 'management_review'
  | 'ready_to_send'
  | 'sent'
  | 'negotiating'
  | 'accepted'
  | 'rejected'
  | 'expired';

// Devises supportées
type CurrencyCode = 'EUR' | 'GBP' | 'USD' | 'CHF';

// Interface Offer
interface Offer {
  id: string;
  company_id: string;
  event_id: string;
  artist_id?: string;
  agency_contact_id?: string;
  stage_id?: string;
  date_time?: string;
  
  // Versioning
  version?: number;
  original_offer_id?: string;
  
  // Financier
  currency: CurrencyCode;
  amount_net?: number;
  amount_gross?: number;
  amount_is_net?: boolean;
  amount_gross_is_subject_to_withholding?: boolean;
  amount_display?: number;
  agency_commission_pct?: number;
  
  // Frais additionnels
  prod_fee_amount?: number;
  prod_fee_currency?: CurrencyCode;
  backline_fee_amount?: number;
  backline_fee_currency?: CurrencyCode;
  buyout_hotel_amount?: number;
  buyout_hotel_currency?: CurrencyCode;
  buyout_meal_amount?: number;
  buyout_meal_currency?: CurrencyCode;
  flight_contribution_amount?: number;
  flight_contribution_currency?: CurrencyCode;
  technical_fee_amount?: number;
  technical_fee_currency?: CurrencyCode;
  
  // Méta
  validity_date?: string;
  status: OfferStatus;
  rejection_reason?: string;
  terms_json?: {
    selectedClauseIds?: string[];
    notes?: string;
  };
  
  // Fichiers
  pdf_storage_path?: string;
  
  // Timestamps
  created_at: string;
  updated_at: string;
  
  // Relations (jointures)
  artist_name?: string;
  stage_name?: string;
  agency_name?: string;
}
```

---

## 🎨 COMPOSANTS REACT PRINCIPAUX

### 1. `BookingPage.tsx`
Page principale du module booking

**Responsabilités :**
- Affichage du Kanban des offres
- Gestion des performances à faire
- Coordination des modals (création, envoi, rejet)
- Rafraîchissement automatique

**États clés :**
```typescript
const [offers, setOffers] = useState<Offer[]>([]);
const [artistPerformances, setArtistPerformances] = useState<any[]>([]);
const [showComposer, setShowComposer] = useState(false);
const [prefilledOfferData, setPrefilledOfferData] = useState<any>(null);
```

### 2. `OfferComposer.tsx`
Modal de création/modification d'offre

**Fonctionnalités :**
- Formulaire complet avec validation
- Sélection d'extras (Festival/Artist)
- Clauses d'exclusivité
- Génération PDF avec prévisualisation
- Support du versioning

**Sections :**
- **Données de base** : Artiste, Contact, Date, Heure, Scène, Deadline
- **Financier** : Type de montant, Montant, Commission, Frais additionnels
- **Clauses et Extra** : Extras assignés, Clauses d'exclusivité

### 3. `KanbanBoard.tsx`
Affichage Kanban des offres

**Colonnes :**
1. Brouillon / À faire
2. Prêt à envoyer
3. Envoyé
4. Accepté
5. Rejeté

**Features :**
- Drag & drop entre colonnes
- Actions contextuelles par colonne
- Compteurs de cartes

### 4. `SendOfferModal.tsx`
Modal d'envoi d'offre par email

**Champs :**
- Email destinataire (auto-rempli depuis le contact)
- CC (optionnel)
- Prénom destinataire
- Date de validité
- Expéditeur (sélection parmi les senders configurés)
- Signature email (sélection depuis la base)
- Message personnalisé

### 5. `RejectOfferModal.tsx`
Modal de rejet d'offre

**Champs :**
- Raison du refus (obligatoire)

**Actions :**
- Mise à jour offre vers statut `rejected`
- Mise à jour performance vers `offre_rejetee`
- Enregistrement de la raison et date

---

*[Suite dans BOOKING_SYSTEM_WORKFLOW.md]*

