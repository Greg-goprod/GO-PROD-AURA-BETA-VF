# 🚀 Message de démarrage optimisé pour nouveau chat

Copiez-collez ce message au démarrage d'un nouveau chat pour restaurer le contexte complet.

---

## 📋 Message à envoyer

```
Bonjour ! Je travaille sur Go-Prod AURA, une plateforme SaaS multi-tenant (React + TypeScript + Vite + Supabase + Tailwind) pour la gestion d'événements/festivals.

📁 Merci de lire CONTEXTE_NOUVEAU_CHAT.md qui contient TOUT le contexte du projet (architecture, standards AURA, composants, règles de développement).

⚠️ STANDARDS OBLIGATOIRES à respecter ABSOLUMENT :

1. **Pickers date/time** : TOUJOURS utiliser `DatePickerPopup`, `TimePickerPopup`, `DateTimePickerPopup` (popup 330x380 / 300x380 / 630x380). Docs : PICKERS_STANDARD.md

2. **Inputs** : Hauteur par défaut 36px (`size='sm'` automatique). Docs : INPUT_SM_DEFAULT_GLOBAL.md

3. **Création événements** : Jours générés automatiquement dès sélection des dates. Règle : un jour commence à sa date mais peut se terminer le lendemain (ex: J1 = 30/10 17:00 → 31/10 03:00). Docs : EVENT_AUTO_DAYS_CREATION.md

4. **Multi-tenant** : TOUJOURS filtrer par `company_id`, vérifier présence avant API call, toast erreur si manquant.

5. **No-event safe mode** : TOUJOURS gérer l'absence d'événement avec `EmptyState`.

6. **Composants AURA uniquement** : Button, Input, Select, Textarea, Modal, Card, Badge, Toast, EmptyState.

7. **react-hook-form** : Standard pour tous les formulaires avec `Controller` pour pickers.

8. **Dark/Light mode** : Variables CSS `var(--color-*)` + classes Tailwind `dark:`.

📚 Docs disponibles :
- PICKERS_STANDARD.md (⭐ référence pickers)
- INPUT_SM_DEFAULT_GLOBAL.md (⭐ référence inputs)
- EVENT_AUTO_DAYS_CREATION.md (⭐ création auto jours)
- AURA_PICKERS_POPUP_MODE.md
- EVENT_MANAGEMENT_SYSTEM.md
- BOOKING_MODULE.md
- TIMELINE_BOOKING.md

🎯 État actuel :
- ✅ Module Artistes complet
- ✅ Module Booking (Kanban 5 colonnes, PDF, email)
- ✅ Timeline drag&drop
- ✅ Paramètres avec tabs persistants
- ✅ Modal "Créer un événement" avec jours inline (3 colonnes : Badge J1-date | Heure début | Heure fin)

Je suis prêt pour la suite ! Que veux-tu développer ?
```

---

## 🎯 Avantages de ce message

### 1. Restauration complète du contexte
- ✅ Référence au fichier `CONTEXTE_NOUVEAU_CHAT.md`
- ✅ Standards AURA rappelés immédiatement
- ✅ Docs clés identifiées (⭐)
- ✅ État actuel du projet

### 2. Prévention des erreurs
- ✅ Standards obligatoires en tête de message
- ✅ Règles multi-tenant et no-event safe mode
- ✅ Convention pickers popup AURA
- ✅ Convention inputs 36px

### 3. Efficacité maximale
- ✅ Pas de temps perdu à réexpliquer
- ✅ L'IA peut démarrer directement
- ✅ Tous les standards sont clairs
- ✅ Docs de référence identifiées

---

## 📝 Variantes selon le contexte

### Si tu veux continuer une feature spécifique

Ajouter après le message de base :

```
Je travaille actuellement sur [FEATURE_NAME]. 
Voici ce qui a été fait : [DESCRIPTION].
Voici ce qui reste à faire : [TODO_LIST].
```

### Si tu veux démarrer une nouvelle feature

Ajouter après le message de base :

```
Je veux créer une nouvelle feature : [DESCRIPTION].
Peux-tu m'aider à :
1. Définir l'architecture (types, API, composants)
2. Respecter les standards AURA
3. Implémenter le multi-tenant et no-event safe mode
4. Créer les composants avec les pickers popup et inputs 36px
```

### Si tu veux corriger un bug

Ajouter après le message de base :

```
J'ai un bug sur [PAGE/COMPOSANT] : [DESCRIPTION DU BUG].
Erreur console : [ERREUR].
Comportement attendu : [ATTENDU].
Comportement actuel : [ACTUEL].
```

---

## 🧪 Test du message

### Checklist avant d'envoyer

- [ ] `CONTEXTE_NOUVEAU_CHAT.md` existe et est à jour
- [ ] Standards AURA rappelés (pickers, inputs, événements)
- [ ] Docs clés identifiées (⭐)
- [ ] État actuel du projet mentionné
- [ ] Contexte spécifique ajouté si nécessaire

### Vérification après envoi

- [ ] L'IA a lu `CONTEXTE_NOUVEAU_CHAT.md`
- [ ] L'IA connaît les standards AURA obligatoires
- [ ] L'IA respecte les conventions (pickers popup, inputs 36px)
- [ ] L'IA applique multi-tenant et no-event safe mode
- [ ] L'IA utilise les bons composants AURA

---

## 🎉 Prêt !

**Ce message permet de restaurer 100% du contexte en un seul envoi.**

**L'IA aura accès à** :
- ✅ Architecture complète du projet
- ✅ Standards AURA obligatoires
- ✅ Composants disponibles
- ✅ Règles de développement
- ✅ Conventions de code
- ✅ État actuel du projet
- ✅ Documentation de référence

**Gain de temps estimé : 15-20 messages d'explications évités ! ⚡**


