# 🎯 PROMPT D'IMPLÉMENTATION - MODAL OFFER COMPOSER

## ⚠️ INSTRUCTIONS PRÉLIMINAIRES CRITIQUES

**AVANT TOUTE MODIFICATION, TU DOIS :**

1. ✅ **VÉRIFIER** si un modal d'offre existe déjà dans le nouveau SaaS
2. ✅ **ANALYSER** son code actuel et ses fonctionnalités existantes
3. ✅ **COMPARER** avec la spécification ci-dessous
4. ✅ **IDENTIFIER** ce qui manque ou doit être modifié
5. ✅ **NE JAMAIS** supprimer de fonctionnalités existantes sans validation

**APPROCHE** :
- Si le modal existe → MODE MODIFICATION (ajouter/corriger fonctionnalités)
- Si le modal n'existe pas → MODE CRÉATION (implémenter depuis zéro)

---

## 📋 CONTEXTE DU PROJET

**SaaS** : GO-PROD V3 (Nouveau)  
**Module** : Booking / Gestion des Offres Artistes  
**Composant** : Modal "Établir une offre" / "Modifier une offre" (OfferComposer)  
**Documentation complète** : `docs/OFFER_COMPOSER_COMPLETE.md`

---

## 🎯 OBJECTIF

Implémenter ou modifier un modal React complexe pour la création et modification d'offres artistes avec :

### Fonctionnalités Essentielles (OBLIGATOIRES)

1. **3 Modes de Fonctionnement**
   - ✅ Création d'une nouvelle offre (version 1)
   - ✅ Modification d'une offre existante (versioning automatique → v2, v3, etc.)
   - ✅ Édition directe d'une offre (sans versioning)

2. **Formulaire en 3 Sections**
   - ✅ Section 1 : Données de base (artiste, contact, date, heure, scène, deadline)
   - ✅ Section 2 : Financier (devise, montant net/brut, commission, 6 frais additionnels)
   - ✅ Section 3 : Extras et clauses (extras artist/festival, clauses d'exclusivité)

3. **Validation Stricte**
   - ✅ 9 champs obligatoires minimum
   - ✅ Affichage bordures rouges + alert en cas d'erreur
   - ✅ Blocage de la sauvegarde si validation échoue

4. **Génération PDF**
   - ✅ Prévisualisation avant sauvegarde finale
   - ✅ Upload automatique dans Supabase Storage (bucket 'offers')
   - ✅ Modal de prévisualisation avec 3 actions : Annuler / Modifier / Prêt à envoyer

5. **Versioning Automatique**
   - ✅ Chaque modification d'offre existante crée une nouvelle version
   - ✅ Lien via `original_offer_id` vers la version 1
   - ✅ Numéro de version incrémenté automatiquement
   - ✅ Conservation de l'historique complet

6. **Gestion Extras et Clauses**
   - ✅ Sélection extras avec assignation mutuellement exclusive (Artist OU Festival)
   - ✅ Multi-sélection de clauses d'exclusivité
   - ✅ Sauvegarde dans tables de liaison dédiées

---

## 🗂️ STRUCTURE DE DONNÉES

### 1. Props du Composant

```typescript
interface OfferComposerProps {
  isOpen: boolean;
  onClose: () => void;
  companyId: string;
  eventId: string;
  eventName?: string;
  onSuccess: () => void;
  editingOffer?: any;
  prefilledData?: {
    // Identifiants
    artist_id?: string;
    stage_id?: string;
    agency_contact_id?: string;
    
    // Date/Heure
    event_day_date?: string;           // Format: 'YYYY-MM-DD'
    performance_time?: string;          // Format: 'HH:MM:SS'
    date_time?: string;                 // Format: ISO datetime
    duration?: number;
    
    // Financier de base
    fee_amount?: number;
    fee_currency?: CurrencyCode;        // 'EUR' | 'GBP' | 'USD' | 'CHF'
    amount_net?: number;
    amount_gross?: number;
    amount_is_net?: boolean;
    amount_gross_is_subject_to_withholding?: boolean;
    amount_display?: number;
    agency_commission_pct?: number;
    currency?: CurrencyCode;
    
    // Frais additionnels (6 types)
    prod_fee_amount?: number;
    prod_fee_currency?: CurrencyCode;
    backline_fee_amount?: number;
    backline_fee_currency?: CurrencyCode;
    buyout_hotel_amount?: number;
    buyout_hotel_currency?: CurrencyCode;
    buyout_meal_amount?: number;
    buyout_meal_currency?: CurrencyCode;
    flight_contribution_amount?: number;
    flight_contribution_currency?: CurrencyCode;
    technical_fee_amount?: number;
    technical_fee_currency?: CurrencyCode;
    
    // Autres
    validity_date?: string;
    withholding_note?: string;
    terms_json?: any;                   // { selectedClauseIds: string[] }
    
    // Versioning (CRITIQUE pour mode Modification)
    isModification?: boolean;           // TRUE = mode modification avec versioning
    originalOfferId?: string;           // UUID de l'offre originale (v1)
    originalVersion?: number;           // Numéro de version actuelle
    version?: number;
  };
}
```

### 2. États React Nécessaires

**États Principaux (13)** :
```typescript
const [formData, setFormData] = useState<CreateOfferPayload>({...});
const [performanceDate, setPerformanceDate] = useState<string>('');
const [performanceTime, setPerformanceTime] = useState<string>('');
const [savedPerformanceTime, setSavedPerformanceTime] = useState<string>('');
const [artists, setArtists] = useState<Array<{id: string, name: string}>>([]);
const [contacts, setContacts] = useState<Array<{id: string, name: string, email?: string}>>([]);
const [stages, setStages] = useState<Array<{id: string, name: string, capacity: number}>>([]);
const [eventDays, setEventDays] = useState<Array<{date: string}>>([]);
const [loading, setLoading] = useState(false);
const [uploadingFile, setUploadingFile] = useState(false);
const [validationErrors, setValidationErrors] = useState<string[]>([]);
const [showValidationAlert, setShowValidationAlert] = useState(false);
const [contactFunctions, setContactFunctions] = useState<any[]>([]);
```

**États Financiers Additionnels (12)** :
```typescript
const [prodFeeAmount, setProdFeeAmount] = useState<number | undefined>();
const [prodFeeCurrency, setProdFeeCurrency] = useState<CurrencyCode>('EUR');
const [backlineFeeAmount, setBacklineFeeAmount] = useState<number | undefined>();
const [backlineFeeCurrency, setBacklineFeeCurrency] = useState<CurrencyCode>('EUR');
const [buyoutHotelAmount, setBuyoutHotelAmount] = useState<number | undefined>();
const [buyoutHotelCurrency, setBuyoutHotelCurrency] = useState<CurrencyCode>('EUR');
const [buyoutMealAmount, setBuyoutMealAmount] = useState<number | undefined>();
const [buyoutMealCurrency, setBuyoutMealCurrency] = useState<CurrencyCode>('EUR');
const [flightContributionAmount, setFlightContributionAmount] = useState<number | undefined>();
const [flightContributionCurrency, setFlightContributionCurrency] = useState<CurrencyCode>('EUR');
const [technicalFeeAmount, setTechnicalFeeAmount] = useState<number | undefined>();
const [technicalFeeCurrency, setTechnicalFeeCurrency] = useState<CurrencyCode>('EUR');
```

**États PDF et Extras (7)** :
```typescript
const [showPdfPreview, setShowPdfPreview] = useState(false);
const [previewPdfUrl, setPreviewPdfUrl] = useState<string | null>(null);
const [currentOfferData, setCurrentOfferData] = useState<OfferPdfData | null>(null);
const [selectedExtras, setSelectedExtras] = useState<Record<string, 'festival' | 'artist'>>({});
const [exclusivityClauses, setExclusivityClauses] = useState<string[]>([]);
const [availableExclusivityClauses, setAvailableExclusivityClauses] = useState<any[]>([]);
const [availableBookingExtras, setAvailableBookingExtras] = useState<any[]>([]);
```

---

## 📐 ARCHITECTURE DU FORMULAIRE

### Section 1 : DONNÉES DE BASE

**État initial** : Ouverte (`<details open>`)

| Champ | Type Input | Obligatoire | Description |
|-------|------------|-------------|-------------|
| Artiste | Select avec bouton "+" | ✅ OUI | Sélection artiste ou création rapide |
| Contact Booking | Select avec bouton "+" | ✅ OUI | Filtre automatique sur contacts avec fonction "booking agent" |
| Date | DatePicker | ✅ OUI | Date de la performance |
| Heure | Input Text avec bouton TBC | ✅ OUI | Format HH:MM ou 'TBC' |
| Scène | Select | ✅ OUI | Sélection scène avec affichage capacité |
| Deadline | DatePicker | ✅ OUI | Date limite validité de l'offre |

**Fonctionnalités spéciales** :

1. **Bouton TBC (Heure)** :
   ```typescript
   const handleToggleTBC = () => {
     if (performanceTime === 'TBC') {
       setPerformanceTime(savedPerformanceTime || '20:00');
     } else {
       setSavedPerformanceTime(performanceTime);
       setPerformanceTime('TBC');
     }
   };
   ```

2. **Ajout rapide artiste** :
   - Ouvre modal simple (nom uniquement)
   - INSERT dans table `artists`
   - Auto-sélection du nouvel artiste
   
3. **Ajout rapide contact** :
   - Ouvre modal formulaire complet
   - INSERT dans table `contacts`
   - Auto-sélection du nouveau contact

---

### Section 2 : FINANCIER

**État initial** : Fermée (`<details>`)

#### 2.1 Type de Montant (XOR - Un seul sélectionnable)

**Deux checkboxes mutuellement exclusives** :

```typescript
// Checkbox 1
<Checkbox
  label="Montant net de taxes (le montant saisi est net)"
  checked={formData.amount_is_net}
  onChange={(checked) => handleToggleAmountIsNet(checked)}
/>

// Checkbox 2
<Checkbox
  label="Montant brut, soumis à l'impôt à la source"
  checked={formData.amount_gross_is_subject_to_withholding}
  onChange={(checked) => handleToggleGrossWithholding(checked)}
/>
```

**Logique** : Au moins une des deux DOIT être cochée à tout moment.

#### 2.2 Champs Financiers de Base

| Champ | Type | Obligatoire | Valeur par défaut |
|-------|------|-------------|-------------------|
| Devise | Select | ✅ OUI | EUR |
| Montant | Number | ✅ OUI | - |
| Commission Agence (%) | Number | ✅ OUI | - |

**Options devise** : EUR, GBP, USD, CHF

#### 2.3 Frais Additionnels (6 types, optionnels)

Chaque frais a 2 champs (montant + devise) :

1. **PROD FEE**
   - `prod_fee_amount` (number)
   - `prod_fee_currency` (CurrencyCode)

2. **BACKLINE FEE**
   - `backline_fee_amount` (number)
   - `backline_fee_currency` (CurrencyCode)

3. **BUY OUT HOTEL**
   - `buyout_hotel_amount` (number)
   - `buyout_hotel_currency` (CurrencyCode)

4. **BUY OUT MEAL**
   - `buyout_meal_amount` (number)
   - `buyout_meal_currency` (CurrencyCode)

5. **FLIGHT CONTRIBUTION**
   - `flight_contribution_amount` (number)
   - `flight_contribution_currency` (CurrencyCode)

6. **TECHNICAL FEE**
   - `technical_fee_amount` (number)
   - `technical_fee_currency` (CurrencyCode)

**Layout** : Grid responsive 3 colonnes, chaque frais prend 1 case.

---

### Section 3 : CLAUSES ET EXTRA

**État initial** : Fermée (`<details>`)

#### 3.1 Extras (Tableau)

**Structure** : Tableau HTML 3 colonnes

| Extra | Artist | Festival |
|-------|--------|----------|
| [Nom extra] | Radio/Checkbox | Radio/Checkbox |

**Comportement** :
- Choix **mutuellement exclusif** par ligne
- Cliquer "Artist" désélectionne "Festival" et inversement
- Possible de ne rien cocher (extra non inclus)

**État** : `Record<extraId, 'artist' | 'festival'>`

```typescript
// Exemple
{
  'uuid-backline': 'artist',
  'uuid-hebergement': 'festival'
}
```

**Gestion du clic** :

```typescript
const handleExtraAssignment = (
  extraId: string,
  assignedTo: 'festival' | 'artist' | null
) => {
  setSelectedExtras(prev => {
    const newExtras = { ...prev };
    if (assignedTo === null) {
      delete newExtras[extraId];
    } else {
      newExtras[extraId] = assignedTo;
    }
    return newExtras;
  });
};
```

#### 3.2 Clauses d'Exclusivité

**Structure** : Liste de checkboxes simples

**État** : `string[]` (array des IDs de clauses sélectionnées)

```typescript
// Exemple
['uuid-clause-1', 'uuid-clause-3', 'uuid-clause-5']
```

**Gestion du toggle** :

```typescript
const handleExclusivityClauseToggle = (clauseId: string, checked: boolean) => {
  setExclusivityClauses(prev => 
    checked 
      ? [...prev, clauseId]
      : prev.filter(item => item !== clauseId)
  );
};
```

---

## 🔍 VALIDATION STRICTE

### Champs Obligatoires (9)

```typescript
const validateRequiredFields = (): string[] => {
  const errors: string[] = [];

  // 1. Artiste
  if (!formData.artist_id) errors.push('artist_id');
  
  // 2. Scène
  if (!formData.stage_id) errors.push('stage_id');
  
  // 3. Date
  if (!performanceDate) errors.push('performanceDate');
  
  // 4. Heure
  if (!performanceTime) errors.push('performanceTime');
  
  // 5. Contact booking (peut être temporairement optionnel)
  // if (!formData.agency_contact_id) errors.push('agency_contact_id');
  
  // 6. Date de validité
  if (!formData.validity_date) errors.push('validity_date');
  
  // 7. Au moins un montant renseigné
  const hasAmount = 
    (formData.amount_is_net && formData.amount_net) || 
    (formData.amount_gross_is_subject_to_withholding && formData.amount_gross);
  if (!hasAmount) errors.push('amount');
  
  // 8. Au moins un type de montant sélectionné
  if (!formData.amount_is_net && !formData.amount_gross_is_subject_to_withholding) {
    errors.push('amount_type');
  }

  // 9. Commission d'agence
  if (!formData.agency_commission_pct) errors.push('agency_commission_pct');

  return errors;
};
```

### Affichage des Erreurs

**1. Bordures rouges sur champs** :

```typescript
const getFieldClassName = (fieldName: string, baseClassName: string = ''): string => {
  const errorClass = validationErrors.includes(fieldName) 
    ? 'border-red-500 bg-red-50' 
    : '';
  return `${baseClassName} ${errorClass}`.trim();
};
```

**2. Alert en haut du modal** :

```typescript
{validationErrors.length > 0 && (
  <div className="bg-red-50 border-2 border-red-500 rounded-lg p-4 mb-4">
    <h3 className="text-sm font-bold text-red-800">
      ⚠️ Champs obligatoires manquants
    </h3>
    <ul className="list-disc list-inside text-sm text-red-700">
      {getErrorMessages(validationErrors).map((message, index) => (
        <li key={index}>{message}</li>
      ))}
    </ul>
  </div>
)}
```

**Mapping des messages** :

```typescript
const errorMap: Record<string, string> = {
  'artist_id': 'Artiste',
  'stage_id': 'Scène',
  'performanceDate': 'Date',
  'performanceTime': 'Heure',
  'agency_contact_id': 'Agence/Contact Booking',
  'validity_date': 'Date de validité de l\'offre (DEADLINE)',
  'amount': 'Montant',
  'amount_type': 'Type de montant (Montant net OU Montant brut)',
  'agency_commission_pct': 'Commission Agence (%)'
};
```

---

## 🔄 LOGIQUE DE SAUVEGARDE (CRITIQUE)

### Fonction handleSubmit - Cœur du Système

```typescript
const handleSubmit = async (
  status: 'draft' | 'ready_to_send', 
  pdfUrl?: string
): Promise<boolean | undefined> => {
  try {
    // 1. VALIDATION
    const errors = validateRequiredFields();
    if (errors.length > 0) {
      setValidationErrors(errors);
      return;
    }
    
    setLoading(true);
    
    // 2. CONSTRUCTION DATE_TIME
    let dateTime = '';
    if (performanceDate && performanceTime) {
      if (performanceTime === 'TBC') {
        dateTime = `${performanceDate}T00:00:00`;
      } else {
        const timeFormatted = performanceTime.includes(':') 
          ? performanceTime 
          : `${performanceTime}:00`;
        dateTime = `${performanceDate}T${timeFormatted}:00`;
      }
    }
    
    // 3. CALCUL MONTANT DISPLAY
    const amountDisplay = formData.amount_is_net 
      ? formData.amount_net 
      : formData.amount_gross;
    
    // 4. CONSTRUCTION PAYLOAD
    const payload = {
      ...formData,
      date_time: dateTime,
      amount_net: formData.amount_is_net ? formData.amount_net : undefined,
      amount_gross: formData.amount_is_net ? undefined : formData.amount_gross,
      amount_display: amountDisplay,
      
      // Frais additionnels
      prod_fee_amount: prodFeeAmount,
      prod_fee_currency: prodFeeAmount ? prodFeeCurrency : undefined,
      backline_fee_amount: backlineFeeAmount,
      backline_fee_currency: backlineFeeAmount ? backlineFeeCurrency : undefined,
      buyout_hotel_amount: buyoutHotelAmount,
      buyout_hotel_currency: buyoutHotelAmount ? buyoutHotelCurrency : undefined,
      buyout_meal_amount: buyoutMealAmount,
      buyout_meal_currency: buyoutMealAmount ? buyoutMealCurrency : undefined,
      flight_contribution_amount: flightContributionAmount,
      flight_contribution_currency: flightContributionAmount ? flightContributionCurrency : undefined,
      technical_fee_amount: technicalFeeAmount,
      technical_fee_currency: technicalFeeAmount ? technicalFeeCurrency : undefined,
      
      // Clauses d'exclusivité
      terms_json: {
        selectedClauseIds: exclusivityClauses
      },
      
      status
    };

    let offerId: string;
    
    // 5. DÉTERMINER LE MODE (CRITIQUE)
    const isModification = prefilledData?.isModification === true;
    
    if (editingOffer) {
      // MODE ÉDITION DIRECTE (modifie l'offre existante, même ID)
      await updateOffer(editingOffer.id, payload);
      offerId = editingOffer.id;
      console.log('✏️ Offre éditée:', offerId);
      
    } else if (isModification && prefilledData?.originalOfferId) {
      // MODE MODIFICATION AVEC VERSIONING (crée nouvelle version)
      console.log('🔄 Création nouvelle version');
      const newVersion = await createOfferVersion({ 
        companyId, 
        eventId, 
        originalOfferId: prefilledData.originalOfferId,
        payload 
      });
      offerId = newVersion.id;
      console.log(`✅ Version ${newVersion.version} créée: ${offerId}`);
      
    } else {
      // MODE CRÉATION NORMALE (nouvelle offre v1)
      const newOffer = await createOffer({ companyId, eventId, payload });
      offerId = newOffer.id;
      console.log(`✅ Nouvelle offre créée: ${offerId} (v1)`);
    }

    // 6. SAUVEGARDER LES EXTRAS
    await saveOfferExtras(offerId, selectedExtras);
    
    // 7. GÉRER LE PDF SI 'ready_to_send'
    if (status === 'ready_to_send') {
      if (pdfUrl) {
        // PDF déjà généré depuis prévisualisation
        let pdfStoragePath = extractPathFromUrl(pdfUrl);
        await supabase
          .from('offers')
          .update({ pdf_storage_path: pdfStoragePath })
          .eq('id', offerId);
      }
      
      // Mettre à jour statut performance
      await updatePerformanceBookingStatus(offerId);
    }
    
    // 8. CALLBACK SUCCÈS
    await onSuccess();
    handleClose();
    return true;
    
  } catch (error) {
    console.error('❌ Erreur sauvegarde:', error);
    alert(`Erreur: ${error instanceof Error ? error.message : error}`);
  } finally {
    setLoading(false);
  }
};
```

### Fonction saveOfferExtras

```typescript
const saveOfferExtras = async (
  offerId: string, 
  extras: Record<string, 'festival' | 'artist'>
): Promise<void> => {
  try {
    // 1. Supprimer extras existants
    await supabase
      .from('offer_extras')
      .delete()
      .eq('offer_id', offerId);

    // 2. Préparer insertions
    const extrasToInsert = Object.entries(extras).map(([extraId, chargedTo]) => ({
      id: crypto.randomUUID(),
      offer_id: offerId,
      extra_id: extraId,
      charge_to: chargedTo
    }));

    // 3. Insérer nouveaux extras
    if (extrasToInsert.length > 0) {
      const { error } = await supabase
        .from('offer_extras')
        .insert(extrasToInsert);
      
      if (error) throw error;
      console.log(`✅ ${extrasToInsert.length} extras sauvegardés`);
    }
  } catch (error) {
    console.error('❌ Erreur sauvegarde extras:', error);
    throw error;
  }
};
```

---

## 📄 GÉNÉRATION PDF

### Workflow Génération PDF

```
1. Clic "Générer offre"
        ↓
2. Validation champs obligatoires
        ↓
3. Préparation OfferPdfData
        ↓
4. Appel generateOfferPdfAndUpload()
        ↓
5. Upload temporaire dans bucket 'offers'
        ↓
6. Récupération URL signée (expire 1h)
        ↓
7. Ouverture PdfPreviewModal
        ↓
8. Utilisateur choisit :
   - Annuler → ferme tout
   - Modifier → retour formulaire
   - Prêt à envoyer → sauvegarde finale
```

### Fonction handleGeneratePdf

```typescript
const handleGeneratePdf = async () => {
  // 1. Validation
  const errors = validateRequiredFields();
  if (errors.length > 0) {
    setValidationErrors(errors);
    setShowValidationAlert(true);
    return;
  }
  
  setLoading(true);
  
  try {
    // 2. Récupération entités sélectionnées
    const selectedArtist = artists.find(a => a.id === formData.artist_id);
    const selectedStage = stages.find(s => s.id === formData.stage_id);
    
    // 3. Préparation extras pour PDF
    const extrasForPdf = Object.entries(selectedExtras).map(([extraId, chargedTo]) => {
      const extra = availableBookingExtras.find(e => e.id === extraId);
      return {
        name: extra?.name || 'Extra inconnu',
        charge_to: chargedTo
      };
    });
    
    // 4. Préparation clauses pour PDF
    const exclusivityClausesForPdf = availableExclusivityClauses.map(clause => ({
      id: clause.id,
      text: clause.text,
      selected: exclusivityClauses.includes(clause.id)
    }));
    
    // 5. Construction OfferPdfData
    const pdfData: OfferPdfData = {
      offerId: `offer_${Date.now()}`,
      artistName: selectedArtist?.name || '',
      stageName: selectedStage?.name || '',
      startTimeHHmm: performanceTime === 'TBC' ? 'TBC' : performanceTime,
      dateLabel: performanceDate,
      durationMin: prefilledData?.duration || 60,
      
      // Financier
      amountNet: formData.amount_is_net ? formData.amount_net : formData.amount_gross,
      agencyCommissionPct: formData.agency_commission_pct,
      currency: formData.currency,
      validityDate: formData.validity_date,
      
      amountIsNet: formData.amount_is_net,
      amountGrossIsSubjectToWithholding: formData.amount_gross_is_subject_to_withholding,
      amountDisplay: amountDisplay,
      amountTypeLabel: formData.amount_is_net 
        ? 'MONTANT NET DE TAXES' 
        : 'MONTANT BRUT, SUJET A L\'IMPOT A LA SOURCE',
      
      // Version
      version: prefilledData?.isModification 
        ? (prefilledData?.originalVersion || 1) + 1 
        : 1,
      
      // Frais additionnels
      prodFeeAmount,
      prodFeeCurrency: prodFeeAmount ? prodFeeCurrency : undefined,
      backlineFeeAmount,
      backlineFeeCurrency: backlineFeeAmount ? backlineFeeCurrency : undefined,
      buyoutHotelAmount,
      buyoutHotelCurrency: buyoutHotelAmount ? buyoutHotelCurrency : undefined,
      buyoutMealAmount,
      buyoutMealCurrency: buyoutMealAmount ? buyoutMealCurrency : undefined,
      flightContributionAmount,
      flightContributionCurrency: flightContributionAmount ? flightContributionCurrency : undefined,
      technicalFeeAmount,
      technicalFeeCurrency: technicalFeeAmount ? technicalFeeCurrency : undefined,
      
      // Extras et clauses
      extras: extrasForPdf,
      exclusivityClauses: exclusivityClausesForPdf
    };
    
    // 6. Génération nom fichier
    const pdfFileName = generatePdfFileName(selectedArtist?.name || 'artiste', true);
    
    // 7. Génération et upload
    const pdfUrl = await generateOfferPdfAndUpload({
      data: pdfData,
      fileBaseName: pdfFileName
    });
    
    if (pdfUrl) {
      // 8. Ouverture modal prévisualisation
      setCurrentOfferData(pdfData);
      setPreviewPdfUrl(pdfUrl);
      setShowPdfPreview(true);
    }
    
  } catch (error) {
    console.error('❌ Erreur génération PDF:', error);
    alert('Erreur lors de la génération du PDF');
  } finally {
    setLoading(false);
  }
};
```

### Format Nom de Fichier PDF

```typescript
const generatePdfFileName = (artistName: string, withTimestamp: boolean = false): string => {
  const eventNameForFile = currentEventName || 'EVENT';
  const artistNameForFile = artistName || 'ARTISTE';
  
  // Nettoyer (supprimer caractères spéciaux)
  const cleanEventName = eventNameForFile
    .replace(/[^a-zA-Z0-9\-_]/g, '_')
    .toUpperCase();
  const cleanArtistName = artistNameForFile
    .replace(/[^a-zA-Z0-9\-_]/g, '_')
    .toUpperCase();
  
  const baseName = `OFFRE_${cleanEventName}_${cleanArtistName}`;
  return withTimestamp ? `${baseName}_${Date.now()}` : baseName;
};
```

**Exemples** :
- `OFFRE_PALEO_FESTIVAL_COLDPLAY_1699875432123.pdf`
- `OFFRE_MONTREUX_JAZZ_JOHN_DOE_1699875987654.pdf`

---

## 🗄️ SCHÉMA DE BASE DE DONNÉES

### Tables Nécessaires

#### 1. Table `offers` (Principale)

```sql
CREATE TABLE offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  artist_id UUID REFERENCES artists(id) ON DELETE SET NULL,
  stage_id UUID REFERENCES stages(id) ON DELETE SET NULL,
  agency_contact_id UUID REFERENCES contacts(id) ON DELETE SET NULL,
  
  -- Date/Heure
  date_time TIMESTAMPTZ,
  duration_minutes INTEGER,
  
  -- Financier de base
  currency TEXT CHECK (currency IN ('EUR', 'GBP', 'USD', 'CHF')),
  amount_net NUMERIC(12,2),
  amount_gross NUMERIC(12,2),
  amount_display NUMERIC(12,2),
  amount_is_net BOOLEAN DEFAULT false,
  amount_gross_is_subject_to_withholding BOOLEAN DEFAULT false,
  agency_commission_pct NUMERIC(5,2),
  
  -- Frais additionnels
  prod_fee_amount NUMERIC(12,2),
  prod_fee_currency TEXT,
  backline_fee_amount NUMERIC(12,2),
  backline_fee_currency TEXT,
  buyout_hotel_amount NUMERIC(12,2),
  buyout_hotel_currency TEXT,
  buyout_meal_amount NUMERIC(12,2),
  buyout_meal_currency TEXT,
  flight_contribution_amount NUMERIC(12,2),
  flight_contribution_currency TEXT,
  technical_fee_amount NUMERIC(12,2),
  technical_fee_currency TEXT,
  
  -- Versioning
  version INTEGER DEFAULT 1,
  original_offer_id UUID REFERENCES offers(id) ON DELETE SET NULL,
  
  -- Autres
  validity_date DATE,
  withholding_note TEXT,
  terms_json JSONB,
  status TEXT CHECK (status IN ('draft', 'ready_to_send', 'sent', 'accepted', 'rejected')),
  pdf_storage_path TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_offers_event_id ON offers(event_id);
CREATE INDEX idx_offers_artist_id ON offers(artist_id);
CREATE INDEX idx_offers_original_offer_id ON offers(original_offer_id);
```

#### 2. Table `booking_extras`

```sql
CREATE TABLE booking_extras (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_booking_extras_active ON booking_extras(is_active);
```

#### 3. Table `offer_extras` (Liaison)

```sql
CREATE TABLE offer_extras (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id UUID REFERENCES offers(id) ON DELETE CASCADE,
  extra_id UUID REFERENCES booking_extras(id) ON DELETE CASCADE,
  charge_to TEXT CHECK (charge_to IN ('artist', 'festival')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(offer_id, extra_id)
);

CREATE INDEX idx_offer_extras_offer_id ON offer_extras(offer_id);
CREATE INDEX idx_offer_extras_extra_id ON offer_extras(extra_id);
```

#### 4. Table `exclusivity_clauses`

```sql
CREATE TABLE exclusivity_clauses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_exclusivity_clauses_active ON exclusivity_clauses(is_active);
```

---

## 📊 DONNÉES À INJECTER (depuis GO-PROD actuel)

### 1. Booking Extras

```sql
-- Insérer dans le nouveau SaaS
INSERT INTO booking_extras (id, name, description, is_active) VALUES
('bc2cd1dd-757b-4297-bc0e-c1faa463050c', 'Backline', 'Équipement musical fourni par l''organisateur', true),
('e25e47bb-dd21-46e8-bb48-b792b111680a', 'Éclairage', 'Éclairage scénique spécifique', true),
('d6ee2711-c00c-47a0-b786-f2796432dab7', 'Hébergement', 'Hébergement pour l''artiste et son équipe', true),
('f6fb33c3-4213-4191-bc4f-b09a899806fd', 'Restauration', 'Restauration sur place (catering)', true),
('63d74a7d-4de9-401d-8008-575a2455de2f', 'Sonorisation', 'Sonorisation et équipement audio spécifique', true),
('5415b35a-84f7-400f-a6e7-0c0b9044e73b', 'Transport local', 'Transport local depuis/vers l''aéroport ou la gare', true);
```

### 2. Exclusivity Clauses

```sql
-- Insérer dans le nouveau SaaS
INSERT INTO exclusivity_clauses (id, text, is_active) VALUES
('27ec9865-5062-467b-a3af-e83d76bf5a67', 'Exclusivité de festival', true),
('12189884-4b61-4a62-bddb-50b1a1db1954', 'Exclusivité de genre musical', true),
('8d5049ba-20b9-43ba-b93b-c271d2735649', 'Exclusivité de label/maison de disques', true),
('b8702206-b828-4869-859d-5299149336ae', 'Exclusivité géographique (rayon 100km)', true),
('3c0cb6a4-c564-4744-9cfc-abfd30d96d67', 'Exclusivité géographique (rayon 200km)', true),
('0dc83650-ff8d-4da9-85e1-9a0d9c4586f4', 'Exclusivité géographique (rayon 50km)', true),
('3e9000e2-6df5-4da8-ac0a-06f5ba8a38bc', 'Exclusivité temporelle (1 mois après)', true),
('ce752c08-edc1-4515-8774-ccba4d808fa5', 'Exclusivité temporelle (1 mois avant)', true),
('184eeff5-41c0-4cd0-bfbc-0bcff01cc8a0', 'Exclusivité temporelle (2 mois après)', true),
('09b63fa4-cb3b-4601-ad30-9d0165025043', 'Exclusivité temporelle (2 mois avant)', true),
('bd59503d-d910-4e3a-bdf2-4a0271c0a36f', 'Exclusivité temporelle (3 mois après)', true),
('711d9db8-ed9c-4cb4-a964-c55b3e240152', 'Exclusivité temporelle (3 mois avant)', true);
```

---

## ✅ CHECKLIST D'IMPLÉMENTATION

### Phase 1 : Analyse Préalable

- [ ] Vérifier si modal d'offre existe déjà dans le nouveau SaaS
- [ ] Si existe : analyser le code existant et lister les fonctionnalités présentes
- [ ] Comparer avec cette spécification
- [ ] Identifier les écarts (fonctionnalités manquantes ou différentes)
- [ ] Décider : MODE MODIFICATION ou MODE CRÉATION complète

### Phase 2 : Base de Données

- [ ] Vérifier existence table `offers` avec tous les champs
- [ ] Vérifier existence table `booking_extras`
- [ ] Vérifier existence table `offer_extras` (liaison)
- [ ] Vérifier existence table `exclusivity_clauses`
- [ ] Créer/Modifier les tables si nécessaire
- [ ] Insérer les données (extras et clauses) depuis GO-PROD actuel
- [ ] Vérifier les index et contraintes

### Phase 3 : Types et Interfaces

- [ ] Créer/Vérifier `OfferComposerProps` interface
- [ ] Créer/Vérifier `CreateOfferPayload` interface
- [ ] Créer/Vérifier `CurrencyCode` type
- [ ] Créer/Vérifier `OfferPdfData` interface

### Phase 4 : Composant Principal

- [ ] Créer/Modifier fichier `OfferComposer.tsx`
- [ ] Implémenter les 32 états React
- [ ] Implémenter les props avec destructuration

### Phase 5 : Section 1 - Données de Base

- [ ] Champ Artiste (select + bouton ajouter)
- [ ] Champ Contact Booking (select + bouton ajouter)
- [ ] Champ Date (DatePicker)
- [ ] Champ Heure avec bouton TBC
- [ ] Champ Scène (select)
- [ ] Champ Deadline (DatePicker)
- [ ] Fonction `handleToggleTBC()`
- [ ] Fonction `handleAddArtist()`
- [ ] Fonction `handleAddContact()`

### Phase 6 : Section 2 - Financier

- [ ] Checkboxes Type de montant (XOR)
- [ ] Fonction `handleToggleAmountIsNet()`
- [ ] Fonction `handleToggleGrossWithholding()`
- [ ] Champ Devise (select)
- [ ] Champ Montant (number)
- [ ] Champ Commission Agence (number)
- [ ] 6 champs Frais additionnels avec devise (12 inputs total)
- [ ] États pour chaque frais additionnel (12 états)

### Phase 7 : Section 3 - Extras et Clauses

- [ ] Tableau Extras (3 colonnes)
- [ ] Fonction `handleExtraAssignment()`
- [ ] Chargement `loadBookingExtras()`
- [ ] Liste Clauses d'exclusivité (checkboxes)
- [ ] Fonction `handleExclusivityClauseToggle()`
- [ ] Chargement `loadExclusivityClauses()`

### Phase 8 : Validation

- [ ] Fonction `validateRequiredFields()`
- [ ] Fonction `getFieldClassName()` pour bordures rouges
- [ ] Fonction `getErrorMessages()` pour mapping
- [ ] Alert affichage erreurs en haut du modal

### Phase 9 : Sauvegarde

- [ ] Fonction `handleSubmit()` complète
- [ ] Logique distinction 3 modes (création/modification/édition)
- [ ] Fonction `saveOfferExtras()`
- [ ] Fonction `updatePerformanceBookingStatus()`
- [ ] Intégration `createOffer()` API
- [ ] Intégration `createOfferVersion()` API
- [ ] Intégration `updateOffer()` API

### Phase 10 : PDF

- [ ] Fonction `handleGeneratePdf()`
- [ ] Fonction `generatePdfFileName()`
- [ ] Préparation `OfferPdfData`
- [ ] Intégration `generateOfferPdfAndUpload()`
- [ ] Composant `PdfPreviewModal`
- [ ] Fonction `handlePdfReadyToSend()`

### Phase 11 : Chargements Données

- [ ] `loadArtists()`
- [ ] `loadContacts()` avec filtre booking agent
- [ ] `loadStages()`
- [ ] `loadEventDays()`
- [ ] `loadBookingExtras()`
- [ ] `loadExclusivityClauses()`
- [ ] `loadOfferExtras()` pour mode modification

### Phase 12 : Hooks useEffect

- [ ] useEffect chargement initial
- [ ] useEffect pré-remplissage depuis `prefilledData`
- [ ] useEffect chargement extras existants (mode modification)
- [ ] useEffect gestion nom événement

### Phase 13 : Tests et Validation

- [ ] Test création nouvelle offre (v1)
- [ ] Test modification offre (versioning → v2, v3)
- [ ] Test édition directe offre
- [ ] Test validation champs obligatoires
- [ ] Test génération PDF
- [ ] Test sauvegarde extras
- [ ] Test sauvegarde clauses
- [ ] Test bouton TBC
- [ ] Test ajout rapide artiste
- [ ] Test ajout rapide contact
- [ ] Test tous les frais additionnels

### Phase 14 : UI/UX

- [ ] Styling sections (3 `<details>`)
- [ ] Responsive design
- [ ] Loading states
- [ ] Error states
- [ ] Success feedback
- [ ] Transitions/animations
- [ ] Accessibilité (ARIA labels)

---

## 🎨 RECOMMANDATIONS UI/UX

### 1. Layout Modal

```typescript
<Modal 
  isOpen={isOpen} 
  onClose={handleClose}
  title={
    prefilledData?.isModification 
      ? `MODIFIER OFFRE (Nouvelle version ${(prefilledData.originalVersion || 1) + 1})`
      : editingOffer 
        ? 'ÉDITER OFFRE'
        : 'ÉTABLIR UNE OFFRE'
  }
  size="xl"
  className="max-h-[90vh] overflow-y-auto"
>
  {/* Contenu */}
</Modal>
```

### 2. Sections Collapsibles

```typescript
<details open className="border rounded-lg p-4 mb-4">
  <summary className="font-bold text-lg cursor-pointer hover:text-blue-600">
    📋 DONNÉES DE BASE
  </summary>
  <div className="mt-4 space-y-4">
    {/* Champs */}
  </div>
</details>
```

### 3. Badges Informatifs

```typescript
{prefilledData?.fee_amount && (
  <span className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded">
    💰 depuis performance
  </span>
)}
```

### 4. États de Chargement

```typescript
{loading && (
  <div className="absolute inset-0 bg-white/80 flex items-center justify-center z-50">
    <div className="flex flex-col items-center gap-2">
      <Loader className="animate-spin h-8 w-8" />
      <span>Génération en cours...</span>
    </div>
  </div>
)}
```

### 5. Boutons d'Action

```typescript
<div className="flex gap-2 justify-end mt-6">
  <Button 
    variant="outline" 
    onClick={handleClose}
    disabled={loading}
  >
    Annuler
  </Button>
  
  <Button 
    variant="secondary" 
    onClick={() => handleSubmit('draft')}
    disabled={loading}
  >
    <Save className="mr-2 h-4 w-4" />
    Enregistrer brouillon
  </Button>
  
  <Button 
    variant="primary" 
    onClick={handleGeneratePdf}
    disabled={loading}
  >
    <Send className="mr-2 h-4 w-4" />
    Générer offre
  </Button>
</div>
```

---

## 🚨 POINTS D'ATTENTION CRITIQUES

### 1. ⚠️ Versioning vs Édition

**ATTENTION** : Ne JAMAIS confondre les deux modes :

- **Modification (versioning)** : `prefilledData.isModification = true` → crée NOUVELLE version
- **Édition directe** : `editingOffer` fourni → modifie MÊME offre

**Règle d'Or** : 
- Offre envoyée → TOUJOURS utiliser versioning
- Offre draft → Édition directe acceptable

### 2. ⚠️ Validation Avant Génération PDF

Le PDF ne doit JAMAIS être généré si la validation échoue. Toujours appeler `validateRequiredFields()` avant.

### 3. ⚠️ Gestion Type de Montant (XOR)

Les deux checkboxes sont mutuellement exclusives MAIS au moins une doit être cochée à tout moment.

```typescript
// TOUJOURS vérifier qu'au moins une option reste cochée
if (!prev.amount_gross_is_subject_to_withholding) {
  return { ...prev, amount_is_net: true }; // Forcer une option
}
```

### 4. ⚠️ Sauvegarde Extras

TOUJOURS supprimer les anciens extras avant d'insérer les nouveaux pour éviter les doublons.

```typescript
// 1. DELETE
await supabase.from('offer_extras').delete().eq('offer_id', offerId);
// 2. INSERT
await supabase.from('offer_extras').insert(extrasToInsert);
```

### 5. ⚠️ Clauses dans JSONB

Les clauses sont stockées dans `offers.terms_json` au format :

```json
{
  "selectedClauseIds": ["uuid1", "uuid2", "uuid3"]
}
```

PAS dans une table de liaison séparée.

### 6. ⚠️ Pré-remplissage Performance

Quand `prefilledData.fee_amount` fourni, afficher badge " depuis performance" et NE PAS écraser si utilisateur modifie.

### 7. ⚠️ Contacts Booking Agent

Le filtre sur les contacts doit se faire via `contact_functions_multi` et non directement sur `contacts`. Fallback sur tous contacts si aucun booking agent trouvé.

---

## 📚 RESSOURCES ET DOCUMENTATION

### Documentation Complète

Lire IMPÉRATIVEMENT avant implémentation :

- **`docs/OFFER_COMPOSER_COMPLETE.md`** - Documentation exhaustive (1000 lignes)

### Autres Docs Utiles

- `docs/BOOKING_SYSTEM_ARCHITECTURE.md` - Architecture du système booking
- `docs/BOOKING_SYSTEM_WORKFLOW.md` - Workflows détaillés
- `docs/BOOKING_SYSTEM_API.md` - Fonctions API
- `docs/BOOKING_SYSTEM_PDF.md` - Génération PDF
- `docs/BOOKING_SYSTEM_RELATIONS.md` - Schéma BDD complet

### Code Référence (GO-PROD V3 actuel)

- `src/features/booking/OfferComposer.tsx` (2065 lignes)
- `src/features/booking/bookingApi.ts`
- `src/features/booking/bookingTypes.ts`
- `src/features/booking/pdf/pdfFill.ts`
- `src/components/offers/PdfPreviewModal.tsx`

---

## 🎯 OBJECTIF FINAL

À la fin de l'implémentation, le modal doit :

✅ Permettre de créer une nouvelle offre depuis une performance  
✅ Permettre de modifier une offre existante (avec versioning automatique)  
✅ Gérer 3 sections de formulaire avec 25+ champs  
✅ Valider strictement 9 champs obligatoires  
✅ Gérer 6 types de frais additionnels avec devises  
✅ Permettre sélection extras (artist/festival)  
✅ Permettre sélection clauses d'exclusivité  
✅ Générer PDF avec prévisualisation  
✅ Sauvegarder avec statut (draft ou ready_to_send)  
✅ Mettre à jour automatiquement le statut des performances  
✅ Conserver historique complet des versions  

---

## 🔄 PROCESSUS D'IMPLÉMENTATION RECOMMANDÉ

### Étape 1 : Analyse et Préparation (1h)

1. Vérifier existence modal dans nouveau SaaS
2. Analyser code existant si présent
3. Comparer avec cette spécification
4. Lister écarts et modifications nécessaires
5. Préparer plan d'action

### Étape 2 : Base de Données (30min)

1. Vérifier/Créer tables nécessaires
2. Exécuter scripts SQL fournis
3. Insérer données extras et clauses
4. Tester avec requêtes SELECT

### Étape 3 : Types et Interfaces (30min)

1. Créer/Vérifier tous les types TypeScript
2. Valider cohérence avec BDD
3. Tester imports

### Étape 4 : Structure Composant (1h)

1. Créer fichier `OfferComposer.tsx`
2. Implémenter squelette avec props
3. Déclarer tous les états (32 useState)
4. Créer structure JSX de base

### Étape 5 : Section par Section (4h)

1. **Section 1** : Données de base (1h30)
2. **Section 2** : Financier (1h30)
3. **Section 3** : Extras et clauses (1h)

### Étape 6 : Validation (1h)

1. Fonction `validateRequiredFields()`
2. Affichage erreurs
3. Mapping messages
4. Styling bordures rouges

### Étape 7 : Sauvegarde (2h)

1. Fonction `handleSubmit()` complète
2. Logique 3 modes
3. Fonctions API
4. Tests sauvegarde

### Étape 8 : PDF (2h)

1. Fonction `handleGeneratePdf()`
2. Préparation données
3. Intégration génération
4. Modal prévisualisation

### Étape 9 : Tests et Debug (2h)

1. Tests tous scénarios
2. Corrections bugs
3. Optimisations
4. Tests validation

### Étape 10 : UI/UX Polish (1h)

1. Styling final
2. Responsive
3. Loading states
4. Animations

**DURÉE TOTALE ESTIMÉE : 15-20 heures**

---

## ✅ VALIDATION FINALE

Avant de considérer l'implémentation terminée, vérifier :

- [ ] Tous les points de la checklist sont cochés
- [ ] Les 3 modes fonctionnent correctement
- [ ] La validation bloque bien les sauvegardes incomplètes
- [ ] Les extras se sauvegardent dans `offer_extras`
- [ ] Les clauses se sauvegardent dans `offers.terms_json`
- [ ] Le versioning crée bien de nouvelles versions
- [ ] Le PDF se génère correctement
- [ ] Le modal de prévisualisation fonctionne
- [ ] Le statut des performances se met à jour
- [ ] Aucune erreur console
- [ ] Code propre et commenté
- [ ] Responsive sur mobile/tablette
- [ ] Performance acceptable (< 2s pour ouverture modal)

---

**FIN DU PROMPT D'IMPLÉMENTATION**

---

## 📞 SUPPORT

En cas de questions ou blocages :

1. Consulter `docs/OFFER_COMPOSER_COMPLETE.md` (documentation exhaustive)
2. Vérifier code référence dans GO-PROD V3 actuel
3. Tester avec données d'exemple
4. Utiliser console.log pour debug
5. Demander revue de code si nécessaire

**Bon courage pour l'implémentation ! 🚀**


