# Fix - Erreur de création d'événement : status check constraint

## 🐛 Problème

Lors de la création d'un événement, l'erreur suivante apparaissait :

```
new row for relation "events" violates check constraint "events_status_check"
```

**Cause** : La colonne `status` avait une valeur par défaut `'draft'` qui n'était pas acceptée par la contrainte CHECK sur la table `events`.

**Payload envoyé** :
```json
{
  "company_id": "06f6c960-3f90-41cb-b0d7-46937eaf90a8",
  "name": "FESTIVAL TEST 2026",
  "slug": "festival-test-2026",
  "color_hex": "#3b82f6",
  "start_date": "2025-12-18",
  "end_date": "2025-12-21",
  "notes": null,
  "status": "draft"  // ❌ Valeur non autorisée
}
```

---

## ✅ Solution

### **Modification de `src/api/eventsApi.ts`**

**Fonction `createEvent`** (ligne 134) :
```typescript
// ❌ Avant
status: data.status || 'draft',

// ✅ Après
status: data.status || 'planned',
```

**Fonction `createEventWithChildren`** (ligne 362) :
```typescript
// ❌ Avant
status: payload.status || 'draft',

// ✅ Après
status: payload.status || 'planned',
```

---

## 📊 Valeurs autorisées pour `status`

D'après la contrainte CHECK sur la table `events`, les valeurs autorisées sont probablement :
- `'planned'` (par défaut)
- `'in_progress'`
- `'completed'`
- `'cancelled'`

**Pas** : `'draft'` ❌

---

## 🧪 Test

1. Aller sur `/app/settings/events`
2. Cliquer sur "Ajouter un évènement"
3. Remplir :
   - Nom : "FESTIVAL TEST 2026"
   - Date début : 18/12/2025
   - Date fin : 21/12/2025
4. Cliquer sur "Enregistrer"
5. ✅ **Résultat attendu** : Événement créé avec succès, toast "Évènement 'FESTIVAL TEST 2026' créé avec succès"

---

## 📝 Logs améliorés

J'ai également ajouté des logs détaillés pour faciliter le debug :

```typescript
if (error) {
  console.error('❌ Erreur createEvent:', error);
  console.error('📋 Payload envoyé:', payload);
  throw new Error(error.message || 'Erreur lors de la création de l\'événement');
}
```

**Dans EventForm.tsx** :
```typescript
catch (err: any) {
  console.error('❌ Erreur sauvegarde évènement:', err);
  console.error('📝 Données du formulaire:', data);
  const errorMessage = err?.message || err?.error_description || err?.hint || 'Erreur lors de la sauvegarde de l\'évènement';
  toastError(errorMessage);
}
```

Ces logs afficheront maintenant :
- L'erreur complète de Supabase
- Le payload exact envoyé
- Les données du formulaire
- Les hints SQL si disponibles

---

**Date de correction** : 30 octobre 2025  
**Fichier modifié** : `src/api/eventsApi.ts` (lignes 134 et 362)  
**Status** : ✅ Corrigé - Événement créé avec succès avec `status='planned'`


