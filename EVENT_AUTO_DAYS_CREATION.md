# ✅ Création automatique des jours d'événement

**Date** : 2025-10-28  
**Fichier** : `src/features/settings/events/EventForm.tsx`

---

## 🎯 Fonctionnalité

Lorsque l'utilisateur sélectionne les dates de début et fin d'un événement, les jours sont **automatiquement créés** avec des horaires par défaut adaptés aux festivals/événements.

---

## 📅 Principe des jours d'événement

### Règle importante

> **Un jour d'événement commence toujours à sa date, mais peut se terminer le lendemain**

### Exemple : Festival du 30 octobre au 1er novembre

```
🎪 Festival (30 oct → 1er nov)

J1 = 30 octobre
   📅 Date: 30/10/2026
   🕐 Ouverture: 17:00 (30 oct)
   🕒 Fermeture: 03:00 (31 oct) ← Le lendemain !
   
J2 = 31 octobre
   📅 Date: 31/10/2026
   🕐 Ouverture: 17:00 (31 oct)
   🕒 Fermeture: 03:00 (1er nov) ← Le lendemain !
   
J3 = 1er novembre
   📅 Date: 01/11/2026
   🕐 Ouverture: 17:00 (1er nov)
   🕒 Fermeture: 03:00 (2 nov) ← Le lendemain !
```

**Logique** :
- **Date du jour** : Détermine le jour festival (J1, J2, J3...)
- **Horaires** : L'événement peut se prolonger après minuit
- **Performances** : Une performance à 01:00 le 31 octobre appartient à **J1** (30 octobre)

---

## 🔧 Implémentation

### 1. Surveillance des dates

```typescript
// Surveiller les changements de start_date et end_date
const [startDate, endDate] = [
  control._formValues?.start_date,
  control._formValues?.end_date,
];

useEffect(() => {
  // Seulement en mode création (pas en édition)
  if (!editingEventId && startDate && endDate) {
    const start = new Date(startDate);
    const end = new Date(endDate);
    
    // Vérifier que end >= start
    if (end >= start) {
      // Générer les jours automatiquement
      const days = generateDays(start, end);
      setValue('days', days);
      
      // Basculer sur l'onglet "Jours"
      if (days.length > 0 && activeSection === 'info') {
        setActiveSection('days');
      }
    }
  }
}, [startDate, endDate, editingEventId, setValue]);
```

**Déclenchement** :
- ✅ Quand `start_date` change
- ✅ Quand `end_date` change
- ✅ Seulement en **mode création** (pas en édition)
- ✅ Seulement si `end_date >= start_date`

---

### 2. Génération des jours

```typescript
const days: EventDayInput[] = [];
let currentDate = new Date(start);

while (currentDate <= end) {
  days.push({
    date: currentDate.toISOString().split('T')[0],  // Format YYYY-MM-DD
    open_time: '17:00',                              // Ouverture 17h
    close_time: '03:00',                             // Fermeture 03h (lendemain)
    is_closing_day: currentDate.getTime() === end.getTime(),  // Dernier jour
    notes: '',
  });
  
  currentDate.setDate(currentDate.getDate() + 1);
}
```

**Propriétés** :
- `date` : Date du jour (YYYY-MM-DD)
- `open_time` : **17:00** par défaut (17h)
- `close_time` : **03:00** par défaut (3h du matin, le lendemain)
- `is_closing_day` : `true` pour le dernier jour uniquement
- `notes` : Vide par défaut

**Exemple** : 30/10 → 01/11 = **3 jours** créés

---

### 3. Indicateur visuel

#### Compteur dans colonne 3

```tsx
<div className="flex items-center justify-center">
  {startDate && endDate && !editingEventId ? (
    <div className="w-full px-2 py-1.5 rounded-lg bg-purple-500/10 border border-purple-500/20 text-center">
      <span className="text-xs font-medium" style={{ color: 'var(--color-primary)' }}>
        📅 3 jours
      </span>
    </div>
  ) : (
    <span className="text-xs text-gray-400">—</span>
  )}
</div>
```

**Affichage** :
- Badge violet avec emoji 📅
- Nombre de jours calculé en temps réel
- Visible uniquement en mode création

#### Message informatif

```tsx
{startDate && endDate && !editingEventId && daysFields.length > 0 && (
  <div className="px-3 py-2 rounded-lg bg-blue-500/10 border border-blue-500/20">
    <p className="text-xs text-blue-700 dark:text-blue-300">
      💡 <strong>3 jours</strong> créés automatiquement (17:00-03:00). 
      Chaque jour commence à sa date et peut se terminer le lendemain. 
      Consultez l'onglet "Jours" pour personnaliser les horaires.
    </p>
  </div>
)}
```

**Contenu** :
- Emoji 💡 pour l'information
- Nombre de jours en gras
- Explication des horaires par défaut
- Rappel de la règle (jour peut se terminer le lendemain)
- Invitation à personnaliser dans l'onglet "Jours"

---

## 🎨 Interface utilisateur

### Onglet "Informations générales"

```
┌─────────────────────────────────────────────────────────┐
│ Nom de l'évènement                                      │
│ [Festival 2026                                     ]    │
│                                                         │
│ Date de début      Date de fin         📅 3 jours      │
│ [30/10/2026]      [01/11/2026]                         │
│                                                         │
│ ┌───────────────────────────────────────────────────┐  │
│ │ 💡 3 jours créés automatiquement (17:00-03:00).   │  │
│ │ Chaque jour commence à sa date et peut se         │  │
│ │ terminer le lendemain. Consultez l'onglet         │  │
│ │ "Jours" pour personnaliser les horaires.          │  │
│ └───────────────────────────────────────────────────┘  │
│                                                         │
│ Notes                                                   │
│ [Notes internes...                                 ]    │
└─────────────────────────────────────────────────────────┘
```

### Onglet "Jours" (généré automatiquement)

```
┌─────────────────────────────────────────────────────────┐
│ [Info] [Jours (3)] [Scènes (1)]                        │
├─────────────────────────────────────────────────────────┤
│ 💡 Si close_time < open_time, la journée se prolonge   │
│    après minuit. Les performances après 00:00 restent   │
│    rattachées à ce jour.                                │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐│
│ │ Jour 1 - 30/10/2026                                 ││
│ │ Ouverture: 17:00  Fermeture: 03:00                  ││
│ │ □ Jour de clôture                                    ││
│ └─────────────────────────────────────────────────────┘│
│                                                         │
│ ┌─────────────────────────────────────────────────────┐│
│ │ Jour 2 - 31/10/2026                                 ││
│ │ Ouverture: 17:00  Fermeture: 03:00                  ││
│ │ □ Jour de clôture                                    ││
│ └─────────────────────────────────────────────────────┘│
│                                                         │
│ ┌─────────────────────────────────────────────────────┐│
│ │ Jour 3 - 01/11/2026                                 ││
│ │ Ouverture: 17:00  Fermeture: 03:00                  ││
│ │ ☑ Jour de clôture                                    ││
│ └─────────────────────────────────────────────────────┘│
│                                                         │
│ [+ Ajouter un jour]                                     │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Flux utilisateur

### Scénario nominal

1. **Ouvrir** le modal "Créer un évènement"
2. **Saisir** le nom : "Festival 2026"
3. **Sélectionner** date de début : 30 octobre 2026
4. **Sélectionner** date de fin : 1er novembre 2026
5. **Observer** :
   - Badge "📅 3 jours" apparaît
   - Message bleu informatif s'affiche
   - Bascule automatique vers l'onglet "Jours"
6. **Voir** dans l'onglet "Jours" :
   - J1 : 30/10 (17:00-03:00)
   - J2 : 31/10 (17:00-03:00)
   - J3 : 01/11 (17:00-03:00, dernier jour)
7. **Personnaliser** les horaires si nécessaire
8. **Enregistrer**

### Scénario édition

1. **Ouvrir** un évènement existant en édition
2. **Observer** : Les jours **ne sont PAS régénérés**
3. **Modifier** manuellement dans l'onglet "Jours" si nécessaire
4. **Enregistrer**

---

## ⚙️ Paramètres par défaut

| Paramètre | Valeur | Raison |
|-----------|--------|--------|
| **open_time** | 17:00 | Heure d'ouverture typique pour festivals |
| **close_time** | 03:00 | Heure de fermeture typique (après minuit) |
| **is_closing_day** | `true` pour dernier jour | Identifie le jour de clôture |

### Pourquoi 17:00-03:00 ?

- **17:00** : Heure d'ouverture standard pour festivals (portes ouvertes en fin d'après-midi)
- **03:00** : Fermeture à 3h du matin (le lendemain), permettant performances nocturnes
- **10 heures** de durée effective par jour

---

## 📊 Exemples

### Festival 1 jour

**Dates** : 15/06/2026 → 15/06/2026

```
J1 = 15 juin 2026
   📅 Date: 15/06/2026
   🕐 17:00 → 03:00 (16/06)
   ☑ Jour de clôture
```

**Résultat** : 1 jour créé

### Festival 3 jours (weekend)

**Dates** : 20/06/2026 → 22/06/2026

```
J1 = 20 juin 2026 (vendredi)
   📅 Date: 20/06/2026
   🕐 17:00 → 03:00 (21/06)
   
J2 = 21 juin 2026 (samedi)
   📅 Date: 21/06/2026
   🕐 17:00 → 03:00 (22/06)
   
J3 = 22 juin 2026 (dimanche)
   📅 Date: 22/06/2026
   🕐 17:00 → 03:00 (23/06)
   ☑ Jour de clôture
```

**Résultat** : 3 jours créés

### Festival 7 jours

**Dates** : 01/07/2026 → 07/07/2026

**Résultat** : 7 jours créés (J1 à J7)

---

## 🎯 Avantages

### 1. Gain de temps

- ✅ **Pas de saisie manuelle** des jours
- ✅ **Génération instantanée** dès sélection des dates
- ✅ **Horaires cohérents** par défaut

### 2. Cohérence

- ✅ **Horaires identiques** pour tous les jours
- ✅ **Convention respectée** (17:00-03:00)
- ✅ **Dernier jour marqué** automatiquement

### 3. Flexibilité

- ✅ **Personnalisation** possible dans l'onglet "Jours"
- ✅ **Ajout/suppression** de jours manuellement
- ✅ **Modification** des horaires individuellement

### 4. Pédagogie

- ✅ **Message explicatif** sur la règle du lendemain
- ✅ **Bascule automatique** vers l'onglet "Jours"
- ✅ **Compteur visuel** du nombre de jours

---

## 🧪 Tests de validation

### Test 1 : Création automatique

1. **Créer** un nouvel événement
2. **Sélectionner** : 30/10/2026 → 01/11/2026
3. **Vérifier** :
   - Badge "📅 3 jours" visible
   - Message informatif affiché
   - Bascule vers onglet "Jours"
4. **Observer** dans onglet "Jours" :
   - 3 jours créés
   - Dates : 30/10, 31/10, 01/11
   - Horaires : 17:00-03:00 pour tous
   - Dernier jour coché "Jour de clôture"

### Test 2 : Calcul nombre de jours

| Date début | Date fin | Jours attendus |
|------------|----------|----------------|
| 15/06/2026 | 15/06/2026 | 1 jour |
| 15/06/2026 | 16/06/2026 | 2 jours |
| 30/10/2026 | 01/11/2026 | 3 jours |
| 01/07/2026 | 07/07/2026 | 7 jours |

**Vérifier** : Badge et liste affichent le bon nombre

### Test 3 : Édition ne régénère pas

1. **Éditer** un événement existant
2. **Observer** : Jours actuels conservés
3. **Modifier** les dates
4. **Vérifier** : Jours **pas régénérés** automatiquement

### Test 4 : Personnalisation

1. **Créer** un événement (jours générés)
2. **Aller** dans onglet "Jours"
3. **Modifier** J1 : 18:00-04:00
4. **Modifier** J2 : 16:00-02:00
5. **Enregistrer**
6. **Vérifier** : Horaires personnalisés sauvegardés

### Test 5 : Validation dates

1. **Sélectionner** date début : 01/11/2026
2. **Sélectionner** date fin : 30/10/2026 (avant début)
3. **Vérifier** : Pas de jours créés (validation)

---

## 📝 Règles métier

### Règle 1 : Date de début vs Date de fermeture

```
Date du jour (date):     30/10/2026
Heure ouverture:         17:00  (30/10 à 17h)
Heure fermeture:         03:00  (31/10 à 3h)

→ Un jour peut durer jusqu'à 34 heures théoriques
→ Performances entre 00:00 et 03:00 le 31/10 appartiennent à J1 (30/10)
```

### Règle 2 : Jour de clôture

```
is_closing_day = true   →  Dernier jour de l'événement
is_closing_day = false  →  Jour intermédiaire
```

**Usage** :
- Affichage différencié dans la timeline
- Logique de nettoyage / démontage
- Reporting / statistiques

### Règle 3 : Mode création vs édition

```
Mode CRÉATION   →  Jours générés automatiquement
Mode ÉDITION    →  Jours conservés, pas de régénération
```

**Raison** : Éviter d'écraser les personnalisations de l'utilisateur

---

## ✅ Résumé

### Fonctionnalité

- ✅ **Génération automatique** des jours dès sélection des dates
- ✅ **Horaires par défaut** : 17:00-03:00 (adaptés aux festivals)
- ✅ **Compteur visuel** : Badge violet avec nombre de jours
- ✅ **Message informatif** : Explication de la règle du lendemain
- ✅ **Bascule automatique** vers l'onglet "Jours"

### Comportement

- ✅ **Mode création** : Génération automatique
- ✅ **Mode édition** : Conservation des jours existants
- ✅ **Validation** : Vérifie que `end_date >= start_date`
- ✅ **Personnalisation** : Modification manuelle possible

### Exemple

**Festival du 30 octobre au 1er novembre** :
- 📅 **3 jours** créés automatiquement
- 🕐 **17:00-03:00** pour chaque jour
- ☑ **Dernier jour** (01/11) marqué comme clôture
- 💡 Chaque jour peut se terminer le lendemain

**Rechargez et testez la création d'un événement !** 🎉


