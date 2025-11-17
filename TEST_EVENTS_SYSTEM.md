# Guide de test - Système de gestion d'évènements

## 📋 Vue d'ensemble

Système complet de gestion d'évènements multi-tenant avec support des jours, scènes et règle "après minuit".

## 🗂️ Fichiers créés/modifiés

### Utilitaires
- ✅ `src/utils/slug.ts` - Génération de slugs (fallback si RPC absent)

### API
- ✅ `src/api/eventsApi.ts` - CRUD complet pour events, event_days, event_stages

### Composants Settings
- ✅ `src/features/settings/events/EventQuickAddModal.tsx` - Création rapide (nom, dates, couleur)
- ✅ `src/features/settings/events/EventForm.tsx` - Formulaire avancé (react-hook-form, sections)
- ✅ `src/pages/settings/SettingsEventsPage.tsx` - Page de gestion des évènements

### Existants (réutilisés)
- ✅ `src/components/events/EventSelector.tsx` - Sélecteur dans le header
- ✅ `src/components/events/EventQuickCreateModal.tsx` - Modal de création rapide existant

## 🎯 Tests d'acceptation

### Test 1 : Création rapide (EventQuickCreateModal)

**Objectif** : Créer un évènement avec données minimales depuis le header

**Étapes** :
1. Ouvrir l'application (`http://localhost:5180/app`)
2. Dans le header, cliquer sur le bouton "Nouveau" du sélecteur d'évènements
3. Remplir :
   - Nom: "Demo 2026"
   - Date de début: 2026-08-15
   - Date de fin: 2026-08-16
   - Couleur: Bleu (défaut)
4. Cliquer sur "Créer l'évènement"

**Résultat attendu** :
- ✅ Évènement créé dans la table `events`
- ✅ `selected_event_id` dans localStorage
- ✅ Store mis à jour (`currentEvent`)
- ✅ Toast de succès
- ✅ Modal fermé
- ✅ Sélecteur d'évènements affiche "Demo 2026"

---

### Test 2 : Création avancée (EventForm - Mode création)

**Objectif** : Créer un évènement complet avec jours et scènes

**Étapes** :
1. Aller dans `/app/settings/events`
2. Cliquer sur "Ajouter un évènement"
3. **Section Informations générales** :
   - Nom: "Festival Test 2026"
   - Date début: 2026-08-15
   - Date fin: 2026-08-17
   - Couleur: #ef4444 (rouge)
   - Notes: "Évènement de test"
4. **Section Jours** :
   - Cliquer sur l'onglet "Jours"
   - Jour 1 :
     - Date: 2026-08-15
     - Ouverture: 11:00
     - Fermeture: 02:00 (règle minuit)
     - Jour de clôture: Non coché
   - Cliquer sur "+ Ajouter un jour"
   - Jour 2 :
     - Date: 2026-08-16
     - Ouverture: 11:00
     - Fermeture: 01:00
     - Jour de clôture: Oui (coché)
5. **Section Scènes** :
   - Cliquer sur l'onglet "Scènes"
   - Scène 1 :
     - Nom: "Main Stage"
     - Type: Principale
     - Capacité: 12000
   - Cliquer sur "+ Ajouter une scène"
   - Scène 2 :
     - Nom: "Club Stage"
     - Type: Secondaire
     - Capacité: 2500
6. Cliquer sur "Enregistrer"

**Résultat attendu** :
- ✅ Évènement créé dans `events` avec slug "festival-test-2026"
- ✅ 2 lignes dans `event_days` avec `display_order` 1 et 2
- ✅ 2 lignes dans `event_stages` avec `display_order` 1 et 2
- ✅ `selected_event_id` = nouvel ID
- ✅ Store mis à jour
- ✅ Toast de succès
- ✅ Modal fermé
- ✅ Liste des évènements rechargée

**Vérification DB** :
```sql
SELECT * FROM events WHERE name = 'Festival Test 2026';
-- Vérifier color_hex = #ef4444, notes = "Évènement de test"

SELECT * FROM event_days WHERE event_id = '<id>' ORDER BY display_order;
-- Vérifier 2 lignes, close_at < open_at pour jour 1

SELECT * FROM event_stages WHERE event_id = '<id>' ORDER BY display_order;
-- Vérifier capacités 12000 et 2500
```

---

### Test 3 : Édition d'évènement (EventForm - Mode édition)

**Objectif** : Modifier un évènement existant et ses enfants

**Étapes** :
1. Dans `/app/settings/events`, cliquer sur le bouton "Éditer" d'un évènement existant
2. **Informations générales** :
   - Changer couleur en #10b981 (vert)
   - Modifier notes
3. **Scènes** :
   - Cliquer sur "+ Ajouter une scène"
   - Nom: "Outdoor Stage"
   - Type: Autre
   - Capacité: 8000
4. Cliquer sur "Enregistrer"

**Résultat attendu** :
- ✅ `events.color_hex` mis à jour
- ✅ Anciennes scènes supprimées (delete)
- ✅ 3 nouvelles scènes insérées (display_order 1, 2, 3)
- ✅ Store rechargé avec nouvelles données
- ✅ Toast de succès

---

### Test 4 : Suppression d'évènement

**Objectif** : Supprimer un évènement et ses dépendances

**Étapes** :
1. Dans `/app/settings/events`, cliquer sur l'icône poubelle d'un évènement
2. Confirmer dans la popup

**Résultat attendu** :
- ✅ Évènement supprimé de `events`
- ✅ Jours et scènes supprimés (cascade ou explicite)
- ✅ Liste rechargée
- ✅ Toast de succès

---

### Test 5 : Règle minuit (non bloquante)

**Objectif** : Vérifier que `close_at < open_at` est autorisé

**Étapes** :
1. Créer ou éditer un évènement
2. Dans l'onglet "Jours", définir :
   - Ouverture: 11:00
   - Fermeture: 02:00
3. Enregistrer

**Résultat attendu** :
- ✅ Aucune erreur de validation
- ✅ `event_days.close_at` = '02:00:00'
- ✅ Helper text visible : "Si close_at < open_at, la journée se prolonge après minuit..."

---

### Test 6 : Gestion du companyId manquant

**Objectif** : Vérifier la protection si `companyId` est indéfini

**Étapes** :
1. Simuler un `companyId` vide (supprimer du localStorage)
2. Tenter d'ouvrir `/app/settings/events`
3. Cliquer sur "Ajouter un évènement"
4. Remplir et soumettre

**Résultat attendu** :
- ✅ Toast d'erreur : "Sélectionnez/chargez d'abord une entreprise"
- ✅ Aucun appel API
- ✅ Modal ne se ferme pas

---

### Test 7 : Évènement actuel dans Settings

**Objectif** : Afficher l'évènement actuel en haut de la page

**Étapes** :
1. Sélectionner un évènement via `EventSelector`
2. Aller dans `/app/settings/events`

**Résultat attendu** :
- ✅ Card avec bordure `border-primary-500`
- ✅ Badge "Évènement actuel"
- ✅ Couleur, nom, dates affichés
- ✅ Bouton "Éditer" fonctionnel

---

## 🔍 Vérifications techniques

### TypeScript
```bash
npx tsc --noEmit
```
✅ Aucune erreur de type

### Structure des données

**EventRow** :
```typescript
{
  id: string;
  company_id: string;
  name: string;
  slug: string;
  color_hex: string;
  start_date: string | null;
  end_date: string | null;
  notes: string | null;
  status: string;
  created_at: string;
  updated_at: string;
  logo_path: string | null;
}
```

**EventDayInput** :
```typescript
{
  date: string | null;
  open_at: string | null;  // HH:mm
  close_at: string | null;  // HH:mm
  is_closing_day: boolean;
  notes: string | null;
}
```

**EventStageInput** :
```typescript
{
  name: string;
  type: 'main' | 'secondary' | 'other';
  capacity: number | null;
  notes: string | null;
}
```

### Appels API

**replaceEventDays** :
1. `DELETE FROM event_days WHERE event_id = :id`
2. `INSERT INTO event_days (...) VALUES (...)`
3. `display_order` = index + 1

**replaceEventStages** :
1. `DELETE FROM event_stages WHERE event_id = :id`
2. `INSERT INTO event_stages (...) VALUES (...)`
3. `display_order` = index + 1

---

## 🐛 Points de vigilance

### 1. Slug RPC manquant
Si `generate_slug` RPC n'existe pas :
- ✅ Fallback sur `slugify()` client
- ✅ Aucune erreur bloquante

### 2. Champs vides → null
- `notes`, `start_date`, `end_date` : '' → null
- `open_at`, `close_at`, `capacity` : '' → null

### 3. Multi-tenant
Toujours passer `company_id` dans les inserts/updates.

### 4. État du store
Après création/édition :
1. `localStorage.setItem('selected_event_id', newId)`
2. `loadFullEvent(newId)`
3. `setCurrentEvent(full.event)`

### 5. Spinners/Disabled
Pendant `saving = true` :
- ✅ Boutons désactivés
- ✅ Inputs désactivés
- ✅ Spinner dans le bouton "Enregistrer"

---

## ✅ Checklist finale

- [ ] Test 1 : Création rapide (EventQuickCreateModal)
- [ ] Test 2 : Création avancée avec jours/scènes
- [ ] Test 3 : Édition d'évènement
- [ ] Test 4 : Suppression d'évènement
- [ ] Test 5 : Règle minuit (close_at < open_at)
- [ ] Test 6 : Gestion companyId manquant
- [ ] Test 7 : Affichage évènement actuel
- [ ] Vérification TypeScript (npx tsc --noEmit)
- [ ] Vérification DB (tables remplies correctement)
- [ ] Dark/Light mode OK
- [ ] Accessibilité (labels, placeholders)
- [ ] Toasts (succès/erreur)

---

## 📝 Notes supplémentaires

### Règle "après minuit"
**Contexte produit** : Un concert programmé le 15 août peut se jouer à 00:15 le 16 août, mais reste considéré comme un concert du 15 août.

**Implémentation** :
- `event_day_id` = jour du 15 août
- `performance_time` = '00:15'
- **Pas de décalage de date** dans `artist_performances`

**UI** :
- Timeline/Booking affichent la fenêtre du jour qui chevauche minuit (ex: 11:00 → 02:00)
- Snapping respecte cette règle
- EventForm autorise `close_at < open_at` sans validation bloquante

### Contacts clés (placeholder)
Dans `EventForm`, section "Informations générales" :
- Placeholder pour contacts clés (artist relations, technique, presse, direction artistique)
- Combobox non implémenté maintenant → à venir

---

## 🚀 Commandes utiles

```bash
# Démarrer le dev server
npm run dev

# Vérifier TypeScript
npx tsc --noEmit

# Ouvrir l'app
http://localhost:5180/app

# Page Settings Events
http://localhost:5180/app/settings/events
```

---

## 📧 Support

En cas de problème :
1. Vérifier la console navigateur (erreurs React/API)
2. Vérifier la console serveur (erreurs Supabase)
3. Vérifier les tables DB (données insérées correctement)
4. Vérifier `localStorage` (`selected_event_id`, `company_id`)

**Logs clés** :
```
✅ Évènement créé avec succès
❌ Erreur création évènement: ...
⚠️ EventSelector: companyId manquant
```


