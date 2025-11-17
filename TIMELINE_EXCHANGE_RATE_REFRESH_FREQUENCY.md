# 🔄 Timeline - Fréquence de Rafraîchissement des Taux de Change

## 📊 **État actuel**

### **Fréquence de rafraîchissement : UNE SEULE FOIS**

Actuellement, les taux de change sont récupérés **une seule fois** au chargement de la page Timeline.

```tsx
useEffect(() => {
  const fetchExchangeRates = async () => {
    // Appel API...
  };
  
  fetchExchangeRates();
}, []); // ← Tableau vide = exécution unique au montage
```

---

## ⏱️ **Moments de rafraîchissement**

### **1. Chargement initial**
Lorsque l'utilisateur ouvre la page Timeline pour la première fois.

### **2. Rafraîchissement manuel (F5)**
Si l'utilisateur rafraîchit la page entière (F5 ou Ctrl+R).

### **3. Navigation**
Si l'utilisateur quitte et revient sur la page Timeline.

---

## 🌐 **API ExchangeRate-API**

### **Fréquence de mise à jour côté API**
L'API ExchangeRate-API met à jour ses taux **1 fois par jour** (quotidiennement).

**Heure de mise à jour** : Variable, généralement autour de **00:00 UTC**.

### **Limites de l'API**
- **Plan gratuit** : 1 500 requêtes/mois
- **Pas de limitation de fréquence** par requête
- **Données** : Taux de change officiels (banques centrales)

---

## ⚠️ **Conséquence actuelle**

### **Scénario**
1. L'utilisateur ouvre la Timeline à **14:00**
2. Les taux sont récupérés et affichés
3. L'utilisateur reste sur la page pendant **4 heures**
4. À **18:00**, les taux affichés sont **toujours ceux de 14:00**

**Problème** : Pas de rafraîchissement automatique pendant la session.

### **Impact**
Pour des taux de change qui ne changent qu'une fois par jour, ce n'est **pas critique**, mais l'affichage peut être **légèrement obsolète** si l'utilisateur reste longtemps sur la page.

---

## 💡 **Options d'amélioration**

### **Option A : Rafraîchissement automatique périodique**

Récupérer les taux toutes les X minutes/heures.

#### **Exemple : Toutes les heures**
```tsx
useEffect(() => {
  const fetchExchangeRates = async () => {
    // Appel API...
  };
  
  // Appel initial
  fetchExchangeRates();
  
  // Rafraîchissement toutes les heures (3 600 000 ms)
  const interval = setInterval(fetchExchangeRates, 60 * 60 * 1000);
  
  return () => clearInterval(interval); // Cleanup
}, []);
```

**Avantages** :
- ✅ Taux toujours à jour
- ✅ Automatique (pas d'action utilisateur)

**Inconvénients** :
- ❌ Consommation de requêtes API (1 requête/heure)
- ❌ Peut être excessif pour des taux qui changent 1 fois/jour

---

### **Option B : Bouton de rafraîchissement manuel**

Ajouter un bouton pour rafraîchir les taux manuellement.

#### **Interface**
```
┌─────────────────────────────────────┐
│ 💰 TAUX DE CHANGE              🔄   │ ← Bouton refresh cliquable
├─────────────────────────────────────┤
│ 1 EUR = 0.940 CHF                   │
│ ...                                 │
└─────────────────────────────────────┘
```

#### **Code**
```tsx
const [loadingRates, setLoadingRates] = useState(false);

const refreshRates = async () => {
  // Même logique que fetchExchangeRates
  setLoadingRates(true);
  // ...
};

// Dans le JSX
<RefreshCw 
  className="w-4 h-4 text-amber-600 cursor-pointer hover:rotate-180 transition-transform"
  onClick={refreshRates}
/>
```

**Avantages** :
- ✅ Contrôle utilisateur
- ✅ Pas de requêtes inutiles
- ✅ Simple à implémenter

**Inconvénients** :
- ❌ Nécessite une action de l'utilisateur

---

### **Option C : Rafraîchissement à intervalles intelligents**

Rafraîchir uniquement si les taux pourraient avoir changé.

#### **Stratégie**
- Vérifier `time_last_update_utc` de l'API
- Si la date a changé (nouveau jour), rafraîchir
- Sinon, conserver les taux en cache

#### **Exemple : Toutes les 6 heures, avec vérification**
```tsx
useEffect(() => {
  const fetchExchangeRates = async () => {
    const response = await fetch('https://api.exchangerate-api.com/v4/latest/EUR');
    const data = await response.json();
    
    // Comparer avec la dernière mise à jour stockée
    if (data.time_last_update_utc !== lastUpdate) {
      setCurrencyRates(data.rates);
      setLastUpdate(data.time_last_update_utc);
    }
  };
  
  fetchExchangeRates();
  const interval = setInterval(fetchExchangeRates, 6 * 60 * 60 * 1000); // 6h
  
  return () => clearInterval(interval);
}, [lastUpdate]);
```

**Avantages** :
- ✅ Économie de requêtes si les taux n'ont pas changé
- ✅ Automatique

**Inconvénients** :
- ❌ Plus complexe
- ❌ Nécessite toujours des requêtes pour vérifier

---

### **Option D : Cache avec LocalStorage**

Stocker les taux et la date de mise à jour dans le LocalStorage.

#### **Stratégie**
- Récupérer les taux du LocalStorage au chargement
- Vérifier si les taux sont "frais" (< 24h)
- Si obsolètes, appeler l'API

#### **Code**
```tsx
useEffect(() => {
  const fetchExchangeRates = async () => {
    // Vérifier le cache LocalStorage
    const cachedRates = localStorage.getItem('exchangeRates');
    const cachedTime = localStorage.getItem('exchangeRatesTime');
    
    if (cachedRates && cachedTime) {
      const cacheAge = Date.now() - parseInt(cachedTime);
      const oneDay = 24 * 60 * 60 * 1000;
      
      if (cacheAge < oneDay) {
        // Cache valide (< 24h)
        setCurrencyRates(JSON.parse(cachedRates));
        return;
      }
    }
    
    // Cache invalide ou absent → Appel API
    const response = await fetch('https://api.exchangerate-api.com/v4/latest/EUR');
    const data = await response.json();
    
    setCurrencyRates(data.rates);
    localStorage.setItem('exchangeRates', JSON.stringify(data.rates));
    localStorage.setItem('exchangeRatesTime', Date.now().toString());
  };
  
  fetchExchangeRates();
}, []);
```

**Avantages** :
- ✅ Économie de requêtes API
- ✅ Chargement instantané (cache)
- ✅ Mise à jour automatique (1 fois/jour max)

**Inconvénients** :
- ❌ Plus complexe
- ❌ Cache partagé entre onglets (peut être un avantage)

---

## 🎯 **Recommandation**

### **Pour votre usage actuel : Option B (Bouton manuel)**

**Pourquoi ?**
1. **Simple** : Facile à implémenter
2. **Contrôlé** : L'utilisateur décide quand rafraîchir
3. **Économique** : Pas de requêtes inutiles
4. **Suffisant** : Les taux changent 1 fois/jour, pas besoin de rafraîchissement automatique

### **Si vous voulez automatiser : Option D (Cache LocalStorage)**

**Pourquoi ?**
1. **Intelligent** : Rafraîchit uniquement si nécessaire (> 24h)
2. **Performant** : Utilise le cache pour les chargements suivants
3. **Économique** : Maximum 1 requête API/jour par utilisateur

---

## 📋 **Récapitulatif**

| Approche | Fréquence | Automatique | Consommation API | Complexité |
|----------|-----------|-------------|------------------|------------|
| **Actuel** | 1× (chargement) | ❌ Non | Faible | ✅ Simple |
| **Option A** | Toutes les 1-6h | ✅ Oui | Moyenne-Haute | Moyenne |
| **Option B** | À la demande | ❌ Non | Faible | ✅ Simple |
| **Option C** | Intelligent | ✅ Oui | Moyenne | Haute |
| **Option D** | 1×/jour max | ✅ Oui | Très faible | Moyenne |

---

## 🚀 **Conclusion**

### **État actuel**
- ✅ Les taux sont récupérés **1 fois au chargement**
- ✅ Les taux de l'API sont mis à jour **1 fois/jour**
- ❌ Pas de rafraîchissement automatique pendant la session

### **Recommandation**
Ajouter un **bouton de rafraîchissement manuel** (Option B) pour un bon compromis entre simplicité et fonctionnalité.

**Voulez-vous que j'implémente cette fonctionnalité ? 🔄**

