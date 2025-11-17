# Test Version Complète Timeline Booking

## 🚀 Configuration de la version complète

### 1. Prérequis
- ✅ Dépendances @dnd-kit installées
- ✅ Cache Vite nettoyé
- ✅ Types DnD définis localement
- ✅ Serveur redémarré

### 2. Exécution du script de configuration
```bash
./setup-complete-version.bat
```

## 🧪 Tests de fonctionnalités

### Test 1 : Accès à la page
1. **Aller sur** : `http://localhost:5176/app/booking`
2. **Cliquer sur** : "📅 Ouvrir la timeline"
3. **Vérifier** : Nouvel onglet s'ouvre avec `/app/lineup/timeline`

### Test 2 : Mode démo
1. **Si pas d'event_id** : EmptyState s'affiche
2. **Cliquer** : "Activer le mode démo"
3. **Vérifier** : Timeline se charge avec données fictives

### Test 3 : Affichage de la grille
1. **Header** : Jours + bande horaire
2. **Colonne gauche** : Liste des scènes
3. **Grille** : Cellules jour × scène
4. **Performances** : Cartes colorées selon statut

### Test 4 : Drag & Drop
1. **Glisser** une carte performance
2. **Déposer** dans une autre cellule
3. **Vérifier** : Snapping à 5 minutes
4. **Toast** : "Performance déplacée (démo)"

### Test 5 : Création de performance
1. **Clic** sur cellule vide
2. **Modal** PerformanceModal s'ouvre
3. **Remplir** les champs
4. **Sauvegarder** : Performance ajoutée

### Test 6 : Édition de performance
1. **Clic** sur carte performance
2. **Modal** s'ouvre avec données préremplies
3. **Modifier** les informations
4. **Sauvegarder** : Performance mise à jour

### Test 7 : Sélecteur temps
1. **Clic** sur icône horloge d'une carte
2. **CustomTimePicker** plein écran s'ouvre
3. **Modifier** heure/durée
4. **Snapping** automatique à 5 minutes
5. **Sauvegarder** : Temps mis à jour

### Test 8 : Suppression
1. **Clic** sur icône poubelle
2. **Confirmation** demandée
3. **Confirmer** : Performance supprimée

### Test 9 : Résumé quotidien
1. **DailySummaryCards** : Cartes par jour
2. **Compteur** : Nombre de performances
3. **Cachets** : Total par devise
4. **Barre progression** : Max 10 performances

## 🔍 Vérifications techniques

### Console du navigateur (F12)
- ✅ Pas d'erreurs JavaScript
- ✅ Logs de chargement des données
- ✅ Logs des actions drag & drop

### Fonctionnalités attendues
- ✅ **Mode démo** : Fonctionne sans event_id
- ✅ **EmptyState** : Affichage si pas d'événement
- ✅ **TimelineGrid** : Grille avec DnD
- ✅ **PerformanceCard** : Cartes draggables
- ✅ **DailySummaryCards** : Résumé par jour
- ✅ **CustomTimePicker** : Sélecteur temps
- ✅ **PerformanceModal** : Création/édition
- ✅ **Snapping** : Alignement 5 minutes
- ✅ **Couleurs** : Selon booking_status
- ✅ **Tooltips** : Infos complètes

## 🐛 Dépannage

### Erreur "DragEndEvent not found"
**Solution** : Types définis localement dans TimelineGrid.tsx
```typescript
interface DragStartEvent {
  active: { id: string };
}

interface DragEndEvent {
  active: { id: string };
  over: { data: { current: any } } | null;
}
```

### Erreur de cache Vite
**Solution** : Nettoyer le cache
```bash
rmdir /s /q node_modules\.vite
npm run dev
```

### Drag & Drop ne fonctionne pas
**Vérifications** :
1. DndContext entoure la grille
2. Zones de drop ont les bons data-attributes
3. PerformanceCard utilise useDraggable
4. Console sans erreurs DnD

### Page blanche
**Actions** :
1. Console du navigateur (F12)
2. Noter les erreurs exactes
3. Vérifier les imports
4. Tester avec version simplifiée si nécessaire

## 📊 Résultats attendus

### Mode démo
- ✅ Timeline fonctionnelle avec données fictives
- ✅ Tous les modaux s'ouvrent
- ✅ Drag & drop opérationnel
- ✅ Snapping 5 minutes
- ✅ Création/édition/suppression

### Mode production
- ✅ Chargement données Supabase
- ✅ Toutes les fonctionnalités du mode démo
- ✅ Synchronisation avec BookingPage
- ✅ Écoute des changements d'offres

## 🎯 Prochaines étapes

1. **Tester toutes les fonctionnalités** listées ci-dessus
2. **Noter les problèmes** rencontrés
3. **Consulter la console** pour les erreurs
4. **Appliquer les corrections** nécessaires
5. **Valider le fonctionnement** complet

## 📞 Support

### En cas de problème
1. **Console** : Copier les erreurs exactes
2. **URL** : Noter l'URL qui pose problème
3. **Étapes** : Décrire les actions effectuées
4. **Résultat** : Expliquer ce qui ne fonctionne pas

### Fichiers de diagnostic
- `setup-complete-version.bat` : Configuration complète
- `TROUBLESHOOTING_BLANK_PAGE.md` : Dépannage page blanche
- `TROUBLESHOOTING_TIMELINE.md` : Dépannage général
- `TEST_TIMELINE_GUIDE.md` : Guide de test détaillé

