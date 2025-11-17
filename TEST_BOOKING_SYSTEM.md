# Test du système Booking PDF + Email

## ✅ Dépendances installées
- `pdf-lib` ✅
- `emailjs-com` ✅

## ✅ Fichiers mis à jour
- `src/features/booking/pdf/pdfFill.ts` → Version complète avec pdf-lib
- `src/services/emailService.ts` → Version complète avec emailjs-com

## 🧪 Tests à effectuer

### 1. Test de base (sans EmailJS configuré)
1. Allez sur `http://localhost:5174/app/booking`
2. Le mode démo devrait s'activer automatiquement
3. Tous les modaux devraient s'ouvrir
4. Le Kanban devrait fonctionner avec drag & drop

### 2. Test de génération PDF (mode démo)
1. Cliquez sur "Prêt à envoyer" sur une offre
2. Le statut devrait passer à "ready_to_send"
3. Un PDF devrait être généré et uploadé dans Supabase
4. Consultez la console pour voir les logs

### 3. Test d'envoi email (mode démo)
1. Cliquez sur "Envoyer" sur une offre
2. Le modal SendOfferModal devrait s'ouvrir
3. Remplissez le formulaire et cliquez "Envoyer"
4. L'email devrait être simulé dans la console
5. Le statut devrait passer à "sent"

### 4. Test avec EmailJS configuré
1. Créez `.env.local` avec vos clés EmailJS
2. Suivez `EMAILJS_CONFIG_EXAMPLE.md`
3. Redémarrez le serveur
4. Testez l'envoi d'un vrai email

## 🔍 Vérifications

### Console du navigateur
- Pas d'erreurs d'import
- Logs de génération PDF
- Logs d'envoi email (simulé ou réel)

### Supabase Storage
- Bucket `offers` accessible
- Fichiers PDF uploadés dans `{event_id}/{offer_id}/OFFRE_*.pdf`

### Base de données
- Champ `pdf_storage_path` rempli dans la table `offers`
- Statuts des offres mis à jour correctement

## 🚨 Problèmes possibles

### Erreur "pdf-lib not found"
- Redémarrez le serveur : `npm run dev`
- Vérifiez que `node_modules/pdf-lib` existe

### Erreur "emailjs-com not found"
- Redémarrez le serveur : `npm run dev`
- Vérifiez que `node_modules/emailjs-com` existe

### PDF ne se génère pas
- Vérifiez les permissions du bucket `offers`
- Consultez la console pour les erreurs Supabase

### Email ne s'envoie pas
- Vérifiez les variables d'environnement EmailJS
- Vérifiez que le template contient toutes les variables

## 📊 Résultats attendus

### Mode démo
- ✅ Application fonctionnelle
- ✅ Modaux s'ouvrent
- ✅ Kanban avec drag & drop
- ✅ PDF généré (simulé)
- ✅ Email simulé dans console

### Mode production (avec EmailJS)
- ✅ Toutes les fonctionnalités du mode démo
- ✅ PDF réel généré et uploadé
- ✅ Email réel envoyé avec lien PDF
- ✅ URLs signées fonctionnelles

## 🎯 Prochaines étapes

1. **Configurer EmailJS** pour les vrais envois
2. **Tester avec un vrai event_id** en production
3. **Personnaliser le template PDF** si nécessaire
4. **Ajouter des validations** supplémentaires
5. **Implémenter les modules Contrats/Budget/Finances**

