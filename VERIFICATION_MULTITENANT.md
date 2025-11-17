# 🔍 Vérification Architecture Multitenant - Guide Rapide

## 📍 Localisation

Les scripts de vérification se trouvent dans : **`supabase/scripts/`**

---

## ⚡ Démarrage Ultra-Rapide

### 1️⃣ Vérification Immédiate (Recommandé)

```bash
# Rendre le script exécutable (une seule fois)
chmod +x supabase/scripts/verify.sh

# Lancer la vérification
./supabase/scripts/verify.sh
```

Le script vous proposera un menu interactif :
- **Option 1** : Vérification SQL complète (affichage détaillé)
- **Option 2** : Vérification JavaScript (rapport JSON)
- **Option 3** : Les deux
- **Option 4** : Générer un rapport et l'enregistrer

---

## 📚 Documentation Complète

Toute la documentation se trouve dans **`supabase/scripts/`** :

| Fichier | Contenu |
|---------|---------|
| 📖 **README.md** | Index et vue d'ensemble |
| 📘 **README_VERIFICATION.md** | Guide de référence complet |
| 📗 **EXEMPLES.md** | Exemples pratiques et cas d'usage |
| 🔧 **verify.sh** | Script interactif |
| 📄 **verify_multitenant_architecture.sql** | Script SQL de vérification |
| 📜 **verify_multitenant_architecture.js** | Script Node.js |

---

## 🎯 Que Vérifie-t-on ?

1. ✅ **Multitenancy** : Toutes les tables métier ont un `company_id`
2. 🔒 **RLS** : Row Level Security activé sur toutes les tables multitenant
3. 🔗 **Intégrité** : Les relations tenant ↔ événement sont cohérentes
4. 📋 **Pots Communs** : Ressources mutualisées (bénévoles, artistes, etc.)
5. 📊 **Statistiques** : Vue d'ensemble de l'architecture

---

## 🚦 Quand Vérifier ?

- ✅ **Avant chaque déploiement**
- ✅ **Après ajout/modification de table**
- ✅ **Après chaque migration**
- ✅ **Hebdomadaire en production** (monitoring)

---

## 📖 Pour Aller Plus Loin

Consultez la documentation complète :

```bash
# Ouvrir la documentation
code supabase/scripts/README.md
```

Ou lisez directement :
- **Guide complet** : [`supabase/scripts/README_VERIFICATION.md`](supabase/scripts/README_VERIFICATION.md)
- **Exemples pratiques** : [`supabase/scripts/EXEMPLES.md`](supabase/scripts/EXEMPLES.md)

---

## 🆘 Besoin d'Aide ?

### Script ne fonctionne pas ?

```bash
# Vérifier les dépendances
node --version  # Node.js installé ?
npm --version   # npm installé ?
supabase --version  # Supabase CLI installé ?

# Installer Supabase CLI si nécessaire
npm install -g supabase

# Installer les dépendances Node.js
npm install @supabase/supabase-js
```

### Variables d'environnement manquantes ?

```bash
# Définir les variables (pour script JavaScript)
export SUPABASE_URL="https://votre-projet.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="eyJhbGc..."
```

### Permission denied ?

```bash
chmod +x supabase/scripts/verify.sh
```

---

## ✅ Résultat Attendu

### ✅ Architecture OK

```
✅ ARCHITECTURE MULTITENANT PARFAITE !

  • 45 tables avec company_id (multitenancy OK)
  • 0 table métier sans company_id
  • 0 table sans RLS
  • 0 violation d'intégrité référentielle
```

### ⚠️ Problèmes Détectés

Consultez [`supabase/scripts/README_VERIFICATION.md`](supabase/scripts/README_VERIFICATION.md) section **"Actions Correctives"**

---

## 🔐 Sécurité

⚠️ Les scripts utilisent la **service_role key** :
- Ne jamais commiter dans Git
- Utiliser des variables d'environnement
- Restreindre l'accès

---

## 📞 Contact

**Équipe Dev Go-Prod AURA**

Pour toute question, contactez l'équipe de développement.

---

**🚀 Prêt à vérifier votre architecture ?**

```bash
./supabase/scripts/verify.sh
```










