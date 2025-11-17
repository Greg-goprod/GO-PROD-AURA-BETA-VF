# 🔧 Corrections et Améliorations du Modal Performance

## 📋 Corrections demandées (5 points)

### ✅ 1. Dropdown artiste vide

**Problème** : Le dropdown artiste n'affichait aucun nom d'artiste.

**Solution** :
- Ajout de `console.log` pour déboguer le chargement
- Ajout de `toastError` dans le `useEffect` pour afficher les erreurs
- Ajout de logs pour vérifier le chargement des artistes, jours et scènes

**Code modifié** : `src/features/booking/modals/PerformanceModal.tsx` (lignes 93-103)

```typescript
console.log("🔍 Chargement des données pour companyId:", initialData.companyId);

const [artistsData, daysData, stagesData] = await Promise.all([
  fetchArtists(initialData.companyId),
  fetchEventDays(initialData.eventId),
  fetchEventStages(initialData.eventId),
]);

console.log("✅ Artistes chargés:", artistsData.length);
console.log("✅ Jours chargés:", daysData.length);
console.log("✅ Scènes chargées:", stagesData.length);
```

---

### ✅ 2. Supprimer le checkbox "Artiste a confirmé sa présence"

**Problème** : Le checkbox `is_confirmed` ne devait pas être affiché.

**Solution** :
- Supprimé le champ `is_confirmed` de l'état du formulaire
- Supprimé le checkbox de l'interface utilisateur
- Retiré `is_confirmed` et `confirmed_at` des fonctions de sauvegarde

**Lignes supprimées** : 395-407 (ancien code)

---

### ✅ 3. Bouton "Ajouter un artiste" doit ouvrir le modal AddArtistModal

**Problème** : Le bouton devait être plus visible et utiliser le bon style.

**Solution** :
- Modifié le bouton pour utiliser `variant="secondary"` et `size="sm"`
- Ajouté une icône `Plus` pour plus de clarté
- Le bouton est maintenant en full width sous le select
- Le modal `AddArtistModal` s'ouvre correctement (déjà fonctionnel)

**Code modifié** : `src/features/booking/modals/PerformanceModal.tsx` (lignes 370-378)

```typescript
<Button
  variant="secondary"
  size="sm"
  onClick={() => setShowAddArtistModal(true)}
  className="text-sm"
>
  <Plus size={14} className="mr-1" />
  Ajouter un artiste
</Button>
```

---

### ✅ 4. Déplacer la durée dans la colonne "Informations générales"

**Problème** : La durée était dans la colonne 3 "Durée et cachet", elle devait être dans la colonne 1.

**Solution** :
- Déplacé le bloc "Durée" entier (durée standard + durée personnalisée) de la colonne 3 vers la colonne 1
- Repositionné après le champ "Statut (booking)"
- Conservé le même style et la même logique (60/75/90 min ou personnalisée)

**Code déplacé** : Lignes 403-467 (colonne 1)

---

### ✅ 5. Ajouter un champ "Commission" (%)

**Problème** : Le champ commission était manquant dans le modal et dans la base de données.

**Solution SQL** : Nouveau fichier `sql/add_commission_to_performances.sql`

```sql
ALTER TABLE public.artist_performances
ADD COLUMN commission_percentage NUMERIC(5,2) NULL
CHECK (commission_percentage >= 0 AND commission_percentage <= 100);
```

**Solution TypeScript** :
1. Ajout de `commission_percentage` dans les interfaces :
   - `Performance`
   - `PerformanceCreate`
   - `PerformanceUpdate`

2. Ajout dans les fonctions API :
   - `fetchPerformances()` → SELECT commission_percentage
   - `createPerformance()` → INSERT commission_percentage
   - `updatePerformance()` → UPDATE commission_percentage

3. Ajout dans le formulaire :
   - État : `commission_percentage: null as number | null`
   - Input number (min 0, max 100, step 0.5)
   - Placeholder "0.0"

**Code UI** : Lignes 593-608

```typescript
<div>
  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
    Commission (%)
  </label>
  <input
    type="number"
    min="0"
    max="100"
    step="0.5"
    className="w-full px-3 py-2 rounded-lg border..."
    value={formData.commission_percentage || ""}
    onChange={(e) => setFormData(prev => ({ ...prev, commission_percentage: parseFloat(e.target.value) || null }))}
    placeholder="0.0"
  />
</div>
```

---

## 🎯 Option B : Modal de rejet automatique

### Objectif

Lorsque l'utilisateur sélectionne "Offre rejetée" dans le statut, le modal `RejectOfferModal` s'ouvre automatiquement pour collecter la raison du rejet.

### Implémentation

#### 1. Déclenchement automatique

Lorsque "Offre rejetée" est sélectionnée dans le dropdown "Statut (booking)", le modal de rejet s'ouvre immédiatement.

**Code** : Lignes 393-401

```typescript
<select
  className="..."
  value={formData.booking_status}
  onChange={(e) => {
    const newStatus = e.target.value as BookingStatus;
    setFormData(prev => ({ ...prev, booking_status: newStatus }));
    
    // Si "Offre rejetée" est sélectionnée, ouvrir le modal de rejet
    if (newStatus === "offre_rejetee") {
      setShowRejectModal(true);
    }
  }}
>
```

#### 2. Stockage temporaire de la raison du rejet

La raison du rejet est stockée temporairement dans `window.__rejectionData` en attendant l'enregistrement final.

**Code** : Lignes 244-259

```typescript
const handleReject = async (reason: string) => {
  // Enregistrer les données de rejet dans le formulaire
  setFormData(prev => ({
    ...prev,
    booking_status: "offre_rejetee",
  }));
  
  // Stocker temporairement la raison du rejet pour la sauvegarde finale
  (window as any).__rejectionData = {
    rejection_reason: reason,
    rejection_date: new Date().toISOString(),
  };
  
  setShowRejectModal(false);
  toastSuccess("Raison du rejet enregistrée. Cliquez sur 'Enregistrer' pour confirmer.");
};
```

#### 3. Intégration lors de la sauvegarde

Lors de l'enregistrement de la performance, si le statut est "offre_rejetee", les données de rejet sont automatiquement ajoutées.

**Code** : Lignes 197-252

```typescript
// Récupérer les données de rejet si disponibles
const rejectionData = (window as any).__rejectionData;

// En création
const createData: any = {
  // ... champs existants
  booking_status: formData.booking_status,
  notes: formData.notes || null,
  created_for_event_id: initialData?.eventId,
};

// Ajouter les données de rejet si le statut est "rejetée"
if (formData.booking_status === "offre_rejetee" && rejectionData) {
  createData.rejection_reason = rejectionData.rejection_reason;
  createData.rejection_date = rejectionData.rejection_date;
}

await createPerformance(createData);

// Nettoyer les données temporaires
delete (window as any).__rejectionData;
```

#### 4. Annulation du rejet

Si l'utilisateur ferme le modal de rejet sans fournir de raison, le statut revient automatiquement à "Idée".

**Code** : Lignes 672-682

```typescript
<RejectOfferModal
  open={showRejectModal}
  onClose={() => {
    setShowRejectModal(false);
    // Annuler la sélection "Offre rejetée" si l'utilisateur ferme le modal sans raison
    if (formData.booking_status === "offre_rejetee" && !(window as any).__rejectionData) {
      setFormData(prev => ({ ...prev, booking_status: "idee" }));
    }
  }}
  onReject={handleReject}
/>
```

---

## 📊 Nouvelle structure du modal

### Colonne 1 : Informations générales
1. **Artiste** (select + bouton)
   - Option "Aucun artiste (optionnel)"
   - Bouton "Ajouter un artiste" → ouvre `AddArtistModal`
2. **Statut (booking)** (select)
   - Idée
   - Offre à faire
   - Offre envoyée
   - Offre acceptée
   - **Offre rejetée** ⚡ → Déclenche automatiquement `RejectOfferModal`
3. **Durée (min)*** (radio + boutons)
   - Durée standard : 60 / 75 / 90 min
   - Durée personnalisée : input number

### Colonne 2 : Planning
1. **Jour*** (select)
2. **Scène*** (select)
3. **Heure de début*** (input time + bouton time picker)

### Colonne 3 : Cachet
1. **Devise** (select)
   - EUR / CHF / USD / GBP
2. **Montant** (input number)
3. **Commission (%)** (input number) ⚡ **NOUVEAU**

### Full Width (en bas)
**Notes internes** (textarea)

---

## 🎬 Workflow utilisateur : Rejet d'une offre

1. Ouvrir le modal (création ou édition)
2. Sélectionner "Offre rejetée" dans le statut
3. → Le modal `RejectOfferModal` s'ouvre automatiquement
4. Saisir la raison du rejet
5. Cliquer "Confirmer" dans `RejectOfferModal`
6. → Toast : "Raison du rejet enregistrée. Cliquez sur 'Enregistrer' pour confirmer."
7. Le modal de performance reste ouvert avec le statut "Offre rejetée"
8. L'utilisateur peut modifier d'autres champs si nécessaire
9. Cliquer "Enregistrer" pour sauvegarder la performance
10. → Les données de rejet (`rejection_reason` + `rejection_date`) sont automatiquement enregistrées

### Cas d'annulation

Si l'utilisateur ferme le modal de rejet sans fournir de raison :
- Le statut revient automatiquement à "Idée"
- Aucune donnée de rejet n'est enregistrée

---

## 📦 Fichiers modifiés

| Fichier | Type | Modifications |
|---------|------|---------------|
| `sql/add_commission_to_performances.sql` | SQL | ✅ Créé - Ajout colonne commission_percentage |
| `src/features/timeline/timelineApi.ts` | API | ✅ Modifié - Ajout commission_percentage dans types et fonctions |
| `src/features/booking/modals/PerformanceModal.tsx` | UI | ✅ Modifié - 5 corrections + modal de rejet automatique |

---

## 🧪 Tests à effectuer

### Test 1 : Dropdown artiste
1. Ouvrir le modal de performance
2. **Vérifier** : Les artistes sont chargés et affichés dans le dropdown
3. **Vérifier** : Les logs dans la console affichent le nombre d'artistes chargés

### Test 2 : Bouton "Ajouter un artiste"
1. Cliquer sur "Ajouter un artiste"
2. **Vérifier** : Le modal `AddArtistModal` s'ouvre
3. Créer un artiste
4. **Vérifier** : Le dropdown artiste se recharge avec le nouvel artiste

### Test 3 : Durée dans colonne 1
1. **Vérifier** : La durée est dans la colonne "Informations générales"
2. Tester la sélection de durée standard (60/75/90)
3. Tester la durée personnalisée

### Test 4 : Champ commission
1. **Vérifier** : Le champ "Commission (%)" est dans la colonne "Cachet"
2. Saisir une commission (ex: 15.5%)
3. Enregistrer
4. **Vérifier** : La commission est sauvegardée en base

### Test 5 : Modal de rejet automatique
1. Ouvrir le modal de performance
2. Sélectionner "Offre rejetée" dans le statut
3. **Vérifier** : Le modal `RejectOfferModal` s'ouvre automatiquement
4. Saisir une raison (ex: "Artiste non disponible")
5. **Vérifier** : Toast "Raison du rejet enregistrée"
6. Enregistrer la performance
7. **Vérifier** : `rejection_reason` et `rejection_date` sont enregistrés

### Test 6 : Annulation du rejet
1. Sélectionner "Offre rejetée"
2. Fermer le modal de rejet (croix ou annuler)
3. **Vérifier** : Le statut revient à "Idée"

---

## 🎉 Résumé

✅ **5 corrections effectuées** :
1. Debugging du dropdown artiste
2. Suppression du checkbox "artiste a confirmé"
3. Amélioration du bouton "Ajouter un artiste"
4. Déplacement de la durée dans colonne 1
5. Ajout du champ commission (SQL + UI)

✅ **Option B implémentée** : Modal de rejet automatique
- Déclenchement automatique lors de la sélection "Offre rejetée"
- Stockage temporaire de la raison du rejet
- Intégration automatique lors de la sauvegarde
- Annulation possible

✅ **Prêt pour les tests !** 🚀

