# ⚡ Référence Rapide - Standard de Page AURA

## 🎯 En 30 secondes

```tsx
import { PageHeader } from "@/components/aura/PageHeader";

<div className="p-6 space-y-6">
  <PageHeader
    title="Ma Page"
    subtitle="Contexte"
    actions={<Button>Action</Button>}
  />
  {/* Contenu */}
</div>
```

✅ **TopBar déjà présente automatiquement**  
✅ **PageHeader standardisé**  
✅ **Charte AURA respectée**

---

## 📦 Imports Essentiels

```tsx
import { PageHeader } from "@/components/aura/PageHeader";
import { Button } from "@/components/aura/Button";
import { Card, CardHeader, CardBody } from "@/components/aura/Card";
import { useCurrentEvent } from "@/hooks/useCurrentEvent";
import { useToast } from "@/components/aura/ToastProvider";
```

---

## 🎨 Charte Graphique AURA

### Couleurs
- **Primary** : Violet (#8B5CF6)
- **Background** : Blanc / Night-900
- **Text** : Gray-900 / Gray-100
- **Border** : Gray-200 / Gray-700

### Spacing
```tsx
className="p-6"        // Padding page
className="space-y-6"  // Espacement vertical
className="gap-3"      // Espacement boutons
```

### Typography
```tsx
className="text-2xl font-semibold"  // Titre page
className="text-sm"                  // Sous-titre
className="font-medium"              // Emphasis
```

---

## ✅ Checklist Rapide

- [ ] `PageHeader` avec titre + actions
- [ ] Wrapper `<div className="p-6 space-y-6">`
- [ ] Composants AURA (Card, Button)
- [ ] `useCurrentEvent()` si événement requis
- [ ] `useToast()` pour notifications
- [ ] États : loading, empty, error
- [ ] Dark mode compatible

---

## 📁 Fichiers Clés

- **Template** : `templates/NewPageTemplate.tsx`
- **Doc complète** : `STANDARD_PAGE_TEMPLATE.md`
- **Exemples** : `BookingPage.tsx`, `LineupTimelinePage.tsx`

---

## 🚀 Création Rapide

1. Copier `templates/NewPageTemplate.tsx`
2. Renommer et adapter
3. Ajouter route dans `App.tsx`
4. Ajouter lien dans `AppLayout.tsx`
5. **C'est tout !**

