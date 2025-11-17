# 📅 DATEPICKER - Cohésion avec TimePicker

## 🎯 Objectif
Rendre le DatePicker **graphiquement cohérent** avec le TimePicker

## 📐 Dimensions

### Popup
- **Largeur** : **330px** (identique au TimePicker)
- **Hauteur** : **380px** (fixe)
- **Structure** : `display: flex`, `flexDirection: column`

### Sections
1. **Top bar** : ~50px (fixe)
2. **Contenu** : flex-1 (scrollable si nécessaire)
3. **Footer** : ~50px (fixe)

## 🎨 Design identique au TimePicker

### 1. Top Bar violet AURA

```tsx
<div className="px-4 py-3 flex items-center justify-between" 
     style={{ backgroundColor: 'var(--color-primary)' }}>
  <span className="text-white text-sm font-medium">
    Sélectionner une date
  </span>
  <div 
    className="flex items-center gap-1 text-white text-xl font-bold" 
    style={{ fontFamily: 'Manrope, Inter, sans-serif', letterSpacing: '0.05em' }}
  >
    {formatDisplayDate()}
  </div>
</div>
```

**Caractéristiques** :
- ✅ Fond `var(--color-primary)` (adaptatif light/dark)
- ✅ Titre à gauche : "Sélectionner une date"
- ✅ **Date affichée** à droite : format `DD / MM / YYYY`
- ✅ Police **Manrope** 20px Bold (identique au HH:MM du TimePicker)
- ✅ Letter-spacing 0.05em

**Affichage de la date** :
```tsx
const formatDisplayDate = () => {
  if (!value) return '── / ── / ────'
  return dayjs(value).format('DD / MM / YYYY')
}
```
- Date sélectionnée : `14 / 03 / 2025`
- Aucune date : `── / ── / ────` (placeholder visuel)

### 2. Contenu scrollable

```tsx
<div className="flex-1 overflow-y-auto p-3">
  {/* Calendrier, mois, années */}
</div>
```

**Caractéristiques** :
- ✅ `flex-1` : Prend tout l'espace disponible
- ✅ `overflow-y-auto` : Scroll vertical si nécessaire
- ✅ Padding 12px (p-3)
- ✅ Contenu adaptable (jours, mois, années)

### 3. Footer violet AURA

```tsx
<div className="px-4 py-3 flex items-center justify-between gap-2" 
     style={{ backgroundColor: 'var(--color-primary)' }}>
  <button className="text-white text-sm font-medium hover:bg-white/10 px-3 py-1 rounded">
    Annuler
  </button>
  <button className="text-white text-sm font-medium hover:bg-white/10 px-3 py-1 rounded">
    Effacer
  </button>
  <button className="bg-white text-sm font-semibold px-4 py-1.5 rounded" 
          style={{ color: 'var(--color-primary)' }}>
    OK
  </button>
</div>
```

**Caractéristiques** :
- ✅ Fond `var(--color-primary)` (identique au top bar)
- ✅ **3 boutons** : Annuler, Effacer, OK
- ✅ Bouton OK en **blanc** avec texte violet (contraste)
- ✅ Hover : fond blanc semi-transparent

**Actions** :
- **Annuler** : `onChange(null)` + `onClose()` (ferme sans valider)
- **Effacer** : `onChange(null)` (réinitialise la sélection)
- **OK** : `onClose()` (valide et ferme)

## 📊 Comparaison Avant/Après

| Aspect | Avant | Après |
|--------|-------|-------|
| **Largeur** | 320px | **330px** ✅ |
| **Hauteur** | Dynamique | **380px fixe** ✅ |
| **Top bar** | Aucun | **Violet AURA** ✅ |
| **Date affichée** | Non | **DD / MM / YYYY** ✅ |
| **Police date** | - | **Manrope Bold** ✅ |
| **Footer** | Boutons internes | **Footer violet** ✅ |
| **Boutons** | Auj., -7j, +7j | **Annuler, Effacer, OK** ✅ |
| **Structure** | Simple div | **Flex column** ✅ |
| **Scroll** | Non | **Contenu scrollable** ✅ |

## 🎨 Cohérence TimePicker/DatePicker

### Identique
- ✅ **Largeur** : 330px
- ✅ **Top bar violet** avec titre + affichage (HH:MM ou DD/MM/YYYY)
- ✅ **Footer violet** avec 3 boutons (Annuler, Effacer, OK)
- ✅ **Police Manrope** 20px Bold pour l'affichage
- ✅ **Couleurs AURA** (var(--color-primary))
- ✅ **Bouton OK blanc** avec texte violet
- ✅ **Hover identique** (bg-white/10)

### Différences (logiques)
- ⚪ **Hauteur** : TimePicker ~400px, DatePicker 380px (calendrier plus compact)
- ⚪ **Contenu** : Cercle heures vs Grille dates
- ⚪ **Affichage** : HH:MM vs DD/MM/YYYY

## 🧪 Tests de validation

### Test 1 : Dimensions
1. Ouvrir le DatePicker
2. **Vérifier** : Largeur **330px** (identique au TimePicker)
3. **Vérifier** : Hauteur **380px** (fixe)

### Test 2 : Top bar
1. Observer le top bar
2. **Vérifier** : Fond **violet AURA** (var(--color-primary))
3. **Vérifier** : Titre "Sélectionner une date" à gauche
4. **Vérifier** : Date **DD / MM / YYYY** à droite
5. **Vérifier** : Police **Manrope Bold 20px**

### Test 3 : Affichage date
1. Aucune date sélectionnée
2. **Vérifier** : Affichage `── / ── / ────`
3. Sélectionner le 14 mars 2025
4. **Vérifier** : Affichage `14 / 03 / 2025`

### Test 4 : Footer
1. Observer le footer
2. **Vérifier** : Fond **violet AURA** (identique au top bar)
3. **Vérifier** : 3 boutons : Annuler, Effacer, OK
4. **Vérifier** : Bouton OK en **blanc** avec texte violet
5. Hover sur Annuler/Effacer
6. **Vérifier** : Fond blanc semi-transparent

### Test 5 : Actions boutons
1. Sélectionner une date
2. Cliquer **"Effacer"**
3. **Vérifier** : Date réinitialisée à `── / ── / ────`
4. **Vérifier** : Picker reste ouvert
5. Sélectionner une date
6. Cliquer **"Annuler"**
7. **Vérifier** : Picker se ferme
8. Sélectionner une date
9. Cliquer **"OK"**
10. **Vérifier** : Picker se ferme et date validée

### Test 6 : Cohérence visuelle
1. Ouvrir TimePicker et DatePicker côte à côte
2. **Vérifier** : **Même largeur** (330px)
3. **Vérifier** : **Même couleur** top bar et footer
4. **Vérifier** : **Même police** (Manrope) pour affichage
5. **Vérifier** : **Même structure** (top bar + contenu + footer)
6. **Vérifier** : **Même style** boutons

### Test 7 : Scroll contenu
1. Ouvrir le DatePicker
2. Si contenu dépasse 280px (380 - 50 top - 50 footer)
3. **Vérifier** : Scroll vertical visible
4. **Vérifier** : Top bar et footer **fixes** (ne scrollent pas)

## ✅ Résultat final

Le DatePicker est maintenant **parfaitement cohérent** avec le TimePicker :
- 🎨 **Même structure visuelle** (top bar + contenu + footer)
- 📏 **Même largeur** (330px)
- 🟣 **Même couleur AURA** (violet adaptatif)
- ✍️ **Même police** (Manrope Bold) pour affichage
- 🎯 **Même UX** (3 boutons, OK blanc, hover identique)
- ♿ **Même accessibilité** (Escape, clic extérieur, scroll)

Les deux pickers forment maintenant un **duo cohérent** dans le design system AURA ! 🎉


