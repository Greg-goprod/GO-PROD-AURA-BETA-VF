# 🔌 API ET FONCTIONS DU SYSTÈME DE BOOKING

## 📂 Fichier : `src/features/booking/bookingApi.ts`

### Fonctions principales

---

## 1. Gestion des offres

### `listOffers()`
**Description :** Récupère la liste des offres avec filtres et tri

**Paramètres :**
```typescript
interface ListOffersParams {
  companyId: string;
  eventId: string;
  filters?: OfferFilters;
  sort?: OfferSort;
}

interface OfferFilters {
  search?: string;
  status?: OfferStatus[];
  stage?: string[];
  currency?: CurrencyCode[];
  category?: string[];
  has_exclusivity?: boolean;
  validity_status?: 'valid' | 'expired' | 'expiring_soon';
}

interface OfferSort {
  field: 'date_time' | 'amount_gross' | 'amount_net' | 'validity_date' | 'created_at';
  direction: 'asc' | 'desc';
}
```

**Retour :** `Promise<Offer[]>`

**Code :**
```typescript
export async function listOffers(params: {
  companyId: string;
  eventId: string;
  filters?: OfferFilters;
  sort?: OfferSort;
}): Promise<Offer[]> {
  const { companyId, eventId, filters, sort } = params;
  
  let query = supabase
    .from('offers')
    .select(`
      *,
      artists(name),
      offer_categories(name)
    `)
    .eq('event_id', eventId);

  // Apply filters
  if (filters?.status?.length) {
    query = query.in('status', filters.status);
  }
  if (filters?.stage?.length) {
    query = query.in('stage_id', filters.stage);
  }
  if (filters?.currency?.length) {
    query = query.in('currency', filters.currency);
  }
  if (filters?.category?.length) {
    query = query.in('category_id', filters.category);
  }
  if (filters?.validity_status) {
    const today = new Date().toISOString().split('T')[0];
    const soonDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    
    if (filters.validity_status === 'expired') {
      query = query.lt('validity_date', today);
    } else if (filters.validity_status === 'expiring_soon') {
      query = query.gte('validity_date', today).lte('validity_date', soonDate);
    } else if (filters.validity_status === 'valid') {
      query = query.gt('validity_date', soonDate);
    }
  }

  // Apply search
  if (filters?.search) {
    query = query.or(`artists.name.ilike.%${filters.search}%`);
  }

  // Apply sort
  if (sort) {
    query = query.order(sort.field, { ascending: sort.direction === 'asc' });
  } else {
    query = query.order('created_at', { ascending: false });
  }

  const { data, error } = await query;
  if (error) throw error;

  return (data || []).map(item => ({
    ...item,
    artist_name: item.artists?.name,
    category_name: item.offer_categories?.name
  }));
}
```

---

### `createOffer()`
**Description :** Crée une nouvelle offre (version 1)

**Paramètres :**
```typescript
interface CreateOfferParams {
  companyId: string;
  eventId: string;
  payload: CreateOfferPayload;
}

interface CreateOfferPayload {
  artist_id?: string;
  agency_contact_id?: string;
  stage_id?: string;
  date_time?: string;
  currency: CurrencyCode;
  amount_net?: number;
  amount_gross?: number;
  amount_is_net?: boolean;
  amount_gross_is_subject_to_withholding?: boolean;
  agency_commission_pct?: number;
  
  // Frais additionnels
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
  
  amount_display?: number;
  validity_date?: string;
  category_id?: string;
  terms_json?: {
    selectedClauseIds?: string[];
    notes?: string;
  };
  exclusivity?: {
    enabled: boolean;
    preset_id?: string;
    region?: string;
    perimeter_km?: number;
    days_before?: number;
    days_after?: number;
    penalty_note?: string;
  };
  payment_schedule_preset_id?: string;
}
```

**Retour :** `Promise<Offer>`

**Code :**
```typescript
export async function createOffer(params: {
  companyId: string;
  eventId: string;
  payload: CreateOfferPayload;
}): Promise<Offer> {
  const { companyId, eventId, payload } = params;
  
  const { data: offer, error } = await supabase
    .from('offers')
    .insert({
      event_id: eventId,
      status: 'draft',
      version: 1, // Toujours version 1 pour une nouvelle offre
      original_offer_id: null, // NULL pour la version originale
      ...payload
    })
    .select()
    .single();

  if (error) throw error;

  // Handle exclusivity if provided for new offer
  if (payload.exclusivity?.enabled) {
    const { error: exclError } = await supabase
      .from('offer_exclusivities')
      .insert({
        offer_id: offer.id,
        region: payload.exclusivity.region,
        perimeter_km: payload.exclusivity.perimeter_km,
        days_before: payload.exclusivity.days_before,
        days_after: payload.exclusivity.days_after,
        penalty_note: payload.exclusivity.penalty_note,
        exclusive: true
      });
    
    if (exclError) throw exclError;
  }

  return offer;
}
```

---

### `createOfferVersion()`
**Description :** Crée une nouvelle version d'une offre existante

**Paramètres :**
```typescript
interface CreateOfferVersionParams {
  companyId: string;
  eventId: string;
  originalOfferId: string;
  payload: CreateOfferPayload;
}
```

**Retour :** `Promise<Offer>`

**Code :**
```typescript
export async function createOfferVersion(params: {
  companyId: string;
  eventId: string;
  originalOfferId: string;
  payload: CreateOfferPayload;
}): Promise<Offer> {
  const { companyId, eventId, originalOfferId, payload } = params;
  
  // 1. Obtenir la prochaine version
  const { data: nextVersionData, error: versionError } = await supabase
    .rpc('get_next_offer_version', { offer_id: originalOfferId });
    
  if (versionError) {
    console.error('❌ Erreur lors de l\'obtention de la prochaine version:', versionError);
    throw versionError;
  }
  
  const nextVersion = nextVersionData;
  console.log(`🔢 Création de la version ${nextVersion} pour l'offre ${originalOfferId}`);
  
  // 2. Déterminer l'ID de l'offre de base
  const { data: originalOffer, error: originalError } = await supabase
    .from('offers')
    .select('id, original_offer_id')
    .eq('id', originalOfferId)
    .single();
    
  if (originalError) throw originalError;
  
  const baseOfferId = originalOffer.original_offer_id || originalOffer.id;
  
  // 3. Créer la nouvelle version
  const { data: newVersion, error: createError } = await supabase
    .from('offers')
    .insert({
      event_id: eventId,
      version: nextVersion,
      original_offer_id: baseOfferId,
      status: payload.status || 'ready_to_send', // Par défaut en "Prêt à envoyer"
      ...payload
    })
    .select()
    .single();

  if (createError) {
    console.error('❌ Erreur lors de la création de la version:', createError);
    throw createError;
  }
  
  console.log(`✅ Version ${nextVersion} créée avec succès:`, newVersion.id);
  
  // Handle exclusivity if provided for the new version
  if (payload.exclusivity?.enabled) {
    const { error: exclError } = await supabase
      .from('offer_exclusivities')
      .insert({
        offer_id: newVersion.id,
        region: payload.exclusivity.region,
        perimeter_km: payload.exclusivity.perimeter_km,
        days_before: payload.exclusivity.days_before,
        days_after: payload.exclusivity.days_after,
        penalty_note: payload.exclusivity.penalty_note,
        exclusive: true
      });
    
    if (exclError) throw exclError;
  }
  
  return newVersion;
}
```

---

### `updateOffer()`
**Description :** Met à jour une offre existante

**Paramètres :**
```typescript
(id: string, payload: Partial<CreateOfferPayload>) => Promise<Offer>
```

**Code :**
```typescript
export async function updateOffer(id: string, payload: Partial<CreateOfferPayload>): Promise<Offer> {
  const { data, error } = await supabase
    .from('offers')
    .update({ ...payload, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;

  // Log activity
  await supabase
    .from('offer_activity_log')
    .insert({
      offer_id: id,
      action: 'updated',
      meta: { fields: Object.keys(payload) }
    });

  // Si le statut a changé, déclencher événement
  if (payload.status) {
    console.log('📡 Déclenchement événement: offer-status-changed (via updateOffer)');
    window.dispatchEvent(new CustomEvent('offer-status-changed', {
      detail: { offerId: id, newStatus: payload.status, timestamp: new Date().toISOString() }
    }));
  }

  return data;
}
```

---

### `moveOffer()`
**Description :** Change le statut d'une offre (drag & drop Kanban)

**Paramètres :**
```typescript
(id: string, newStatus: OfferStatus) => Promise<void>
```

**Code :**
```typescript
export async function moveOffer(id: string, newStatus: OfferStatus): Promise<void> {
  console.log('🔄 DEBUT moveOffer - ID:', id, 'Nouveau statut:', newStatus);
  
  const { error } = await supabase
    .from('offers')
    .update({ status: newStatus, updated_at: new Date().toISOString() })
    .eq('id', id);

  if (error) {
    console.error('❌ Erreur lors de la mise à jour du statut:', error);
    throw error;
  }
  
  console.log('✅ Statut mis à jour avec succès en base de données');

  // Si l'offre passe en "ready_to_send", générer automatiquement le PDF
  if (newStatus === 'ready_to_send') {
    try {
      console.log('🔄 DÉCLENCHEMENT génération automatique du PDF');
      await generateOfferPdfOnStatusChange(id);
      console.log('✅ PDF généré automatiquement avec succès pour l\'offre:', id);
    } catch (pdfError) {
      console.error('❌ ERREUR CRITIQUE lors de la génération automatique du PDF:', pdfError);
      // Ne pas bloquer le changement de statut
    }
  }

  // Si l'offre passe en "accepted", créer automatiquement un contrat
  if (newStatus === 'accepted') {
    try {
      console.log('🔄 DÉCLENCHEMENT création automatique de contrat');
      
      // Vérifier qu'un contrat n'existe pas déjà
      const contractExists = await checkExistingContractForOffer(id);
      
      if (contractExists) {
        console.log('⚠️ Un contrat existe déjà pour cette offre, création ignorée');
      } else {
        const contract = await createContractFromAcceptedOffer(id);
        
        if (contract) {
          console.log('✅ Contrat créé automatiquement avec succès:', contract.id);
          
          // Déclencher un événement pour informer l'interface
          window.dispatchEvent(new CustomEvent('contract-created-from-offer', {
            detail: { 
              offerId: id, 
              contractId: contract.id,
              contractTitle: contract.contract_title,
              timestamp: new Date().toISOString() 
            }
          }));
        }
      }
    } catch (contractError) {
      console.error('❌ ERREUR lors de la création automatique du contrat:', contractError);
      // Ne pas bloquer le changement de statut
    }
  }

  // Log activity
  await supabase
    .from('offer_activity_log')
    .insert({
      offer_id: id,
      action: 'moved',
      meta: { new_status: newStatus }
    });

  // Déclencher événement pour rafraîchissement automatique
  console.log('📡 Déclenchement événement: offer-status-changed');
  window.dispatchEvent(new CustomEvent('offer-status-changed', {
    detail: { offerId: id, newStatus, timestamp: new Date().toISOString() }
  }));
}
```

---

### `deleteOffer()`
**Description :** Supprime une offre

**Paramètres :**
```typescript
(id: string) => Promise<void>
```

**Code :**
```typescript
export async function deleteOffer(id: string): Promise<void> {
  const { error } = await supabase
    .from('offers')
    .delete()
    .eq('id', id);

  if (error) throw error;
}
```

---

### `getOfferVersions()`
**Description :** Récupère toutes les versions d'une offre

**Paramètres :**
```typescript
(offerId: string) => Promise<any[]>
```

**Code :**
```typescript
export async function getOfferVersions(offerId: string): Promise<any[]> {
  const { data, error } = await supabase
    .rpc('get_offer_versions', { offer_id: offerId });
    
  if (error) {
    console.error('❌ Erreur lors de la récupération des versions:', error);
    throw error;
  }
  
  return data || [];
}
```

---

## 2. Gestion des fichiers

### `uploadOfferFile()`
**Description :** Upload un fichier lié à une offre

**Paramètres :**
```typescript
(offerId: string, file: File) => Promise<OfferFile>
```

**Code :**
```typescript
export async function uploadOfferFile(offerId: string, file: File): Promise<OfferFile> {
  // Get offer details for path
  const { data: offer } = await supabase
    .from('offers')
    .select('event_id')
    .eq('id', offerId)
    .single();

  if (!offer) throw new Error('Offer not found');

  const fileName = `${Date.now()}-${file.name}`;
  const filePath = `offers/${offer.event_id}/${offerId}/${fileName}`;

  // Upload to storage
  const { error: uploadError } = await supabase.storage
    .from('offers')
    .upload(filePath, file);

  if (uploadError) throw uploadError;

  // Save file record
  const { data, error } = await supabase
    .from('offer_files')
    .insert({
      offer_id: offerId,
      path: filePath,
      kind: 'offer'
    })
    .select()
    .single();

  if (error) throw error;

  // Log activity
  await supabase
    .from('offer_activity_log')
    .insert({
      offer_id: offerId,
      action: 'file_added',
      meta: { filename: file.name }
    });

  return data;
}
```

---

## 3. Génération de PDF

### `generateOfferPdfOnStatusChange()`
**Description :** Génère le PDF d'une offre lors du changement de statut vers "ready_to_send"

**Paramètres :**
```typescript
(offerId: string) => Promise<void>
```

**Process :**
1. Vérifier si un PDF existe déjà (éviter régénération)
2. Récupérer les données complètes de l'offre
3. Récupérer la durée depuis la performance liée
4. Récupérer les extras
5. Récupérer les clauses d'exclusivité
6. Préparer les données pour le PDF
7. Générer le PDF via `generateOfferPdfAndUpload()`
8. Mettre à jour l'offre avec le chemin du PDF

**Code :**
```typescript
export async function generateOfferPdfOnStatusChange(offerId: string): Promise<void> {
  console.log('📋 Début génération PDF pour offre:', offerId);
  
  // 0. Vérifier si un PDF existe déjà
  const { data: existingOffer } = await supabase
    .from('offers')
    .select('pdf_storage_path')
    .eq('id', offerId)
    .single();
  
  if (existingOffer?.pdf_storage_path) {
    console.log('✅ PDF déjà existant, pas de régénération');
    return;
  }
  
  console.log('🔄 Aucun PDF existant, génération en cours...');
  
  // 1. Récupérer les données complètes de l'offre
  const { data: offerData, error: offerError } = await supabase
    .from('offers')
    .select(`
      *,
      events:event_id(name),
      artists:artist_id(name)
    `)
    .eq('id', offerId)
    .single();

  if (offerError || !offerData) {
    throw new Error(`Impossible de récupérer les données de l'offre`);
  }

  // 2. Récupérer la durée depuis la performance liée
  let durationMin = 60; // Valeur par défaut
  if (offerData.artist_id && offerData.event_id) {
    let performanceQuery = supabase
      .from('artist_performances')
      .select('duration')
      .eq('artist_id', offerData.artist_id)
      .eq('event_id', offerData.event_id);
    
    if (offerData.stage_id) {
      performanceQuery = performanceQuery.eq('stage_id', offerData.stage_id);
    }
    
    const { data: performanceData } = await performanceQuery.maybeSingle();
    
    if (performanceData?.duration) {
      durationMin = performanceData.duration;
    }
  }

  // 3. Récupérer les extras
  const { data: extrasData } = await supabase
    .from('offer_extras')
    .select(`
      *,
      booking_extras:extra_id(name, description)
    `)
    .eq('offer_id', offerId);

  const extrasForPdf = extrasData?.map(extra => ({
    charge_to: extra.charge_to as 'artist' | 'festival'
  })) || [];

  // 4. Récupérer les clauses d'exclusivité
  let exclusivityClausesForPdf: Array<{ id: string; text: string; selected: boolean }> = [];
  if (offerData.terms_json?.selectedClauseIds) {
    const { data: clausesData } = await supabase
      .from('exclusivity_clauses')
      .select('id, text')
      .in('id', offerData.terms_json.selectedClauseIds);

    if (clausesData) {
      exclusivityClausesForPdf = clausesData.map(clause => ({
        id: clause.id,
        text: clause.text,
        selected: true
      }));
    }
  }

  // 5. Préparer les données pour le PDF
  const pdfData = {
    offerId: offerData.id,
    artistName: offerData.artists?.name || 'Artiste',
    stageName: offerData.event_stages?.name || 'Scène',
    startTimeHHmm: /* heure */,
    dateLabel: /* date */,
    durationMin: durationMin,
    amountNet: offerData.amount_is_net ? offerData.amount_net : offerData.amount_gross,
    agencyCommissionPct: offerData.agency_commission_pct,
    currency: offerData.currency,
    validityDate: offerData.validity_date,
    version: offerData.version || 1,
    extras: extrasForPdf,
    exclusivityClauses: exclusivityClausesForPdf,
    amountIsNet: offerData.amount_is_net,
    amountGrossIsSubjectToWithholding: offerData.amount_gross_is_subject_to_withholding,
    amountDisplay: offerData.amount_is_net ? offerData.amount_net : offerData.amount_gross,
    amountTypeLabel: offerData.amount_is_net ? 'MONTANT NET DE TAXES' : 'MONTANT BRUT...',
    // Champs financiers additionnels
    prodFeeAmount: offerData.prod_fee_amount,
    prodFeeCurrency: offerData.prod_fee_currency,
    // ... autres
  };

  // 6. Générer le PDF
  const { generateOfferPdfAndUpload } = await import('./pdf/pdfFill');
  
  const artistName = offerData.artists?.name || 'Artiste';
  const eventName = offerData.events?.name || 'Festival';
  
  const fileBaseName = `OFFRE_${eventName}_${artistName}`.replace(/[^a-zA-Z0-9]/g, '_');
  
  const pdfUrl = await generateOfferPdfAndUpload({
    data: pdfData,
    fileBaseName: fileBaseName
  });

  if (!pdfUrl) {
    throw new Error('Impossible de générer le PDF');
  }

  // 7. Mettre à jour l'offre avec le chemin du PDF
  const pdfStoragePath = extractPathFromUrl(pdfUrl);
  
  const { error: updateError } = await supabase
    .from('offers')
    .update({ pdf_storage_path: pdfStoragePath })
    .eq('id', offerId);

  if (updateError) {
    throw new Error(`Impossible de sauvegarder l'URL du PDF`);
  }

  console.log('✅ PDF généré et sauvegardé:', pdfUrl);
}
```

---

## 4. Gestion des catégories

### `listOfferCategories()`
**Description :** Liste les catégories d'offres

**Code :**
```typescript
export async function listOfferCategories(companyId: string): Promise<OfferCategory[]> {
  const { data, error } = await supabase
    .from('offer_categories')
    .select('*')
    .eq('company_id', companyId)
    .order('name');

  if (error) throw error;
  return data || [];
}
```

---

## 5. Gestion des clauses

### `listClauses()`
**Description :** Liste les clauses d'offres (booking clauses)

**Code :**
```typescript
export async function listClauses(companyId: string): Promise<OfferClause[]> {
  const { data, error } = await supabase
    .from('offer_clauses')
    .select('*')
    .eq('company_id', companyId)
    .order('title');

  if (error) throw error;
  return data || [];
}
```

---

*[Suite dans BOOKING_SYSTEM_PDF.md]*

