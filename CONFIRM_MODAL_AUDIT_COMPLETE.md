# Audit complet : Remplacement de confirm() par ConfirmDeleteModal

## 🎯 Objectif
Remplacer toutes les utilisations de `window.confirm()` (modal natif du navigateur) par le composant AURA `ConfirmDeleteModal` pour une expérience utilisateur cohérente.

---

## 📊 Résultat de l'audit

### Fichiers concernés

| Fichier | Type d'action | Statut |
|---------|---------------|--------|
| `SettingsEventsPage.tsx` | Suppression d'événement | ✅ Corrigé |
| `LineupTimelinePage.tsx` | Suppression de performance | ✅ Corrigé |
| `BookingPage.tsx` | Suppression d'offre | ✅ Corrigé (ajout confirmation) |
| `StageEnumsManager.tsx` | Initialisation des enums | ✅ Corrigé |
| **StageEnumsManager.tsx** | Suppression types/specs | ✅ **Déjà OK** |
| **artistes/index.tsx** | Suppression d'artiste | ✅ **Déjà OK** |

---

## 🔧 Corrections effectuées

### 1. **SettingsEventsPage.tsx** - Suppression d'événement

#### ❌ Avant
```typescript
const handleDeleteEvent = async (eventId: string, eventName: string) => {
  if (!confirm(`Êtes-vous sûr de vouloir supprimer l'évènement "${eventName}" ? Cette action est irréversible.`)) {
    return;
  }
  // ... suppression
};
```

#### ✅ Après
```typescript
// États ajoutés
const [deletingEvent, setDeletingEvent] = useState<{ id: string; name: string } | null>(null);
const [deleting, setDeleting] = useState(false);

// Handler modifié
const handleDeleteEvent = (eventId: string, eventName: string) => {
  setDeletingEvent({ id: eventId, name: eventName });
};

const handleConfirmDelete = async () => {
  if (!deletingEvent) return;
  setDeleting(true);
  try {
    await deleteEvent(deletingEvent.id);
    toastSuccess(`Évènement "${deletingEvent.name}" supprimé avec succès`);
    loadEvents();
    setDeletingEvent(null);
  } catch (err: any) {
    toastError(err.message || 'Erreur lors de la suppression');
  } finally {
    setDeleting(false);
  }
};

// Modal ajouté dans le JSX
<ConfirmDeleteModal
  isOpen={!!deletingEvent}
  onClose={() => setDeletingEvent(null)}
  onConfirm={handleConfirmDelete}
  title="Supprimer l'évènement"
  message="Êtes-vous sûr de vouloir supprimer cet évènement ?"
  itemName={deletingEvent?.name}
  loading={deleting}
/>
```

---

### 2. **LineupTimelinePage.tsx** - Suppression de performance

#### ❌ Avant
```typescript
const handleCardDelete = async (performance: Performance) => {
  if (!confirm(`Supprimer la performance de ${performance.artist_name} ?`)) return;
  // ... suppression
};
```

#### ✅ Après
```typescript
// États ajoutés
const [deletingPerformance, setDeletingPerformance] = useState<Performance | null>(null);
const [deleting, setDeleting] = useState(false);

// Handler modifié
const handleCardDelete = (performance: Performance) => {
  setDeletingPerformance(performance);
};

const handleConfirmDeletePerformance = async () => {
  if (!deletingPerformance) return;
  setDeleting(true);
  try {
    if (demoMode) {
      setPerformances(prev => prev.filter(p => p.id !== deletingPerformance.id));
      toastSuccess("Performance supprimée (démo)");
    } else {
      await deletePerformance(deletingPerformance.id);
      await loadData();
      toastSuccess("Performance supprimée");
    }
    setDeletingPerformance(null);
  } catch (error: any) {
    toastError(error?.message || "Erreur de suppression");
  } finally {
    setDeleting(false);
  }
};

// Modal ajouté dans le JSX
<ConfirmDeleteModal
  isOpen={!!deletingPerformance}
  onClose={() => setDeletingPerformance(null)}
  onConfirm={handleConfirmDeletePerformance}
  title="Supprimer la performance"
  message="Êtes-vous sûr de vouloir supprimer cette performance ?"
  itemName={deletingPerformance?.artist_name}
  loading={deleting}
/>
```

---

### 3. **BookingPage.tsx** - Suppression d'offre

#### ❌ Avant (AUCUNE CONFIRMATION !)
```typescript
async function handleDelete(offerId: string) {
  try {
    await deleteOffer(offerId);
    setOffers((prev) => prev.filter((o) => o.id !== offerId));
    toastSuccess("Offre supprimée");
  } catch (e:any) {
    toastError(e?.message || "Erreur suppression");
  }
}
```

#### ✅ Après (CONFIRMATION AJOUTÉE)
```typescript
// États ajoutés
const [deletingOffer, setDeletingOffer] = useState<Offer | null>(null);
const [deleting, setDeleting] = useState(false);

// Handler modifié
function handleDelete(offerId: string) {
  const offer = offers.find(o => o.id === offerId);
  if (offer) {
    setDeletingOffer(offer);
  }
}

async function handleConfirmDeleteOffer() {
  if (!deletingOffer) return;
  setDeleting(true);
  try {
    if (demoMode) {
      setOffers(prev => prev.filter(o => o.id !== deletingOffer.id));
      toastSuccess("Offre supprimée (démo)");
    } else {
      await deleteOffer(deletingOffer.id);
      setOffers((prev) => prev.filter((o) => o.id !== deletingOffer.id));
      toastSuccess("Offre supprimée");
    }
    setDeletingOffer(null);
  } catch (e:any) {
    toastError(e?.message || "Erreur suppression");
  } finally {
    setDeleting(false);
  }
}

// Modal ajouté dans le JSX
<ConfirmDeleteModal
  isOpen={!!deletingOffer}
  onClose={() => setDeletingOffer(null)}
  onConfirm={handleConfirmDeleteOffer}
  title="Supprimer l'offre"
  message="Êtes-vous sûr de vouloir supprimer cette offre ?"
  itemName={deletingOffer?.artist_name}
  loading={deleting}
/>
```

---

### 4. **StageEnumsManager.tsx** - Initialisation des valeurs par défaut

#### ❌ Avant
```typescript
const handleInitialize = async () => {
  if (!confirm('Voulez-vous initialiser les valeurs par défaut ? (Cela ne créera pas de doublons)')) {
    return;
  }
  // ... initialisation
};
```

#### ✅ Après
```typescript
// États ajoutés
const [showInitModal, setShowInitModal] = useState(false);
const [initializing, setInitializing] = useState(false);

// Handler modifié
const handleInitialize = () => {
  setShowInitModal(true);
};

const handleConfirmInitialize = async () => {
  setInitializing(true);
  try {
    await initializeStageEnumsForCompany(companyId);
    toastSuccess('Valeurs par défaut initialisées');
    loadData();
    setShowInitModal(false);
  } catch (err: any) {
    toastError(err.message || 'Erreur lors de l\'initialisation');
  } finally {
    setInitializing(false);
  }
};

// Modal ajouté dans le JSX
<ConfirmDeleteModal
  isOpen={showInitModal}
  onClose={() => setShowInitModal(false)}
  onConfirm={handleConfirmInitialize}
  title="Initialiser les valeurs par défaut"
  message="Voulez-vous initialiser les valeurs par défaut ? Cela ne créera pas de doublons."
  itemName=""
  loading={initializing}
/>
```

---

## 📋 Modèle de code pour futures implémentations

### Pattern standard pour une suppression avec ConfirmDeleteModal

```typescript
// 1. Importer le composant
import { ConfirmDeleteModal } from '@/components/ui/ConfirmDeleteModal';

// 2. Ajouter les états
const [deletingItem, setDeletingItem] = useState<YourType | null>(null);
const [deleting, setDeleting] = useState(false);

// 3. Handler qui ouvre le modal
const handleDelete = (item: YourType) => {
  setDeletingItem(item);
};

// 4. Handler qui confirme la suppression
const handleConfirmDelete = async () => {
  if (!deletingItem) return;
  
  setDeleting(true);
  try {
    await deleteItemApi(deletingItem.id);
    toastSuccess("Item supprimé avec succès");
    refreshData();
    setDeletingItem(null);
  } catch (error: any) {
    toastError(error?.message || "Erreur lors de la suppression");
  } finally {
    setDeleting(false);
  }
};

// 5. Ajouter le modal dans le JSX
<ConfirmDeleteModal
  isOpen={!!deletingItem}
  onClose={() => setDeletingItem(null)}
  onConfirm={handleConfirmDelete}
  title="Supprimer l'élément"
  message="Êtes-vous sûr de vouloir supprimer cet élément ?"
  itemName={deletingItem?.name}
  loading={deleting}
/>
```

---

## ✅ Avantages du ConfirmDeleteModal AURA

| Aspect | `confirm()` natif | `ConfirmDeleteModal` AURA |
|--------|-------------------|---------------------------|
| **Design** | Varie selon navigateur | Cohérent avec design AURA |
| **Dark mode** | ❌ Non supporté | ✅ Supporté |
| **Personnalisation** | ❌ Impossible | ✅ Messages personnalisables |
| **Loading state** | ❌ Non supporté | ✅ Spinner pendant suppression |
| **Icône warning** | ❌ Basique | ✅ Icône ⚠️ visuelle |
| **Responsive** | ❌ Basique | ✅ Adapté mobile/desktop |
| **Toasts** | ❌ Indépendant | ✅ Intégré avec ToastProvider |
| **Z-index** | ❌ Peut être caché | ✅ Toujours au-dessus |

---

## 🧪 Tests à effectuer

### Test 1 : Suppression d'événement
1. Aller sur `/app/settings/events`
2. Cliquer sur le bouton "🗑️" d'un événement
3. ✅ Le modal AURA s'ouvre (pas le confirm natif)
4. ✅ Le nom de l'événement est affiché
5. ✅ Boutons "Annuler" (gris) et "Supprimer" (rouge)
6. Cliquer sur "Supprimer"
7. ✅ Le bouton affiche un spinner
8. ✅ Toast vert "Événement supprimé avec succès"
9. ✅ L'événement disparaît de la liste

### Test 2 : Suppression de performance
1. Aller sur `/app/lineup-timeline`
2. Cliquer sur le bouton de suppression d'une performance
3. ✅ Le modal AURA s'ouvre
4. ✅ Le nom de l'artiste est affiché
5. Tester l'annulation
6. ✅ Le modal se ferme sans suppression
7. Retester et confirmer
8. ✅ Toast vert "Performance supprimée"

### Test 3 : Suppression d'offre (NOUVEAU)
1. Aller sur `/app/booking`
2. Cliquer sur "Supprimer" pour une offre
3. ✅ **Le modal AURA s'ouvre maintenant** (avant : suppression directe)
4. ✅ Le nom de l'artiste est affiché
5. Confirmer
6. ✅ Toast vert "Offre supprimée"

### Test 4 : Initialisation des enums
1. Aller sur `/app/settings/events`
2. Scroller jusqu'à "Configuration des scènes"
3. Cliquer sur "Initialiser les valeurs par défaut"
4. ✅ Le modal AURA s'ouvre (pas le confirm natif)
5. ✅ Message "Voulez-vous initialiser..." affiché
6. Confirmer
7. ✅ Toast vert "Valeurs par défaut initialisées"

---

## 📈 Impact

### Sécurité
- ✅ **BookingPage** : Ajout d'une confirmation avant suppression d'offre (protection contre suppression accidentelle)
- ✅ **Toutes les pages** : Messages d'avertissement clairs avec icône ⚠️

### UX
- ✅ Design cohérent dans toute l'application
- ✅ Support dark/light mode
- ✅ Feedback visuel (spinner pendant suppression)
- ✅ Noms des éléments affichés clairement
- ✅ Toasts z-index: 9999 (toujours visibles)

### Maintenance
- ✅ Code réutilisable (`ConfirmDeleteModal`)
- ✅ Pattern standard documenté
- ✅ Facile à étendre pour nouvelles fonctionnalités

---

## 📝 Fichiers modifiés

1. `src/pages/settings/SettingsEventsPage.tsx`
2. `src/pages/LineupTimelinePage.tsx`
3. `src/pages/BookingPage.tsx`
4. `src/features/settings/events/StageEnumsManager.tsx`

**Aucun fichier créé** : Réutilisation du composant `ConfirmDeleteModal` existant.

---

**Date d'audit** : 30 octobre 2025  
**Status** : ✅ Tous les `confirm()` natifs remplacés  
**Prêt pour tests** : Oui


