# 🎨 Design System AURA - Guide Complet de Standardisation

## 📋 Table des matières
1. [Icônes standards](#-icônes-standards)
2. [Actions standards](#-actions-standards)
3. [Boutons](#-boutons)
4. [Layout des pages](#-layout-des-pages)
5. [Composants réutilisables](#-composants-réutilisables)
6. [Règles à respecter](#-règles-à-respecter)

---

## 🎯 Icônes standards

### Actions principales

| Action | Icône | Taille | Couleur | Contexte |
|--------|-------|--------|---------|----------|
| **Ajouter / Créer** | `Plus` | 16px | Blanc (dans bouton violet) | Header, bouton principal |
| **Modifier / Éditer** | `Edit2` | 16px | Bleu (#3B82F6) | Actions inline, boutons secondaires |
| **Supprimer** | `Trash2` | 16px | Rouge (#EF4444) | Actions inline, boutons de suppression |
| **Fermer** | `X` | 16px | Gris | Modals uniquement |
| **Rechercher** | `Search` | 20px | Gris (#9CA3AF) | Champs de recherche |
| **Retour** | `ArrowLeft` | 16px | Gris | Navigation |
| **Valider** | `Check` | 16px | Vert (#22C55E) | Confirmations |
| **Annuler** | `X` | 16px | Gris | Annulations, rejets |

### Navigation et vues

| Action | Icône | Taille | Contexte |
|--------|-------|--------|----------|
| **Vue liste** | `List` | 20px | Toggle de vue |
| **Vue grille** | `Grid3x3` | 20px | Toggle de vue |
| **Filtrer** | `Filter` | 16px | Boutons de filtre |
| **Exporter** | `Download` | 16px | Boutons d'export |

### Entités

| Entité | Icône | Taille |
|--------|-------|--------|
| Artistes | `Music` | 20px |
| Contacts | `Users` | 20px |
| Entreprises | `Building2` | 20px |
| Staff | `Users` | 20px |
| Événements | `Calendar` | 20px |

---

## ⚡ Actions standards

### 1. Bouton d'ajout principal (Header)

```tsx
import { Plus } from 'lucide-react';
import { Button } from '@/components/aura/Button';

<Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
  Ajouter [entité]
</Button>
```

**✅ Caractéristiques**:
- Toujours dans le header
- Toujours avec `leftIcon`
- Texte explicite: "Ajouter [entité]"
- Hauteur: 44px
- Couleur: Violet AURA (par défaut)

### 2. Actions inline (Modifier / Supprimer)

```tsx
import { Edit2, Trash2 } from 'lucide-react';
import { Button } from '@/components/aura/Button';

{/* Dans une table ou liste */}
<div className="flex gap-2">
  <Button 
    variant="ghost" 
    size="sm"
    onClick={() => handleEdit(item)}
    className="text-blue-500 hover:text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-900/20"
  >
    <Edit2 className="w-4 h-4" />
  </Button>
  <Button 
    variant="ghost" 
    size="sm"
    onClick={() => handleDelete(item)}
    className="text-red-500 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20"
  >
    <Trash2 className="w-4 h-4" />
  </Button>
</div>
```

**✅ Caractéristiques**:
- `Edit2` toujours en bleu
- `Trash2` toujours en rouge
- Taille icône: 16px (4 × 4 en Tailwind)
- `variant="ghost"` pour transparence
- `size="sm"` pour compacité

### 3. Actions sur cartes (hover)

```tsx
{/* Actions en hover sur une carte */}
<div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
  <button
    onClick={() => handleEdit(item)}
    className="p-1.5 bg-blue-500 hover:bg-blue-600 text-white rounded transition-colors"
    title="Modifier"
  >
    <Edit2 className="w-3.5 h-3.5" />
  </button>
  <button
    onClick={() => handleDelete(item)}
    className="p-1.5 bg-red-500 hover:bg-red-600 text-white rounded transition-colors"
    title="Supprimer"
  >
    <Trash2 className="w-3.5 h-3.5" />
  </button>
</div>
```

**✅ Caractéristiques**:
- Apparaissent au hover (`opacity-0 group-hover:opacity-100`)
- Position absolue (top-2 right-2)
- Fond coloré (bleu/rouge)
- Taille icône: 14px (3.5 × 3.5)

---

## 🔘 Boutons

### Variantes

| Variante | Usage | Code |
|----------|-------|------|
| **Primary** (défaut) | Actions principales (Ajouter, Enregistrer, Confirmer) | `<Button>` ou `<Button variant="primary">` |
| **Secondary** | Actions secondaires (Annuler, Filtrer) | `<Button variant="secondary">` |
| **Ghost** | Actions inline discrètes (Edit, Delete) | `<Button variant="ghost">` |
| **Danger** | Actions destructives (Supprimer en modal) | `<Button variant="danger">` |

### Tailles

| Taille | Hauteur | Usage |
|--------|---------|-------|
| **Normal** (défaut) | 44px | Boutons principaux |
| **Small** | 36px | Actions compactes |

### Structure standard

```tsx
<Button 
  variant="primary"           // Optionnel (primary par défaut)
  size="sm"                   // Optionnel (normal par défaut)
  leftIcon={<Plus size={16} />}  // Icône à gauche
  onClick={handleAction}
>
  Texte du bouton
</Button>
```

---

## 📐 Layout des pages

### Structure standard d'une page

```tsx
export default function MaPage() {
  return (
    <div className="p-6 space-y-6">
      {/* 📌 1. HEADER STANDARD */}
      <header className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-2">
          <IconeEntite className="w-5 h-5 text-violet-400" />
          <h1 className="text-xl font-semibold text-gray-900 dark:text-white">
            TITRE PAGE
          </h1>
        </div>
        <Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
          Ajouter [entité]
        </Button>
      </header>

      {/* 📌 2. BREADCRUMB (optionnel) */}
      <p className="text-sm text-gray-400 mb-6">
        Section / Sous-section
      </p>

      {/* 📌 3. BARRE DE RECHERCHE ET FILTRES */}
      <div className="mb-6 flex gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <Input
            type="text"
            placeholder="Rechercher..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10"
          />
        </div>
        {/* Actions secondaires */}
        <Button variant="secondary" leftIcon={<Filter size={16} />}>
          Filtrer
        </Button>
      </div>

      {/* 📌 4. CONTENU PRINCIPAL */}
      {/* Table, grille, ou liste */}
    </div>
  );
}
```

### Header - Variantes

#### Avec événement actif
```tsx
<header className="flex items-center justify-between mb-6">
  <div>
    <div className="flex items-center gap-2">
      <Music className="w-5 h-5 text-violet-400" />
      <h1 className="text-xl font-semibold text-gray-900 dark:text-white">
        ARTISTES
      </h1>
    </div>
    {currentEvent && (
      <p className="text-sm text-gray-400 mt-1">
        <span className="font-medium" style={{ color: currentEvent.color_hex }}>
          {currentEvent.name}
        </span>
        {" • "} 142 artistes
      </p>
    )}
  </div>
  <div className="flex items-center gap-2">
    <Button variant="secondary" leftIcon={<Download size={16} />}>
      Exporter
    </Button>
    <Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
      Ajouter artiste
    </Button>
  </div>
</header>
```

#### Avec retour
```tsx
<header className="flex items-center justify-between">
  <div className="flex items-center gap-3">
    <button
      onClick={() => navigate(-1)}
      className="btn btn-secondary w-10 h-10 p-0 flex items-center justify-center"
    >
      <ArrowLeft size={16} />
    </button>
    <div className="flex items-center gap-2">
      <User className="w-5 h-5 text-violet-400" />
      <h1 className="text-xl font-semibold text-gray-900 dark:text-white">
        {artist.name}
      </h1>
    </div>
  </div>
  <Button leftIcon={<Edit2 size={16} />}>
    Modifier
  </Button>
</header>
```

---

## 🧩 Composants réutilisables

### ActionButtons (à créer)

Composant pour standardiser les actions Edit/Delete :

```tsx
import { Edit2, Trash2 } from 'lucide-react';
import { Button } from '@/components/aura/Button';

interface ActionButtonsProps {
  onEdit?: () => void;
  onDelete?: () => void;
  variant?: 'inline' | 'hover';
  size?: 'sm' | 'xs';
}

export function ActionButtons({ 
  onEdit, 
  onDelete, 
  variant = 'inline',
  size = 'sm' 
}: ActionButtonsProps) {
  const iconSize = size === 'xs' ? 'w-3.5 h-3.5' : 'w-4 h-4';
  
  if (variant === 'hover') {
    return (
      <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
        {onEdit && (
          <button
            onClick={onEdit}
            className="p-1.5 bg-blue-500 hover:bg-blue-600 text-white rounded transition-colors"
            title="Modifier"
          >
            <Edit2 className={iconSize} />
          </button>
        )}
        {onDelete && (
          <button
            onClick={onDelete}
            className="p-1.5 bg-red-500 hover:bg-red-600 text-white rounded transition-colors"
            title="Supprimer"
          >
            <Trash2 className={iconSize} />
          </button>
        )}
      </div>
    );
  }

  return (
    <div className="flex gap-2">
      {onEdit && (
        <Button 
          variant="ghost" 
          size="sm"
          onClick={onEdit}
          className="text-blue-500 hover:text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-900/20"
        >
          <Edit2 className={iconSize} />
        </Button>
      )}
      {onDelete && (
        <Button 
          variant="ghost" 
          size="sm"
          onClick={onDelete}
          className="text-red-500 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20"
        >
          <Trash2 className={iconSize} />
        </Button>
      )}
    </div>
  );
}
```

**Usage** :
```tsx
{/* Dans une table */}
<ActionButtons 
  onEdit={() => handleEdit(item)} 
  onDelete={() => handleDelete(item)} 
/>

{/* Sur une carte avec hover */}
<ActionButtons 
  variant="hover"
  size="xs"
  onEdit={() => handleEdit(item)} 
  onDelete={() => handleDelete(item)} 
/>
```

### ViewModeToggle (à créer)

```tsx
import { List, Grid3x3 } from 'lucide-react';

interface ViewModeToggleProps {
  mode: 'list' | 'grid';
  onChange: (mode: 'list' | 'grid') => void;
}

export function ViewModeToggle({ mode, onChange }: ViewModeToggleProps) {
  return (
    <div className="flex gap-2 bg-white dark:bg-gray-800 rounded-lg p-1 shadow">
      <button
        onClick={() => onChange('list')}
        className={`p-2 rounded transition-colors ${
          mode === 'list'
            ? 'bg-violet-500 text-white'
            : 'text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200'
        }`}
        title="Vue liste"
      >
        <List className="w-5 h-5" />
      </button>
      <button
        onClick={() => onChange('grid')}
        className={`p-2 rounded transition-colors ${
          mode === 'grid'
            ? 'bg-violet-500 text-white'
            : 'text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200'
        }`}
        title="Vue grille"
      >
        <Grid3x3 className="w-5 h-5" />
      </button>
    </div>
  );
}
```

---

## ✅ Règles à respecter

### ✅ À FAIRE

1. **Toujours utiliser les icônes standards**
   - `Edit2` pour modifier (jamais `Edit`)
   - `Trash2` pour supprimer (jamais `Trash` ou `X`)
   - `Plus` pour ajouter (jamais `PlusCircle`)

2. **Toujours utiliser `leftIcon` pour les icônes dans les boutons**
   ```tsx
   {/* ✅ Correct */}
   <Button leftIcon={<Plus size={16} />}>Ajouter</Button>
   
   {/* ❌ Incorrect */}
   <Button><Plus className="w-4 h-4 mr-2" />Ajouter</Button>
   ```

3. **Respecter les couleurs des actions**
   - Bleu (#3B82F6) pour modifier
   - Rouge (#EF4444) pour supprimer
   - Vert (#22C55E) pour valider
   - Gris pour annuler

4. **Structure de page standard**
   - Header avec titre et bouton principal
   - Breadcrumb (optionnel)
   - Barre de recherche et filtres
   - Contenu principal

5. **Toujours utiliser `ConfirmDialog` pour les suppressions**
   ```tsx
   <ConfirmDialog
     open={deleteConfirm.open}
     onClose={() => setDeleteConfirm({ open: false, item: null })}
     onConfirm={handleDeleteConfirm}
     title="Supprimer [entité]"
     message="Êtes-vous sûr ?"
     variant="danger"
   />
   ```

### ❌ À ÉVITER

1. **Ne JAMAIS mélanger les icônes**
   - Pas de `Edit` ET `Edit2` dans la même page
   - Pas de `Trash` ET `Trash2`
   - Pas de `Plus` ET `PlusCircle`

2. **Ne JAMAIS utiliser `X` pour supprimer**
   - `X` est réservé pour FERMER les modals
   - Utiliser `Trash2` pour supprimer

3. **Ne JAMAIS utiliser `window.confirm()` pour les confirmations**
   - Toujours utiliser `ConfirmDialog`

4. **Ne JAMAIS créer des boutons avec `<button>` directement**
   - Toujours utiliser le composant `<Button>`

5. **Ne JAMAIS oublier les `title` sur les boutons icône seule**
   ```tsx
   <button title="Modifier"> {/* ✅ Bon pour l'accessibilité */}
     <Edit2 />
   </button>
   ```

---

## 📝 Checklist pour nouvelle page

Avant de créer une nouvelle page, vérifier :

- [ ] Header avec icône d'entité (20px, violet-400)
- [ ] Titre en MAJUSCULES
- [ ] Bouton principal avec `leftIcon={<Plus size={16} />}`
- [ ] Breadcrumb si nécessaire
- [ ] Barre de recherche avec icône `Search` (20px)
- [ ] Actions Edit avec `Edit2` en bleu
- [ ] Actions Delete avec `Trash2` en rouge
- [ ] `ConfirmDialog` pour les suppressions
- [ ] Hover uniforme sur les lignes (`var(--color-hover-row)`)
- [ ] Transitions fluides (0.15s ease)

---

## 🔄 Migration des pages existantes

Pour mettre à jour une page existante :

1. **Vérifier les icônes**
   ```bash
   # Rechercher les icônes non standard
   grep -r "import.*Edit[^2]" src/pages/
   grep -r "import.*Trash[^2]" src/pages/
   grep -r "PlusCircle" src/pages/
   ```

2. **Remplacer les icônes**
   - `Edit` → `Edit2`
   - `Trash` → `Trash2`
   - `PlusCircle` → `Plus`

3. **Standardiser les boutons**
   - Utiliser `leftIcon` au lieu de children
   - Supprimer `variant="primary"` (c'est le défaut)
   - Vérifier la taille des icônes (16px)

4. **Vérifier les couleurs des actions**
   - Bleu pour Edit
   - Rouge pour Delete

5. **Tester les hovers**
   - Vérifier que `var(--color-hover-row)` est utilisé

---

## 📚 Ressources

- [Boutons standards](./BUTTON_STANDARDS.md)
- [Composant Button](./src/components/aura/Button.tsx)
- [Template de page](./templates/NewPageTemplate.tsx)
- [Tokens de couleurs](./src/styles/tokens.css)

---

**Version** : 1.0.0  
**Dernière mise à jour** : Novembre 2024










