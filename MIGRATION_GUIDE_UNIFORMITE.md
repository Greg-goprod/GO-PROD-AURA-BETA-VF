# 📘 Guide de Migration vers le Design System Unifié

## 🎯 Objectif

Standardiser toutes les pages de l'application pour garantir une expérience utilisateur cohérente et faciliter la maintenance.

---

## 🔍 Audit rapide d'une page

### Checklist de vérification

```bash
# 1. Vérifier les icônes non standard
grep -n "import.*Edit[^2]" votre-page.tsx
grep -n "import.*Trash[^2]" votre-page.tsx  
grep -n "PlusCircle" votre-page.tsx

# 2. Vérifier l'utilisation de window.confirm
grep -n "window.confirm\|confirm(" votre-page.tsx

# 3. Vérifier les boutons avec icônes dans children
grep -n "<Plus.*className" votre-page.tsx
```

---

## 🔧 Corrections courantes

### 1. Remplacer les icônes non standard

#### ❌ Avant
```tsx
import { Edit, Trash, PlusCircle } from 'lucide-react';
```

#### ✅ Après
```tsx
import { Edit2, Trash2, Plus } from 'lucide-react';
```

---

### 2. Standardiser le bouton d'ajout

#### ❌ Avant
```tsx
<Button variant="primary" onClick={handleAdd}>
  <Plus className="w-4 h-4 mr-2" />
  Ajouter un contact
</Button>
```

#### ✅ Après
```tsx
<Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
  Ajouter un contact
</Button>
```

---

### 3. Utiliser ActionButtons pour Edit/Delete

#### ❌ Avant
```tsx
<div className="flex gap-2">
  <Button 
    variant="secondary" 
    size="sm"
    onClick={() => handleEdit(contact)}
  >
    <Edit2 className="w-4 h-4" />
  </Button>
  <Button 
    variant="secondary" 
    size="sm"
    onClick={() => handleDelete(contact)}
  >
    <Trash2 className="w-4 h-4" />
  </Button>
</div>
```

#### ✅ Après
```tsx
import { ActionButtons } from '@/components/aura/ActionButtons';

<ActionButtons 
  onEdit={() => handleEdit(contact)} 
  onDelete={() => handleDeleteClick(contact)} 
/>
```

**Avantages** :
- ✅ Couleurs standardisées (bleu/rouge)
- ✅ Hovers cohérents
- ✅ Tailles d'icônes correctes
- ✅ Moins de code

---

### 4. Utiliser ViewModeToggle

#### ❌ Avant
```tsx
<div className="flex gap-2 bg-white dark:bg-gray-800 rounded-lg p-1 shadow">
  <button
    onClick={() => setViewMode('list')}
    className={`p-2 rounded transition-colors ${
      viewMode === 'list'
        ? 'bg-violet-500 text-white'
        : 'text-gray-500 hover:text-gray-700 dark:text-gray-400'
    }`}
  >
    <List className="w-5 h-5" />
  </button>
  <button
    onClick={() => setViewMode('grid')}
    className={`p-2 rounded transition-colors ${
      viewMode === 'grid'
        ? 'bg-violet-500 text-white'
        : 'text-gray-500 hover:text-gray-700 dark:text-gray-400'
    }`}
  >
    <Grid3x3 className="w-5 h-5" />
  </button>
</div>
```

#### ✅ Après
```tsx
import { ViewModeToggle } from '@/components/aura/ViewModeToggle';

<ViewModeToggle mode={viewMode} onChange={setViewMode} />
```

---

### 5. Standardiser le hover des lignes de table

#### ❌ Avant
```tsx
<tr className="hover:bg-gray-50 dark:hover:bg-gray-750">
```

#### ✅ Après (Option 1 - Avec helper)
```tsx
import { getTableRowHoverProps } from '@/lib/designSystem';

<tr {...getTableRowHoverProps()} key={item.id}>
```

#### ✅ Après (Option 2 - Manuel)
```tsx
<tr 
  style={{ transition: 'background 0.15s ease' }}
  onMouseEnter={(e) => e.currentTarget.style.background = 'var(--color-hover-row)'}
  onMouseLeave={(e) => e.currentTarget.style.background = ''}
>
```

---

### 6. Remplacer window.confirm par ConfirmDialog

#### ❌ Avant
```tsx
const handleDelete = async (id: string) => {
  if (!confirm('Êtes-vous sûr ?')) return;
  
  await deleteItem(id);
  success('Supprimé');
};
```

#### ✅ Après
```tsx
import { ConfirmDialog } from '@/components/aura/ConfirmDialog';

const [deleteConfirm, setDeleteConfirm] = useState<{ 
  open: boolean; 
  item: MyType | null 
}>({ open: false, item: null });

const handleDeleteClick = (item: MyType) => {
  setDeleteConfirm({ open: true, item });
};

const handleDeleteConfirm = async () => {
  if (!deleteConfirm.item) return;
  
  await deleteItem(deleteConfirm.item.id);
  success('Supprimé');
  setDeleteConfirm({ open: false, item: null });
};

// Dans le JSX
<ConfirmDialog
  open={deleteConfirm.open}
  onClose={() => setDeleteConfirm({ open: false, item: null })}
  onConfirm={handleDeleteConfirm}
  title="Supprimer l'élément"
  message={`Êtes-vous sûr de vouloir supprimer "${deleteConfirm.item?.name}" ?`}
  variant="danger"
/>
```

---

### 7. Actions sur cartes avec hover

#### ❌ Avant
```tsx
<div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 flex gap-1">
  <button onClick={() => handleEdit(contact)} className="p-1.5 bg-blue-500 text-white rounded">
    <Edit2 className="w-3.5 h-3.5" />
  </button>
  <button onClick={() => handleDelete(contact)} className="p-1.5 bg-red-500 text-white rounded">
    <Trash2 className="w-3.5 h-3.5" />
  </button>
</div>
```

#### ✅ Après
```tsx
<ActionButtons 
  variant="hover"
  size="xs"
  onEdit={() => handleEdit(contact)} 
  onDelete={() => handleDeleteClick(contact)} 
/>
```

**Note** : N'oubliez pas d'ajouter `group` sur l'élément parent :
```tsx
<div className="... relative group">
  <ActionButtons variant="hover" ... />
</div>
```

---

## 📝 Exemple complet de migration

### Page avant migration

```tsx
import { useState } from 'react';
import { Users, Plus, Edit, Trash, Search } from 'lucide-react';
import { Button } from '@/components/aura/Button';
import { Input } from '@/components/aura/Input';

export default function ContactsPage() {
  const [contacts, setContacts] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');

  const handleEdit = (contact) => {
    // ...
  };

  const handleDelete = (contact) => {
    if (!confirm('Supprimer ?')) return;
    // ...
  };

  return (
    <div className="p-6">
      <header className="flex items-center justify-between mb-6">
        <h1>CONTACTS</h1>
        <Button variant="primary" onClick={handleAdd}>
          <Plus className="w-4 h-4 mr-2" />
          Ajouter
        </Button>
      </header>

      <div className="relative mb-6">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5" />
        <Input 
          placeholder="Rechercher..." 
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="pl-10"
        />
      </div>

      <table>
        <tbody>
          {contacts.map(contact => (
            <tr key={contact.id} className="hover:bg-gray-50 dark:hover:bg-gray-750">
              <td>{contact.name}</td>
              <td>
                <div className="flex gap-2">
                  <Button size="sm" onClick={() => handleEdit(contact)}>
                    <Edit className="w-4 h-4" />
                  </Button>
                  <Button size="sm" onClick={() => handleDelete(contact)}>
                    <Trash className="w-4 h-4" />
                  </Button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

### Page après migration

```tsx
import { useState } from 'react';
import { Users, Plus, Search } from 'lucide-react';
import { Button } from '@/components/aura/Button';
import { Input } from '@/components/aura/Input';
import { ActionButtons } from '@/components/aura/ActionButtons';
import { ConfirmDialog } from '@/components/aura/ConfirmDialog';
import { getTableRowHoverProps } from '@/lib/designSystem';

export default function ContactsPage() {
  const [contacts, setContacts] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [deleteConfirm, setDeleteConfirm] = useState({ 
    open: false, 
    contact: null 
  });

  const handleEdit = (contact) => {
    // ...
  };

  const handleDeleteClick = (contact) => {
    setDeleteConfirm({ open: true, contact });
  };

  const handleDeleteConfirm = async () => {
    if (!deleteConfirm.contact) return;
    // ... suppression
    setDeleteConfirm({ open: false, contact: null });
  };

  return (
    <div className="p-6">
      {/* Header standard */}
      <header className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-2">
          <Users className="w-5 h-5 text-violet-400" />
          <h1 className="text-xl font-semibold text-gray-900 dark:text-white">
            CONTACTS
          </h1>
        </div>
        <Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
          Ajouter un contact
        </Button>
      </header>

      {/* Barre de recherche */}
      <div className="relative mb-6">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
        <Input 
          placeholder="Rechercher..." 
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="pl-10"
        />
      </div>

      {/* Table */}
      <table>
        <tbody>
          {contacts.map(contact => (
            <tr {...getTableRowHoverProps()} key={contact.id}>
              <td>{contact.name}</td>
              <td>
                <ActionButtons 
                  onEdit={() => handleEdit(contact)} 
                  onDelete={() => handleDeleteClick(contact)} 
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* Dialogue de confirmation */}
      <ConfirmDialog
        open={deleteConfirm.open}
        onClose={() => setDeleteConfirm({ open: false, contact: null })}
        onConfirm={handleDeleteConfirm}
        title="Supprimer le contact"
        message={`Êtes-vous sûr de vouloir supprimer "${deleteConfirm.contact?.name}" ?`}
        variant="danger"
      />
    </div>
  );
}
```

---

## 📊 Avantages de la migration

### Avant

❌ **Problèmes** :
- Icônes incohérentes (`Edit` vs `Edit2`, `Trash` vs `Trash2`)
- Couleurs variables pour les actions
- Hovers différents selon les pages
- Code répétitif pour Edit/Delete
- `window.confirm()` peu esthétique
- Tailles d'icônes variables

### Après

✅ **Avantages** :
- Icônes uniformes sur toute l'app
- Couleurs standardisées (bleu pour Edit, rouge pour Delete)
- Hover uniforme avec `var(--color-hover-row)`
- Moins de code grâce aux composants réutilisables
- `ConfirmDialog` moderne et cohérent
- Tailles d'icônes standards
- Maintenance facilitée
- Accessibilité améliorée

---

## 🔄 Ordre de migration recommandé

1. **Migrations simples** (10-15 min par page)
   - Remplacer les icônes (`Edit` → `Edit2`, etc.)
   - Standardiser les boutons d'ajout
   - Fixer les hovers de lignes

2. **Migrations moyennes** (20-30 min par page)
   - Utiliser `ActionButtons`
   - Ajouter `ConfirmDialog` pour les suppressions
   - Standardiser les headers

3. **Pages prioritaires**
   1. Pages de contact (Personnes, Entreprises) ✅ **FAIT**
   2. Pages d'artistes
   3. Pages de staff
   4. Pages de settings
   5. Autres pages

---

## ✅ Validation post-migration

### Checklist visuelle

- [ ] Header avec icône violette (20px)
- [ ] Titre en MAJUSCULES
- [ ] Bouton d'ajout avec icône `Plus` (16px)
- [ ] Actions Edit en bleu
- [ ] Actions Delete en rouge
- [ ] Hover uniforme sur les lignes
- [ ] `ConfirmDialog` pour les suppressions
- [ ] Transitions fluides

### Tests fonctionnels

- [ ] Le bouton d'ajout fonctionne
- [ ] Les boutons Edit ouvrent le bon modal/formulaire
- [ ] Les boutons Delete ouvrent le dialogue de confirmation
- [ ] Le dialogue de confirmation supprime bien l'élément
- [ ] Le hover des lignes fonctionne en mode clair ET dark

---

## 📚 Ressources

- [Design System complet](./DESIGN_SYSTEM_AURA.md)
- [Composant ActionButtons](./src/components/aura/ActionButtons.tsx)
- [Composant ViewModeToggle](./src/components/aura/ViewModeToggle.tsx)
- [Helpers designSystem](./src/lib/designSystem.ts)
- [Template de page standardisé](./templates/NewPageTemplate.tsx)

---

**Dernière mise à jour** : Novembre 2024










