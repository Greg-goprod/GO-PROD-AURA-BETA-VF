# 🎨 Timeline - Restructuration Complète AURA

## 📊 Vue d'ensemble

La Timeline a été **complètement restructurée** pour correspondre à l'image de référence fournie, avec les **jours en vertical** et les **heures en horizontal**.

---

## ✅ Modifications effectuées

### 1. **Structure inversée** ✨

#### Avant
```
[Header]
  Scènes | Jour 1 | Jour 2
  
[Body]
  Scène 1 | [Perfs J1] | [Perfs J2]
  Scène 2 | [Perfs J1] | [Perfs J2]
```

#### Après (comme dans l'image)
```
[Header]
  Horaires | 18:00 | 19:00 | 20:00 | ... | 4:00

[Body]
  VENDREDI 28 novembre 2025
    2ème scène     | [Performances]
    ma scène       | [Performances]
  
  SAMEDI 29 novembre 2025
    2ème scène     | [Performances]
    ma scène       | [Performances]
```

---

### 2. **Scènes triées par capacité** 📊

Les scènes sont maintenant automatiquement triées par **capacité décroissante** (de la plus grande à la plus petite) :

```tsx
// src/features/timeline/components/TimelineGrid.tsx

const sortedStages = useMemo(() => {
  return [...stages].sort((a, b) => (b.capacity || 0) - (a.capacity || 0));
}, [stages]);
```

---

### 3. **Amplitude horaire globale** ⏰

L'amplitude horaire est calculée automatiquement selon :
- **Heure d'ouverture la plus tôt** de tous les jours
- **Heure de fermeture la plus tard** de tous les jours

```tsx
// Exemple :
// Vendredi : 18:00 → 02:00
// Samedi : 19:00 → 04:00
// 
// Timeline affichera : 18:00 → 04:00 (amplitude globale)
```

**Gestion du passage minuit** : Si une fermeture est après minuit (ex: 02:00), elle est automatiquement convertie en heures continues (26:00).

---

### 4. **Responsive & Largeur page** 📱

La timeline est maintenant **responsive** et s'adapte à la largeur de la page :

```tsx
<div className="w-full overflow-x-auto">
  <div style={{ minWidth: totalWidth + 192 + 'px' }}>
    {/* Contenu timeline */}
  </div>
</div>
```

- `overflow-x-auto` : scroll horizontal sur petits écrans
- `w-full` : prend toute la largeur disponible
- `minWidth` : largeur minimale calculée dynamiquement

---

### 5. **Cartes KPI ajustées** 💰

#### Avant
- 1 carte par jour
- 1 carte "Total Général"
- 1 carte "Taux de change" (statique)

#### Après (comme demandé)
- **1 carte par jour** (avec totaux par devise + CHF)
- **1 carte "Taux de change"** (API temps réel)

---

### 6. **API Taux de change en temps réel** 🌍

Intégration de l'API **Exchangerate API** :

```tsx
// src/features/timeline/components/DailySummaryCards.tsx

useEffect(() => {
  const fetchExchangeRates = async () => {
    const response = await fetch('https://api.exchangerate-api.com/v4/latest/EUR');
    const data = await response.json();
    setCurrencyRates(data.rates);
  };

  fetchExchangeRates();
}, []);
```

**Fonctionnalités** :
- ✅ Taux en temps réel (EUR → USD, GBP, JPY, CHF)
- ✅ Icône de chargement (spinner)
- ✅ Gestion d'erreur avec fallback (taux fixes)
- ✅ Affichage "✓ Taux en temps réel (API)"

---

## 🎨 Design AURA

### Couleurs utilisées
- **Violet** : Primary AURA (#7C3AED)
- **Amber** : Taux de change (#F59E0B)
- **Vert** : Success (#22C55E)
- **Orange** : Warning (#F59E0B)
- **Rouge** : Error (#EF4444)

### Layout
```
[Cartes KPI - responsive grid]
  Card 1 (Vendredi) | Card 2 (Samedi) | ... | Card Taux

[Timeline - scroll horizontal]
  Header fixe (Horaires : 18:00, 19:00, ...)
  
  Jour 1 (fond violet clair)
    Scène 1 (barre violet + capacité)
    Scène 2 (barre violet + capacité)
    ...
  
  Jour 2 (fond violet clair)
    Scène 1 (barre violet + capacité)
    Scène 2 (barre violet + capacité)
    ...
```

---

## 📁 Fichiers modifiés

### `src/features/timeline/components/TimelineGrid.tsx`
**Réécriture complète** (290 lignes → 320 lignes)

**Changements majeurs** :
- Structure JSX complètement inversée
- Tri des scènes par capacité
- Calcul amplitude horaire globale
- Génération bande horaire unique
- Positionnement performances par calcul
- Responsive avec `overflow-x-auto`

**Nouvelles fonctions** :
```tsx
const sortedStages = useMemo(...);           // Tri par capacité
const { globalStartHour, totalHours } = ...;  // Amplitude globale
const timelineHours = useMemo(...);           // Bande horaire
const getPerformancePosition = (...);         // Position carte
```

---

### `src/features/timeline/components/DailySummaryCards.tsx`
**Refonte partielle** (180 lignes)

**Changements majeurs** :
- Suppression carte "Total Général"
- API taux de change en temps réel
- Gestion état (loading, error, rates)
- Affichage conditionnel des devises (masque si 0)
- Calcul CHF avec taux API

**Nouveaux hooks** :
```tsx
const [currencyRates, setCurrencyRates] = useState<CurrencyRates | null>(null);
const [loadingRates, setLoadingRates] = useState(true);
const [ratesError, setRatesError] = useState<string | null>(null);

useEffect(() => {
  const fetchExchangeRates = async () => {...};
  fetchExchangeRates();
}, []);
```

---

### `src/features/timeline/components/PerformanceCard.tsx`
**Modifications esthétiques** (déjà faites précédemment)

- Couleurs selon statut (orange, vert, rouge, bleu)
- Icônes d'actions (œil, éditer, supprimer)
- Design arrondi (`rounded-xl`)
- Montant en gros
- Nom artiste en UPPERCASE

---

## 🚀 Améliorations techniques

### Performance
- ✅ `useMemo` pour éviter recalculs
- ✅ Tri des scènes une seule fois
- ✅ Calcul amplitude horaire une seule fois
- ✅ Filtrage performances optimisé

### UX
- ✅ Scroll horizontal fluide
- ✅ Header sticky (fixe en scroll)
- ✅ Hover effects sur cellules
- ✅ Icône de chargement taux de change
- ✅ Messages d'erreur clairs

### Accessibilité
- ✅ Contraste élevé (WCAG AA)
- ✅ Labels explicites
- ✅ Dark mode complet
- ✅ Titles sur hover (tooltip natif)

---

## 📊 Structure de données

### Exemple de timeline
```ts
{
  days: [
    {
      id: "d1",
      date: "2025-11-28",
      open_time: "18:00",
      close_time: "02:00"
    },
    {
      id: "d2",
      date: "2025-11-29",
      open_time: "19:00",
      close_time: "04:00"
    }
  ],
  stages: [
    { id: "s1", name: "2ème scène", capacity: 5000 },
    { id: "s2", name: "ma scène", capacity: 1000 }
  ],
  performances: [
    {
      id: "p1",
      artist_name: "SOFIAN PAMART",
      event_day_id: "d1",
      stage_id: "s1",
      performance_time: "21:00",
      duration: 75,
      fee_amount: 100000,
      fee_currency: "EUR",
      booking_status: "offre_a_faire"
    },
    // ...
  ]
}
```

### Rendu final
```
18:00     19:00     20:00     21:00     22:00     23:00     0:00      1:00      2:00      3:00      4:00

VENDREDI 28 novembre 2025 (18:00 → 02:00)

  2ème scène (5000 pers.)
    ├─ [SOFIAN PAMART | 100'000 EUR | 21:00-22:15]
    
  ma scène (1000 pers.)
    ├─ [NISKA | 80'000 EUR | 23:00-00:15]


SAMEDI 29 novembre 2025 (19:00 → 04:00)

  2ème scène (5000 pers.)
    ├─ [...]
    
  ma scène (1000 pers.)
    ├─ [...]
```

---

## ✅ Tests recommandés

### Fonctionnels
- [ ] Scènes triées par capacité
- [ ] Amplitude horaire correcte (min → max)
- [ ] Performances affichées au bon horaire
- [ ] Drag & drop fonctionne entre jours
- [ ] Création performance sur clic cellule

### API
- [ ] Taux de change chargés au mount
- [ ] Spinner visible pendant chargement
- [ ] Fallback si erreur API
- [ ] Conversion CHF correcte

### Responsive
- [ ] Scroll horizontal sur mobile
- [ ] Header sticky lors du scroll
- [ ] Cartes KPI responsive (1 → 2 → 4 cols)
- [ ] Largeur minimale respectée

### Dark mode
- [ ] Toutes les couleurs adaptées
- [ ] Contraste suffisant
- [ ] Bordures visibles
- [ ] Hover effects visibles

---

## 🎯 Prochaines améliorations

1. **Drag & Drop amélioré** : Calculer la nouvelle heure selon la position de drop
2. **Zoom timeline** : Ajuster HOUR_WIDTH dynamiquement
3. **Filtres** : Par scène, par jour, par statut
4. **Export PDF** : Générer un PDF de la timeline
5. **Modes d'affichage** : Compact / Normal / Large
6. **Refresh taux** : Bouton pour recharger les taux manuellement

---

## 📚 Documentation liée

- `TIMELINE_AURA_DESIGN.md` : Design détaillé
- `CONTEXTE_NOUVEAU_CHAT.md` : Contexte projet
- `src/features/timeline/timelineApi.ts` : API functions

---

## 🔥 Points clés

### Ce qui a changé
✅ Structure : Jours en vertical, heures en horizontal  
✅ Scènes : Triées par capacité décroissante  
✅ Horaires : Amplitude globale (min → max)  
✅ Responsive : S'adapte à la largeur de la page  
✅ API : Taux de change en temps réel  
✅ KPI : 1 carte par jour + taux de change  

### Ce qui reste identique
✅ Drag & Drop (fonctionne toujours)  
✅ Cartes de performances (design AURA)  
✅ Création performance sur clic  
✅ Édition / Suppression  
✅ Dark mode  

---

**Timeline restructurée selon vos specs ! 🎉**

