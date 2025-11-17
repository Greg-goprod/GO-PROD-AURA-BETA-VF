# 🔍 INDEX COMPLET - SYSTÈME DE BOOKING

## Recherche rapide par thème

---

## 🎯 Par objectif

### Je veux comprendre le système
→ [Architecture](./BOOKING_SYSTEM_ARCHITECTURE.md) puis [Workflow](./BOOKING_SYSTEM_WORKFLOW.md)

### Je veux migrer vers une nouvelle version
→ [Checklist dans Relations](./BOOKING_SYSTEM_RELATIONS.md#-checklist-pour-migration)

### Je veux implémenter l'API
→ [API et fonctions](./BOOKING_SYSTEM_API.md)

### Je veux générer des PDFs
→ [Système PDF](./BOOKING_SYSTEM_PDF.md)

### Je veux connaître les tables
→ [Tables et relations](./BOOKING_SYSTEM_RELATIONS.md)

---

## 📊 Par composant

### Tables de base de données

| Table | Description | Documentation |
|-------|-------------|---------------|
| `offers` | Table principale des offres | [Relations §1](./BOOKING_SYSTEM_RELATIONS.md#1-offers) |
| `artist_performances` | Performances programmées (source) | [Relations §2](./BOOKING_SYSTEM_RELATIONS.md#2-artist_performances) |
| `offer_extras` | Extras assignés par offre | [Relations §3](./BOOKING_SYSTEM_RELATIONS.md#3-offer_extras) |
| `booking_extras` | Catalogue des extras | [Relations §4](./BOOKING_SYSTEM_RELATIONS.md#4-booking_extras) |
| `exclusivity_clauses` | Catalogue des clauses | [Relations §5](./BOOKING_SYSTEM_RELATIONS.md#5-exclusivity_clauses) |
| `offer_activity_log` | Journal d'activités | [Relations §6](./BOOKING_SYSTEM_RELATIONS.md#6-offer_activity_log) |
| `offer_categories` | Catégories d'offres | [Relations §7](./BOOKING_SYSTEM_RELATIONS.md#7-offer_categories) |
| `email_signatures` | Signatures pour emails | [Relations §9](./BOOKING_SYSTEM_RELATIONS.md#9-email_signatures) |

### Composants React

| Composant | Rôle | Documentation |
|-----------|------|---------------|
| `BookingPage.tsx` | Page principale, coordination | [Architecture §3.1](./BOOKING_SYSTEM_ARCHITECTURE.md#1-bookingpagetsx) |
| `OfferComposer.tsx` | Création/modification offre | [Architecture §3.2](./BOOKING_SYSTEM_ARCHITECTURE.md#2-offercomposertsx) |
| `KanbanBoard.tsx` | Vue Kanban drag & drop | [Architecture §3.3](./BOOKING_SYSTEM_ARCHITECTURE.md#3-kanbanboardtsx) |
| `SendOfferModal.tsx` | Envoi email avec PDF | [Architecture §3.4](./BOOKING_SYSTEM_ARCHITECTURE.md#4-sendoffermodaltsx) |
| `RejectOfferModal.tsx` | Rejet d'offre | [Architecture §3.5](./BOOKING_SYSTEM_ARCHITECTURE.md#5-rejectoffermodaltsx) |
| `PdfPreviewModal.tsx` | Prévisualisation PDF | [Workflow - Étape 5](./BOOKING_SYSTEM_WORKFLOW.md#étape-5--finalisation-prêt-à-envoyer) |

### Fonctions API

| Fonction | Rôle | Documentation |
|----------|------|---------------|
| `listOffers()` | Récupère les offres avec filtres | [API §1.1](./BOOKING_SYSTEM_API.md#listoffers) |
| `createOffer()` | Crée une offre (v1) | [API §1.2](./BOOKING_SYSTEM_API.md#createoffer) |
| `createOfferVersion()` | Crée une nouvelle version | [API §1.3](./BOOKING_SYSTEM_API.md#createofferversion) |
| `updateOffer()` | Met à jour une offre | [API §1.4](./BOOKING_SYSTEM_API.md#updateoffer) |
| `moveOffer()` | Change le statut (Kanban) | [API §1.5](./BOOKING_SYSTEM_API.md#moveoffer) |
| `deleteOffer()` | Supprime une offre | [API §1.6](./BOOKING_SYSTEM_API.md#deleteoffer) |
| `generateOfferPdfOnStatusChange()` | Génère PDF auto | [API §3](./BOOKING_SYSTEM_API.md#3-génération-de-pdf) |

---

## 🔄 Par workflow

### Création d'une offre
1. [Création performance](./BOOKING_SYSTEM_WORKFLOW.md#étape-1--création-de-la-performance)
2. [Affichage Kanban](./BOOKING_SYSTEM_WORKFLOW.md#étape-2--affichage-dans-le-kanban)
3. [Création offre](./BOOKING_SYSTEM_WORKFLOW.md#étape-3--création-de-loffre)
4. [Remplissage formulaire](./BOOKING_SYSTEM_WORKFLOW.md#étape-4--remplissage-du-formulaire-dans-offercomposer)
5. [Génération PDF](./BOOKING_SYSTEM_WORKFLOW.md#étape-5--génération-du-pdf)
6. [Finalisation](./BOOKING_SYSTEM_WORKFLOW.md#étape-6--finalisation-prêt-à-envoyer)
7. [Envoi email](./BOOKING_SYSTEM_WORKFLOW.md#étape-7--envoi-de-loffre-par-email)
8. [Acceptation](./BOOKING_SYSTEM_WORKFLOW.md#étape-8a--acceptation-de-loffre) ou [Rejet](./BOOKING_SYSTEM_WORKFLOW.md#étape-8b--rejet-de-loffre)

### Modification d'une offre (Versioning)
→ [Cas spécial : Modification](./BOOKING_SYSTEM_WORKFLOW.md#-cas-spécial--modification-doffre-versioning)

---

## 📝 Par type de données

### Types TypeScript

| Type | Description | Documentation |
|------|-------------|---------------|
| `OfferStatus` | Statuts d'offre | [Architecture - Types](./BOOKING_SYSTEM_ARCHITECTURE.md#types-principaux) |
| `CurrencyCode` | Codes devises | [Architecture - Types](./BOOKING_SYSTEM_ARCHITECTURE.md#types-principaux) |
| `Offer` | Interface offre complète | [Architecture - Types](./BOOKING_SYSTEM_ARCHITECTURE.md#types-principaux) |
| `OfferPdfData` | Données pour PDF | [PDF - Interface](./BOOKING_SYSTEM_PDF.md#-interface-offerpdfdata) |
| `OfferFilters` | Filtres de recherche | [Architecture - Types](./BOOKING_SYSTEM_ARCHITECTURE.md#types-principaux) |
| `CreateOfferPayload` | Payload création offre | [API §1.2](./BOOKING_SYSTEM_API.md#createoffer) |

### Enums PostgreSQL

| Enum | Valeurs | Documentation |
|------|---------|---------------|
| `offer_status_enum` | draft, ready_to_send, sent, accepted, rejected, etc. | [Relations - Enums](./BOOKING_SYSTEM_RELATIONS.md#offer_status_enum) |
| `currency_code_enum` | EUR, USD, GBP, CHF | [Relations - Enums](./BOOKING_SYSTEM_RELATIONS.md#currency_code_enum) |

---

## 🛠️ Par fonctionnalité

### Versioning
- [Principe du versioning](./BOOKING_SYSTEM_ARCHITECTURE.md#-système-de-versioning)
- [Fonction `get_next_offer_version()`](./BOOKING_SYSTEM_RELATIONS.md#1-get_next_offer_version)
- [Fonction `get_offer_versions()`](./BOOKING_SYSTEM_RELATIONS.md#2-get_offer_versions)
- [Vue `offer_versions_view`](./BOOKING_SYSTEM_RELATIONS.md#-vue--offer_versions_view)
- [Workflow modification](./BOOKING_SYSTEM_WORKFLOW.md#-cas-spécial--modification-doffre-versioning)

### Génération PDF
- [Vue d'ensemble](./BOOKING_SYSTEM_PDF.md#-vue-densemble)
- [Interface OfferPdfData](./BOOKING_SYSTEM_PDF.md#-interface-offerpdfdata)
- [Fonction principale](./BOOKING_SYSTEM_PDF.md#-fonction-principale--generateofferpdfandupload)
- [Formatage et nettoyage](./BOOKING_SYSTEM_PDF.md#-fonctions-utilitaires)
- [Champs du template](./BOOKING_SYSTEM_PDF.md#-template-pdf---champs-disponibles)

### Envoi d'emails
- [Modal SendOfferModal](./BOOKING_SYSTEM_ARCHITECTURE.md#4-sendoffermodaltsx)
- [Process d'envoi](./BOOKING_SYSTEM_WORKFLOW.md#étape-7--envoi-de-loffre-par-email)
- [Service EmailJS](./BOOKING_SYSTEM_WORKFLOW.md#4-envoi-via-emailjs-)

### Extras
- [Table booking_extras](./BOOKING_SYSTEM_RELATIONS.md#4-booking_extras)
- [Table offer_extras](./BOOKING_SYSTEM_RELATIONS.md#3-offer_extras)
- [Assignation Festival/Artist](./BOOKING_SYSTEM_WORKFLOW.md#étape-4--remplissage-du-formulaire-dans-offercomposer)

### Clauses d'exclusivité
- [Table exclusivity_clauses](./BOOKING_SYSTEM_RELATIONS.md#5-exclusivity_clauses)
- [Sélection dans OfferComposer](./BOOKING_SYSTEM_WORKFLOW.md#étape-4--remplissage-du-formulaire-dans-offercomposer)
- [Remplissage dans PDF](./BOOKING_SYSTEM_PDF.md#-fonction-principale--generateofferpdfandupload)

### Création automatique de contrat
- [Principe](./BOOKING_SYSTEM_WORKFLOW.md#étape-8a--acceptation-de-loffre)
- [Fonction `createContractFromAcceptedOffer()`](./BOOKING_SYSTEM_WORKFLOW.md#2-création-automatique-du-contrat-)
- [Table contracts (relation)](./BOOKING_SYSTEM_RELATIONS.md#offers--contracts)

---

## 🔍 Recherche par mot-clé

### A
- **Acceptation** : [Workflow §8A](./BOOKING_SYSTEM_WORKFLOW.md#étape-8a--acceptation-de-loffre)
- **Activity log** : [Relations §6](./BOOKING_SYSTEM_RELATIONS.md#6-offer_activity_log)
- **API** : [Documentation complète](./BOOKING_SYSTEM_API.md)
- **Artist performances** : [Relations §2](./BOOKING_SYSTEM_RELATIONS.md#2-artist_performances)

### B
- **Booking extras** : [Relations §4](./BOOKING_SYSTEM_RELATIONS.md#4-booking_extras)
- **Booking status** : [Architecture §1.A](./BOOKING_SYSTEM_ARCHITECTURE.md#a-états-des-performances-artist_performancesbooking_status)

### C
- **Clauses** : [Relations §5](./BOOKING_SYSTEM_RELATIONS.md#5-exclusivity_clauses)
- **Contrat** : [Workflow §8A.2](./BOOKING_SYSTEM_WORKFLOW.md#2-création-automatique-du-contrat-)
- **Currency** : [Types](./BOOKING_SYSTEM_ARCHITECTURE.md#types-principaux)

### D
- **Database schema** : [Architecture §2](./BOOKING_SYSTEM_ARCHITECTURE.md#--schéma-de-base-de-données)
- **Drag & drop** : [KanbanBoard](./BOOKING_SYSTEM_ARCHITECTURE.md#3-kanbanboardtsx)

### E
- **EmailJS** : [Workflow §7.4](./BOOKING_SYSTEM_WORKFLOW.md#4-envoi-via-emailjs-)
- **Enums** : [Relations - Enums](./BOOKING_SYSTEM_RELATIONS.md#-enums-postgresql)
- **Extras** : [Relations §3-4](./BOOKING_SYSTEM_RELATIONS.md#3-offer_extras)
- **Exclusivity** : [Relations §5](./BOOKING_SYSTEM_RELATIONS.md#5-exclusivity_clauses)

### F
- **Filtres** : [API §1.1](./BOOKING_SYSTEM_API.md#listoffers)
- **Fonctions PostgreSQL** : [Relations - Fonctions](./BOOKING_SYSTEM_RELATIONS.md#-fonctions-postgresql)

### G
- **Génération PDF** : [PDF - Vue d'ensemble](./BOOKING_SYSTEM_PDF.md#-vue-densemble)

### K
- **Kanban** : [Architecture §3.3](./BOOKING_SYSTEM_ARCHITECTURE.md#3-kanbanboardtsx), [Workflow §2](./BOOKING_SYSTEM_WORKFLOW.md#étape-2--affichage-dans-le-kanban)

### M
- **Migration** : [Checklist](./BOOKING_SYSTEM_RELATIONS.md#-checklist-pour-migration)
- **Modal** : [Architecture §3](./BOOKING_SYSTEM_ARCHITECTURE.md#-composants-react-principaux)

### O
- **Offers (table)** : [Relations §1](./BOOKING_SYSTEM_RELATIONS.md#1-offers)
- **OfferComposer** : [Architecture §3.2](./BOOKING_SYSTEM_ARCHITECTURE.md#2-offercomposertsx)

### P
- **PDF** : [Documentation complète](./BOOKING_SYSTEM_PDF.md)
- **Performance** : [Relations §2](./BOOKING_SYSTEM_RELATIONS.md#2-artist_performances), [Workflow §1](./BOOKING_SYSTEM_WORKFLOW.md#étape-1--création-de-la-performance)

### R
- **Rejet** : [Workflow §8B](./BOOKING_SYSTEM_WORKFLOW.md#étape-8b--rejet-de-loffre)
- **Relations** : [Documentation complète](./BOOKING_SYSTEM_RELATIONS.md)

### S
- **Status** : [Architecture §1.B](./BOOKING_SYSTEM_ARCHITECTURE.md#b-états-des-offres-offersstatus)
- **Storage (Supabase)** : [Relations - Storage](./BOOKING_SYSTEM_RELATIONS.md#-supabase-storage), [PDF - Stockage](./BOOKING_SYSTEM_PDF.md#-stockage-du-pdf)
- **Synchronisation** : [Workflow - Mise à jour performance](./BOOKING_SYSTEM_WORKFLOW.md#5-mise-à-jour-de-la-performance-)

### T
- **Tables** : [Relations - Vue d'ensemble](./BOOKING_SYSTEM_RELATIONS.md#-schéma-complet-des-tables)
- **Template PDF** : [PDF - Template](./BOOKING_SYSTEM_PDF.md#template-pdf)
- **Types TypeScript** : [Architecture - Types](./BOOKING_SYSTEM_ARCHITECTURE.md#-types-typescript)

### V
- **Versioning** : [Architecture - Versioning](./BOOKING_SYSTEM_ARCHITECTURE.md#-système-de-versioning), [Workflow - Modification](./BOOKING_SYSTEM_WORKFLOW.md#-cas-spécial--modification-doffre-versioning)
- **Vue** : [Relations - Vue](./BOOKING_SYSTEM_RELATIONS.md#-vue--offer_versions_view)

### W
- **Workflow** : [Documentation complète](./BOOKING_SYSTEM_WORKFLOW.md)

---

## 📚 Documents complets

1. **[README Principal](./BOOKING_SYSTEM_README.md)** - Introduction et guide de démarrage
2. **[Architecture](./BOOKING_SYSTEM_ARCHITECTURE.md)** - Structure et composants
3. **[Workflow](./BOOKING_SYSTEM_WORKFLOW.md)** - Process détaillé étape par étape
4. **[API](./BOOKING_SYSTEM_API.md)** - Toutes les fonctions API
5. **[PDF](./BOOKING_SYSTEM_PDF.md)** - Système de génération PDF
6. **[Relations](./BOOKING_SYSTEM_RELATIONS.md)** - Tables et relations SQL

---

## 🎯 Raccourcis utiles

### Je cherche...

| Quoi ? | Où ? |
|--------|------|
| Comment créer une offre | [Workflow §3-6](./BOOKING_SYSTEM_WORKFLOW.md#étape-3--création-de-loffre) |
| Structure table `offers` | [Relations §1](./BOOKING_SYSTEM_RELATIONS.md#1-offers) |
| Générer un PDF | [PDF - Fonction](./BOOKING_SYSTEM_PDF.md#-fonction-principale--generateofferpdfandupload) |
| Envoyer un email | [Workflow §7](./BOOKING_SYSTEM_WORKFLOW.md#étape-7--envoi-de-loffre-par-email) |
| Créer une version d'offre | [API - createOfferVersion](./BOOKING_SYSTEM_API.md#createofferversion) |
| Liste des statuts | [Architecture §1.B](./BOOKING_SYSTEM_ARCHITECTURE.md#b-états-des-offres-offersstatus) |
| Checklist migration | [Relations - Checklist](./BOOKING_SYSTEM_RELATIONS.md#-checklist-pour-migration) |
| Template PDF champs | [PDF - Champs](./BOOKING_SYSTEM_PDF.md#-template-pdf---champs-disponibles) |

---

**Dernière mise à jour :** Novembre 2024

