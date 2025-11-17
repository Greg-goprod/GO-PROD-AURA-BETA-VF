# ⏰ Timeline - Propositions d'emplacement des heures

## 📍 **Situation actuelle (❌ Pas satisfaisant)**

```
┌──────────────────────────────────────────────────────────────────┐
│ HORAIRES │  18:00  │  19:00  │  20:00  │  21:00  │  22:00  │...  │  ← STICKY TOP
├──────────────────────────────────────────────────────────────────┤
│ VENDREDI 31 OCTOBRE 2025                                          │
│ ┌────────────────────────────────────────────────────────────┐   │
│ │ 🎵 Scène Principale (5000p.)                                │   │
│ │ [█ Artiste █][█ Artiste █]                                  │   │
│ └────────────────────────────────────────────────────────────┘   │
│ ┌────────────────────────────────────────────────────────────┐   │
│ │ 🎵 Scène Secondaire (2000p.)                                │   │
│ │        [█ Artiste █]                                        │   │
│ └────────────────────────────────────────────────────────────┘   │
│                                                                    │
│ SAMEDI 1 NOVEMBRE 2025                                            │
│ ...                                                                │
└────────────────────────────────────────────────────────────────────┘
```

**Problème** : Les heures sont loin des scènes, difficile de lire l'heure précise d'une performance.

---

## 🎯 **OPTION A : Heures répétées pour CHAQUE JOUR**

**Concept** : Chaque jour affiche sa propre bande horaire

```
┌────────────────────────────────────────────────────────────────────┐
│ VENDREDI 31 OCTOBRE 2025                                           │
│ ┌─────────┬────────────────────────────────────────────────────┐  │
│ │ HORAIRES│  17:00  │  18:00  │  19:00  │  20:00  │  21:00  │  │  │  ← Pour ce jour
│ ├─────────┼────────────────────────────────────────────────────┤  │
│ │ Scène 1 │ [██ Artiste 1 ██][██ Artiste 2 ██]                │  │
│ ├─────────┼────────────────────────────────────────────────────┤  │
│ │ Scène 2 │        [██ Artiste 3 ██]                          │  │
│ └─────────┴────────────────────────────────────────────────────┘  │
│                                                                     │
│ SAMEDI 1 NOVEMBRE 2025                                             │
│ ┌─────────┬────────────────────────────────────────────────────┐  │
│ │ HORAIRES│  17:00  │  18:00  │  19:00  │  20:00  │  21:00  │  │  │  ← Pour ce jour
│ ├─────────┼────────────────────────────────────────────────────┤  │
│ │ Scène 1 │ [██ Artiste 4 ██]                                 │  │
│ │ Scène 2 │           [██ Artiste 5 ██]                       │  │
│ └─────────┴────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

**✅ Avantages** :
- Lecture facile : heures proches des performances
- Contexte visuel : on voit immédiatement l'amplitude de chaque jour
- Pas de confusion entre les jours

**❌ Inconvénients** :
- Répétition visuelle (mais utile)
- Prend un peu plus de hauteur

---

## 🎯 **OPTION B : Heures à GAUCHE de chaque ligne**

**Concept** : Une mini-règle horaire sur chaque ligne de scène

```
┌────────────────────────────────────────────────────────────────────┐
│ VENDREDI 31 OCTOBRE 2025                                           │
│ ┌─────────────┬──────────────────────────────────────────────┐    │
│ │ Scène 1     │ 17 18 19 20 21 22 23 00 01 02 03             │    │
│ │ (5000p.)    │ [██ Artiste 1 ██][██ Artiste 2 ██]           │    │
│ ├─────────────┼──────────────────────────────────────────────┤    │
│ │ Scène 2     │ 17 18 19 20 21 22 23 00 01 02 03             │    │
│ │ (2000p.)    │        [██ Artiste 3 ██]                     │    │
│ └─────────────┴──────────────────────────────────────────────┘    │
│                                                                     │
│ SAMEDI 1 NOVEMBRE 2025                                             │
│ ┌─────────────┬──────────────────────────────────────────────┐    │
│ │ Scène 1     │ 17 18 19 20 21 22 23 00 01 02 03             │    │
│ │ (5000p.)    │ [██ Artiste 4 ██]                            │    │
│ └─────────────┴──────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────────┘
```

**✅ Avantages** :
- Lecture super facile : heures juste au-dessus des performances
- Pas de répétition verticale
- Compact

**❌ Inconvénients** :
- Beaucoup de répétition (chaque ligne)
- Peut être visuellement chargé

---

## 🎯 **OPTION C : Heures en BAS de chaque jour (sticky bottom per day)**

**Concept** : Les heures collent en bas du bloc jour

```
┌────────────────────────────────────────────────────────────────────┐
│ VENDREDI 31 OCTOBRE 2025                                           │
│ ┌─────────────┬──────────────────────────────────────────────┐    │
│ │ Scène 1     │ [██ Artiste 1 ██][██ Artiste 2 ██]           │    │
│ ├─────────────┼──────────────────────────────────────────────┤    │
│ │ Scène 2     │        [██ Artiste 3 ██]                     │    │
│ ├─────────────┼──────────────────────────────────────────────┤    │
│ │ HORAIRES    │  17:00  │  18:00  │  19:00  │  20:00  │ ... │    │  ← En bas du jour
│ └─────────────┴──────────────────────────────────────────────┘    │
│                                                                     │
│ SAMEDI 1 NOVEMBRE 2025                                             │
│ ┌─────────────┬──────────────────────────────────────────────┐    │
│ │ Scène 1     │ [██ Artiste 4 ██]                            │    │
│ ├─────────────┼──────────────────────────────────────────────┤    │
│ │ HORAIRES    │  17:00  │  18:00  │  19:00  │  20:00  │ ... │    │  ← En bas du jour
│ └─────────────┴──────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────────┘
```

**✅ Avantages** :
- Récapitulatif clair par jour
- Pas de confusion
- Heures toujours visibles si on scroll

**❌ Inconvénients** :
- Encore assez loin des performances
- Répétition par jour

---

## 🎯 **OPTION D : Grille verticale PLUS VISIBLE + Labels heures dans les cellules**

**Concept** : Pas de bande séparée, mais les heures sont affichées DANS la grille, plus visibles

```
┌────────────────────────────────────────────────────────────────────┐
│ VENDREDI 31 OCTOBRE 2025                                           │
│ ┌─────────────┬──────────────────────────────────────────────┐    │
│ │ Scène 1     │ 17:00 │ 18:00 │ 19:00 │ 20:00 │ 21:00 │      │    │
│ │ (5000p.)    │   │   │[██ Artiste 1 ██]│[██ Artiste 2 ██] │    │
│ ├─────────────┼───────┼───────┼───────┼───────┼───────┼──────┤    │
│ │ Scène 2     │ 17:00 │ 18:00 │ 19:00 │ 20:00 │ 21:00 │      │    │
│ │ (2000p.)    │   │   │   │   [██ Artiste 3 ██]   │   │      │    │
│ └─────────────┴───────┴───────┴───────┴───────┴───────┴──────┘    │
│                                                                     │
│ SAMEDI 1 NOVEMBRE 2025                                             │
│ └─────────────┴───────┴───────┴───────┴───────┴───────┴──────┘    │
└────────────────────────────────────────────────────────────────────┘
```

**✅ Avantages** :
- Lecture TRÈS facile
- Pas de bande séparée
- Chaque cellule montre son heure

**❌ Inconvénients** :
- Beaucoup de répétition
- Peut être visuellement chargé
- Prend plus d'espace en largeur

---

## 🎯 **OPTION E : Heures en HAUT + RÉPÉTÉES sur chaque ligne (hybride)**

**Concept** : Header global + mini-règle par ligne

```
┌────────────────────────────────────────────────────────────────────┐
│ HORAIRES │  17:00  │  18:00  │  19:00  │  20:00  │  21:00  │ ...  │  ← STICKY TOP
├──────────────────────────────────────────────────────────────────────┤
│ VENDREDI 31 OCTOBRE 2025                                           │
│ ┌─────────────┬──────────────────────────────────────────────┐    │
│ │ Scène 1     │ 17  18  19  20  21  22  23  00  01  02  03   │    │  ← Mini-règle
│ │ (5000p.)    │ [██ Artiste 1 ██][██ Artiste 2 ██]           │    │
│ ├─────────────┼──────────────────────────────────────────────┤    │
│ │ Scène 2     │ 17  18  19  20  21  22  23  00  01  02  03   │    │  ← Mini-règle
│ │ (2000p.)    │        [██ Artiste 3 ██]                     │    │
│ └─────────────┴──────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────────┘
```

**✅ Avantages** :
- Vue d'ensemble (top) + précision (ligne)
- Lecture facile

**❌ Inconvénients** :
- Beaucoup de répétition

---

## 🏆 **MA RECOMMANDATION : OPTION A**

**Pourquoi ?**
1. ✅ **Lecture facile** : Heures proches des performances
2. ✅ **Contexte clair** : Chaque jour a son amplitude visible
3. ✅ **Pas de surcharge** : Une seule bande par jour
4. ✅ **Intuitif** : On voit immédiatement "ce jour va de 17h à 3h"
5. ✅ **Responsive** : S'adapte bien à la largeur dynamique

**Implémentation** :
- Déplacer la bande horaire du header global vers le header de chaque jour
- Conserver la logique responsive (HOUR_WIDTH dynamique)
- Grille verticale (lignes d'heures) reste visible dans chaque ligne de scène

---

## ❓ **Quelle option préférez-vous ?**

- **A** : Heures répétées pour chaque jour (recommandé)
- **B** : Heures à gauche de chaque ligne
- **C** : Heures en bas de chaque jour
- **D** : Grille + labels dans les cellules
- **E** : Hybride (top + ligne)
- **Autre** : Proposez votre idée !

Je peux implémenter n'importe laquelle ou créer une variante !

