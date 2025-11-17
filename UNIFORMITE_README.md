# 🎨 Design System AURA - Uniformité

## 🚀 Démarrage rapide

➡️ **[START_HERE_UNIFORMITE.md](./START_HERE_UNIFORMITE.md)** ⬅️

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[START_HERE_UNIFORMITE.md](./START_HERE_UNIFORMITE.md)** | 👈 **Commencer ici - Guide de démarrage** |
| [RESUME_UNIFORMITE_VISUEL.md](./RESUME_UNIFORMITE_VISUEL.md) | Résumé visuel avec tableaux |
| [DESIGN_SYSTEM_AURA.md](./DESIGN_SYSTEM_AURA.md) | Référence complète du design system |
| [MIGRATION_GUIDE_UNIFORMITE.md](./MIGRATION_GUIDE_UNIFORMITE.md) | Comment migrer une page existante |
| [UNIFORMITE_COMPLETE.md](./UNIFORMITE_COMPLETE.md) | Vue d'ensemble complète |

---

## 🧩 Composants créés

```tsx
// ActionButtons - Uniformise Edit/Delete
import { ActionButtons } from '@/components/aura/ActionButtons';
<ActionButtons onEdit={...} onDelete={...} />

// ViewModeToggle - Bascule liste/grille
import { ViewModeToggle } from '@/components/aura/ViewModeToggle';
<ViewModeToggle mode={mode} onChange={setMode} />

// Helpers
import { getTableRowHoverProps } from '@/lib/designSystem';
<tr {...getTableRowHoverProps()}>...</tr>
```

---

## 🛠️ Outils

```bash
# Audit d'une page/dossier
bash audit-uniformite.sh src/pages/app/ma-page.tsx

# Template pour nouvelle page
cp templates/NewPageTemplate.tsx src/pages/app/nouvelle-page.tsx
```

---

## ✅ Standards clés

```
Ajouter    →  Plus (16px)   →  Violet (bouton)
Modifier   →  Edit2 (16px)  →  Bleu #3B82F6
Supprimer  →  Trash2 (16px) →  Rouge #EF4444
Fermer     →  X (16px)      →  Gris (modals)
```

---

## 🎯 Checklist

- [ ] Icônes : `Edit2`, `Trash2`, `Plus`
- [ ] Couleurs : Bleu (Edit), Rouge (Delete)
- [ ] `leftIcon` dans boutons
- [ ] `ConfirmDialog` pour suppressions
- [ ] Testé mode clair ET dark

---

**Version** : 1.0.0 | **Date** : Novembre 2024










