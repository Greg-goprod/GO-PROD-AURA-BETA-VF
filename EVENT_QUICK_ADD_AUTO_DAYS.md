# ✅ Modal "Créer un évènement" - Création automatique des jours

**Date** : 2025-10-28  
**Fichier** : `src/features/settings/events/EventQuickAddModal.tsx`

---

## 🎯 Fonctionnalités ajoutées

### 1. Validation des dates

**Règle** : La date de fin ne peut **pas** être avant la date de début

#### Validation en temps réel

```typescript
useEffect(() => {
  if (formData.start_date && formData.end_date) {
    if (formData.end_date < formData.start_date) {
      setErrors((prev) => ({ 
        ...prev, 
        end_date: 'La date de fin ne peut pas être avant la date de début' 
      }));
    } else {
      setErrors((prev) => ({ ...prev, end_date: '' }));
    }
  }
}, [formData.start_date, formData.end_date]);
```

**Comportement** :
- ✅ Vérification **immédiate** dès que les deux dates sont sélectionnées
- ✅ Message d'erreur **rouge** sous le champ "Date de fin"
- ✅ Validation aussi au moment du clic "Créer"

---

### 2. Calcul automatique du nombre de jours

```typescript
const calculateDaysCount = () => {
  if (!formData.start_date || !formData.end_date) return 0;
  const start = new Date(formData.start_date);
  const end = new Date(formData.end_date);
  const diffTime = end.getTime() - start.getTime();
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1; // +1 pour inclure le jour de fin
  return diffDays > 0 ? diffDays : 0;
};
```

**Logique** :
- Calcul de la **différence en millisecondes**
- Conversion en **jours** (arrondi au supérieur)
- **+1** pour inclure le jour de fin (ex: du 15 au 17 = 3 jours, pas 2)
- Retourne **0** si les dates ne sont pas valides

**Exemples** :
| Date début | Date fin | Jours calculés |
|------------|----------|----------------|
| 15/06/2026 | 15/06/2026 | 1 jour |
| 15/06/2026 | 16/06/2026 | 2 jours |
| 15/06/2026 | 17/06/2026 | 3 jours |

---

### 3. Indicateur visuel du nombre de jours

```tsx
{daysCount > 0 && (
  <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-purple-500/10 border border-purple-500/20">
    <span className="text-sm font-medium" style={{ color: 'var(--color-primary)' }}>
      📅 {daysCount} jour{daysCount > 1 ? 's' : ''} {daysCount > 1 ? 'seront créés' : 'sera créé'} automatiquement
    </span>
  </div>
)}
```

**Affichage** :
- ✅ Apparaît **sous les champs de dates** dès que les deux sont sélectionnées
- ✅ Badge **violet** avec bordure
- ✅ Emoji **📅** pour visibilité
- ✅ Texte adapté : "1 jour sera créé" ou "3 jours seront créés"
- ✅ Couleur : `var(--color-primary)` (violet AURA)

**Exemple visuel** :
```
┌─────────────────────────────────────────────────────────┐
│ 📅 3 jours seront créés automatiquement                 │
└─────────────────────────────────────────────────────────┘
```

---

### 4. Création automatique des jours

```typescript
if (formData.start_date && formData.end_date) {
  const days = [];
  const start = new Date(formData.start_date);
  const end = new Date(formData.end_date);
  
  let currentDate = new Date(start);
  let dayIndex = 1;
  
  while (currentDate <= end) {
    days.push({
      event_id: newId,
      date: currentDate.toISOString().split('T')[0],
      display_order: dayIndex,
      open_at: '11:00',
      close_at: '02:00',
      is_closing_day: currentDate.getTime() === end.getTime(),
      notes: null,
    });
    
    currentDate.setDate(currentDate.getDate() + 1);
    dayIndex++;
  }
  
  await replaceEventDays(newId, days);
}
```

**Logique** :
1. **Itération** : De la date de début à la date de fin (inclusif)
2. **Création** : Un objet jour par date
3. **Propriétés** :
   - `date` : Format ISO `YYYY-MM-DD`
   - `display_order` : Index séquentiel (1, 2, 3...)
   - `open_at` : **11:00** par défaut
   - `close_at` : **02:00** par défaut
   - `is_closing_day` : `true` pour le **dernier jour**
   - `notes` : `null`
4. **Insertion** : Appel à `replaceEventDays()` pour créer tous les jours en une fois

**Exemple** : Évènement du 15 au 17 juin 2026

```javascript
[
  {
    event_id: "uuid-event",
    date: "2026-06-15",
    display_order: 1,
    open_at: "11:00",
    close_at: "02:00",
    is_closing_day: false,
    notes: null
  },
  {
    event_id: "uuid-event",
    date: "2026-06-16",
    display_order: 2,
    open_at: "11:00",
    close_at: "02:00",
    is_closing_day: false,
    notes: null
  },
  {
    event_id: "uuid-event",
    date: "2026-06-17",
    display_order: 3,
    open_at: "11:00",
    close_at: "02:00",
    is_closing_day: true,  // ← Dernier jour
    notes: null
  }
]
```

---

### 5. Toast amélioré avec nombre de jours

```typescript
if (formData.start_date && formData.end_date) {
  // ... création des jours ...
  toastSuccess(`Évènement "${formData.name}" créé avec ${days.length} jour${days.length > 1 ? 's' : ''}`);
} else {
  toastSuccess(`Évènement "${formData.name}" créé avec succès`);
}
```

**Messages** :
- **Avec dates** : "Évènement 'Festival 2026' créé avec 3 jours"
- **Sans dates** : "Évènement 'Festival 2026' créé avec succès"

---

### 6. Message d'info adaptatif

```tsx
<p className="text-sm text-gray-500 dark:text-gray-400">
  {daysCount > 0 
    ? `Les jours seront créés automatiquement avec les horaires par défaut (11:00-02:00).` 
    : `Vous pourrez ajouter les jours et scènes dans les paramètres avancés.`}
</p>
```

**Affichage** :
- **Avec dates** : "Les jours seront créés automatiquement avec les horaires par défaut (11:00-02:00)."
- **Sans dates** : "Vous pourrez ajouter les jours et scènes dans les paramètres avancés."

---

## 🎨 Interface utilisateur

### Layout du formulaire

```
┌────────────────────────────────────────────────────────┐
│ Nom de l'évènement *                                   │
│ [Festival 2026                        ]                │
├────────────────────────────────────────────────────────┤
│ Date de début          │ Date de fin                   │
│ [15 juin 2026     ]    │ [17 juin 2026     ]           │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 📅 3 jours seront créés automatiquement         │   │
│ └─────────────────────────────────────────────────┘   │
├────────────────────────────────────────────────────────┤
│ Couleur                                                │
│ [🎨] [#3b82f6                       ]                  │
├────────────────────────────────────────────────────────┤
│ Les jours seront créés automatiquement avec les        │
│ horaires par défaut (11:00-02:00).                     │
└────────────────────────────────────────────────────────┘
[Annuler]                                   [+ Créer]
```

---

## 🔄 Flux utilisateur

### Scénario nominal

1. **Ouvrir** le modal "Créer un évènement"
2. **Saisir** le nom : "Festival 2026"
3. **Sélectionner** date de début : 15 juin 2026
4. **Sélectionner** date de fin : 17 juin 2026
5. **Observer** : Badge "📅 3 jours seront créés automatiquement"
6. **Observer** : Message "Les jours seront créés automatiquement..."
7. **Cliquer** "Créer"
8. **Résultat** :
   - Évènement créé
   - 3 jours créés automatiquement (15, 16, 17 juin)
   - Toast : "Évènement 'Festival 2026' créé avec 3 jours"
   - Store mis à jour
   - Modal fermé

### Scénario avec erreur de date

1. **Sélectionner** date de début : 17 juin 2026
2. **Sélectionner** date de fin : 15 juin 2026
3. **Observer** : Message d'erreur rouge sous "Date de fin"
4. **Observer** : Pas de badge de comptage (dates invalides)
5. **Cliquer** "Créer" → **Bloqué** par validation

### Scénario sans dates

1. **Saisir** le nom uniquement
2. **Ne pas** sélectionner de dates
3. **Cliquer** "Créer"
4. **Résultat** :
   - Évènement créé **sans jours**
   - Toast : "Évènement 'Festival 2026' créé avec succès"
   - Jours à ajouter manuellement plus tard

---

## 🧪 Tests de validation

### Test 1 : Validation date de fin < date de début

1. **Date début** : 20/06/2026
2. **Date fin** : 18/06/2026
3. **Vérifier** : Message d'erreur "La date de fin ne peut pas être avant la date de début"
4. **Vérifier** : Badge compteur **pas affiché**
5. **Vérifier** : Bouton "Créer" **bloqué** par validation

### Test 2 : Calcul nombre de jours

| Date début | Date fin | Attendu |
|------------|----------|---------|
| 15/06/2026 | 15/06/2026 | 1 jour |
| 15/06/2026 | 16/06/2026 | 2 jours |
| 15/06/2026 | 17/06/2026 | 3 jours |
| 15/06/2026 | 21/06/2026 | 7 jours |

**Vérifier** : Badge affiche le bon nombre

### Test 3 : Création automatique des jours

1. **Créer** un évènement du 15 au 17 juin 2026
2. **Vérifier** en base de données :
   - 3 lignes dans `event_days`
   - Dates : 2026-06-15, 2026-06-16, 2026-06-17
   - `display_order` : 1, 2, 3
   - `open_at` : 11:00 pour tous
   - `close_at` : 02:00 pour tous
   - `is_closing_day` : `false`, `false`, `true`

### Test 4 : Toast avec nombre de jours

1. **Créer** avec dates → **Vérifier** : "créé avec N jour(s)"
2. **Créer** sans dates → **Vérifier** : "créé avec succès"

### Test 5 : Message info adaptatif

1. **Avec dates** → **Vérifier** : "Les jours seront créés automatiquement..."
2. **Sans dates** → **Vérifier** : "Vous pourrez ajouter les jours..."

---

## 📊 Propriétés par défaut des jours

| Propriété | Valeur par défaut | Modifiable après ? |
|-----------|-------------------|-------------------|
| `date` | Date calculée | ❌ Non (via événement) |
| `display_order` | Séquentiel (1, 2, 3...) | ✅ Oui (dans EventForm) |
| `open_at` | **11:00** | ✅ Oui (dans EventForm) |
| `close_at` | **02:00** | ✅ Oui (dans EventForm) |
| `is_closing_day` | `true` pour dernier jour | ✅ Oui (dans EventForm) |
| `notes` | `null` | ✅ Oui (dans EventForm) |

---

## 🔧 Améliorations futures possibles

### Phase 2

- [ ] **Personnaliser les horaires par défaut** (dans les paramètres)
- [ ] **Prévisualisation** des jours avant création (modal avec liste)
- [ ] **Modification** des horaires par défaut dans le modal
- [ ] **Copie** d'horaires d'un évènement précédent

### Phase 3

- [ ] **Templates d'évènements** (ex: "Festival 3 jours", "Concert 1 soir")
- [ ] **Import** de dates depuis un fichier externe
- [ ] **Synchronisation** avec calendrier externe (iCal, Google Calendar)

---

## ✅ Résumé

### Fonctionnalités ajoutées

- ✅ **Validation** : Date de fin ≥ Date de début
- ✅ **Calcul automatique** : Nombre de jours entre deux dates
- ✅ **Indicateur visuel** : Badge violet avec compteur
- ✅ **Création automatique** : Jours créés avec horaires par défaut
- ✅ **Toast amélioré** : Affiche le nombre de jours créés
- ✅ **Message adaptatif** : Info différente selon présence de dates

### Bénéfices utilisateur

- 🚀 **Gain de temps** : Plus besoin de créer les jours manuellement
- ✅ **Moins d'erreurs** : Validation automatique des dates
- 👁️ **Visibilité** : Indication claire du nombre de jours
- 🎯 **Cohérence** : Horaires par défaut uniformes (11:00-02:00)

---

**La création d'évènements est maintenant intelligente et automatisée !** 🎉


