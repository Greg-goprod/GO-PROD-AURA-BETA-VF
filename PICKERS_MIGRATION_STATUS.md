# 📊 État de la migration des Pickers

## ✅ Terminé

| Fichier | Type | Statut | Date |
|---------|------|--------|------|
| `DateTimePickerPopup.tsx` | Nouveau composant | ✅ Créé | 2025-10-28 |
| `pickers/index.ts` | Exports | ✅ Mis à jour | 2025-10-28 |
| `PICKERS_STANDARD.md` | Documentation | ✅ Créé | 2025-10-28 |
| `EventQuickAddModal.tsx` | Migration | ✅ Migré | 2025-10-28 |

## 🔄 En cours / À faire

### Fichiers avec `type="date"` (3 restants)

| Fichier | Lignes | Priorité | Notes |
|---------|--------|----------|-------|
| `components/events/EventForm.tsx` | ? | 🔴 Haute | Formulaire principal événements |
| `components/events/EventQuickCreateModal.tsx` | 36,48 | 🟡 Moyenne | Déjà migré `EventQuickAddModal` (similaire) |
| `features/booking/modals/OfferComposer.tsx` | ? | 🟡 Moyenne | Module Booking |

### Fichiers avec `type="time"` (5 fichiers)

| Fichier | Lignes | Priorité | Notes |
|---------|--------|----------|-------|
| `components/events/EventForm.tsx` | ? | 🔴 Haute | Formulaire principal (dates + heures) |
| `features/booking/modals/OfferComposer.tsx` | ? | 🟡 Moyenne | Module Booking |
| `features/booking/modals/PerformanceModal.tsx` | ? | 🟡 Moyenne | Module Booking |
| `features/timeline/components/CustomTimePicker.tsx` | ? | 🟢 Basse | Composant spécialisé Timeline |
| `pages/settings/SettingsHospitalityPage.tsx` | ? | 🟢 Basse | Page paramètres |

### Fichiers avec composants de base directs (1 fichier)

| Fichier | Composants | Priorité | Notes |
|---------|-----------|----------|-------|
| `pages/Booking.tsx` | `DatePickerAura`, `TimePickerCircular24` | 🟡 Moyenne | À vérifier |

---

## 📋 Plan de migration détaillé

### Phase 1 : Composants critiques (PRIORITÉ)

#### 1.1 `components/events/EventForm.tsx`
**Pourquoi** : Formulaire principal pour la gestion des événements, utilisé partout.

**Actions** :
- [ ] Scanner les usages de `type="date"` et `type="time"`
- [ ] Remplacer par `DatePickerPopup` et `TimePickerPopup`
- [ ] Adapter les types (`string` → `Date | null` pour dates)
- [ ] Tester avec `react-hook-form`

**Estimation** : 30 min

---

### Phase 2 : Module Booking (IMPORTANT)

#### 2.1 `features/booking/modals/OfferComposer.tsx`
**Pourquoi** : Composition d'offres, utilisé fréquemment.

**Actions** :
- [ ] Remplacer `type="date"` par `DatePickerPopup`
- [ ] Remplacer `type="time"` par `TimePickerPopup`
- [ ] Adapter les conversions de valeurs

**Estimation** : 20 min

#### 2.2 `features/booking/modals/PerformanceModal.tsx`
**Pourquoi** : Gestion des performances artistes.

**Actions** :
- [ ] Remplacer `type="time"` par `TimePickerPopup`
- [ ] Tester l'intégration avec Timeline

**Estimation** : 15 min

#### 2.3 `pages/Booking.tsx`
**Pourquoi** : Page principale Booking, usage direct des composants de base.

**Actions** :
- [ ] Vérifier l'usage de `DatePickerAura` / `TimePickerCircular24`
- [ ] Remplacer par `DatePickerPopup` / `TimePickerPopup` si applicable
- [ ] Tester la page complète

**Estimation** : 20 min

---

### Phase 3 : Composants secondaires (NORMAL)

#### 3.1 `components/events/EventQuickCreateModal.tsx`
**Pourquoi** : Modal de création rapide (similaire à `EventQuickAddModal` déjà migré).

**Actions** :
- [ ] Copier/adapter la migration de `EventQuickAddModal`
- [ ] Remplacer `type="date"` par `DatePickerPopup`

**Estimation** : 10 min

#### 3.2 `pages/settings/SettingsHospitalityPage.tsx`
**Pourquoi** : Page de paramètres, peu critique.

**Actions** :
- [ ] Remplacer `type="time"` par `TimePickerPopup`
- [ ] Tester en mode Settings

**Estimation** : 10 min

---

### Phase 4 : Composants spécialisés (À ÉVALUER)

#### 4.1 `features/timeline/components/CustomTimePicker.tsx`
**Pourquoi** : Composant custom pour Timeline, peut avoir des besoins spécifiques.

**Actions** :
- [ ] **Analyser** si `TimePickerPopup` convient
- [ ] **Option 1** : Remplacer par `TimePickerPopup`
- [ ] **Option 2** : Garder custom mais utiliser `TimePickerCircular24` en base
- [ ] **Option 3** : Créer un wrapper spécifique Timeline

**Estimation** : 30 min (analyse + migration)

**⚠️ Note** : Ce composant peut nécessiter une approche différente selon les contraintes de la Timeline.

---

## 🎯 Stratégie recommandée

### Ordre d'exécution

1. **Immédiat** (Phase 1) :
   - ✅ `EventForm.tsx` → Formulaire central

2. **Prioritaire** (Phase 2) :
   - ✅ `OfferComposer.tsx` → Booking
   - ✅ `PerformanceModal.tsx` → Booking
   - ✅ `Booking.tsx` → Page principale

3. **Normal** (Phase 3) :
   - ✅ `EventQuickCreateModal.tsx` → Création événement
   - ✅ `SettingsHospitalityPage.tsx` → Paramètres

4. **Analyse** (Phase 4) :
   - 🔍 `CustomTimePicker.tsx` → Timeline (évaluer besoin)

---

## 🔧 Étapes de migration par fichier

Pour chaque fichier :

1. **Backup** : Commit avant modification
2. **Scan** : Identifier tous les `type="date"` / `type="time"`
3. **Import** : Ajouter `import { DatePickerPopup, TimePickerPopup } from '@/components/ui/pickers'`
4. **Types** : Adapter les types de state (`string` → `Date | null` pour dates)
5. **Replace** : Remplacer chaque input par le picker correspondant
6. **Convert** : Ajouter conversions si nécessaire (`Date` ↔ `ISO string`)
7. **Test** : Vérifier en mode clair et dark
8. **Lint** : Corriger les erreurs TypeScript
9. **Commit** : Commit avec message clair

---

## ✅ Checklist finale

Avant de considérer la migration terminée :

### Composants

- [x] `DateTimePickerPopup` créé (630×380px)
- [x] `pickers/index.ts` mis à jour avec exports et `@deprecated`
- [x] Documentation `PICKERS_STANDARD.md` créée
- [ ] Tous les `type="date"` remplacés
- [ ] Tous les `type="time"` remplacés
- [ ] Usages directs de `DatePickerAura`/`TimePickerCircular24` migrés

### Tests

- [ ] Mode clair : Pas de coins blancs, ombres visibles
- [ ] Mode dark : Ombres marquées, contours subtils
- [ ] Formulaires : Validation `react-hook-form` OK
- [ ] Accessibilité : Tab, Enter, Escape fonctionnent
- [ ] Conversions : `Date` ↔ `string` correctes
- [ ] Régression : Aucune fonctionnalité cassée

### Documentation

- [x] `PICKERS_STANDARD.md` : Guide complet
- [x] `PICKERS_MIGRATION_STATUS.md` : Suivi des migrations
- [ ] Exemples de code : Dans fichiers sources
- [ ] Commentaires `@deprecated` : Sur anciens composants

---

## 📊 Métriques

| Métrique | Valeur |
|----------|--------|
| **Fichiers à migrer** | 8 |
| **Fichiers migrés** | 1 ✅ |
| **Progression** | 12.5% |
| **Temps estimé restant** | ~2h30 |

---

## 🚀 Prochaines étapes

### Maintenant

1. ✅ Migrer `EventForm.tsx` (priorité haute)
2. ✅ Migrer module Booking (`OfferComposer`, `PerformanceModal`, `Booking.tsx`)
3. ✅ Migrer composants secondaires

### Après migration

1. ✅ Tests complets (tous les formulaires)
2. ✅ Tests accessibilité
3. ✅ Tests responsive
4. ✅ Supprimer les TODOs/imports inutiles
5. ✅ Commit final avec récapitulatif

---

## 📝 Notes importantes

### `CustomTimePicker.tsx` (Timeline)

Ce composant nécessite une **analyse approfondie** car :
- Utilisé dans la Timeline avec contraintes spécifiques (snap 5 min, etc.)
- Peut avoir besoin d'un comportement différent des formulaires standards
- **Options** :
  1. Remplacer par `TimePickerPopup` si compatible
  2. Garder comme wrapper custom de `TimePickerCircular24`
  3. Créer `TimePickerTimelinePopup` spécialisé

**Décision** : À prendre après analyse fonctionnelle avec l'équipe.

### `EventForm.tsx` vs `EventQuickCreateModal.tsx`

Ces deux fichiers ont des rôles similaires mais distincts :
- `EventForm` : Formulaire **complet** avec jours et scènes
- `EventQuickCreateModal` : Formulaire **rapide** sans jours/scènes

Migration similaire mais attention aux différences de structure.

---

## ✅ Fichiers déjà conformes

| Fichier | Usage | Note |
|---------|-------|------|
| `features/settings/events/EventForm.tsx` | ✅ Utilise déjà `DatePickerPopup` / `TimePickerPopup` | Référence à suivre |

---

**Dernière mise à jour** : 2025-10-28  
**Status global** : 🔄 En cours (12.5%)  
**Prochain objectif** : Migrer `EventForm.tsx` et module Booking


