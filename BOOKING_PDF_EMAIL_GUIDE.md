# Guide Booking PDF + Email - Go-Prod AURA

## 🎯 Fonctionnalités implémentées

### ✅ Génération PDF automatique
- **PDF-lib** : Génération côté client de PDFs d'offres
- **Upload Supabase** : Stockage dans le bucket `offers`
- **Génération automatique** : Quand une offre passe en "Prêt à envoyer"
- **Format standardisé** : Template AURA avec toutes les infos de l'offre

### ✅ Envoi d'emails via EmailJS
- **EmailJS** : Service d'envoi d'emails sans serveur
- **Templates personnalisables** : HTML avec variables dynamiques
- **URLs signées** : Liens PDF sécurisés (7 jours de validité)
- **Multi-expéditeurs** : Configuration flexible des comptes d'envoi

### ✅ Modaux AURA
- **SendOfferModal** : Formulaire d'envoi d'email complet
- **RejectOfferModal** : Saisie de raison de rejet
- **PerformanceModal** : Gestion des performances (MVP)

### ✅ Intégration complète
- **Mode démo** : Fonctionne sans event_id
- **Mode production** : Appels RPC + génération PDF + email
- **Gestion d'erreurs** : Toasts AURA pour feedback utilisateur
- **Design cohérent** : Utilise les composants AURA existants

## 🚀 Installation

### 1. Dépendances
```bash
# Exécuter un des scripts :
./install-deps.bat        # Windows CMD
./install-deps.ps1        # Windows PowerShell
# ou manuellement :
npm install pdf-lib emailjs-com
```

### 2. Configuration EmailJS
1. Créez un compte sur https://www.emailjs.com/
2. Suivez les instructions dans `EMAILJS_SETUP.md`
3. Créez `.env.local` avec vos clés :
```bash
VITE_EMAILJS_PUBLIC_KEY=pk_xxxxx
VITE_EMAILJS_SERVICE_ID=service_xxxxx
VITE_EMAILJS_TEMPLATE_ID=template_xxxxx
```

## 📁 Structure des fichiers

```
src/
├── services/
│   ├── date.ts                    # Helpers de formatage
│   └── emailService.ts            # Service EmailJS
├── features/booking/
│   ├── pdf/
│   │   └── pdfFill.ts            # Génération PDF + upload
│   ├── modals/
│   │   ├── SendOfferModal.tsx    # Modal envoi email
│   │   ├── RejectOfferModal.tsx  # Modal rejet offre
│   │   └── PerformanceModal.tsx  # Modal performance
│   ├── bookingApi.ts             # API étendue (PDF + email)
│   └── bookingTypes.ts           # Types TypeScript
└── pages/
    └── BookingPage.tsx           # Page principale avec modaux
```

## 🔧 Utilisation

### Mode Démo (sans event_id)
1. Allez sur `/app/booking` ou `/app/administration/booking`
2. Le mode démo s'active automatiquement
3. Tous les boutons fonctionnent avec des données fictives
4. Les modaux s'ouvrent mais les emails ne sont pas envoyés

### Mode Production (avec event_id)
1. Définissez `localStorage.setItem("selected_event_id", "uuid-event")`
2. Rechargez la page
3. Les données réelles sont chargées depuis Supabase
4. La génération PDF et l'envoi d'emails fonctionnent

## 📋 Workflow complet

### 1. Création d'offre
- Via `OfferComposer` ou performance "À faire"
- Statut initial : `draft` ou `offre_a_faire`

### 2. Préparation à l'envoi
- Clic sur "Prêt à envoyer"
- Statut : `ready_to_send`
- **PDF généré automatiquement** et uploadé dans Supabase

### 3. Envoi d'offre
- Clic sur "Envoyer"
- **Modal SendOfferModal** s'ouvre
- Saisie email, CC, message personnalisé, validité
- **Email envoyé via EmailJS** avec lien PDF signé
- Statut : `sent`

### 4. Réponse artiste
- **Acceptation** : Clic "Valider" → statut `accepted`
- **Rejet** : Clic "Rejeter" → **Modal RejectOfferModal** → statut `rejected`

## 🎨 Design AURA

### Couleurs des colonnes Kanban
- **Mode clair** : `bg-white` avec `border-gray-200`
- **Mode sombre** : `bg-[#161C31]` avec `border-[#24304A]`
- **Cohérence** : Exactement les mêmes couleurs que les cartes artistes

### Composants utilisés
- `Modal` : Modaux AURA
- `Button` : Boutons avec variants (primary, ghost, danger)
- `Card` : Cartes d'offres
- `Badge` : Statuts colorés
- `Toast` : Notifications (success, error, warning)

## 🔒 Sécurité

### URLs signées
- **Durée** : 7 jours par défaut
- **Bucket privé** : `offers` avec RLS
- **Génération à la demande** : Pas de stockage permanent

### Variables d'environnement
- **Publiques** : `VITE_*` (dans le bundle client)
- **Privées** : `SUPABASE_SERVICE_KEY` (côté serveur uniquement)

## 🐛 Dépannage

### PDF ne se génère pas
1. Vérifiez que l'offre a un `event_id` et `company_id`
2. Vérifiez les permissions du bucket `offers`
3. Consultez la console pour les erreurs

### Email ne s'envoie pas
1. Vérifiez les clés EmailJS dans `.env.local`
2. Vérifiez que le template contient toutes les variables
3. Testez avec un email valide

### Mode démo ne s'active pas
1. Vérifiez que `localStorage.getItem("selected_event_id")` est vide
2. Le mode démo s'active automatiquement si pas d'event

## 🚀 Prochaines étapes

### Modules à implémenter
1. **Contrats** : `createContractFromAcceptedOffer()`
2. **Budget** : Agrégation des offres acceptées
3. **Finances** : Factures et paiements

### Améliorations possibles
1. **Templates PDF** : Design plus sophistiqué
2. **Historique** : Log des envois d'emails
3. **Notifications** : Alertes en temps réel
4. **API** : Endpoints pour intégrations externes

## 📞 Support

- **Documentation** : `EMAILJS_SETUP.md`
- **Configuration** : Variables d'environnement
- **Debug** : Console du navigateur + logs Supabase
- **Design** : Composants AURA existants

