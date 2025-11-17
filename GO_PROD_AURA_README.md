# 🎭 Go-Prod AURA

**Plateforme de gestion d'événements multitenant**

---

## 🏗️ Architecture

Go-Prod AURA est une application **multitenant** basée sur Supabase, conçue pour gérer des événements avec isolation complète des données par tenant (company).

### Caractéristiques Principales

- ✅ **Multitenant** : Isolation par `company_id`
- 🔒 **Row Level Security (RLS)** : Sécurité au niveau des lignes
- 📅 **Gestion d'événements** : Événements, artistes, offres, staff
- 👥 **Module CRM** : Contacts, entreprises, activités
- 🎤 **Module Artistes** : Base de données artistes avec enrichissement
- 👷 **Module Staff** : Gestion bénévoles, shifts, campagnes
- 📊 **RBAC** : Contrôle d'accès basé sur les rôles

---

## 🚀 Démarrage

### Installation

```bash
# Installer les dépendances
npm install

# Lancer en développement
npm run dev
```

### Configuration Supabase

```bash
# Initialiser Supabase local
supabase init

# Démarrer Supabase local
supabase start

# Appliquer les migrations
supabase db push
```

---

## 🔍 Vérification Architecture Multitenant

⚠️ **IMPORTANT** : Avant chaque déploiement, vérifiez l'intégrité de l'architecture multitenant.

### Vérification Rapide

```bash
# Via npm
npm run verify:multitenant

# Via le script shell
chmod +x supabase/scripts/verify.sh
./supabase/scripts/verify.sh

# Via Supabase CLI
supabase db execute -f supabase/scripts/verify_multitenant_architecture.sql
```

### Documentation Complète

📖 **Guide complet** : [`VERIFICATION_MULTITENANT.md`](./VERIFICATION_MULTITENANT.md)

📚 **Documentation détaillée** : [`supabase/scripts/README.md`](./supabase/scripts/README.md)

---

## 📁 Structure du Projet

```
go-prod-aura/
├── src/                        # Code source React
│   ├── components/             # Composants React
│   ├── pages/                  # Pages de l'application
│   ├── lib/                    # Bibliothèques (Supabase client, etc.)
│   └── types/                  # Types TypeScript
├── supabase/
│   ├── migrations/             # Migrations SQL
│   ├── scripts/                # Scripts de vérification et maintenance
│   │   ├── README.md           # Documentation scripts
│   │   ├── verify.sh           # Script interactif de vérification
│   │   └── ...
│   └── config.toml             # Configuration Supabase
├── VERIFICATION_MULTITENANT.md # Guide vérification rapide
└── package.json
```

---

## 🗄️ Architecture Base de Données

### Tables Principales

#### 1. **Système**
- `companies` : Tenants
- `profiles` : Utilisateurs
- `rbac_*` : Contrôle d'accès

#### 2. **Événements**
- `events` : Événements principaux
- `event_days` : Journées d'événements
- `event_stages` : Scènes
- `event_artists` : Artistes programmés

#### 3. **Artistes**
- `artists` : Base de données artistes (mutualisée)
- `artist_performances` : Performances
- `artist_stats_*` : Statistiques Spotify

#### 4. **Offres**
- `offers` : Offres commerciales
- `offer_extras` : Options d'offres

#### 5. **CRM**
- `crm_contacts` : Contacts (mutualisés)
- `crm_companies` : Entreprises (mutualisées)
- `crm_*_activity_log` : Logs d'activité

#### 6. **Staff / Bénévoles**
- `staff_volunteers` : Bénévoles (mutualisés)
- `staff_events` : Événements staff
- `staff_shifts` : Créneaux horaires
- `staff_shift_assignments` : Affectations
- `staff_campaigns` : Campagnes recrutement

### Principe Multitenant

Toutes les tables métier ont :
- ✅ Un champ `company_id` (référence vers `companies`)
- 🔒 RLS activé avec policies basées sur `auth_company_id()`
- 📇 Index sur `company_id`

### "Pots Communs" (Ressources Mutualisées)

Certaines ressources sont **mutualisées entre événements** d'un même tenant :

- `staff_volunteers` : Un bénévole peut travailler sur plusieurs événements
- `artists` : Un artiste peut jouer à plusieurs événements
- `crm_contacts` : Un contact peut être lié à plusieurs événements
- Tables de lookups (`*_statuses`, `*_types`, etc.)

---

## 🔐 Sécurité

### Row Level Security (RLS)

Toutes les tables avec `company_id` ont RLS activé :

```sql
-- Exemple de policy
CREATE POLICY "Users can view data of their company"
ON table_name FOR SELECT
USING (company_id = auth_company_id());
```

### Fonction Helper

```sql
-- Récupère le company_id de l'utilisateur connecté
auth_company_id()
```

---

## 📊 Modules de l'Application

### 1. **Dashboard**
- Vue d'ensemble des événements
- KPIs et statistiques

### 2. **Événements**
- Création et gestion d'événements
- Programmation artistes
- Gestion scènes et jours

### 3. **Artistes**
- Base de données artistes
- Enrichissement automatique (Spotify, etc.)
- Statistiques et analytics

### 4. **Offres**
- Création d'offres commerciales
- Options et tarification
- Suivi des ventes

### 5. **CRM**
- Gestion contacts
- Gestion entreprises
- Historique des interactions
- Activités liées aux événements

### 6. **Staff / Bénévoles**
- Base de données bénévoles
- Planning shifts
- Affectations
- Campagnes de recrutement
- Communications

### 7. **Settings**
- Paramètres de l'entreprise
- Gestion utilisateurs
- Rôles et permissions
- Lookups/référentiels

---

## 🛠️ Développement

### Scripts NPM

```bash
# Développement
npm run dev

# Build
npm run build

# Lint
npm run lint

# Preview
npm run preview

# Vérification architecture multitenant
npm run verify:multitenant
npm run verify:multitenant:json
```

### Workflow de Développement

1. **Créer une branche**
   ```bash
   git checkout -b feature/ma-fonctionnalite
   ```

2. **Développer**
   - Coder la fonctionnalité
   - Si nouvelle table : Ajouter `company_id`, RLS, indexes

3. **Vérifier l'architecture**
   ```bash
   npm run verify:multitenant
   ```

4. **Tester**
   - Tests unitaires
   - Tests d'intégration
   - Tests manuels

5. **Commit et Push**
   ```bash
   git add .
   git commit -m "feat: ma fonctionnalité"
   git push origin feature/ma-fonctionnalite
   ```

6. **Pull Request**
   - Créer une PR
   - CI/CD vérifie automatiquement l'architecture
   - Review par l'équipe

7. **Merge et Deploy**

---

## 🧪 Tests

### Tests Unitaires

```bash
npm run test
```

### Tests E2E

```bash
npm run test:e2e
```

### Vérification Architecture

```bash
npm run verify:multitenant
```

---

## 📦 Déploiement

### Avant Déploiement

```bash
# 1. Vérifier l'architecture
npm run verify:multitenant

# 2. Build
npm run build

# 3. Tester le build
npm run preview

# 4. Pusher les migrations
supabase db push
```

### Production

```bash
# Via Supabase CLI
supabase link --project-ref <project-ref>
supabase db push
```

---

## 🔧 Maintenance

### Vérification Régulière

```bash
# Vérification hebdomadaire recommandée
npm run verify:multitenant

# Générer un rapport
npm run verify:multitenant:json > report.json
```

### Migrations

```bash
# Créer une nouvelle migration
supabase migration new ma_migration

# Appliquer les migrations
supabase db push

# Vérifier immédiatement après
npm run verify:multitenant
```

---

## 📚 Documentation

- 📖 [Guide Vérification Multitenant](./VERIFICATION_MULTITENANT.md)
- 📘 [Documentation Scripts](./supabase/scripts/README.md)
- 📗 [Exemples Pratiques](./supabase/scripts/EXEMPLES.md)

---

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request
6. **Vérifier que l'architecture multitenant est valide** ✅

---

## 📄 Licence

© 2025 Go-Prod AURA - Usage interne uniquement

---

## 🆘 Support

Pour toute question ou problème, contactez l'équipe de développement.

---

## 🎯 Roadmap

### Phase 1 - MVP ✅
- [x] Architecture multitenant
- [x] Modules Événements, Artistes, Offres
- [x] Module CRM
- [x] Module Staff
- [x] RBAC
- [x] Scripts de vérification

### Phase 2 - En cours 🚧
- [ ] Dashboard analytics avancé
- [ ] Exports avancés
- [ ] Notifications en temps réel
- [ ] API publique

### Phase 3 - À venir 📋
- [ ] Mobile app
- [ ] Intégrations tierces (Mailchimp, Stripe, etc.)
- [ ] IA pour recommandations artistes
- [ ] Marketplace d'événements

---

**🚀 Go-Prod AURA** - La plateforme de gestion d'événements nouvelle génération










