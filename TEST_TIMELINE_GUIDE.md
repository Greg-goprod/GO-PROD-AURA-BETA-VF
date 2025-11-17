# Guide de test Timeline Booking

## 🚀 Installation

1. **Installer les dépendances DnD** :
   ```bash
   npm install @dnd-kit/core @dnd-kit/modifiers @dnd-kit/sortable
   ```

2. **Redémarrer le serveur** :
   ```bash
   npm run dev
   ```

## 🧪 Tests à effectuer

### 1. Test de base (sans event_id)
1. Allez sur `http://localhost:5174/app/booking`
2. Cliquez sur "📅 Ouvrir la timeline"
3. La page Timeline s'ouvre dans un nouvel onglet
4. **EmptyState** devrait s'afficher avec bouton "Activer le mode démo"
5. Cliquez "Activer le mode démo"
6. La timeline devrait se charger avec des données fictives

### 2. Test mode démo complet
1. **Données visibles** :
   - 2 jours (aujourd'hui, demain)
   - 3 scènes (principale, secondaire, acoustique)
   - 3 performances avec différents statuts

2. **DailySummaryCards** :
   - Cartes de résumé par jour
   - Compteur de performances
   - Total des cachets par devise
   - Barre de progression

3. **TimelineGrid** :
   - Header avec jours et heures
   - Colonne scènes à gauche
   - Grille avec zones de drop

### 3. Test drag & drop
1. **Déplacer une performance** :
   - Glissez une carte performance
   - Déposez-la dans une autre cellule jour/scène
   - La performance devrait se déplacer
   - Toast "Performance déplacée (démo)"

2. **Snapping 5 minutes** :
   - Glissez une carte entre deux heures
   - Elle devrait s'aligner sur 5 minutes

### 4. Test création performance
1. **Clic sur cellule vide** :
   - Cliquez sur une cellule vide jour/scène
   - Modal PerformanceModal devrait s'ouvrir
   - Champs préremplis avec jour/scène/heure

2. **Bouton "+ Performance"** :
   - Cliquez sur le bouton header
   - Modal s'ouvre avec champs vides
   - Remplissez et sauvegardez

### 5. Test édition performance
1. **Clic sur carte** :
   - Cliquez sur une carte performance
   - Modal s'ouvre avec données préremplies
   - Modifiez et sauvegardez

2. **Bouton horloge** :
   - Cliquez sur l'icône horloge d'une carte
   - CustomTimePicker plein écran s'ouvre
   - Modifiez heure/durée avec snapping 5min

### 6. Test suppression
1. **Bouton poubelle** :
   - Cliquez sur l'icône poubelle d'une carte
   - Confirmation demandée
   - Performance supprimée

### 7. Test avec event_id réel
1. **Définir un event** :
   ```javascript
   localStorage.setItem('selected_event_id', 'uuid-event-reel');
   ```

2. **Recharger la page** :
   - Mode production s'active
   - Données chargées depuis Supabase
   - Toutes les fonctionnalités marchent avec vraies données

## 🔍 Vérifications

### Console du navigateur
- Pas d'erreurs d'import
- Logs de chargement des données
- Logs des actions drag & drop

### Fonctionnalités attendues
✅ **Mode démo** : Fonctionne sans event_id  
✅ **EmptyState** : Affichage si pas d'event  
✅ **DailySummaryCards** : Résumé par jour  
✅ **TimelineGrid** : Grille jours+heures+scènes  
✅ **PerformanceCard** : Cartes draggables  
✅ **Drag & Drop** : Déplacement avec snapping  
✅ **Modaux** : PerformanceModal + CustomTimePicker  
✅ **Couleurs statut** : Ambre/Bleu/Vert selon booking_status  
✅ **Tooltips** : Infos complètes au survol  
✅ **Responsive** : Adaptation mobile  

### URLs de test
- **Booking** : `http://localhost:5174/app/booking`
- **Timeline** : `http://localhost:5174/app/lineup/timeline`
- **Bouton Timeline** : Dans BookingPage → "📅 Ouvrir la timeline"

## 🐛 Dépannage

### Erreur "@dnd-kit not found"
- Redémarrer le serveur après installation
- Vérifier que `node_modules/@dnd-kit` existe

### Timeline ne se charge pas
- Vérifier la console pour erreurs Supabase
- Tester en mode démo d'abord

### Drag & drop ne fonctionne pas
- Vérifier que les zones de drop sont bien définies
- Consulter la console pour erreurs DnD

### Modaux ne s'ouvrent pas
- Vérifier les imports des composants AURA
- Consulter la console pour erreurs React

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

1. **Tester avec vraies données** Supabase
2. **Personnaliser les couleurs** selon les besoins
3. **Ajouter des validations** supplémentaires
4. **Optimiser les performances** pour gros volumes
5. **Intégrer avec autres modules** (Contrats, Budget)

