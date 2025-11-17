# MODULE PRODUCTION - GUIDE DE DÉMARRAGE

## 🎯 Bienvenue dans la Documentation Production

Ce guide vous aidera à comprendre et à utiliser le **module Production** de GO-PROD, le système complet de gestion de la production d'événements.

---

## 🚀 Démarrage Rapide

### Pour les Nouveaux Arrivants

1. **Commencez ici** : [PRODUCTION_SYSTEM_ARCHITECTURE.md](./PRODUCTION_SYSTEM_ARCHITECTURE.md)
   - Vue d'ensemble complète
   - Structure des 7 sous-modules
   - Principes de base

2. **Ensuite** : [PRODUCTION_SYSTEM_WORKFLOW.md](./PRODUCTION_SYSTEM_WORKFLOW.md)
   - Comprendre les workflows
   - Cas d'usage pratiques
   - Interactions entre modules

3. **Pour approfondir** : [PRODUCTION_SYSTEM_RELATIONS.md](./PRODUCTION_SYSTEM_RELATIONS.md)
   - Schéma de base de données
   - Tables et relations
   - SQL et migrations

4. **Navigation** : [PRODUCTION_INDEX.md](./PRODUCTION_INDEX.md)
   - Index complet
   - Liens rapides
   - Table des matières

---

## 📋 Qu'est-ce que le Module Production ?

Le module Production gère **toute la logistique opérationnelle** d'un événement :

```
┌─────────────────────────────────────────────────────────┐
│                   MODULE PRODUCTION                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  🎤 TOURING PARTY    →  Équipes d'artistes             │
│  ✈️  TRAVELS         →  Voyages (avion, train, auto)    │
│  🚗 GROUND           →  Logistique terrestre           │
│     ├─ Missions      →  Transferts et transports       │
│     ├─ Drivers       →  Chauffeurs                     │
│     ├─ Vehicles      →  Flotte de véhicules            │
│     └─ Shifts        →  Planification équipes          │
│  🏨 HOSPITALITY      →  Accueil et services            │
│     ├─ Hotels        →  Réservations hôtelières        │
│     ├─ Backstage     →  Gestion des loges              │
│     ├─ Catering      →  Restauration                   │
│     └─ Accred-Invits →  Accréditations                 │
│  🔧 TECHNIQUE        →  Aspects techniques (à venir)    │
│  ⏰ TIMETABLE        →  Planning temporel (à venir)     │
│  🎉 PARTY CREW       →  Équipe festive (à venir)        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Cas d'Usage Principaux

### 1. Planifier l'Arrivée d'un Artiste

**Objectif** : Organiser l'arrivée d'un artiste de l'aéroport à l'hôtel.

**Étapes** :
1. **TOURING PARTY** : Définir la taille de l'équipe
2. **TRAVELS** : Créer le vol d'arrivée
3. **MISSIONS** : Mission créée automatiquement
4. **GROUND** : Dispatcher un chauffeur + véhicule
5. **HOTELS** : Réserver les chambres
6. **CATERING** : Configurer les repas

**Documentation** : [Workflow Global](./PRODUCTION_SYSTEM_WORKFLOW.md#1-workflow-global---cycle-de-vie-dun-événement-production)

---

### 2. Gérer les Régimes Alimentaires

**Objectif** : Gérer les besoins catering avec régimes spéciaux.

**Étapes** :
1. Accéder à **CATERING**
2. Sélectionner le jour d'événement
3. Pour chaque artiste :
   - Définir les quantités (breakfast, lunch, dinner)
   - Ajouter les régimes spéciaux (vegan, sans gluten, etc.)
   - Configurer l'after-show
4. Générer les vouchers
5. Scanner les vouchers sur site

**Documentation** : [Workflow Catering](./PRODUCTION_SYSTEM_WORKFLOW.md#5-catering---workflow-de-configuration)

---

### 3. Dispatcher une Mission de Transport

**Objectif** : Assigner un chauffeur et un véhicule à une mission.

**Étapes** :
1. Aller dans **GROUND → MISSIONS**
2. Missions créées automatiquement depuis TRAVELS
3. Cliquer "Dispatch" sur une mission
4. Sélectionner véhicule disponible
5. Sélectionner chauffeur disponible
6. Valider → Mission passe en statut "ASSIGNED"
7. (Optionnel) Notification WhatsApp envoyée

**Documentation** : [Workflow Dispatch](./PRODUCTION_SYSTEM_WORKFLOW.md#4-missions---workflow-de-dispatch)

---

## 🗂️ Structure de la Documentation

### Fichiers Principaux

| Fichier | Description | Pour qui ? |
|---------|-------------|------------|
| **PRODUCTION_README.md** | Ce fichier - Guide de démarrage | Tous |
| **PRODUCTION_SYSTEM_ARCHITECTURE.md** | Architecture complète du module | Développeurs, Architectes |
| **PRODUCTION_SYSTEM_WORKFLOW.md** | Workflows et processus métier | Product Owners, Développeurs |
| **PRODUCTION_SYSTEM_RELATIONS.md** | Schéma BDD, tables, SQL | Développeurs Backend, DBA |
| **PRODUCTION_INDEX.md** | Index et navigation complète | Tous |

---

## 🛠️ Technologies Utilisées

### Frontend
- **React** avec TypeScript
- **Supabase Realtime** pour synchronisation temps réel
- **React Hook Form** pour les formulaires
- **Lucide React** pour les icônes
- **date-fns** pour manipulation des dates

### Backend
- **Supabase** (PostgreSQL)
- **RPC Functions** pour logique métier complexe
- **Triggers** pour automatisations
- **JSONB** pour structures flexibles

### Patterns
- **Upsert** : Touring Party, Catering
- **Realtime Subscriptions** : Travels → Missions
- **Polymorphisme** : Travels (artist OU contact)
- **Many-to-Many** : Shifts-Drivers, Artist-Diets

---

## 📊 Statistiques du Module

### Sous-Modules
- **7 modules principaux**
- **4 sous-modules Ground**
- **4 sous-modules Hospitality**

### Pages
- **15+ pages React**
- **30+ composants**

### Base de Données
- **19 tables principales**
- **40+ migrations**
- **10+ fonctions SQL**
- **5+ triggers**

### Fonctionnalités
- ✅ **8 modules fonctionnels**
- 🚧 **3 en développement**
- 📋 **Nombreuses améliorations prévues**

---

## 🔗 Liens Rapides par Rôle

### Pour les Product Owners
1. [Architecture - Vue d'ensemble](./PRODUCTION_SYSTEM_ARCHITECTURE.md#vue-densemble)
2. [Workflows complets](./PRODUCTION_SYSTEM_WORKFLOW.md)
3. [Cas d'usage](./PRODUCTION_SYSTEM_WORKFLOW.md#2-touring-party---workflow-de-configuration)

### Pour les Développeurs Frontend
1. [Architecture - Structure UI](./PRODUCTION_SYSTEM_ARCHITECTURE.md#navigation-et-structure-ui)
2. [Composants principaux](./PRODUCTION_INDEX.md#-composants-communs)
3. [Workflows - Code exemples](./PRODUCTION_SYSTEM_WORKFLOW.md)

### Pour les Développeurs Backend
1. [Relations BDD](./PRODUCTION_SYSTEM_RELATIONS.md)
2. [Fonctions SQL](./PRODUCTION_SYSTEM_RELATIONS.md#fonctions-sql-utilitaires)
3. [Migrations](./PRODUCTION_SYSTEM_RELATIONS.md#migrations-clés)

### Pour les Designers/UX
1. [Architecture - Navigation](./PRODUCTION_SYSTEM_ARCHITECTURE.md#navigation-et-structure-ui)
2. [Workflows utilisateurs](./PRODUCTION_SYSTEM_WORKFLOW.md)
3. [Statuts et états](./PRODUCTION_INDEX.md#gestion-des-statuts)

### Pour les Testeurs QA
1. [Workflows complets](./PRODUCTION_SYSTEM_WORKFLOW.md)
2. [Cas limites](./PRODUCTION_SYSTEM_WORKFLOW.md#10-gestion-des-erreurs-et-cas-limites)
3. [Index fonctionnalités](./PRODUCTION_INDEX.md)

---

## 🎓 Parcours d'Apprentissage

### Niveau 1 : Débutant (1-2h)
1. Lire [Architecture - Vue d'ensemble](./PRODUCTION_SYSTEM_ARCHITECTURE.md#vue-densemble)
2. Explorer [Structure du Module](./PRODUCTION_SYSTEM_ARCHITECTURE.md#structure-du-module)
3. Comprendre [Touring Party](./PRODUCTION_SYSTEM_ARCHITECTURE.md#1-touring-party---gestion-des-équipes)
4. Comprendre [Travels](./PRODUCTION_SYSTEM_ARCHITECTURE.md#2-travels---gestion-des-voyages)

### Niveau 2 : Intermédiaire (3-4h)
1. Étudier [GROUND complet](./PRODUCTION_SYSTEM_ARCHITECTURE.md#3-ground---logistique-terrestre)
2. Étudier [HOSPITALITY complet](./PRODUCTION_SYSTEM_ARCHITECTURE.md#4-hospitality---accueil-et-services)
3. Explorer [Workflows détaillés](./PRODUCTION_SYSTEM_WORKFLOW.md)
4. Comprendre [Synchronisations](./PRODUCTION_SYSTEM_WORKFLOW.md#9-intégrations-et-synchronisations)

### Niveau 3 : Avancé (5-6h)
1. Maîtriser [Schéma BDD complet](./PRODUCTION_SYSTEM_RELATIONS.md)
2. Comprendre [Fonctions SQL](./PRODUCTION_SYSTEM_RELATIONS.md#fonctions-sql-utilitaires)
3. Analyser [Migrations](./PRODUCTION_SYSTEM_RELATIONS.md#migrations-clés)
4. Étudier [Contraintes et validations](./PRODUCTION_SYSTEM_RELATIONS.md#contraintes-et-validations)

### Niveau 4 : Expert (Full Deep Dive)
1. Lire **toute la documentation**
2. Explorer le **code source** avec la documentation comme guide
3. Comprendre les **patterns avancés**
4. Maîtriser les **optimisations**

---

## 🔍 Recherche Rapide

### Je veux comprendre...

| Sujet | Lien Direct |
|-------|-------------|
| Comment fonctionne Touring Party | [Architecture TP](./PRODUCTION_SYSTEM_ARCHITECTURE.md#1-touring-party---gestion-des-équipes) |
| Comment créer un travel | [Workflow Travels](./PRODUCTION_SYSTEM_WORKFLOW.md#3-travels---workflow-de-gestion-des-voyages) |
| Comment dispatcher une mission | [Workflow Missions](./PRODUCTION_SYSTEM_WORKFLOW.md#4-missions---workflow-de-dispatch) |
| La structure de la table travels | [BDD Travels](./PRODUCTION_SYSTEM_RELATIONS.md#2-travels) |
| Les relations entre tables | [Schéma Global](./PRODUCTION_SYSTEM_RELATIONS.md#schéma-relationnel-global) |
| Les synchronisations temps réel | [Intégrations](./PRODUCTION_SYSTEM_WORKFLOW.md#9-intégrations-et-synchronisations) |
| Comment gérer le catering | [Workflow Catering](./PRODUCTION_SYSTEM_WORKFLOW.md#5-catering---workflow-de-configuration) |
| Les migrations importantes | [Migrations](./PRODUCTION_SYSTEM_RELATIONS.md#migrations-clés) |

---

## ⚠️ Points d'Attention

### Sécurité
- ⚠️ **RLS désactivé** sur la plupart des tables (à activer en production)
- 🔒 Voir : [RLS Section](./PRODUCTION_SYSTEM_RELATIONS.md#row-level-security-rls)

### Performance
- ✅ Index créés sur toutes les FK
- ✅ Requêtes optimisées
- 📊 Voir : [Index](./PRODUCTION_SYSTEM_RELATIONS.md#index-de-performance)

### Fonctionnalités en Développement
- 🚧 Notifications WhatsApp
- 🚧 Détection conflits avancée
- 🚧 Modules Technique, Timetable, Party Crew

---

## 🆘 Besoin d'Aide ?

### Documentation
- [Index Complet](./PRODUCTION_INDEX.md)
- [Architecture](./PRODUCTION_SYSTEM_ARCHITECTURE.md)
- [Workflow](./PRODUCTION_SYSTEM_WORKFLOW.md)
- [BDD](./PRODUCTION_SYSTEM_RELATIONS.md)

### Code Source
- Frontend : `src/pages/*Page.tsx`
- Composants : `src/components/`
- Types : `src/types/index.ts`
- SQL : `supabase/migrations/*.sql`

---

## 🎉 Vous êtes Prêt !

Maintenant que vous avez une vue d'ensemble, explorez la documentation selon vos besoins :

1. 📖 **Lecture complète** : Suivez le parcours d'apprentissage
2. 🎯 **Besoin spécifique** : Utilisez l'index ou la recherche rapide
3. 🔍 **Exploration** : Parcourez les différentes sections

**Bon voyage dans le monde de la Production GO-PROD ! 🚀**

---

**Prochaines étapes recommandées** :
→ [PRODUCTION_SYSTEM_ARCHITECTURE.md](./PRODUCTION_SYSTEM_ARCHITECTURE.md) pour comprendre la structure globale
→ [PRODUCTION_INDEX.md](./PRODUCTION_INDEX.md) pour naviguer rapidement

---

*Documentation mise à jour : Novembre 2025*


