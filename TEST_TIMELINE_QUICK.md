# 🧪 Tests Rapides - Timeline Booking

## ⚡ Tests en 5 minutes

### Étape 1: Exécuter la migration SQL
```sql
-- Dans Supabase SQL Editor, exécuter:
-- Copier/coller le contenu de: sql/add_created_for_event_to_performances.sql
```

**Résultat attendu**:
```
✅ Colonne created_for_event_id ajoutée à artist_performances avec FK, index et données migrées.
```

---

### Étape 2: Ouvrir la page Timeline
1. Démarrer le serveur: `npm run dev`
2. Naviguer vers: `http://localhost:5180/app/administration/timeline`
3. **Vérifier**: Pas d'erreur dans la console

---

### Étape 3: Sélectionner un événement
1. Cliquer sur le sélecteur d'événement dans le header
2. Choisir un événement existant
3. **Vérifier**: 
   - Console log: `🔄 Event changed, recharging timeline...`
   - Nom de l'événement affiché dans le header
   - Couleur de l'événement appliquée

---

### Étape 4: Tester le Drag & Drop
1. Cliquer et maintenir sur une carte de performance
2. **Vérifier**: La carte devient semi-transparente (opacity 50%)
3. Déplacer vers une autre scène
4. Relâcher
5. **Vérifier**: 
   - Toast: "Performance déplacée"
   - La carte est maintenant dans la nouvelle scène

---

### Étape 5: Créer une performance (Quick Add)
1. Cliquer sur une cellule vide de la timeline
2. **Vérifier**: Modal s'ouvre avec:
   - Jour pré-sélectionné ✓
   - Scène pré-sélectionnée ✓
   - Heure calculée depuis le clic ✓
3. Sélectionner un artiste
4. Cliquer sur "Créer"
5. **Vérifier**:
   - Toast: "Performance créée"
   - Carte apparaît dans la timeline

---

### Étape 6: Vérifier le tracking
```sql
-- Dans Supabase SQL Editor:
SELECT 
    ap.id,
    a.name as artist_name,
    e.name as event_name,
    ap.performance_time,
    ap.created_for_event_id
FROM artist_performances ap
JOIN artists a ON ap.artist_id = a.id
JOIN events e ON ap.created_for_event_id = e.id
ORDER BY ap.created_at DESC
LIMIT 5;
```

**Vérifier**: 
- Les nouvelles performances ont un `created_for_event_id` non-null
- Le nom de l'événement correspond à l'événement actuel

---

### Étape 7: Tester le mode démo
1. Cliquer sur le bouton "Mode démo OFF/ON"
2. **Vérifier**: 
   - Données factices affichées
   - Toasts indiquent "(démo)"
   - Drag & drop fonctionne en local
3. Recliquer pour revenir en mode production

---

## ❌ Problèmes courants

### Problème: "Cannot read property 'id' of undefined"
**Solution**: Vérifier qu'un événement est bien sélectionné ou activer le mode démo

### Problème: Drag & drop ne fonctionne pas
**Causes possibles**:
1. Vérifier que la carte n'est pas en mode édition
2. Vérifier la console pour les erreurs
3. Vider le cache: Ctrl+Shift+R

### Problème: Modal ne s'ouvre pas
**Causes possibles**:
1. Vérifier qu'un événement est sélectionné
2. Vérifier la console pour les erreurs d'import
3. Vérifier que `companyId` n'est pas undefined

### Problème: Migration SQL échoue
**Causes possibles**:
1. La colonne existe déjà (message: "⚠️ Colonne created_for_event_id existe déjà")
2. Permissions insuffisantes
3. Conflit de contrainte FK

**Solution**: 
```sql
-- Vérifier si la colonne existe:
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'artist_performances' 
AND column_name = 'created_for_event_id';
```

---

## ✅ Checklist de validation

- [ ] Migration SQL exécutée sans erreur
- [ ] Page Timeline charge sans erreur
- [ ] Événement sélectionné s'affiche dans le header
- [ ] Drag & drop fonctionne
- [ ] Modal création s'ouvre au clic sur cellule
- [ ] Performance créée avec `created_for_event_id`
- [ ] Mode démo fonctionne
- [ ] Changement d'événement recharge la timeline

---

## 🎯 Test complet (si tout fonctionne)

### Scénario réel:
1. ✅ Créer un nouvel événement "Test Timeline" dans Paramètres > Événements
2. ✅ Ajouter 2 jours et 2 scènes
3. ✅ Aller sur Timeline Booking
4. ✅ Sélectionner "Test Timeline"
5. ✅ Créer 5 performances via clic sur cellules
6. ✅ Déplacer 2 performances vers d'autres scènes
7. ✅ Éditer une performance (changer l'heure)
8. ✅ Supprimer une performance
9. ✅ Vérifier dans Supabase que toutes les actions sont trackées

**Durée estimée**: 10 minutes

---

## 📊 Résultat final attendu

Si tous les tests passent:
- ✅ **Drag & Drop**: Fonctionnel et fluide
- ✅ **Tracking**: Toutes les performances ont `created_for_event_id`
- ✅ **Intégration**: Synchronisé avec EventSelector
- ✅ **UI/UX**: Réactif et sans bug
- ✅ **Mode démo**: Opérationnel pour développement/démo

**Vous êtes prêt pour la production ! 🚀**


