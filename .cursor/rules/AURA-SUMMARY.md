# 🎨 AURA - Résumé pour User Rules

## ⚡ Les 5 Règles d'Or (TOUJOURS respecter)

1. **Icônes** : UNIQUEMENT Lucide React (`lucide-react`) - JAMAIS d'emojis
2. **Composants** : Utiliser les composants Aura existants (`@/components/aura/`)
3. **Dark Mode** : TOUJOURS ajouter les classes `dark:` en parallèle
4. **Couleur Primary** : Violet (`violet-500`, `violet-600`)
5. **Imports** : ES6 uniquement - JAMAIS `require()`

---

## 🎨 Standards Visuels

### Couleurs de texte
```tsx
// Labels (plus lisibles)
text-gray-900 dark:text-gray-100

// Texte secondaire
text-gray-500 dark:text-gray-400

// Focus
focus:ring-2 focus:ring-violet-500
```

### Composants Aura à utiliser
- `Button` - variants: primary, secondary, ghost, danger
- `Input` - pour tous les champs texte
- `PhoneInput` - pour TOUS les téléphones
- `Modal` - widthClass: max-w-2xl, max-w-4xl, max-w-6xl
- `ConfirmDialog` - pour TOUTES les suppressions
- `Accordion` - pour formulaires complexes

### Structure Table Standard
```tsx
<div className="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden border border-gray-200 dark:border-gray-700">
  <table className="w-full">
    <thead className="bg-gray-50 dark:bg-gray-900">
      <tr>
        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
          Colonne
        </th>
      </tr>
    </thead>
    <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
      <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
        <td className="px-4 py-3">...</td>
      </tr>
    </tbody>
  </table>
</div>
```

### Colonnes Triables
```tsx
<th 
  className="cursor-pointer hover:text-violet-400 transition-colors select-none"
  onClick={() => handleSort('column')}
>
  <div className="flex items-center gap-2">
    Nom
    <span className={sortColumn === 'column' ? 'text-violet-400' : 'text-gray-400'}>
      {sortDirection === 'asc' ? '▲' : '▼'}
    </span>
  </div>
</th>
```

---

## 🏢 CRM Spécifique

### Entreprises - Modal avec Accordéons
1. **📋 Informations générales** (ouvert par défaut)
2. **💳 Facturation & Finance** (IBAN, SWIFT, etc.)
3. **👥 Contacts associés**

### Contacts - Modal Simple
- 3 colonnes : Prénom, Nom, Email
- 2 colonnes : Fonction, Téléphone
- Zones scrollables : `max-h-24 overflow-y-auto` pour artistes/entreprises

### Sélecteurs Multi-select
- `ArtistSelector`, `CompanySelector`, `ContactSelector`, `RoleSelector`
- Zone tags scrollable : `max-h-24 overflow-y-auto p-2 bg-gray-50 rounded-lg border`

### Badges
- **Violet** : Fonctions/Rôles
- **Bleu** : Entreprise principale, Fournisseur
- **Gris** : Entreprises liées
- **Vert** : Client
- **Rouge** : Erreur, suppression

### Téléphones
- Toujours `PhoneInput` component
- Toujours `formatPhoneNumber()` pour affichage
- `getWhatsAppLink()` pour liens WhatsApp

---

## 📐 Layout Standards

### Page Type
```tsx
<div className="p-6">
  <header className="flex items-center justify-between mb-6">
    <div className="flex items-center gap-2">
      <Icon className="w-5 h-5 text-violet-400" />
      <h1 className="text-xl font-semibold text-gray-900 dark:text-white">TITRE</h1>
    </div>
    <Button variant="primary" onClick={handleAdd}>
      <Plus className="w-4 h-4 mr-1" />
      Ajouter
    </Button>
  </header>
  
  <p className="text-sm text-gray-400 mb-6">Breadcrumb</p>
  
  {/* Filtres sur une ligne */}
  <div className="mb-6 flex gap-4">
    <div className="relative flex-1">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
      <Input placeholder="Rechercher..." className="pl-10" />
    </div>
    <select className="min-w-[200px] px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg">
      <option>Filtre</option>
    </select>
  </div>
  
  {/* Contenu */}
</div>
```

### Grids
- 2 cols : `grid grid-cols-2 gap-4`
- 3 cols : `grid grid-cols-3 gap-4`
- 4 cols : `grid grid-cols-4 gap-3`

### Dropdowns
```tsx
<select className="px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-violet-500">
  <option value="">Sélectionner...</option>
</select>
```

---

## ✅ Checklist Avant de Coder

1. [ ] Un composant Aura existe-t-il déjà ? → Utiliser l'existant
2. [ ] Icônes Lucide uniquement ? → JAMAIS d'emojis
3. [ ] Dark mode prévu ? → Classes `dark:` partout
4. [ ] Couleurs AURA ? → Violet primary
5. [ ] Textes lisibles ? → `gray-900/gray-100` pour labels
6. [ ] Pattern cohérent ? → Vérifier dans le codebase

---

## 🚫 JAMAIS

- ❌ Emojis (sauf demande explicite)
- ❌ `require()` - Utiliser `import`
- ❌ `any` TypeScript
- ❌ Oublier le dark mode
- ❌ Créer nouveau composant sans vérifier l'existant
- ❌ Icônes autres que Lucide React
- ❌ Classes `text-gray-700 dark:text-gray-300` → Utiliser `text-gray-900 dark:text-gray-100`

---

## 🎯 Quick Reference

**Imports courants**
```tsx
import { Button } from '@/components/aura/Button'
import { Input } from '@/components/aura/Input'
import { PhoneInput } from '@/components/aura/PhoneInput'
import { Modal } from '@/components/aura/Modal'
import { ConfirmDialog } from '@/components/aura/ConfirmDialog'
import { Accordion } from '@/components/ui/Accordion'
import { Building2, Plus, Search, Edit2, Trash2 } from 'lucide-react'
import { formatPhoneNumber, getWhatsAppLink } from '@/utils/phoneUtils'
```

**Classes fréquentes**
```tsx
// Conteneur principal
"p-6"

// Espacements
"space-y-4"  // vertical
"gap-4"      // flex/grid

// Bordures standard
"border border-gray-300 dark:border-gray-600"

// Fond standard
"bg-white dark:bg-gray-800"

// Hover standard
"hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors"
```

