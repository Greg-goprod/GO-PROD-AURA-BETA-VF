# 📊 Timeline - Comportement des Cartes KPI (État Actuel)

## 🎯 **Vue d'ensemble**

Les cartes KPI sont organisées en **8 colonnes** :
- **Colonnes 1-6** : Cartes par jour (max 6 jours)
- **Colonne 7** : Total Général
- **Colonne 8** : Taux de Change

---

## 📈 **Comportement actuel des totaux**

### **1. Cartes par jour (Colonnes 1-6)**

#### **Calcul**
```tsx
// Pour chaque jour
const dayPerformances = performances.filter(p => p.event_day_id === day.id);

// Grouper par devise
const feesByCurrency: Record<string, number> = {};
dayPerformances.forEach(perf => {
  if (perf.fee_amount && perf.fee_currency) {
    feesByCurrency[perf.fee_currency] = (feesByCurrency[perf.fee_currency] || 0) + perf.fee_amount;
  }
});
```

**Résultat** : Chaque jour affiche la **somme des cachets** pour chaque devise.

#### **Affichage**
```
┌─────────────────────────┐
│ 📅 VENDREDI 31 oct. 2025│
├─────────────────────────┤
│ EUR:     12 000 EUR     │ ← Somme des cachets EUR du vendredi
│ USD:      5 000 USD     │ ← Somme des cachets USD du vendredi
│ GBP:      2 000 GBP     │ ← Somme des cachets GBP du vendredi
│ CHF:      3 000 CHF     │ ← Somme des cachets CHF du vendredi
├─────────────────────────┤
│ Total CHF: 18 450 CHF   │ ← Total converti en CHF
└─────────────────────────┘
```

**Total CHF du jour** : Converti en temps réel avec les taux de change.

```tsx
const totalCHF = calculateCHFTotal(totalFees);

// calculateCHFTotal() :
let totalCHF = fees.CHF || 0;
totalCHF += fees.EUR * currencyRates.CHF;        // EUR → CHF
totalCHF += fees.USD * (currencyRates.CHF / currencyRates.USD); // USD → CHF
totalCHF += fees.GBP * (currencyRates.CHF / currencyRates.GBP); // GBP → CHF
```

---

### **2. Carte Total Général (Colonne 7)**

#### **Calcul**
```tsx
// Total de TOUTES les performances (tous jours confondus)
const totalFees: Record<string, number> = {};
performances.forEach(perf => {
  if (perf.fee_amount && perf.fee_currency) {
    totalFees[perf.fee_currency] = (totalFees[perf.fee_currency] || 0) + perf.fee_amount;
  }
});
```

**Résultat** : Somme de **tous les cachets** de l'événement, groupés par devise.

#### **Affichage**
```
┌─────────────────────────┐
│ 📈 TOTAL GÉNÉRAL        │
├─────────────────────────┤
│ EUR:     35 000 EUR     │ ← Somme de TOUS les cachets EUR
│ USD:     12 000 USD     │ ← Somme de TOUS les cachets USD
│ GBP:      8 000 GBP     │ ← Somme de TOUS les cachets GBP
│ CHF:     10 000 CHF     │ ← Somme de TOUS les cachets CHF
├─────────────────────────┤
│ Total CHF: 64 320 CHF   │ ← Total global converti en CHF
└─────────────────────────┘
```

**Total CHF global** : Conversion en CHF avec les taux de change en temps réel.

---

### **3. Carte Taux de Change (Colonne 8)**

#### **Affichage**
```
┌─────────────────────────┐
│ 💰 TAUX DE CHANGE       │
├─────────────────────────┤
│ 1 EUR = 0.940 CHF       │
│ 1 USD = 0.757 CHF       │
│ 1 GBP = 1.015 CHF       │
│ 1 CHF = 1.000 CHF       │
├─────────────────────────┤
│ ● Taux en temps réel    │
│ Mis à jour: 31/10/2024  │
│ à 14:23                 │
│ Source: ExchangeRate-API│
└─────────────────────────┘
```

---

## 🔢 **Exemple concret**

### **Données de performances**

#### **Vendredi 31 octobre**
- Artiste A : 5 000 EUR
- Artiste B : 2 000 USD
- Artiste C : 1 000 CHF

#### **Samedi 1er novembre**
- Artiste D : 8 000 EUR
- Artiste E : 3 000 USD
- Artiste F : 2 000 GBP

#### **Dimanche 2 novembre**
- Artiste G : 4 000 EUR
- Artiste H : 1 000 GBP

### **Taux de change (exemple)**
- 1 EUR = 0.940 CHF
- 1 USD = 0.757 CHF
- 1 GBP = 1.015 CHF

---

### **Calcul des cartes**

#### **Carte Vendredi**
```
EUR: 5 000 EUR
USD: 2 000 USD
GBP: 0 GBP
CHF: 1 000 CHF

Total CHF = 1 000 (CHF direct)
          + 5 000 × 0.940 (EUR → CHF) = 4 700
          + 2 000 × 0.757 (USD → CHF) = 1 514
          = 7 214 CHF
```

#### **Carte Samedi**
```
EUR: 8 000 EUR
USD: 3 000 USD
GBP: 2 000 GBP
CHF: 0 CHF

Total CHF = 0
          + 8 000 × 0.940 = 7 520
          + 3 000 × 0.757 = 2 271
          + 2 000 × 1.015 = 2 030
          = 11 821 CHF
```

#### **Carte Dimanche**
```
EUR: 4 000 EUR
USD: 0 USD
GBP: 1 000 GBP
CHF: 0 CHF

Total CHF = 0
          + 4 000 × 0.940 = 3 760
          + 1 000 × 1.015 = 1 015
          = 4 775 CHF
```

#### **Carte Total Général**
```
EUR: 5 000 + 8 000 + 4 000 = 17 000 EUR
USD: 2 000 + 3 000 + 0     = 5 000 USD
GBP: 0 + 2 000 + 1 000     = 3 000 GBP
CHF: 1 000 + 0 + 0         = 1 000 CHF

Total CHF = 1 000
          + 17 000 × 0.940 = 15 980
          + 5 000 × 0.757  = 3 785
          + 3 000 × 1.015  = 3 045
          = 23 810 CHF
```

**Vérification** : 7 214 + 11 821 + 4 775 = 23 810 CHF ✓

---

## 📊 **Résultat visuel complet**

```
┌──────────────┬──────────────┬──────────────┬────────┬────────┬────────┬──────────────┬──────────────┐
│ VENDREDI     │ SAMEDI       │ DIMANCHE     │ (vide) │ (vide) │ (vide) │ TOTAL GÉNÉRAL│ TAUX CHANGE  │
│ 31 oct. 2025 │ 1er nov. 2025│ 2 nov. 2025  │        │        │        │              │              │
├──────────────┼──────────────┼──────────────┼────────┼────────┼────────┼──────────────┼──────────────┤
│ EUR: 5 000   │ EUR: 8 000   │ EUR: 4 000   │        │        │        │ EUR: 17 000  │ 1 EUR = 0.940│
│ USD: 2 000   │ USD: 3 000   │ USD: 0       │        │        │        │ USD: 5 000   │ 1 USD = 0.757│
│ GBP: 0       │ GBP: 2 000   │ GBP: 1 000   │        │        │        │ GBP: 3 000   │ 1 GBP = 1.015│
│ CHF: 1 000   │ CHF: 0       │ CHF: 0       │        │        │        │ CHF: 1 000   │ 1 CHF = 1.000│
├──────────────┼──────────────┼──────────────┼────────┼────────┼────────┼──────────────┼──────────────┤
│ Total CHF:   │ Total CHF:   │ Total CHF:   │        │        │        │ Total CHF:   │ ● Temps réel │
│ 7 214 CHF    │ 11 821 CHF   │ 4 775 CHF    │        │        │        │ 23 810 CHF   │ 31/10 14:23  │
└──────────────┴──────────────┴──────────────┴────────┴────────┴────────┴──────────────┴──────────────┘
   Colonne 1      Colonne 2      Colonne 3       4        5        6       Colonne 7      Colonne 8
```

---

## 🎯 **Points clés**

### ✅ **Cartes par jour (1-6)**
- **Source** : Performances filtrées par `event_day_id`
- **Groupement** : Par devise (EUR, USD, GBP, CHF)
- **Total CHF** : Conversion en temps réel

### ✅ **Carte Total Général (7)**
- **Source** : TOUTES les performances (tous jours confondus)
- **Groupement** : Par devise (EUR, USD, GBP, CHF)
- **Total CHF** : Conversion en temps réel
- **Vérification** : Somme des totaux CHF des jours = Total CHF général

### ✅ **Carte Taux de Change (8)**
- **Source** : API ExchangeRate-API
- **Mise à jour** : En temps réel (quotidienne)
- **Affichage** : Date/heure de mise à jour + source

---

## 🔄 **Conversions des devises**

### **Formules utilisées**

#### **EUR → CHF**
```
montantCHF = montantEUR × taux[CHF]
```
Exemple : 1 000 EUR × 0.940 = 940 CHF

#### **USD → CHF**
```
montantCHF = montantUSD × (taux[CHF] / taux[USD])
```
Exemple : 1 000 USD × (0.940 / 1.241) = 757 CHF

#### **GBP → CHF**
```
montantCHF = montantGBP × (taux[CHF] / taux[GBP])
```
Exemple : 1 000 GBP × (0.940 / 0.926) = 1 015 CHF

#### **CHF → CHF**
```
montantCHF = montantCHF
```
Exemple : 1 000 CHF = 1 000 CHF

---

## 📝 **Comportement spécifique**

### **1. Performances sans cachet**
```tsx
if (perf.fee_amount && perf.fee_currency) {
  // Comptabilisé
}
```

**Règle** : Si `fee_amount` ou `fee_currency` est `null`, la performance n'est **pas comptabilisée** dans les totaux.

### **2. Formatage des montants**
```tsx
formatCurrency(amount)  // 12345 → "12 345" (sans décimales)
```

**Règle** : Les montants sont affichés **sans décimales**, avec des espaces comme séparateurs de milliers.

### **3. Total CHF arrondi**
```tsx
{formatCurrency(Math.round(totalCHF))} CHF
```

**Règle** : Le total CHF est **arrondi à l'entier** le plus proche.

### **4. Cartes vides (colonnes 4-6)**
Si l'événement a moins de 6 jours, les colonnes restantes affichent des **cartes vides** (bordure en pointillés).

---

## 🔍 **Vérification de cohérence**

### **Test de cohérence**
```
Somme des totaux CHF des jours === Total CHF général
```

**Exemple** :
- Vendredi : 7 214 CHF
- Samedi : 11 821 CHF
- Dimanche : 4 775 CHF
- **Total** : 7 214 + 11 821 + 4 775 = **23 810 CHF**
- **Carte Total Général** : **23 810 CHF** ✓

**Cohérent !**

---

## 🎨 **Design et couleurs**

### **Cartes par jour**
- Fond : Blanc (`bg-white`)
- Bordure : Grise (`border-gray-200`)
- Icône : Violet (`text-violet-600`)
- Total CHF : Violet (`text-violet-600`)

### **Carte Total Général**
- Fond : Dégradé violet → bleu (`from-violet-50 to-blue-50`)
- Bordure : Violet (`border-violet-200`)
- Icône : Violet (`text-violet-600`)
- Total CHF : Violet (`text-violet-600`)

### **Carte Taux de Change**
- Fond : Dégradé ambre → orange (`from-amber-50 to-orange-50`)
- Bordure : Ambre (`border-amber-200`)
- Icône : Ambre (`text-amber-600`)
- Taux : Ambre (`text-amber-600`)

---

## 📊 **Résumé de l'état actuel**

### ✅ **Fonctionnalités opérationnelles**
1. **Calcul des totaux par jour** (groupés par devise)
2. **Calcul du total général** (somme de toutes les performances)
3. **Conversion en CHF** en temps réel (via API)
4. **Affichage des taux de change** avec date/heure de mise à jour
5. **Indicateur de connexion** (pastille colorée)
6. **Grille 8 colonnes** responsive
7. **Cartes vides** pour les jours manquants (max 6 jours)

### ✅ **Cohérence des données**
- ✅ Somme des totaux CHF des jours = Total CHF général
- ✅ Conversions de devises correctes
- ✅ Taux de change en temps réel
- ✅ Performances sans cachet ignorées

### ✅ **Interface utilisateur**
- ✅ Design AURA (violet, ambre)
- ✅ Mode clair/sombre
- ✅ Formatage français (espaces, date, heure)
- ✅ Responsive (grille 8 colonnes)

---

## 🚀 **État actuel : Fonctionnel et cohérent !**

Les cartes KPI fonctionnent correctement et affichent les totaux de manière cohérente :
- **Par jour** : Somme des cachets du jour
- **Total Général** : Somme de tous les cachets
- **Conversion CHF** : En temps réel avec l'API
- **Vérification** : Somme des jours = Total général ✓

**Le système est opérationnel et fiable ! 📊✨**

