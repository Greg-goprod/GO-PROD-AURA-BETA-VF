# 🔗 TABLES ET RELATIONS - SYSTÈME DE BOOKING

## 🗂️ Schéma complet des tables

### 📋 Tables principales

---

## 1. `offers`

**Description :** Table centrale des offres de booking

```sql
CREATE TABLE offers (
  -- Identifiants
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  event_id uuid NOT NULL REFERENCES events(id),
  
  -- Relations
  artist_id uuid REFERENCES artists(id),
  agency_contact_id uuid REFERENCES contacts(id),
  stage_id uuid REFERENCES event_stages(id),
  category_id uuid REFERENCES offer_categories(id),
  contract_id uuid REFERENCES contracts(id),  -- Créé après acceptation
  
  -- Versioning
  version integer DEFAULT 1,
  original_offer_id uuid REFERENCES offers(id),
  
  -- Temporel
  date_time timestamptz,
  validity_date date,
  
  -- Financier principal
  currency currency_code_enum DEFAULT 'EUR',
  amount_net numeric(12,2),
  amount_gross numeric(12,2),
  amount_is_net boolean,
  amount_gross_is_subject_to_withholding boolean,
  amount_display numeric(12,2),
  agency_commission_pct numeric(5,2),
  withholding_note text,
  
  -- Frais additionnels
  prod_fee_amount numeric(10,2),
  prod_fee_currency text,
  backline_fee_amount numeric(10,2),
  backline_fee_currency text,
  buyout_hotel_amount numeric(10,2),
  buyout_hotel_currency text,
  buyout_meal_amount numeric(10,2),
  buyout_meal_currency text,
  flight_contribution_amount numeric(10,2),
  flight_contribution_currency text,
  technical_fee_amount numeric(10,2),
  technical_fee_currency text,
  
  -- Méta
  status offer_status_enum DEFAULT 'draft',
  rejection_reason text,
  terms_json jsonb,
  
  -- Fichiers
  pdf_storage_path text,
  
  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Contraintes
  CONSTRAINT check_version_consistency 
    CHECK (
      (version = 1 AND original_offer_id IS NULL) OR 
      (version > 1 AND original_offer_id IS NOT NULL)
    )
);

-- Index
CREATE INDEX idx_offers_event ON offers(event_id);
CREATE INDEX idx_offers_status ON offers(status);
CREATE INDEX idx_offers_validity ON offers(validity_date);
CREATE INDEX idx_offers_stage_dt ON offers(stage_id, date_time);
CREATE INDEX idx_offers_original_id ON offers(original_offer_id);
CREATE INDEX idx_offers_version ON offers(version);
CREATE INDEX idx_offers_version_composite ON offers(original_offer_id, version) 
  WHERE original_offer_id IS NOT NULL;

-- Trigger updated_at
CREATE TRIGGER tr_set_updated_at_offers
BEFORE UPDATE ON offers
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## 2. `artist_performances`

**Description :** Performances d'artistes programmées (source des offres)

```sql
CREATE TABLE artist_performances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  artist_id uuid NOT NULL REFERENCES artists(id),
  event_id uuid NOT NULL REFERENCES events(id),
  event_day_id uuid REFERENCES event_days(id),
  event_stage_id uuid REFERENCES event_stages(id),
  
  -- Horaires
  performance_time time,
  duration integer,  -- minutes
  
  -- Booking
  booking_status text,  -- 'offre_a_faire', 'offre_envoyee', 'offre_acceptee', 'offre_rejetee'
  rejection_reason text,
  rejection_date timestamptz,
  
  -- Financier (pré-remplissage)
  fee_amount numeric(12,2),
  fee_currency text,
  
  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Index
CREATE INDEX idx_artist_performances_artist ON artist_performances(artist_id);
CREATE INDEX idx_artist_performances_event ON artist_performances(event_id);
CREATE INDEX idx_artist_performances_booking_status ON artist_performances(booking_status);
```

---

## 3. `offer_extras`

**Description :** Extras assignés à une offre

```sql
CREATE TABLE offer_extras (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id uuid NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  extra_id uuid NOT NULL REFERENCES booking_extras(id),
  charge_to text CHECK (charge_to IN ('artist', 'festival')),
  created_at timestamptz DEFAULT now()
);

-- Index
CREATE INDEX idx_offer_extras_offer ON offer_extras(offer_id);
CREATE INDEX idx_offer_extras_extra ON offer_extras(extra_id);
```

---

## 4. `booking_extras`

**Description :** Catalogue des extras disponibles

```sql
CREATE TABLE booking_extras (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Trigger updated_at
CREATE TRIGGER tr_set_updated_at_booking_extras
BEFORE UPDATE ON booking_extras
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

**Données par défaut :**
```sql
INSERT INTO booking_extras (name) VALUES
  ('Hébergement'),
  ('Restauration'),
  ('Transport local'),
  ('Backline'),
  ('Éclairage'),
  ('Sonorisation');
```

---

## 5. `exclusivity_clauses`

**Description :** Catalogue des clauses d'exclusivité

```sql
CREATE TABLE exclusivity_clauses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  text text NOT NULL UNIQUE,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Trigger updated_at
CREATE TRIGGER tr_set_updated_at_exclusivity_clauses
BEFORE UPDATE ON exclusivity_clauses
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

**Données par défaut :**
```sql
INSERT INTO exclusivity_clauses (text) VALUES
  ('Exclusivité géographique (rayon 50km)'),
  ('Exclusivité géographique (rayon 100km)'),
  ('Exclusivité géographique (rayon 200km)'),
  ('Exclusivité temporelle (1 mois avant)'),
  ('Exclusivité temporelle (2 mois avant)'),
  ('Exclusivité temporelle (3 mois avant)'),
  ('Exclusivité temporelle (1 mois après)'),
  ('Exclusivité temporelle (2 mois après)'),
  ('Exclusivité temporelle (3 mois après)'),
  ('Exclusivité de genre musical'),
  ('Exclusivité de festival'),
  ('Exclusivité de label/maison de disques');
```

---

## 6. `offer_activity_log`

**Description :** Journal des activités sur les offres

```sql
CREATE TABLE offer_activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id uuid NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  actor_id uuid,
  action text NOT NULL,  -- 'created', 'updated', 'moved', 'sent', 'accepted', 'rejected', etc.
  meta jsonb,
  created_at timestamptz DEFAULT now()
);

-- Index
CREATE INDEX idx_offer_log_offer ON offer_activity_log(offer_id);
CREATE INDEX idx_offer_log_action ON offer_activity_log(action);
CREATE INDEX idx_offer_log_created ON offer_activity_log(created_at);
```

---

## 7. `offer_categories`

**Description :** Catégories d'offres

```sql
CREATE TABLE offer_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Index unique (insensible à la casse)
CREATE UNIQUE INDEX uq_offer_categories_company_name_idx 
  ON offer_categories (company_id, lower(name));

-- Trigger updated_at
CREATE TRIGGER tr_set_updated_at_offer_categories
BEFORE UPDATE ON offer_categories
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## 8. `offer_files`

**Description :** Fichiers attachés aux offres

```sql
CREATE TABLE offer_files (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id uuid NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  path text NOT NULL,
  kind text NOT NULL DEFAULT 'offer',  -- 'offer', 'rider', 'tech', 'other'
  created_at timestamptz DEFAULT now()
);

-- Index
CREATE INDEX idx_offer_files_offer ON offer_files(offer_id);
```

---

## 9. `email_signatures`

**Description :** Signatures email pour l'envoi d'offres

```sql
CREATE TABLE email_signatures (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  content text NOT NULL,
  html_content text,
  is_default boolean DEFAULT false,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Trigger updated_at
CREATE TRIGGER tr_set_updated_at_email_signatures
BEFORE UPDATE ON email_signatures
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## 10. `offer_clauses`

**Description :** Bibliothèque de clauses éditables pour les offres

```sql
CREATE TABLE offer_clauses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  key text,
  title text NOT NULL,
  body text NOT NULL,
  locale text NOT NULL DEFAULT 'fr',
  category text,
  default_enabled boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Trigger updated_at
CREATE TRIGGER tr_set_updated_at_offer_clauses
BEFORE UPDATE ON offer_clauses
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## 11. `offer_exclusivities`

**Description :** Exclusivités par offre

```sql
CREATE TABLE offer_exclusivities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id uuid NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  region text,
  perimeter_km integer,
  days_before integer,
  days_after integer,
  exclusive boolean NOT NULL DEFAULT true,
  penalty_note text,
  created_at timestamptz DEFAULT now()
);

-- Index
CREATE INDEX idx_offer_excl_offer ON offer_exclusivities(offer_id);
```

---

## 12. `offer_payments`

**Description :** Échéanciers de paiement par offre

```sql
CREATE TABLE offer_payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id uuid NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  label text NOT NULL,
  due_offset_days integer,
  due_date date,
  amount numeric(12,2),
  is_milestone boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Index
CREATE INDEX idx_offer_pay_offer ON offer_payments(offer_id);
```

---

## 13. `exclusivity_presets`

**Description :** Presets d'exclusivité réutilisables

```sql
CREATE TABLE exclusivity_presets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  name text NOT NULL,
  region text,
  perimeter_km integer,
  days_before integer,
  days_after integer,
  penalty_note text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Index unique (insensible à la casse)
CREATE UNIQUE INDEX uq_excl_presets_company_name_idx
  ON exclusivity_presets (company_id, lower(name));

-- Trigger updated_at
CREATE TRIGGER tr_set_updated_at_exclusivity_presets
BEFORE UPDATE ON exclusivity_presets
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## 14. `payment_schedule_presets`

**Description :** Presets d'échéanciers de paiement

```sql
CREATE TABLE payment_schedule_presets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  name text NOT NULL,
  items jsonb NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Index unique (insensible à la casse)
CREATE UNIQUE INDEX uq_pay_sched_presets_company_name_idx
  ON payment_schedule_presets (company_id, lower(name));

-- Trigger updated_at
CREATE TRIGGER tr_set_updated_at_payment_schedule_presets
BEFORE UPDATE ON payment_schedule_presets
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## 📊 Relations clés

### Diagramme relationnel

```
┌─────────────┐
│   events    │
└──────┬──────┘
       │
       ├─────► event_days
       │
       ├─────► event_stages
       │            │
       │            ▼
       │    ┌────────────────────┐
       │    │artist_performances │ (booking_status)
       │    └────────┬───────────┘
       │             │
       │             ▼
       ├──────► ┌─────────┐
       │        │ offers  │◄──── original_offer_id (versioning)
       └──────► └────┬────┘
                     │
                     ├──► offer_extras ◄─── booking_extras
                     │
                     ├──► offer_exclusivities
                     │
                     ├──► offer_payments
                     │
                     ├──► offer_files
                     │
                     ├──► offer_activity_log
                     │
                     └──► contracts (création automatique si accepté)
```

### Relations détaillées

#### `offers` → `events`
- **Type :** Many-to-One
- **Clé étrangère :** `event_id`
- **Cascade :** Offres liées à un événement

#### `offers` → `artists`
- **Type :** Many-to-One
- **Clé étrangère :** `artist_id`
- **Cascade :** Offres pour un artiste

#### `offers` → `contacts`
- **Type :** Many-to-One
- **Clé étrangère :** `agency_contact_id`
- **Cascade :** Contact de l'agence de booking

#### `offers` → `event_stages`
- **Type :** Many-to-One
- **Clé étrangère :** `stage_id`
- **Cascade :** Scène de la performance

#### `offers` → `offer_categories`
- **Type :** Many-to-One
- **Clé étrangère :** `category_id`
- **Cascade :** SET NULL on delete

#### `offers` → `contracts`
- **Type :** One-to-One
- **Clé étrangère :** `contract_id`
- **Création :** Automatique si offre acceptée

#### `offers` → `offers` (versioning)
- **Type :** Self-reference
- **Clé étrangère :** `original_offer_id`
- **Cascade :** Versions d'une même offre

#### `artist_performances` → `offers`
- **Type :** One-to-Many
- **Relation :** Performance source → Offre créée
- **Synchronisation :** `booking_status` mis à jour selon statut offre

#### `offer_extras` → `offers`
- **Type :** Many-to-One
- **Clé étrangère :** `offer_id`
- **Cascade :** DELETE on parent delete

#### `offer_extras` → `booking_extras`
- **Type :** Many-to-One
- **Clé étrangère :** `extra_id`
- **Cascade :** Référence au catalogue

---

## 🔧 Fonctions PostgreSQL

### 1. `get_next_offer_version()`

**Description :** Retourne le prochain numéro de version pour une offre

```sql
CREATE OR REPLACE FUNCTION get_next_offer_version(offer_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    base_offer_id UUID;
    max_version INTEGER;
BEGIN
    -- Trouver l'ID de l'offre de base
    SELECT COALESCE(original_offer_id, id) INTO base_offer_id
    FROM offers 
    WHERE id = offer_id;
    
    -- Trouver la version maximale
    SELECT COALESCE(MAX(version), 0) INTO max_version
    FROM offers 
    WHERE (id = base_offer_id OR original_offer_id = base_offer_id);
    
    -- Retourner la prochaine version
    RETURN max_version + 1;
END;
$$;
```

**Usage :**
```sql
SELECT get_next_offer_version('offre-uuid');  -- Retourne 2, 3, 4, etc.
```

---

### 2. `get_offer_versions()`

**Description :** Retourne toutes les versions d'une offre

```sql
CREATE OR REPLACE FUNCTION get_offer_versions(offer_id UUID)
RETURNS TABLE (
    id UUID,
    version INTEGER,
    status TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    amount_display NUMERIC,
    currency TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    base_offer_id UUID;
BEGIN
    -- Trouver l'ID de l'offre de base
    SELECT COALESCE(original_offer_id, id) INTO base_offer_id
    FROM offers 
    WHERE offers.id = offer_id;
    
    -- Retourner toutes les versions
    RETURN QUERY
    SELECT 
        o.id,
        o.version,
        o.status::TEXT,
        o.created_at,
        o.updated_at,
        o.amount_display,
        o.currency::TEXT
    FROM offers o
    WHERE (o.id = base_offer_id OR o.original_offer_id = base_offer_id)
    ORDER BY o.version DESC;
END;
$$;
```

**Usage :**
```sql
SELECT * FROM get_offer_versions('offre-uuid');
```

---

### 3. `set_updated_at()`

**Description :** Fonction trigger pour mettre à jour automatiquement `updated_at`

```sql
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## 📌 Vue : `offer_versions_view`

**Description :** Facilite l'accès aux informations de versioning

```sql
CREATE OR REPLACE VIEW offer_versions_view AS
SELECT 
    o.id,
    o.version,
    o.status,
    o.created_at,
    o.updated_at,
    o.amount_display,
    o.currency,
    o.artist_id,
    o.stage_id,
    o.original_offer_id,
    COALESCE(o.original_offer_id, o.id) as base_offer_id,
    -- Informations sur l'artiste et la scène
    a.name as artist_name,
    s.name as stage_name,
    -- Compter le nombre total de versions
    (SELECT COUNT(*) 
     FROM offers o2 
     WHERE (o2.id = COALESCE(o.original_offer_id, o.id) 
            OR o2.original_offer_id = COALESCE(o.original_offer_id, o.id))
    ) as total_versions,
    -- Indiquer si c'est la version la plus récente
    o.version = (
        SELECT MAX(o3.version) 
        FROM offers o3 
        WHERE (o3.id = COALESCE(o.original_offer_id, o.id) 
               OR o3.original_offer_id = COALESCE(o.original_offer_id, o.id))
    ) as is_latest_version
FROM offers o
LEFT JOIN artists a ON o.artist_id = a.id
LEFT JOIN event_stages s ON o.stage_id = s.id;
```

---

## 🔒 Enums PostgreSQL

### `offer_status_enum`

```sql
CREATE TYPE offer_status_enum AS ENUM (
  'draft',
  'legal_review',
  'management_review',
  'ready_to_send',
  'sent',
  'negotiating',
  'accepted',
  'rejected',
  'expired'
);
```

### `currency_code_enum`

```sql
CREATE TYPE currency_code_enum AS ENUM (
  'EUR',
  'GBP',
  'USD',
  'CHF'
);
```

---

## 📦 Supabase Storage

### Bucket : `offers`

**Configuration :**
- Public : Non
- Autorisations : Authentifié seulement

**Politiques RLS :**
```sql
-- SELECT
CREATE POLICY "offers_select_auth" ON storage.objects 
  FOR SELECT TO authenticated 
  USING (bucket_id='offers');

-- INSERT
CREATE POLICY "offers_insert_auth" ON storage.objects 
  FOR INSERT TO authenticated 
  WITH CHECK (bucket_id='offers');

-- UPDATE
CREATE POLICY "offers_update_auth" ON storage.objects 
  FOR UPDATE TO authenticated 
  USING (bucket_id='offers');

-- DELETE
CREATE POLICY "offers_delete_auth" ON storage.objects 
  FOR DELETE TO authenticated 
  USING (bucket_id='offers');
```

**Structure :**
```
offers/
  offers-pdf/
    OFFRE_EVENEMENT_ARTISTE_timestamp.pdf
    ...
```

---

## 🚀 CHECKLIST POUR MIGRATION

### ✅ Tables à créer

- [ ] `offers` avec tous les champs financiers
- [ ] `artist_performances` avec `booking_status`
- [ ] `offer_extras`
- [ ] `booking_extras`
- [ ] `exclusivity_clauses`
- [ ] `offer_activity_log`
- [ ] `offer_categories`
- [ ] `offer_files`
- [ ] `email_signatures`
- [ ] `offer_clauses`
- [ ] `offer_exclusivities`
- [ ] `offer_payments`
- [ ] `exclusivity_presets`
- [ ] `payment_schedule_presets`

### ✅ Enums à créer

- [ ] `offer_status_enum`
- [ ] `currency_code_enum`

### ✅ Fonctions PostgreSQL à créer

- [ ] `get_next_offer_version()`
- [ ] `get_offer_versions()`
- [ ] `set_updated_at()`

### ✅ Vues à créer

- [ ] `offer_versions_view`

### ✅ Storage à configurer

- [ ] Bucket `offers` avec RLS
- [ ] Bucket `word-templates` (public, template PDF)

### ✅ Migrations à appliquer

- [ ] `20240912_offer_versioning.sql`
- [ ] `20250903130000_add_financial_fields_to_offers.sql`
- [ ] `20250904120000_create_exclusivity_clauses.sql`
- [ ] `20250905120000_add_amount_type_to_offers.sql`
- [ ] `20250905130000_apply_booking_offers_init.sql`
- [ ] `20250905140000_fix_offers_status_enum.sql`
- [ ] `20250905150000_create_email_signatures.sql`
- [ ] `20250905160000_add_rejection_reason_to_offers.sql`

---

**FIN DE LA DOCUMENTATION TECHNIQUE**

*Cette documentation couvre l'intégralité du système de booking et d'offres de GO-PROD V3. Pour toute question ou clarification, référez-vous aux fichiers sources mentionnés.*

