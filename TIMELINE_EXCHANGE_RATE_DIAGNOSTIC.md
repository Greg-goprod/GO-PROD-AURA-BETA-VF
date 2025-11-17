# 🔍 Timeline - Diagnostic Carte Taux de Change

## ❓ **Problème**

La carte "Taux de Change" ne s'affiche pas comme attendu.

---

## 🛠️ **Actions à effectuer pour diagnostiquer**

### **Étape 1 : Rafraîchir la page**

1. Appuyez sur **F5** ou **Ctrl+R** (Windows) / **Cmd+R** (Mac)
2. Attendez que la page se recharge complètement

**Raison** : Le code modifié doit être rechargé par le navigateur.

---

### **Étape 2 : Ouvrir la console du navigateur**

1. Appuyez sur **F12** pour ouvrir les outils de développement
2. Cliquez sur l'onglet **Console**
3. Regardez les messages affichés

**Messages attendus** :
```
🔄 Chargement des taux de change...
✅ Taux de change récupérés: { rates: {...}, time_last_update_utc: "..." }
```

**Messages d'erreur possibles** :
```
❌ Erreur chargement taux de change: ...
⚠️ Utilisation des taux fixes (fallback)
```

---

### **Étape 3 : Vérifier l'affichage**

Regardez la **8ème colonne** des cartes KPI (tout à droite).

#### **Si vous voyez la carte avec le titre "TAUX DE CHANGE"**

✅ **Cas A : Carte vide avec un spinner** 🔄
```
┌─────────────────────────────────────┐
│ 💰 TAUX DE CHANGE              🔄   │ ← Spinner qui tourne
└─────────────────────────────────────┘
```

**Problème** : Chargement en cours (ne devrait durer que quelques secondes)

**Solution** : Attendez quelques secondes

---

✅ **Cas B : Carte avec message "Aucune donnée disponible"**
```
┌─────────────────────────────────────┐
│ 💰 TAUX DE CHANGE                   │
│ Aucune donnée disponible            │
└─────────────────────────────────────┘
```

**Problème** : Les taux n'ont pas été chargés

**Solution** : Vérifiez la console pour voir l'erreur

---

✅ **Cas C : Carte avec message d'erreur rouge**
```
┌─────────────────────────────────────┐
│ 💰 TAUX DE CHANGE                   │
│ ⚠️ Impossible de charger les taux   │
│ ...taux fixes (fallback)...         │
└─────────────────────────────────────┘
```

**Problème** : Erreur réseau ou API inaccessible

**Solution** : Vérifiez votre connexion internet

---

✅ **Cas D : Carte complète avec les taux**
```
┌─────────────────────────────────────┐
│ 💰 TAUX DE CHANGE              🔄   │
├─────────────────────────────────────┤
│ 1 EUR = 0.940 CHF                   │
│ 1 USD = 0.757 CHF                   │
│ 1 GBP = 1.015 CHF                   │
│ 1 CHF = 1.000 CHF                   │
├─────────────────────────────────────┤
│ ● Taux en temps réel                │
│ MàJ 31.10.2024 - 14:23              │
│ Source: ExchangeRate-API            │
└─────────────────────────────────────┘
```

**C'est bon !** ✅ La carte s'affiche correctement.

---

#### **Si vous ne voyez PAS la carte du tout**

❌ **La 8ème colonne n'existe pas ou est vide**

**Problèmes possibles** :
1. La page Timeline n'est pas la bonne
2. Le composant `DailySummaryCards` n'est pas rendu
3. Il n'y a pas d'événement sélectionné

**Solution** :
1. Vérifiez que vous êtes bien sur la page **Timeline** (`/app/administration/booking/timeline`)
2. Vérifiez qu'un **événement est sélectionné** dans le sélecteur d'événements (en haut)

---

## 🔍 **Vérifications supplémentaires**

### **1. Êtes-vous sur la bonne page ?**

La carte "Taux de Change" s'affiche uniquement sur la page **Timeline**.

**URL attendue** : `http://localhost:5173/app/administration/booking/timeline`

### **2. Un événement est-il sélectionné ?**

Les cartes KPI (incluant la carte Taux de Change) ne s'affichent que si un événement est sélectionné.

**Vérification** : Regardez le sélecteur d'événements en haut à gauche. Un événement doit être sélectionné.

### **3. Y a-t-il des jours dans l'événement ?**

Les cartes KPI s'affichent avec les jours de l'événement.

**Vérification** : L'événement sélectionné doit avoir au moins 1 jour configuré.

---

## 📋 **Checklist de diagnostic**

Cochez les éléments au fur et à mesure :

- [ ] Page rafraîchie (F5)
- [ ] Console ouverte (F12)
- [ ] Messages de logs visibles dans la console
- [ ] URL correcte (`/timeline`)
- [ ] Événement sélectionné
- [ ] Événement avec au moins 1 jour
- [ ] Cartes KPI visibles (colonnes 1-7)
- [ ] 8ème colonne visible (Taux de Change)

---

## 🚨 **Messages d'erreur possibles dans la console**

### **Erreur 1 : CORS**
```
Access to fetch at 'https://api.exchangerate-api.com/...' from origin '...' 
has been blocked by CORS policy
```

**Cause** : L'API bloque les requêtes depuis votre domaine

**Solution** : Utilisation des taux fixes (fallback automatique)

---

### **Erreur 2 : Réseau**
```
Failed to fetch
TypeError: NetworkError when attempting to fetch resource
```

**Cause** : Pas de connexion internet ou API inaccessible

**Solution** : Vérifiez votre connexion internet

---

### **Erreur 3 : Timeout**
```
The request timed out
```

**Cause** : L'API met trop de temps à répondre

**Solution** : Réessayez en rafraîchissant la page

---

## 💡 **Solutions par ordre de priorité**

### **Solution 1 : Rafraîchir la page**
```
F5 ou Ctrl+R
```

**90% des problèmes** sont résolus par un simple rafraîchissement.

---

### **Solution 2 : Vider le cache du navigateur**
```
Ctrl+Shift+R (Windows/Linux)
Cmd+Shift+R (Mac)
```

Force le rechargement sans utiliser le cache.

---

### **Solution 3 : Vérifier la console**

Ouvrez la console (F12) et regardez les messages d'erreur.

---

### **Solution 4 : Vérifier l'événement**

Assurez-vous qu'un événement est sélectionné et qu'il a des jours configurés.

---

## 📊 **État attendu après diagnostic**

### **Console**
```
🔄 Chargement des taux de change...
✅ Taux de change récupérés: {
  rates: {
    CHF: 0.940,
    USD: 1.241,
    GBP: 0.926,
    EUR: 1,
    ...
  },
  time_last_update_utc: "Fri, 31 Oct 2024 14:23:00 +0000"
}
```

### **Visuel**
8 colonnes de cartes KPI :
1. Jour 1
2. Jour 2
3. Jour 3
4. (vide)
5. (vide)
6. (vide)
7. Total Général
8. **Taux de Change** ← Cette carte doit être visible

---

## 🎯 **Actions immédiates**

1. **Rafraîchissez la page** (F5)
2. **Ouvrez la console** (F12)
3. **Partagez-moi** :
   - Les messages dans la console
   - Une capture d'écran de la page Timeline
   - Ce que vous voyez à la place de la carte Taux de Change

---

**Avec ces informations, je pourrai vous aider à résoudre le problème ! 🔍✨**

