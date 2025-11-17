# 🔄 WORKFLOW DU SYSTÈME DE BOOKING

## Vue d'ensemble du processus

```
┌──────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW COMPLET D'UNE OFFRE                      │
└──────────────────────────────────────────────────────────────────────┘

1️⃣ CRÉATION PERFORMANCE
   - Timeline / PerformanceModal
   - Enregistrement dans `artist_performances`
   - booking_status = 'offre_a_faire'
   
2️⃣ AFFICHAGE EN KANBAN
   - Colonne "Brouillon / À faire"
   - Carte de performance avec bouton "Établir offre"
   
3️⃣ CRÉATION OFFRE
   - Click "Établir offre" → OfferComposer
   - Pré-remplissage depuis la performance
   - Remplissage formulaire complet
   
4️⃣ GÉNÉRATION PDF
   - Click "Générer offre" → Validation champs
   - Génération PDF via pdf-lib
   - Prévisualisation dans PdfPreviewModal
   
5️⃣ FINALISATION
   - Click "Prêt à envoyer" depuis preview
   - Sauvegarde en BDD (status: ready_to_send)
   - PDF stocké dans Supabase Storage
   - Déplacement vers colonne "Prêt à envoyer"
   
6️⃣ ENVOI EMAIL
   - Click "Envoyer" → SendOfferModal
   - Email via EmailJS avec PDF joint
   - Statut → 'sent'
   - Performance → 'offre_envoyee'
   
7️⃣ RÉPONSE
   A. ACCEPTATION :
      - Statut → 'accepted'
      - Création automatique CONTRAT
      - Performance → 'offre_acceptee'
   
   B. REJET :
      - RejectOfferModal
      - Statut → 'rejected'
      - Performance → 'offre_rejetee'
      - Enregistrement raison + date
```

---

## 📋 DÉTAIL DES ÉTAPES

### ÉTAPE 1 : Création de la performance

**Source :** `LineupTimelineView.tsx` ou `PerformanceModal.tsx`

**Données requises :**
- `artist_id`
- `event_id`
- `event_day_id`
- `event_stage_id`
- `performance_time`
- `duration` (minutes)
- `booking_status` = `'offre_a_faire'`
- `fee_amount` (optionnel, pré-remplissage)
- `fee_currency` (optionnel)

**Code API :**
```typescript
const { data, error } = await supabase
  .from('artist_performances')
  .insert({
    artist_id,
    event_id,
    event_day_id,
    event_stage_id,
    performance_time,
    duration,
    booking_status: 'offre_a_faire',
    fee_amount,
    fee_currency
  });
```

---

### ÉTAPE 2 : Affichage dans le Kanban

**Source :** `BookingPage.tsx` → `loadArtistPerformances()`

**Filtrage des performances :**
```typescript
const { data, error } = await supabase
  .from('artist_performances')
  .select(`
    id,
    artist_id,
    event_stage_id,
    booking_status,
    performance_time,
    duration,
    fee_amount,
    fee_currency,
    artist:artists(id, name),
    event_day:event_days(id, date),
    stage:event_stages(id, name)
  `)
  .in('booking_status', ['offre_a_faire', 'offre_rejetee'])
  .in('event_day_id', eventDayIds);
```

**Mapping en items Kanban :**
```typescript
const offreAFaireItems = artistPerformances
  .filter(perf => perf.booking_status === 'offre_a_faire')
  .filter(perf => {
    // Exclure celles avec offre déjà créée
    return !offers.some(offer => 
      offer.artist_id === perf.artist_id && 
      offer.stage_id === perf.event_stage_id
    );
  })
  .map(perf => ({
    id: `perf_${perf.id}`,
    type: 'performance',
    artist_name: perf.artist?.name,
    stage_name: perf.stage?.name,
    performance_time: perf.performance_time,
    duration: perf.duration,
    fee_amount: perf.fee_amount,
    fee_currency: perf.fee_currency,
    status: 'offre_a_faire'
  }));
```

---

### ÉTAPE 3 : Création de l'offre

**Trigger :** Click sur "Établir offre" dans la carte de performance

**Fonction :** `handleQuickAction()` dans `BookingPage.tsx`

**Process :**

1. **Récupération de la performance complète :**
```typescript
const { data: performance, error } = await supabase
  .from('artist_performances')
  .select(`
    *,
    artists(id, name),
    event_days(id, date),
    event_stages(id, name)
  `)
  .eq('id', performanceId)
  .single();
```

2. **Pré-remplissage du formulaire :**
```typescript
const prefilledData = {
  artist_name: performance.artists?.name,
  artist_id: performance.artist_id,
  stage_name: performance.event_stages?.name,
  stage_id: performance.event_stages?.id,
  event_day_date: performance.event_days?.date,
  performance_time: performance.performance_time,
  duration: performance.duration,
  fee_amount: performance.fee_amount,
  fee_currency: performance.fee_currency,
  performance_id: performance.id
};

setPrefilledOfferData(prefilledData);
setShowComposer(true);
```

3. **Ouverture du `OfferComposer`**

---

### ÉTAPE 4 : Remplissage du formulaire dans OfferComposer

**Champs obligatoires :**
- ✅ Artiste
- ✅ Contact Booking / Agence
- ✅ Date
- ✅ Heure (ou TBC)
- ✅ Scène
- ✅ Deadline (validity_date)
- ✅ Type de montant (Net OU Brut soumis à impôt)
- ✅ Montant
- ✅ Commission Agence (%)

**Champs optionnels :**
- Frais additionnels (Prod, Backline, Buyout Hotel/Meal, Flight Contribution, Technical)
- Extras (assignation Festival/Artist)
- Clauses d'exclusivité

**Validation :**
```typescript
const validateRequiredFields = (): string[] => {
  const errors: string[] = [];
  
  if (!formData.artist_id) errors.push('artist_id');
  if (!formData.stage_id) errors.push('stage_id');
  if (!performanceDate) errors.push('performanceDate');
  if (!performanceTime) errors.push('performanceTime');
  if (!formData.validity_date) errors.push('validity_date');
  
  // Montant obligatoire
  const hasAmount = (formData.amount_is_net && formData.amount_net) || 
                   (formData.amount_gross_is_subject_to_withholding && formData.amount_gross);
  if (!hasAmount) errors.push('amount');
  
  // Type de montant obligatoire
  if (!formData.amount_is_net && !formData.amount_gross_is_subject_to_withholding) {
    errors.push('amount_type');
  }
  
  // Commission obligatoire
  if (!formData.agency_commission_pct) errors.push('agency_commission_pct');
  
  return errors;
};
```

---

### ÉTAPE 5 : Génération du PDF

**Trigger :** Click "Générer offre" dans OfferComposer

**Fonction :** `handleGeneratePdf()` dans `OfferComposer.tsx`

**Process :**

1. **Validation des champs** (voir ci-dessus)

2. **Préparation des données PDF :**
```typescript
const pdfData: OfferPdfData = {
  offerId: `offer_${Date.now()}`,
  artistName: selectedArtist?.name,
  stageName: selectedStage?.name,
  startTimeHHmm: performanceTime === 'TBC' ? 'TBC' : performanceTime,
  dateLabel: performanceDate,
  durationMin: prefilledData?.duration || 60,
  amountNet: formData.amount_is_net ? formData.amount_net : formData.amount_gross,
  agencyCommissionPct: formData.agency_commission_pct,
  currency: formData.currency,
  validityDate: formData.validity_date,
  version: 1,  // ou version suivante pour modification
  
  // Type de montant
  amountIsNet: formData.amount_is_net,
  amountGrossIsSubjectToWithholding: formData.amount_gross_is_subject_to_withholding,
  amountDisplay: formData.amount_is_net ? formData.amount_net : formData.amount_gross,
  amountTypeLabel: formData.amount_is_net 
    ? 'MONTANT NET DE TAXES' 
    : 'MONTANT BRUT, SUJET A L\'IMPOT A LA SOURCE',
  
  // Frais additionnels
  prodFeeAmount, prodFeeCurrency,
  backlineFeeAmount, backlineFeeCurrency,
  buyoutHotelAmount, buyoutHotelCurrency,
  buyoutMealAmount, buyoutMealCurrency,
  flightContributionAmount, flightContributionCurrency,
  technicalFeeAmount, technicalFeeCurrency,
  
  // Extras et clauses
  extras: extrasForPdf,
  exclusivityClauses: exclusivityClausesForPdf
};
```

3. **Génération du PDF :**
```typescript
import { generateOfferPdfAndUpload } from './pdf/pdfFill';

const pdfFileName = generatePdfFileName(artistName, true);
const pdfUrl = await generateOfferPdfAndUpload({
  data: pdfData,
  fileBaseName: pdfFileName
});
```

4. **Prévisualisation :**
```typescript
setPreviewPdfUrl(pdfUrl);
setCurrentOfferData(pdfData);
setShowPdfPreview(true);
```

**Modal PdfPreviewModal affiche :**
- Iframe du PDF
- Boutons : "Modifier" / "Prêt à envoyer"

---

### ÉTAPE 6 : Finalisation (Prêt à envoyer)

**Trigger :** Click "Prêt à envoyer" dans PdfPreviewModal

**Fonction :** `handlePdfReadyToSend()` dans OfferComposer

**Process :**

1. **Détection du mode (création ou modification) :**
```typescript
const isModification = prefilledData?.isModification === true;
```

2. **Sauvegarde en base :**

   A. **Mode création (v1) :**
   ```typescript
   const newOffer = await createOffer({ 
     companyId, 
     eventId, 
     payload: {
       ...formData,
       status: 'ready_to_send',
       date_time: combinedDateTime,
       amount_display: effectiveAmount
     }
   });
   ```

   B. **Mode modification (v2+) :**
   ```typescript
   const newVersion = await createOfferVersion({ 
     companyId, 
     eventId, 
     originalOfferId: prefilledData.originalOfferId,
     payload: {
       ...formData,
       status: 'ready_to_send'
     }
   });
   ```

3. **Sauvegarde des extras :**
```typescript
await saveOfferExtras(offerId, selectedExtras);
```

4. **Sauvegarde du chemin PDF :**
```typescript
const pdfStoragePath = extractPathFromUrl(pdfUrl);

await supabase
  .from('offers')
  .update({ pdf_storage_path: pdfStoragePath })
  .eq('id', offerId);
```

5. **Mise à jour de la performance :**
```typescript
await supabase
  .from('artist_performances')
  .update({ booking_status: 'offre_envoyee' })
  .eq('id', performanceId);
```

6. **Log d'activité :**
```typescript
await supabase
  .from('offer_activity_log')
  .insert({
    offer_id: offerId,
    action: 'moved',
    meta: { new_status: 'ready_to_send' }
  });
```

**Résultat :** L'offre apparaît dans la colonne "Prêt à envoyer" du Kanban

---

### ÉTAPE 7 : Envoi de l'offre par email

**Trigger :** Click "Envoyer" sur la carte dans "Prêt à envoyer"

**Fonction :** `handleSendOffer()` dans BookingPage

**Modal :** SendOfferModal

**Champs du modal :**
- Email (auto-rempli depuis `agency_contact_id`)
- CC (optionnel, multi-emails séparés par virgule)
- Prénom destinataire (optionnel)
- Date de validité (auto-remplie depuis `validity_date`)
- Expéditeur (sélection parmi `AVAILABLE_SENDERS`)
- Signature (sélection depuis `email_signatures`)
- Message personnalisé (optionnel)

**Process d'envoi :**

1. **Validation email :**
```typescript
const validateEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};
```

2. **Récupération de l'URL signée du PDF :**
```typescript
const { data, error } = await supabase.storage
  .from('offers')
  .createSignedUrl(offer.pdf_storage_path, 604800);  // 7 jours

const pdfUrl = data?.signedUrl;
```

3. **Génération du template HTML responsive :**
```typescript
import { generateEmailJSHtmlTemplate } from '../utils/emailJSTemplates';

const htmlContent = generateEmailJSHtmlTemplate({
  artistName,
  eventName,
  senderName: emailData.sender?.name,
  recipientName: emailData.recipientFirstName,
  validityDate: emailData.validityDate,
  customMessage: emailData.customMessage,
  pdfDownloadUrl: pdfUrl,
  pdfFileName: `OFFRE_${eventName}_${artistName}.pdf`
});
```

4. **Envoi via EmailJS :**
```typescript
import { sendOfferEmail, initializeEmailJS } from '../services/emailService';

initializeEmailJS();

const result = await sendOfferEmail({
  toEmail: emailData.email,
  toName: emailData.recipientFirstName,
  ccEmails: emailData.ccEmails,
  sender: emailData.sender,
  subject: `Offre ${artistName} - ${eventName}`,
  htmlContent: htmlContent,
  pdfUrl: pdfUrl,
  pdfFileName: `OFFRE_${eventName}_${artistName}.pdf`,
  artistName,
  eventName,
  validityDate: emailData.validityDate,
  customMessage: emailData.customMessage
});
```

5. **Mise à jour des statuts :**
```typescript
// Offre → 'sent'
await moveOffer(offerId, 'sent');

// Performance → 'offre_envoyee'
await supabase
  .from('artist_performances')
  .update({ booking_status: 'offre_envoyee' })
  .eq('id', performanceId);
```

6. **Log d'activité :**
```typescript
await supabase
  .from('offer_activity_log')
  .insert({
    offer_id: offerId,
    action: 'sent',
    meta: { 
      sent_to: emailData.email,
      sent_at: new Date().toISOString()
    }
  });
```

**Résultat :** L'offre se déplace dans la colonne "Envoyé"

---

### ÉTAPE 8A : Acceptation de l'offre

**Trigger :** Click "Valider" sur la carte dans "Envoyé" (ou drag vers "Accepté")

**Fonction :** `moveOffer(offerId, 'accepted')` dans `bookingApi.ts`

**Process :**

1. **Mise à jour du statut de l'offre :**
```typescript
await supabase
  .from('offers')
  .update({ 
    status: 'accepted',
    updated_at: new Date().toISOString()
  })
  .eq('id', offerId);
```

2. **Création automatique du contrat :**
```typescript
import { createContractFromAcceptedOffer } from '../features/contracts/contractsApi';

const contract = await createContractFromAcceptedOffer(offerId);
```

**Détails de création du contrat :**
```typescript
// Récupération de l'offre acceptée
const { data: offer } = await supabase
  .from('offers')
  .select(`
    id,
    artist_id,
    event_id,
    amount_net,
    amount_gross,
    currency,
    artists!inner (id, name, agency_contact_id),
    events!inner (id, name)
  `)
  .eq('id', offerId)
  .eq('status', 'accepted')
  .single();

// Récupération du contact agence
let managementEmail = '';
if (offer.artists.agency_contact_id) {
  const { data: agencyContact } = await supabase
    .from('contacts')
    .select('email')
    .eq('id', offer.artists.agency_contact_id)
    .single();
  
  managementEmail = agencyContact?.email || '';
}

// Création du titre
const contractTitle = `Contrat ${offer.artists.name} - ${offer.events.name}`;

// Historique initial
const initialHistory = [{
  at: new Date().toISOString(),
  action: 'created_from_offer',
  details: `Contrat créé automatiquement depuis l'offre acceptée`
}];

// Insertion
const { data: contract } = await supabase
  .from('contracts')
  .insert({
    artist_id: offer.artist_id,
    contract_title: contractTitle,
    status: 'to_receive',
    management_email: managementEmail,
    history: initialHistory,
    source_offer_id: offerId,
    event_id: offer.event_id
  })
  .select()
  .single();

// Lier l'offre au contrat
await supabase
  .from('offers')
  .update({ contract_id: contract.id })
  .eq('id', offerId);
```

3. **Mise à jour de la performance :**
```typescript
await supabase
  .from('artist_performances')
  .update({ booking_status: 'offre_acceptee' })
  .eq('artist_id', offer.artist_id)
  .eq('event_stage_id', offer.stage_id);
```

4. **Log d'activité :**
```typescript
await supabase
  .from('offer_activity_log')
  .insert({
    offer_id: offerId,
    action: 'accepted',
    meta: { 
      contract_id: contract.id,
      contract_title: contractTitle
    }
  });
```

5. **Déclenchement d'événements :**
```typescript
// Événement pour rafraîchir l'UI
window.dispatchEvent(new CustomEvent('offer-status-changed', {
  detail: { offerId, newStatus: 'accepted' }
}));

window.dispatchEvent(new CustomEvent('contract-created-from-offer', {
  detail: { 
    offerId, 
    contractId: contract.id,
    contractTitle: contract.contract_title
  }
}));
```

**Résultat :** L'offre dans "Accepté", contrat créé dans le module Contracts

---

### ÉTAPE 8B : Rejet de l'offre

**Trigger :** Click "Rejeter" sur la carte (ou drag vers "Rejeté")

**Modal :** RejectOfferModal

**Champs :**
- Raison du refus (obligatoire, textarea)

**Process :**

1. **Mise à jour de l'offre :**
```typescript
await supabase
  .from('offers')
  .update({ 
    status: 'rejected',
    rejection_reason: rejectionReason,
    updated_at: new Date().toISOString()
  })
  .eq('id', offerId);
```

2. **Mise à jour de la performance :**
```typescript
await supabase
  .from('artist_performances')
  .update({ 
    booking_status: 'offre_rejetee',
    rejection_reason: rejectionReason,
    rejection_date: new Date().toISOString()
  })
  .eq('artist_id', offer.artist_id)
  .eq('event_stage_id', offer.stage_id);
```

3. **Log d'activité :**
```typescript
await supabase
  .from('offer_activity_log')
  .insert({
    offer_id: offerId,
    action: 'rejected',
    meta: { 
      rejection_reason: rejectionReason,
      rejected_at: new Date().toISOString()
    }
  });
```

4. **Déclenchement d'événement :**
```typescript
window.dispatchEvent(new CustomEvent('offer-status-changed', {
  detail: { offerId, newStatus: 'rejected' }
}));
```

**Résultat :** L'offre dans "Rejeté" avec raison affichée

---

## 🔄 CAS SPÉCIAL : Modification d'offre (Versioning)

**Trigger :** Click "Modifier" sur une offre existante dans "Envoyé" ou "Accepté"

**Process :**

1. **Ouverture du Composer en mode modification :**
```typescript
const prefilledData = {
  isModification: true,
  originalOfferId: offer.id,
  originalVersion: offer.version || 1,
  // Toutes les données de l'offre actuelle
  ...offer
};

setPrefilledOfferData(prefilledData);
setShowComposer(true);
```

2. **Génération PDF avec nouveau numéro de version :**
```typescript
const pdfData = {
  ...offerData,
  version: originalVersion + 1  // V2, V3, etc.
};
```

3. **Sauvegarde avec versioning :**
```typescript
const newVersion = await createOfferVersion({
  companyId,
  eventId,
  originalOfferId: originalOfferId,
  payload: {
    ...formData,
    status: 'ready_to_send'
  }
});
```

La fonction `createOfferVersion` :
- Appelle `get_next_offer_version(originalOfferId)` → obtient version 2, 3, etc.
- Insère avec `version = nextVersion` et `original_offer_id = baseOfferId`

**Résultat :** Nouvelle version de l'offre créée, version précédente conservée

---

*[Suite dans BOOKING_SYSTEM_API.md]*

