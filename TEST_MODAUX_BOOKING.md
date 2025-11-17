# Test des Modaux Booking - Guide Complet

## 🎯 Objectif
Tester les nouveaux modaux "Ajouter performance" et "Établir une offre" avec AURA + Supabase.

## 📋 Prérequis
- ✅ Serveur de développement actif (`npm run dev`)
- ✅ Dépendances installées (`@emailjs/browser`, `pdf-lib`)
- ✅ Variables d'environnement EmailJS configurées
- ✅ Base de données Supabase accessible

## 🧪 Tests à Effectuer

### 1. Test PerformanceModal - BookingPage

#### 1.1 Accès au modal
1. **Aller sur** : `http://localhost:5176/app/booking`
2. **Cliquer sur** : "➕ Ajouter une performance"
3. **Vérifier** : Modal PerformanceModal s'ouvre

#### 1.2 Création d'une performance
1. **Sélectionner** : Un artiste dans la liste
2. **Sélectionner** : Un jour et une scène
3. **Définir** : Heure (14:00) et durée (60 min)
4. **Optionnel** : Ajouter un cachet (1000 EUR)
5. **Cliquer** : "Créer"
6. **Vérifier** : Toast "Performance créée" + modal se ferme

#### 1.3 Validation des champs
1. **Tester** : Création sans artiste → Erreur "Artiste requis"
2. **Tester** : Création sans jour → Erreur "Jour requis"
3. **Tester** : Création sans scène → Erreur "Scène requise"
4. **Tester** : Création sans heure → Erreur "Heure requise"

#### 1.4 Fonctionnalités avancées
1. **Création rapide d'artiste** :
   - Cliquer sur "+" à côté du select artiste
   - Saisir un nom d'artiste
   - Cliquer "Créer"
   - Vérifier que l'artiste apparaît dans la liste

2. **Sélecteur temps** :
   - Cliquer sur l'icône horloge
   - Modifier heure/durée dans le CustomTimePicker
   - Confirmer
   - Vérifier que les valeurs sont mises à jour

### 2. Test OfferComposer - BookingPage

#### 2.1 Accès au modal
1. **Dans le Kanban** : Colonne "Brouillon / À faire"
2. **Cliquer sur** : "Établir l'offre" sur une carte performance
3. **Vérifier** : Modal OfferComposer s'ouvre avec données préremplies

#### 2.2 Création d'une offre
1. **Vérifier** : Données préremplies (artiste, scène, date, heure, durée)
2. **Modifier** : Montant net (1500) et brut (1800)
3. **Sélectionner** : Devise (EUR)
4. **Définir** : Date de validité (dans 7 jours)
5. **Cliquer** : "Créer"
6. **Vérifier** : Toast "Offre créée" + modal se ferme

#### 2.3 Génération PDF
1. **Après création** : Cliquer "Générer l'offre"
2. **Vérifier** : Toast "PDF généré avec succès"
3. **Cliquer** : "Prévisualiser"
4. **Vérifier** : Modal PDF s'ouvre avec iframe
5. **Cliquer** : "Prêt à envoyer"
6. **Vérifier** : Toast "Offre marquée comme prête à envoyer"

#### 2.4 Validation des champs
1. **Tester** : Création sans artiste → Erreur "Artiste requis"
2. **Tester** : Création sans scène → Erreur "Scène requise"
3. **Tester** : Création sans date → Erreur "Date requise"
4. **Tester** : Création sans montant → Erreur "Montant requis"

### 3. Test PerformanceModal - Timeline

#### 3.1 Accès au modal
1. **Aller sur** : `http://localhost:5176/app/lineup/timeline`
2. **Cliquer sur** : Une cellule vide dans la grille
3. **Vérifier** : Modal PerformanceModal s'ouvre avec données préremplies

#### 3.2 Création depuis timeline
1. **Vérifier** : Jour et scène préremplis
2. **Vérifier** : Heure préremplie selon position du clic
3. **Sélectionner** : Un artiste
4. **Définir** : Durée et cachet
5. **Cliquer** : "Créer"
6. **Vérifier** : Performance apparaît dans la timeline

#### 3.3 Édition depuis timeline
1. **Cliquer sur** : Une carte performance existante
2. **Vérifier** : Modal s'ouvre avec données préremplies
3. **Modifier** : Heure ou durée
4. **Cliquer** : "Modifier"
5. **Vérifier** : Performance mise à jour dans la timeline

### 4. Test SendOfferModal

#### 4.1 Accès au modal
1. **Dans le Kanban** : Colonne "Prêt à envoyer"
2. **Cliquer sur** : "Envoyer" sur une offre
3. **Vérifier** : Modal SendOfferModal s'ouvre

#### 4.2 Envoi d'email
1. **Saisir** : Adresse email de test
2. **Modifier** : Sujet si nécessaire
3. **Modifier** : Message si nécessaire
4. **Cliquer** : "Envoyer"
5. **Vérifier** : Toast "Offre envoyée par email"

### 5. Test RejectOfferModal

#### 5.1 Accès au modal
1. **Dans le Kanban** : Colonne "Envoyé"
2. **Cliquer sur** : "Rejeter" sur une offre
3. **Vérifier** : Modal RejectOfferModal s'ouvre

#### 5.2 Rejet d'offre
1. **Saisir** : Motif de rejet ("Prix trop élevé")
2. **Cliquer** : "Rejeter"
3. **Vérifier** : Toast "Offre rejetée" + offre passe en "Rejeté"

### 6. Test Mode Démo

#### 6.1 Activation du mode démo
1. **Cliquer sur** : "Mode Démo OFF" → devient "Mode Démo ON"
2. **Vérifier** : Données fictives s'affichent
3. **Tester** : Toutes les fonctionnalités en mode démo

#### 6.2 Fonctionnalités démo
1. **Création performance** : Fonctionne avec données fictives
2. **Création offre** : Fonctionne avec données fictives
3. **Actions** : Tous les boutons fonctionnent avec toasts "démo"

## 🔍 Vérifications Techniques

### Console du navigateur (F12)
- ✅ Pas d'erreurs JavaScript
- ✅ Logs de chargement des données
- ✅ Logs des actions des modaux

### Base de données Supabase
- ✅ Nouvelles performances créées dans `artist_performances`
- ✅ Nouvelles offres créées dans `offers`
- ✅ PDF générés dans le bucket `offers`
- ✅ Statuts mis à jour correctement

### Variables d'environnement
- ✅ `VITE_EMAILJS_PUBLIC_KEY` configurée
- ✅ `VITE_EMAILJS_SERVICE_ID` configurée
- ✅ `VITE_EMAILJS_TEMPLATE_ID` configurée

## 🐛 Dépannage

### Erreur "createOffer non implémenté"
**Solution** : Les fonctions sont maintenant implémentées dans `bookingApi.ts`

### Erreur "Configuration EmailJS manquante"
**Solution** : Vérifier les variables d'environnement dans `.env.local`

### Erreur "PDF non généré"
**Solution** : Vérifier que `pdf-lib` est installé et que le bucket `offers` existe

### Modal ne s'ouvre pas
**Solution** : Vérifier les imports et les props des modaux

### Données non préremplies
**Solution** : Vérifier que `initialData` est correctement passé

## 📊 Résultats Attendus

### PerformanceModal
- ✅ Création/édition de performances
- ✅ Validation des champs obligatoires
- ✅ Création rapide d'artistes
- ✅ Sélecteur temps avec snapping 5 minutes
- ✅ Gestion des statuts (idée, offre à faire, rejetée)

### OfferComposer
- ✅ Création/édition d'offres
- ✅ Préremplissage depuis performances
- ✅ Génération PDF automatique
- ✅ Prévisualisation PDF
- ✅ Marquage "Prêt à envoyer"
- ✅ Gestion des montants net/brut

### SendOfferModal
- ✅ Envoi d'emails avec PDF joint
- ✅ Personnalisation du message
- ✅ Gestion des erreurs d'envoi

### RejectOfferModal
- ✅ Collecte du motif de rejet
- ✅ Mise à jour du statut
- ✅ Sauvegarde en base

## 🎯 Prochaines Étapes

1. **Tester tous les workflows** listés ci-dessus
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
- `src/features/booking/modals/PerformanceModal.tsx`
- `src/features/booking/modals/OfferComposer.tsx`
- `src/features/booking/modals/SendOfferModal.tsx`
- `src/features/booking/modals/RejectOfferModal.tsx`
- `src/features/booking/bookingApi.ts`
- `src/services/emailService.ts`

