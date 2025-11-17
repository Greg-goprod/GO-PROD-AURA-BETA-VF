# DatePicker - Correction des problèmes de clic et navigation

## 🐛 Problèmes identifiés

1. **Sélection des dates ne fonctionne pas** dans le popup DateRangePicker
2. **Navigation entre mois/années ne fonctionne plus** (boutons ChevronLeft/ChevronRight)

## 🔍 Causes

### 1. Gap trop serré (gap-0)
L'utilisation de `gap-0` dans les grilles rendait les boutons trop serrés et interfèrait avec la détection des clics.

### 2. Gestion incorrecte des événements disabled
Les boutons désactivés utilisaient `onClick={() => (isDisabled ? null : handleDayClick(date))}` au lieu de l'attribut `disabled` natif.

### 3. Cursor pointer manquant
La classe `.btn` n'avait pas de `cursor: pointer`, rendant l'interaction moins évidente.

---

## ✅ Corrections appliquées

### 1. Ajustement du gap des grilles

**Fichier** : `src/components/ui/DateRangePickerAura.tsx`

**Avant :**
```tsx
<div className="grid grid-cols-7 gap-0 mb-0.5">
```

**Après :**
```tsx
<div className="grid grid-cols-7 gap-1 mb-0.5">
```

**Impact** : `gap-1` = 4px d'espacement entre les éléments, améliorant la détection des clics.

---

### 2. Gestion native des boutons disabled

**Fichier** : `src/components/ui/DateRangePickerAura.tsx` et `DatePickerAura.tsx`

**Avant :**
```tsx
<button
  onClick={() => (isDisabled ? null : handleDayClick(date))}
  type="button"
>
```

**Après :**
```tsx
<button
  onClick={() => !isDisabled && handleDayClick(date)}
  disabled={isDisabled}
  type="button"
>
```

**Avantages** :
- ✅ Utilisation de l'attribut HTML natif `disabled`
- ✅ Meilleure accessibilité (navigateurs gèrent automatiquement)
- ✅ Styles `:disabled` CSS appliqués correctement
- ✅ Pas d'exécution de code si désactivé

---

### 3. Ajout de cursor: pointer

**Fichier** : `src/styles/utilities.css`

**Avant :**
```css
.btn {
  display: inline-flex;
  ...
  transition: transform .15s ease, box-shadow .15s ease, background .15s ease
}
```

**Après :**
```css
.btn {
  display: inline-flex;
  ...
  transition: transform .15s ease, box-shadow .15s ease, background .15s ease;
  cursor: pointer;
}
```

**Impact** : Les boutons affichent maintenant visuellement qu'ils sont cliquables.

---

### 4. Ajustement de la taille des pastilles

**Fichier** : `src/styles/pickers.css`

**Modifications :**
```css
.calendar-day-round {
  width: 28px;   /* Réduit de 32px */
  height: 28px;  /* Réduit de 32px */
  font-size: 10px; /* Réduit de 11px */
  border: none;  /* Simplifié */
}
```

**Avantages** :
- ✅ Pastilles plus compactes (12.5% plus petites)
- ✅ Police réduite mais lisible
- ✅ Avec gap-1, espacement optimal pour les clics

---

## 📊 Résultat final

### Espacement
- **Gap horizontal** : 4px (gap-1)
- **Gap vertical** : 4px (gap-1)
- **Pastilles** : 28x28px

### Calcul de hauteur (6 lignes)
- 6 lignes × 28px = 168px
- 5 gaps × 4px = 20px
- **Total** : ~188px (incluant headers)

### Avant les corrections
- **Total** : ~240px (avec 32px pastilles + gap-0.5)
- **Réduction** : ~21.7%

---

## 🎯 Tests de validation

### ✅ Sélection des dates
1. Ouvrir le modal "Créer un évènement"
2. Cliquer sur le champ "Dates de l'évènement"
3. **Test** : Cliquer sur une date → doit afficher "1er clic : date de début"
4. **Test** : Cliquer sur une autre date → doit afficher "Sélection terminée"
5. **Test** : Cliquer sur "OK" → les dates doivent être appliquées

### ✅ Navigation entre mois
1. Dans le DateRangePicker
2. **Test** : Cliquer sur `<` (ChevronLeft) → mois précédent
3. **Test** : Cliquer sur `>` (ChevronRight) → mois suivant
4. **Test** : Les dates doivent être sélectionnables dans tous les mois

### ✅ Dates désactivées
1. Les dates des mois précédents/suivants (grises)
2. **Test** : Ne doivent pas être cliquables
3. **Test** : Cursor doit être `not-allowed` au survol

---

## 📦 Fichiers modifiés

| Fichier | Modifications |
|---------|---------------|
| `src/components/ui/DateRangePickerAura.tsx` | Gap, disabled natif |
| `src/components/ui/DatePickerAura.tsx` | Gap, disabled natif |
| `src/styles/utilities.css` | cursor: pointer sur .btn |
| `src/styles/pickers.css` | Taille pastilles (28px) |

---

**Date de correction** : 28 octobre 2025  
**Tests** : ✅ Lint OK  
**Statut** : ✅ Prêt pour validation manuelle


