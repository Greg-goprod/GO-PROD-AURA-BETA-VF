# 📄 SYSTÈME DE GÉNÉRATION PDF

## 📂 Fichier : `src/features/booking/pdf/pdfFill.ts`

---

## 🎯 Vue d'ensemble

Le système de génération PDF utilise **pdf-lib** pour remplir un template PDF pré-conçu avec les données de l'offre.

### Template PDF

**URL :** `https://oqqphvcylcsxgxbtvwau.supabase.co/storage/v1/object/public/word-templates/MOCKUP-OFFRE-GOPROD_-_VENOGE.pdf`

**Nom de fichier :** `MOCKUP-OFFRE-GOPROD_-_VENOGE.pdf`

**Stockage :** Supabase Storage, bucket `word-templates` (public)

---

## 📋 Interface `OfferPdfData`

```typescript
interface OfferPdfData {
  // Identifiants
  offerId?: string;
  
  // Informations artiste/scène
  artistName?: string;
  stageName?: string;
  
  // Informations temporelles
  startTimeHHmm?: string;  // Format HH:MM ou "TBC"
  dateLabel?: string;  // Format: MARDI 11 août 2026 – 20:15 ou DD.MM.YYYY
  durationMin?: number | string;  // Durée en minutes
  
  // Financier principal
  amountNet?: number | string;
  agencyCommissionPct?: number | string;
  currency?: string;  // EUR, USD, GBP, CHF
  validityDate?: string;  // Format YYYY-MM-DD
  
  // Type de montant
  amountIsNet?: boolean;
  amountGrossIsSubjectToWithholding?: boolean;
  amountDisplay?: number | string;
  amountTypeLabel?: string;  // "MONTANT NET DE TAXES" ou "MONTANT BRUT, SUJET..."
  
  // Versioning
  version?: number;  // 1, 2, 3, etc.
  
  // Frais additionnels
  prodFeeAmount?: number;
  prodFeeCurrency?: string;
  backlineFeeAmount?: number;
  backlineFeeCurrency?: string;
  buyoutHotelAmount?: number;
  buyoutHotelCurrency?: string;
  buyoutMealAmount?: number;
  buyoutMealCurrency?: string;
  flightContributionAmount?: number;
  flightContributionCurrency?: string;
  technicalFeeAmount?: number;
  technicalFeeCurrency?: string;
  
  // Extras
  extras?: Array<{ 
    charge_to: 'artist' | 'festival' 
  }>;
  
  // Clauses
  exclusivitiesText?: string;  // Compatibilité
  exclusivityClauses?: Array<{ 
    id: string; 
    text: string; 
    selected: boolean 
  }>;
  
  // Autres
  withholdingNote?: string;
  paymentTermsText?: string;
  clausesText?: string;
}
```

---

## 🔧 Fonction principale : `generateOfferPdfAndUpload()`

**Signature :**
```typescript
function generateOfferPdfAndUpload(params: {
  data: OfferPdfData;
  fileBaseName: string;
}): Promise<string>
```

**Retour :** URL signée du PDF généré

**Process :**

1. **Téléchargement du template :**
```typescript
const templateUrl = DEFAULT_OFFER_TEMPLATE_URL;
const templateBytes = await fetch(templateUrl).then(res => res.arrayBuffer());
const pdfDoc = await PDFDocument.load(templateBytes);
```

2. **Récupération du formulaire PDF :**
```typescript
const form = pdfDoc.getForm();
```

3. **Remplissage des champs :**

Les champs du PDF sont remplis via la fonction `setTextSafe()` qui gère les erreurs :

```typescript
function setTextSafe(form: any, name: string, value: string | number | undefined | null) {
  if (value === undefined || value === null) return;
  try {
    const tf = form.getTextField(name);
    const cleanValue = cleanTextForPdf(String(value));
    tf.setText(cleanValue);
  } catch (error) {
    console.warn(`⚠️ Impossible de définir le champ PDF "${name}":`, error);
  }
}
```

**Champs PDF remplis :**

### Données de base
- `ARTIST_NAME` : Nom de l'artiste
- `STAGE_NAME` : Nom de la scène
- `DATE` : Date de la performance
- `TIME` : Heure de la performance (ou TBC)
- `DURATION` : Durée en minutes
- `VALIDITY_DATE` : Date limite de validité

### Financier
- `AMOUNT` : Montant principal formaté (avec apostrophes suisses)
- `CURRENCY` : Code devise (EUR, USD, GBP, CHF)
- `AMOUNT_TYPE` : Label du type de montant
- `AGENCY_COMMISSION` : Commission agence en %

### Frais additionnels
- `PROD_FEE_AMOUNT`, `PROD_FEE_CURRENCY`
- `BACKLINE_FEE_AMOUNT`, `BACKLINE_FEE_CURRENCY`
- `BUYOUT_HOTEL_AMOUNT`, `BUYOUT_HOTEL_CURRENCY`
- `BUYOUT_MEAL_AMOUNT`, `BUYOUT_MEAL_CURRENCY`
- `FLIGHT_CONTRIBUTION_AMOUNT`, `FLIGHT_CONTRIBUTION_CURRENCY`
- `TECHNICAL_FEE_AMOUNT`, `TECHNICAL_FEE_CURRENCY`

### Extras (cases à cocher)
- `EXTRA_1_ARTIST`, `EXTRA_1_FESTIVAL` : Hébergement
- `EXTRA_2_ARTIST`, `EXTRA_2_FESTIVAL` : Restauration
- `EXTRA_3_ARTIST`, `EXTRA_3_FESTIVAL` : Transport local
- `EXTRA_4_ARTIST`, `EXTRA_4_FESTIVAL` : Backline
- `EXTRA_5_ARTIST`, `EXTRA_5_FESTIVAL` : Éclairage
- `EXTRA_6_ARTIST`, `EXTRA_6_FESTIVAL` : Sonorisation

### Clauses d'exclusivité (cases à cocher + textes)
- `EXCLUSIVITY_CLAUSE_1`, `EXCLUSIVITY_CLAUSE_1_TEXT`
- `EXCLUSIVITY_CLAUSE_2`, `EXCLUSIVITY_CLAUSE_2_TEXT`
- ...jusqu'à `EXCLUSIVITY_CLAUSE_12`

### Versioning
- Tampon "V1", "V2", "V3", etc. sur la première page

4. **Aplatissement du formulaire :**
```typescript
form.flatten();  // Rend les champs non-modifiables
```

5. **Sauvegarde du PDF :**
```typescript
const pdfBytes = await pdfDoc.save();
```

6. **Upload vers Supabase Storage :**
```typescript
const fileName = `${fileBaseName}_${Date.now()}.pdf`;
const filePath = `offers-pdf/${fileName}`;

const { error: uploadError } = await supabase.storage
  .from('offers')
  .upload(filePath, pdfBytes, {
    contentType: 'application/pdf',
    upsert: true
  });

if (uploadError) throw uploadError;
```

7. **Génération URL signée (7 jours) :**
```typescript
const { data, error } = await supabase.storage
  .from('offers')
  .createSignedUrl(filePath, 604800);  // 7 jours

if (error) throw error;

return data.signedUrl;
```

---

## 🧹 Fonctions utilitaires

### `cleanTextForPdf()`
**Description :** Nettoie les caractères Unicode problématiques pour le PDF

```typescript
function cleanTextForPdf(text: string): string {
  if (!text) return '';
  return text
    .replace(/\u202f/g, ' ')    // Espace fine insécable → espace
    .replace(/\u00a0/g, ' ')    // Espace insécable → espace
    .replace(/[\u2000-\u200f]/g, ' ') // Autres espaces Unicode → espace
    .replace(/[\u2010-\u2015]/g, '-') // Tirets Unicode → tiret normal
    .replace(/[\u2018-\u2019]/g, "'") // Guillemets simples → apostrophe
    .replace(/[\u201c-\u201d]/g, '"') // Guillemets doubles → guillemets normaux
    .replace(/[^\x00-\x7F]/g, (char) => {
      // Remplacer accents par équivalents ASCII
      const replacements: { [key: string]: string } = {
        'à': 'a', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'î': 'i', 'ï': 'i', 'ô': 'o', 'ù': 'u', 'û': 'u', 'ü': 'u',
        'ç': 'c', 'ñ': 'n',
        // Majuscules
        'À': 'A', 'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
        'Î': 'I', 'Ï': 'I', 'Ô': 'O', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
        'Ç': 'C', 'Ñ': 'N'
      };
      return replacements[char] || char;
    });
}
```

### `formatCurrency()`
**Description :** Formate un montant selon la norme suisse (apostrophes)

```typescript
function formatCurrency(amount: number | string | undefined): string {
  if (amount === null || amount === undefined) return '';
  const num = typeof amount === 'string' ? parseFloat(amount) : amount;
  if (isNaN(num)) return '';
  
  const formatted = new Intl.NumberFormat('fr-CH', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
    useGrouping: true
  }).format(num);
  
  // Remplacer espaces par apostrophes (norme suisse)
  return formatted
    .replace(/\u202f/g, "'")
    .replace(/\u00a0/g, " ")
    .replace(/\s/g, "'");
}
```

**Exemples :**
- `1000` → `1'000`
- `1500.50` → `1'500.50`
- `100000` → `100'000`

### `formatDate()`
**Description :** Formate une date en DD.MM.YYYY

```typescript
function formatDate(dateString: string | undefined): string {
  if (!dateString) return '';
  
  if (dateString.includes('-')) {
    // Format YYYY-MM-DD
    const [year, month, day] = dateString.split('-');
    return `${day.padStart(2, '0')}.${month.padStart(2, '0')}.${year}`;
  }
  
  // Fallback
  const date = new Date(dateString);
  const day = date.getDate().toString().padStart(2, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const year = date.getFullYear();
  return `${day}.${month}.${year}`;
}
```

### `formatPercentage()`
**Description :** Formate un pourcentage

```typescript
function formatPercentage(value: number | string | undefined): string {
  if (value === null || value === undefined) return '';
  return cleanTextForPdf(`${value} %`);
}
```

### `formatDuration()`
**Description :** Formate une durée en minutes

```typescript
function formatDuration(minutes: number | string | undefined): string {
  if (minutes === null || minutes === undefined) return '';
  return cleanTextForPdf(`${minutes}'`);
}
```

---

## 📦 Stockage du PDF

### Bucket Supabase : `offers`

**Politique d'accès :**
- SELECT : Authentifié
- INSERT : Authentifié
- UPDATE : Authentifié
- DELETE : Authentifié

**Structure des chemins :**
```
offers/
  offers-pdf/
    OFFRE_EVENEMENT_ARTISTE_1234567890.pdf
    OFFRE_EVENEMENT_ARTISTE_9876543210.pdf
    ...
```

**Durée des URLs signées :** 7 jours (604800 secondes)

---

## 🔄 Process complet

```
1. OfferComposer : Collecte données formulaire
   ↓
2. handleGeneratePdf() : Validation + préparation OfferPdfData
   ↓
3. generateOfferPdfAndUpload() : 
   - Téléchargement template
   - Remplissage champs
   - Aplatissement
   - Sauvegarde binaire
   ↓
4. Upload Supabase Storage (bucket 'offers')
   ↓
5. Création URL signée (7 jours)
   ↓
6. Prévisualisation dans PdfPreviewModal
   ↓
7. Click "Prêt à envoyer"
   ↓
8. Sauvegarde BDD : offers.pdf_storage_path = "offers-pdf/OFFRE_..."
   ↓
9. Envoi email : Régénération URL signée + EmailJS
```

---

## 🎨 Template PDF - Champs disponibles

### Champs texte
- `ARTIST_NAME`
- `STAGE_NAME`
- `DATE`
- `TIME`
- `DURATION`
- `AMOUNT`
- `CURRENCY`
- `AMOUNT_TYPE`
- `AGENCY_COMMISSION`
- `VALIDITY_DATE`
- `PROD_FEE_AMOUNT`
- `PROD_FEE_CURRENCY`
- `BACKLINE_FEE_AMOUNT`
- `BACKLINE_FEE_CURRENCY`
- `BUYOUT_HOTEL_AMOUNT`
- `BUYOUT_HOTEL_CURRENCY`
- `BUYOUT_MEAL_AMOUNT`
- `BUYOUT_MEAL_CURRENCY`
- `FLIGHT_CONTRIBUTION_AMOUNT`
- `FLIGHT_CONTRIBUTION_CURRENCY`
- `TECHNICAL_FEE_AMOUNT`
- `TECHNICAL_FEE_CURRENCY`

### Cases à cocher (Extras)
- `EXTRA_1_ARTIST`, `EXTRA_1_FESTIVAL` (Hébergement)
- `EXTRA_2_ARTIST`, `EXTRA_2_FESTIVAL` (Restauration)
- `EXTRA_3_ARTIST`, `EXTRA_3_FESTIVAL` (Transport local)
- `EXTRA_4_ARTIST`, `EXTRA_4_FESTIVAL` (Backline)
- `EXTRA_5_ARTIST`, `EXTRA_5_FESTIVAL` (Éclairage)
- `EXTRA_6_ARTIST`, `EXTRA_6_FESTIVAL` (Sonorisation)

### Cases à cocher + textes (Clauses d'exclusivité)
- `EXCLUSIVITY_CLAUSE_1` à `EXCLUSIVITY_CLAUSE_12` (checkboxes)
- `EXCLUSIVITY_CLAUSE_1_TEXT` à `EXCLUSIVITY_CLAUSE_12_TEXT` (textes)

---

## 🐛 Debugging

### Fonction `debugPdfData()`

Fichier : `src/features/booking/pdf/debugPdfFields.ts`

**Usage :**
```typescript
import { debugPdfData, generatePdfDataReport } from './pdf/debugPdfFields';

debugPdfData(pdfData, 'GENERATION DEPUIS OFFERCOMPOSER');
console.log(generatePdfDataReport(pdfData));
```

**Affiche :**
- Présence de chaque champ
- Valeurs non-définies
- Types de données
- Rapport détaillé formaté

---

*[Suite et fin dans BOOKING_SYSTEM_RELATIONS.md]*

