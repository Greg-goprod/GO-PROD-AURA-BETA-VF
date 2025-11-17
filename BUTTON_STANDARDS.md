# 🎯 Standards des Boutons - Go-Prod AURA

## 📋 **Référence : Bouton d'ajout standard**

### **Page de référence**
`/app/artistes` - Bouton "Ajouter artiste"

---

## 🎨 **Bouton d'ajout standard**

### **Code de référence**
```tsx
<Button leftIcon={<Plus size={16} />} onClick={() => setShowAdd(true)}>
  Ajouter [entité]
</Button>
```

### **Styles appliqués (par défaut)**

#### **Classes CSS**
- `.btn` - Classe de base
- `.btn-primary` - Variante principale (défaut)

#### **Propriétés CSS détaillées**

```css
/* Classe .btn (base) */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;              /* 8px entre icône et texte */
  height: 44px;             /* ← HAUTEUR STANDARD */
  padding: 0 1rem;          /* 16px horizontal */
  border-radius: 14px;      /* Coins arrondis */
  font-weight: 600;         /* Semi-bold */
  border: 1px solid transparent;
  transition: transform .15s ease, box-shadow .15s ease, background .15s ease;
  cursor: pointer;
}

/* Classe .btn-primary (couleur) */
.btn-primary {
  background: var(--color-primary);          /* Violet AURA */
  color: var(--color-text-inverse);          /* Blanc */
  box-shadow: var(--shadow-sm);              /* Ombre légère */
}

.btn-primary:hover {
  background: var(--color-primary-hover);    /* Violet plus foncé */
  transform: translateY(-1px);               /* Légère élévation */
  box-shadow: var(--shadow-md);              /* Ombre plus prononcée */
}
```

---

## 🎨 **Valeurs des variables CSS**

### **Mode Clair**
```css
--color-primary: #8B5CF6;           /* Violet */
--color-primary-hover: #7C3AED;     /* Violet foncé */
--color-text-inverse: #FFFFFF;      /* Blanc */
--shadow-sm: 0 1px 2px 0 rgba(0,0,0,0.05);
--shadow-md: 0 4px 6px -1px rgba(0,0,0,0.1);
```

### **Mode Sombre**
```css
--color-primary: #8B5CF6;           /* Violet (identique) */
--color-primary-hover: #7C3AED;     /* Violet foncé (identique) */
--color-text-inverse: #FFFFFF;      /* Blanc (identique) */
--shadow-sm: 0 1px 2px 0 rgba(0,0,0,0.2);
--shadow-md: 0 4px 6px -1px rgba(0,0,0,0.3);
```

**Note** : Les couleurs du bouton primaire sont **identiques** en mode clair et sombre, seules les ombres changent légèrement.

---

## 📐 **Spécifications du bouton d'ajout**

| Propriété | Valeur | Description |
|-----------|--------|-------------|
| **Hauteur** | `44px` | ⚠️ **STANDARD OBLIGATOIRE** |
| **Padding horizontal** | `16px` | `0 1rem` |
| **Border radius** | `14px` | Coins arrondis |
| **Fond** | `#8B5CF6` | Violet AURA |
| **Texte** | `#FFFFFF` | Blanc |
| **Font weight** | `600` | Semi-bold |
| **Gap** | `8px` | `0.5rem` entre icône et texte |
| **Icône** | `Plus` | Taille 16px |

---

## 🔧 **Utilisation du composant Button**

### **Props du composant**

```tsx
type Props = {
  variant?: 'primary' | 'secondary';  // Défaut: 'primary'
  leftIcon?: React.ReactNode;         // Icône à gauche
  rightIcon?: React.ReactNode;        // Icône à droite
  className?: string;                 // Classes additionnelles
  onClick?: () => void;               // Action au clic
  children: React.ReactNode;          // Texte du bouton
  disabled?: boolean;                 // Désactivé
  type?: 'button' | 'submit' | 'reset'; // Type HTML
}
```

### **Exemple d'utilisation standard**

```tsx
import { Button } from '@/components/ui/Button';
import { Plus } from 'lucide-react';

// Bouton d'ajout standard
<Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
  Ajouter [entité]
</Button>

// Avec variante secondaire
<Button variant="secondary" leftIcon={<Plus size={16} />} onClick={handleAdd}>
  Ajouter [entité]
</Button>

// Désactivé
<Button leftIcon={<Plus size={16} />} onClick={handleAdd} disabled>
  Ajouter [entité]
</Button>
```

---

## 📋 **Variantes de boutons**

### **1. Bouton Primary (par défaut)**
```tsx
<Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
  Ajouter
</Button>
```
- **Usage** : Actions principales (Ajouter, Créer, Enregistrer)
- **Couleur** : Violet AURA
- **Hauteur** : 44px

### **2. Bouton Secondary**
```tsx
<Button variant="secondary" leftIcon={<Edit2 size={16} />} onClick={handleEdit}>
  Modifier
</Button>
```
- **Usage** : Actions secondaires (Modifier, Annuler)
- **Couleur** : Fond gris, bordure
- **Hauteur** : 44px

### **3. Bouton Small (pour icônes uniquement)**
```tsx
<Button variant="secondary" className="w-8 h-8 p-1" onClick={handleEdit}>
  <Edit2 className="w-4 h-4" />
</Button>
```
- **Usage** : Actions compactes (Éditer, Supprimer dans une liste)
- **Taille** : 32px × 32px
- **Note** : ⚠️ **Exception** à la règle des 44px

---

## 🎯 **Standards à respecter**

### **✅ À FAIRE**

1. **Toujours utiliser le composant `Button`**
   ```tsx
   <Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
     Ajouter
   </Button>
   ```

2. **Utiliser `leftIcon` pour l'icône**
   ```tsx
   leftIcon={<Plus size={16} />}
   ```

3. **Hauteur standard de 44px**
   - Par défaut avec le composant `Button`
   - Ne pas override avec `className="h-[autre valeur]"`

4. **Icône Plus de 16px**
   ```tsx
   <Plus size={16} />
   ```

5. **Texte explicite**
   ```tsx
   Ajouter [entité]
   Créer [entité]
   ```

### **❌ À ÉVITER**

1. **Ne PAS mettre l'icône directement dans children**
   ```tsx
   {/* ❌ Incorrect */}
   <Button onClick={handleAdd}>
     <Plus className="w-4 h-4 mr-2" />
     Ajouter
   </Button>
   
   {/* ✅ Correct */}
   <Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
     Ajouter
   </Button>
   ```

2. **Ne PAS override la hauteur**
   ```tsx
   {/* ❌ Incorrect */}
   <Button className="h-10" onClick={handleAdd}>
     Ajouter
   </Button>
   
   {/* ✅ Correct */}
   <Button onClick={handleAdd}>
     Ajouter
   </Button>
   ```

3. **Ne PAS utiliser de classes inline pour le gap**
   ```tsx
   {/* ❌ Incorrect */}
   <Button className="gap-3" onClick={handleAdd}>
     Ajouter
   </Button>
   
   {/* ✅ Correct - Le gap est déjà géré par .btn */}
   <Button onClick={handleAdd}>
     Ajouter
   </Button>
   ```

---

## 📍 **Localisation des boutons d'ajout dans l'application**

### **Pages avec boutons d'ajout à vérifier**

1. **`/app/artistes`** ✅ **RÉFÉRENCE**
   - Bouton : "Ajouter artiste"
   - Status : ✅ Conforme (référence)

2. **`/app/settings/events`**
   - Bouton : "Ajouter un évènement"
   - Status : ⚠️ À vérifier/corriger

3. **`/app/administration/booking`**
   - Bouton : "Nouvelle performance" (probable)
   - Status : ⚠️ À vérifier

4. **`/app/administration/permissions`**
   - Bouton : "Ajouter permission" (probable)
   - Status : ⚠️ À vérifier

5. **Autres pages de settings**
   - Véhicules, Chauffeurs, etc.
   - Status : ⚠️ À vérifier

---

## 🔍 **Checklist de conformité**

Pour chaque bouton d'ajout, vérifier :

- [ ] Utilise le composant `<Button>` de `@/components/ui/Button`
- [ ] Variante `primary` (défaut) ou explicitement définie
- [ ] Icône `Plus` de taille 16px dans `leftIcon`
- [ ] Hauteur de 44px (par défaut, sans override)
- [ ] Gap de 0.5rem entre icône et texte (par défaut)
- [ ] Texte explicite ("Ajouter [entité]")
- [ ] Fond violet (#8B5CF6) en mode clair ET sombre
- [ ] Texte blanc (#FFFFFF) en mode clair ET sombre

---

## 🎨 **Rendu visuel**

### **Mode Clair**
```
┌──────────────────────────┐
│  +  Ajouter artiste      │  ← Violet #8B5CF6, texte blanc
└──────────────────────────┘
     ↑       ↑
   16px    44px hauteur
   gap
```

### **Mode Sombre**
```
┌──────────────────────────┐
│  +  Ajouter artiste      │  ← Violet #8B5CF6, texte blanc (identique)
└──────────────────────────┘
```

### **Hover**
```
┌──────────────────────────┐
│  +  Ajouter artiste      │  ← Violet plus foncé #7C3AED
└──────────────────────────┘
   ↑ Légèrement surélevé (-1px transform)
   avec ombre plus prononcée
```

---

## 📝 **Template de code**

### **Pour une nouvelle page avec bouton d'ajout**

```tsx
import { useState } from 'react';
import { Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';

export default function MaPage() {
  const [showAdd, setShowAdd] = useState(false);

  return (
    <div>
      {/* Header avec bouton d'ajout */}
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold">
          Ma Page
        </h1>
        <Button leftIcon={<Plus size={16} />} onClick={() => setShowAdd(true)}>
          Ajouter [entité]
        </Button>
      </div>

      {/* Reste du contenu */}
    </div>
  );
}
```

---

## 🚀 **Plan de standardisation**

### **Phase 1 : Documentation**
- [x] Identifier le bouton de référence (`/app/artistes`)
- [x] Documenter les styles exacts
- [x] Créer ce document de référence

### **Phase 2 : Audit**
- [ ] Lister tous les boutons d'ajout de l'application
- [ ] Vérifier la conformité de chaque bouton
- [ ] Identifier les déviations

### **Phase 3 : Correction**
- [ ] Corriger les boutons non conformes
- [ ] Tester visuellement en mode clair et sombre
- [ ] Vérifier la hauteur (44px) et l'espacement

### **Phase 4 : Validation**
- [ ] Revue visuelle de toutes les pages
- [ ] Tests d'interaction (hover, click)
- [ ] Validation finale

---

## 📚 **Ressources**

### **Fichiers source**
- Composant : `src/components/ui/Button.tsx`
- Styles : `src/styles/utilities.css` (classes `.btn` et `.btn-primary`)
- Tokens : `src/styles/tokens.css` (variables CSS)

### **Pages de référence**
- Artistes : `src/pages/app/artistes/index.tsx` (ligne 307)

---

## ✅ **Résumé**

**Bouton d'ajout standard Go-Prod AURA**

```tsx
<Button leftIcon={<Plus size={16} />} onClick={handleAdd}>
  Ajouter [entité]
</Button>
```

**Caractéristiques**
- Hauteur : **44px**
- Couleur : **Violet #8B5CF6** (identique clair/sombre)
- Texte : **Blanc #FFFFFF**
- Icône : **Plus 16px**
- Gap : **8px**

**Ce standard doit être appliqué à TOUS les boutons d'ajout de l'application.**

