# 📚 DOCUMENTATION COMPLÈTE - SYSTÈME DE BOOKING ET D'OFFRES

## 🎯 Introduction

Cette documentation technique complète décrit l'intégralité du système de booking et de gestion des offres de **GO-PROD V3**. Elle est conçue pour permettre une migration complète vers une nouvelle version du SaaS.

---

## 📖 Table des matières

### 1. [Architecture du système](./BOOKING_SYSTEM_ARCHITECTURE.md)
**Contenu :**
- Vue d'ensemble du système
- Architecture globale et cycle de vie d'une offre
- États des performances et des offres
- Schéma de base de données détaillé
- Système de versioning
- Types TypeScript
- Composants React principaux

**À lire en premier** pour comprendre la structure générale du système.

---

### 2. [Workflow détaillé](./BOOKING_SYSTEM_WORKFLOW.md)
**Contenu :**
- Process complet étape par étape
- Création de performance → Envoi email → Acceptation/Rejet
- Détail de chaque étape avec code
- Cas spéciaux (modification d'offre, versioning)
- Interactions entre composants

**À lire pour comprendre** le flux utilisateur et les interactions système.

---

### 3. [API et fonctions](./BOOKING_SYSTEM_API.md)
**Contenu :**
- Toutes les fonctions de `bookingApi.ts`
- Signatures, paramètres et retours
- Exemples de code complet
- Gestion des offres (CRUD)
- Gestion des fichiers
- Génération de PDF automatique
- Gestion des catégories et clauses

**À lire pour implémenter** les fonctions backend et API.

---

### 4. [Système de génération PDF](./BOOKING_SYSTEM_PDF.md)
**Contenu :**
- Utilisation de pdf-lib
- Template PDF et champs disponibles
- Interface `OfferPdfData`
- Fonctions utilitaires (formatage, nettoyage)
- Process complet de génération
- Stockage dans Supabase Storage
- Debugging

**À lire pour comprendre** la génération et le remplissage des PDFs.

---

### 5. [Tables et relations](./BOOKING_SYSTEM_RELATIONS.md)
**Contenu :**
- Schéma SQL complet de toutes les tables
- Relations et clés étrangères
- Fonctions PostgreSQL
- Vues et enums
- Configuration Supabase Storage
- **Checklist de migration complète**

**À lire pour implémenter** la structure de base de données.

---

## 🚀 Guide de démarrage rapide

### Pour comprendre le système
1. Lire [Architecture](./BOOKING_SYSTEM_ARCHITECTURE.md) (30 min)
2. Lire [Workflow](./BOOKING_SYSTEM_WORKFLOW.md) (45 min)

### Pour implémenter une migration
1. Lire [Tables et relations](./BOOKING_SYSTEM_RELATIONS.md) - **Checklist**
2. Appliquer les migrations SQL
3. Configurer Supabase Storage
4. Implémenter [API](./BOOKING_SYSTEM_API.md)
5. Implémenter [PDF](./BOOKING_SYSTEM_PDF.md)
6. Implémenter les composants React depuis [Architecture](./BOOKING_SYSTEM_ARCHITECTURE.md)

---

## 📊 Diagramme simplifié du système

```
┌─────────────────────────────────────────────────────────────────┐
│                        CYCLE DE VIE                             │
└─────────────────────────────────────────────────────────────────┘

TIMELINE/PERFORMANCES
        ↓
    [Performance créée]
    booking_status = 'offre_a_faire'
        ↓
    KANBAN - Colonne "Brouillon / À faire"
        ↓
    [Click "Établir offre"]
        ↓
    OFFER COMPOSER
        ↓
    [Remplissage formulaire]
        ↓
    [Click "Générer offre"]
        ↓
    PDF PREVIEW MODAL
        ↓
    [Click "Prêt à envoyer"]
        ↓
    SAUVEGARDE BDD
    status = 'ready_to_send'
    PDF stocké dans Storage
        ↓
    KANBAN - Colonne "Prêt à envoyer"
        ↓
    [Click "Envoyer"]
        ↓
    SEND OFFER MODAL
        ↓
    [Email via EmailJS + PDF joint]
        ↓
    status = 'sent'
        ↓
    KANBAN - Colonne "Envoyé"
        ↓
    ┌─────────────────┴─────────────────┐
    │                                   │
    ▼                                   ▼
[ACCEPTÉ]                          [REJETÉ]
status = 'accepted'                status = 'rejected'
    │                              rejection_reason enregistrée
    ▼
CRÉATION AUTO CONTRAT
```

---

## 🗂️ Structure des fichiers source

### Backend / API
```
src/features/booking/
├── bookingTypes.ts          # Tous les types TypeScript
├── bookingApi.ts            # Toutes les fonctions API
├── pdf/
│   ├── pdfFill.ts          # Génération PDF
│   └── debugPdfFields.ts   # Debug PDF
```

### Frontend / Composants
```
src/
├── pages/
│   └── BookingPage.tsx     # Page principale
├── features/booking/
│   ├── OfferComposer.tsx   # Modal création/modification
│   ├── KanbanBoard.tsx     # Vue Kanban
│   ├── OfferCard.tsx       # Carte d'offre
│   ├── OffersListView.tsx  # Vue liste
│   └── UniformOfferCard.tsx
├── components/
│   ├── offers/
│   │   ├── SendOfferModal.tsx    # Modal envoi email
│   │   ├── RejectOfferModal.tsx  # Modal rejet
│   │   └── PdfPreviewModal.tsx   # Prévisualisation PDF
│   └── timetable/
│       └── PerformanceModal.tsx  # Modal performance
```

### Migrations SQL
```
supabase/migrations/
├── 20240912_offer_versioning.sql
├── 20250903130000_add_financial_fields_to_offers.sql
├── 20250904120000_create_exclusivity_clauses.sql
├── 20250905120000_add_amount_type_to_offers.sql
├── 20250905130000_apply_booking_offers_init.sql
├── 20250905140000_fix_offers_status_enum.sql
├── 20250905150000_create_email_signatures.sql
└── 20250905160000_add_rejection_reason_to_offers.sql
```

---

## 🔑 Concepts clés

### 1. Versioning d'offres
- Chaque modification d'offre crée une **nouvelle version**
- Version 1 : `original_offer_id = NULL`
- Versions 2+ : `original_offer_id` pointe vers la v1
- Fonction PostgreSQL `get_next_offer_version()` gère la numérotation

### 2. Synchronisation Performance ↔ Offre
- Performance créée → `booking_status = 'offre_a_faire'`
- Offre envoyée → `booking_status = 'offre_envoyee'`
- Offre acceptée → `booking_status = 'offre_acceptee'`
- Offre rejetée → `booking_status = 'offre_rejetee'`

### 3. Génération automatique
- **PDF :** Quand statut passe à `ready_to_send`
- **Contrat :** Quand statut passe à `accepted`

### 4. Extras et Clauses
- **Extras :** Assignés "Festival" ou "Artist" via `offer_extras`
- **Clauses :** Sélectionnées dans un catalogue, stockées dans `terms_json`

---

## 🛠️ Technologies utilisées

### Backend
- **Supabase PostgreSQL** : Base de données
- **Supabase Storage** : Stockage PDFs
- **Supabase Auth** : Authentification (RLS)

### Frontend
- **React** + **TypeScript**
- **pdf-lib** : Génération PDF côté client
- **EmailJS** : Envoi d'emails
- **Zustand** : State management
- **Lucide React** : Icônes

### Services externes
- **EmailJS** : Service d'envoi d'emails avec pièces jointes

---

## 📝 Checklist de migration

### Phase 1 : Base de données
- [ ] Créer tous les enums (`offer_status_enum`, `currency_code_enum`)
- [ ] Créer toutes les tables (voir [Relations](./BOOKING_SYSTEM_RELATIONS.md))
- [ ] Créer les index pour performances
- [ ] Créer les fonctions PostgreSQL (`get_next_offer_version`, etc.)
- [ ] Créer les vues (`offer_versions_view`)
- [ ] Appliquer les triggers `updated_at`
- [ ] Insérer les données de seed (extras, clauses)

### Phase 2 : Storage
- [ ] Créer bucket `offers` (privé)
- [ ] Configurer RLS pour `offers`
- [ ] Créer bucket `word-templates` (public)
- [ ] Uploader le template PDF

### Phase 3 : Backend/API
- [ ] Implémenter `bookingTypes.ts`
- [ ] Implémenter `bookingApi.ts`
- [ ] Implémenter génération PDF (`pdf/pdfFill.ts`)
- [ ] Tester toutes les fonctions API

### Phase 4 : Frontend
- [ ] Créer `BookingPage.tsx`
- [ ] Créer `OfferComposer.tsx`
- [ ] Créer `KanbanBoard.tsx` et composants Kanban
- [ ] Créer modals (Send, Reject, PdfPreview)
- [ ] Intégrer avec EmailJS
- [ ] Tester workflow complet

### Phase 5 : Tests
- [ ] Test création performance
- [ ] Test création offre
- [ ] Test génération PDF
- [ ] Test envoi email
- [ ] Test acceptation → contrat
- [ ] Test rejet
- [ ] Test modification (versioning)
- [ ] Test drag & drop Kanban

---

## 🐛 Points d'attention

### Encodage PDF
- Utiliser `cleanTextForPdf()` pour éviter erreurs encodage
- Remplacer caractères Unicode problématiques
- Tester avec noms d'artistes accentués

### Durée de performance
- Récupérée depuis `artist_performances.duration`
- Valeur par défaut : 60 minutes si non trouvée

### URLs signées
- Durée : 7 jours (604800 secondes)
- Régénérer avant envoi email pour éviter expiration

### Synchronisation Performance
- Toujours mettre à jour `booking_status` après changement statut offre
- Déclencher événements CustomEvent pour rafraîchir l'UI

---

## 📞 Support et questions

Pour toute question sur cette documentation :
1. Référez-vous aux fichiers sources mentionnés
2. Consultez les migrations SQL pour la structure exacte
3. Examinez les composants React pour l'implémentation UI

---

## 📅 Version de la documentation

**Date :** Novembre 2024  
**Version système :** GO-PROD V3  
**Auteur :** Documentation générée par analyse complète du codebase  

---

**Bonne migration ! 🚀**

