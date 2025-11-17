# 📐 Standard de Page - Go-Prod AURA

## 🎯 Objectif

Toutes les pages du SaaS doivent suivre **le même standard** pour garantir :
- ✅ Cohérence visuelle (TopBar + PageHeader)
- ✅ Expérience utilisateur uniforme
- ✅ Maintenance facilitée
- ✅ Intégration avec EventSelector automatique

---

## 🏗️ Architecture Standard (2 niveaux)

### Niveau 1 : TopBar (GLOBAL - automatique) ✅

**Fichier** : `src/components/topbar/TopBar.tsx`

**Intégration** : Via `AppLayout.tsx` - **Appliquée automatiquement à TOUTES les pages**

**Contenu** :
- EventSelector (sélection d'événement)
- GlobalSearch (recherche globale)
- NotificationButton
- ThemeToggle (dark/light mode)

⚠️ **RIEN À FAIRE** : Cette TopBar est déjà présente sur toutes les pages `/app/*`

---

### Niveau 2 : PageHeader (PAR PAGE - manuel) 📄

**Fichier** : `src/components/aura/PageHeader.tsx`

**Intégration** : À ajouter manuellement dans chaque page

**Contenu** :
- Titre de la page
- Sous-titre / contexte
- Actions (boutons, filtres, etc.)

✅ **À UTILISER SYSTÉMATIQUEMENT** dans toutes les nouvelles pages

---

## 📋 Template Standard de Page

### Fichier : `src/pages/MaNouvellePage.tsx`

```tsx
import { PageHeader } from "@/components/aura/PageHeader";
import { Button } from "@/components/aura/Button";
import { Card, CardHeader, CardBody } from "@/components/aura/Card";
import { useCurrentEvent } from "@/hooks/useCurrentEvent";
import { useToast } from "@/components/aura/ToastProvider";
import { useState, useEffect } from "react";

export default function MaNouvellePage() {
  // 🎯 Hooks standards (dans cet ordre)
  const { currentEvent, companyId } = useCurrentEvent();
  const { success: toastSuccess, error: toastError } = useToast();
  
  // États locaux
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState([]);
  
  // Chargement des données
  useEffect(() => {
    // Logique de chargement
  }, [currentEvent?.id]);
  
  // Handlers
  const handleAction = () => {
    // Logique
  };

  return (
    <div className="p-6 space-y-6">
      {/* 📌 HEADER STANDARD - OBLIGATOIRE */}
      <PageHeader
        title="Titre de ma page"
        subtitle={
          <>
            {currentEvent ? (
              <>
                <span className="font-medium" style={{ color: currentEvent.color_hex }}>
                  {currentEvent.name}
                </span>
                {" • "}
              </>
            ) : null}
            Contexte • {data.length} éléments
          </>
        }
        actions={
          <>
            <Button variant="secondary" onClick={handleAction}>
              Action secondaire
            </Button>
            <Button variant="primary" onClick={handleAction}>
              Action principale
            </Button>
          </>
        }
      />

      {/* 📦 CONTENU DE LA PAGE */}
      <Card>
        <CardHeader>
          <h2 className="font-semibold text-gray-900 dark:text-gray-100">
            Section principale
          </h2>
        </CardHeader>
        <CardBody>
          {loading ? (
            <div className="text-center text-gray-500">Chargement...</div>
          ) : (
            <div>
              {/* Contenu */}
            </div>
          )}
        </CardBody>
      </Card>
    </div>
  );
}
```

---

## ✅ Checklist Création de Page

### Avant de créer une page

- [ ] Vérifier que la route est définie dans `src/App.tsx`
- [ ] Vérifier que le lien est dans la sidebar (`src/layout/AppLayout.tsx`)
- [ ] Choisir un nom cohérent (ex: `MyFeaturePage.tsx`)

### Structure de la page

- [ ] Importer `PageHeader` de `@/components/aura/PageHeader`
- [ ] Utiliser `useCurrentEvent()` si la page dépend d'un événement
- [ ] Utiliser `useToast()` pour les notifications
- [ ] Wrapper le contenu dans `<div className="p-6 space-y-6">`
- [ ] Ajouter le `PageHeader` en premier
- [ ] Utiliser les composants AURA (Card, Button, etc.)

### PageHeader

- [ ] `title` : Nom clair de la page
- [ ] `subtitle` : Contexte (événement, nombre d'éléments, etc.)
- [ ] `actions` : Boutons d'action (si nécessaire)
- [ ] Afficher le nom de l'événement avec sa couleur (si applicable)

### Gestion des états

- [ ] Loading state avec indicateur
- [ ] Empty state avec message clair
- [ ] Error state avec toast
- [ ] Données affichées dans des Cards

---

## 📚 Exemples de Référence

### Pages déjà standardisées ✅

1. **BookingPage** (`src/pages/BookingPage.tsx`)
   - ✅ PageHeader avec événement + actions multiples
   - ✅ Mode démo
   - ✅ Gestion complète des états

2. **LineupTimelinePage** (`src/pages/LineupTimelinePage.tsx`)
   - ✅ PageHeader avec nom d'événement coloré
   - ✅ Integration EventSelector
   - ✅ Actions conditionnelles

### Code à copier

```tsx
// Import du PageHeader
import { PageHeader } from "@/components/aura/PageHeader";

// Dans le composant
<PageHeader
  title="Nom de la page"
  subtitle="Description"
  actions={
    <>
      <Button onClick={handleAction}>Action</Button>
    </>
  }
/>
```

---

## 🚫 Anti-Patterns à Éviter

### ❌ NE PAS créer de header custom

```tsx
// ❌ MAUVAIS
<div className="flex items-center justify-between">
  <h1 className="text-2xl font-semibold">Mon Titre</h1>
  <Button>Action</Button>
</div>
```

```tsx
// ✅ BON
<PageHeader
  title="Mon Titre"
  actions={<Button>Action</Button>}
/>
```

### ❌ NE PAS dupliquer le code de TopBar

La TopBar est **déjà présente** via `AppLayout`. Ne pas la recréer !

### ❌ NE PAS oublier le wrapper padding

```tsx
// ❌ MAUVAIS - Pas de padding
<div>
  <PageHeader title="..." />
</div>

// ✅ BON - Padding standard
<div className="p-6 space-y-6">
  <PageHeader title="..." />
</div>
```

---

## 🎨 Design Tokens AURA

### Spacing

```tsx
className="p-6 space-y-6"  // Padding et espacement standard des pages
className="gap-3"          // Espacement entre boutons d'action
```

### Colors

```tsx
// Titre
className="text-gray-900 dark:text-gray-100"

// Sous-titre
className="text-gray-600 dark:text-gray-400"

// Événement (utiliser la couleur de l'événement)
style={{ color: currentEvent.color_hex }}
```

### Typography

```tsx
// Titre de page (dans PageHeader)
className="text-2xl font-semibold"

// Sous-titre (dans PageHeader)
className="text-sm"
```

---

## 🔧 Configuration Route

### Dans `src/App.tsx`

```tsx
// Ajouter la route
<Route path="/app/ma-section">
  <Route index element={<MaNouvellePage />} />
</Route>
```

### Dans `src/layout/AppLayout.tsx`

```tsx
// Ajouter le lien dans la sidebar
<Link 
  to="/app/ma-section" 
  className={`sidebar-item ${location.pathname === '/app/ma-section' ? 'active' : ''}`}
>
  <Icon name="IconName" size={18} /> MA SECTION
</Link>
```

---

## 📊 Validation

### Critères de conformité

Une page est conforme au standard si :

1. ✅ La TopBar globale est visible (automatique via AppLayout)
2. ✅ Le `PageHeader` est présent avec :
   - Titre clair
   - Sous-titre informatif (avec événement si applicable)
   - Actions pertinentes
3. ✅ Le padding standard est appliqué (`p-6 space-y-6`)
4. ✅ Les composants AURA sont utilisés (Card, Button, etc.)
5. ✅ Le dark mode fonctionne correctement
6. ✅ Les toasts sont utilisés pour les notifications
7. ✅ Les états (loading, empty, error) sont gérés

### Tests manuels

- [ ] La TopBar s'affiche en haut
- [ ] Le PageHeader s'affiche sous la TopBar
- [ ] Le nom de l'événement est visible (si applicable)
- [ ] Les actions fonctionnent
- [ ] Le dark mode est correct
- [ ] Responsive (mobile/desktop)

---

## 🚀 Script de Création Rapide

### Créer une nouvelle page conforme

```bash
# 1. Créer le fichier
touch src/pages/MaNouvellePage.tsx

# 2. Copier le template
# (Copier le code du template ci-dessus)

# 3. Ajouter la route dans App.tsx
# 4. Ajouter le lien dans AppLayout.tsx
# 5. Tester dans le navigateur
```

---

## 📝 Notes Importantes

### TopBar vs PageHeader

| Composant | Où | Quoi | Quand |
|-----------|-----|------|-------|
| **TopBar** | Global (AppLayout) | EventSelector, Search, Notifs | Automatique ✅ |
| **PageHeader** | Dans chaque page | Titre, actions spécifiques | Manuel (à ajouter) |

### Événements

- Toutes les pages qui dépendent d'un événement doivent utiliser `useCurrentEvent()`
- Afficher le nom de l'événement dans le `subtitle` du PageHeader
- Utiliser la couleur de l'événement pour le highlighting

### Multi-tenancy

- Toujours utiliser `companyId` pour les requêtes
- Filtrer les données par `company_id`
- Ne jamais afficher de données d'autres companies

---

## 🎓 Formation Développeur

### Pour les nouveaux développeurs

1. Lire ce document en entier
2. Étudier `BookingPage.tsx` et `LineupTimelinePage.tsx`
3. Créer une page de test avec le template
4. Faire valider par un senior

### Points d'attention

- **Ne jamais** créer de header custom
- **Toujours** utiliser PageHeader
- **Toujours** respecter le spacing standard
- **Toujours** gérer les états (loading, empty, error)

---

## 📞 Support

En cas de doute sur le standard :
1. Consulter ce document
2. Regarder les exemples (`BookingPage`, `LineupTimelinePage`)
3. Vérifier que la TopBar est bien présente (elle l'est toujours !)

---

## 🔄 Mises à jour

**Dernière mise à jour** : 31 octobre 2025

**Prochaines évolutions** :
- Template avec TypeScript strict
- Generator CLI pour créer des pages
- Tests automatisés de conformité

---

## ✅ TL;DR - Résumé Ultra-Rapide

```tsx
// 1. Importer
import { PageHeader } from "@/components/aura/PageHeader";

// 2. Utiliser dans la page
<div className="p-6 space-y-6">
  <PageHeader
    title="Titre"
    subtitle="Contexte"
    actions={<Button>Action</Button>}
  />
  {/* Contenu */}
</div>

// 3. La TopBar est DÉJÀ là automatiquement ✅
```

**C'est tout ! Toutes les pages doivent suivre ce pattern.** 🎯

