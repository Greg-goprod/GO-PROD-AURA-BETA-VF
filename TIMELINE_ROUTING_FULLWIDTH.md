# 🛣️ Timeline - Routing Full-Width

## 🎯 Problème résolu

La Timeline s'affichait **avec la sidebar** car sa route était à l'intérieur du `<AppLayout>` qui contient automatiquement :
- Sidebar (menu latéral)
- TopBar
- Contenu principal

---

## ⚠️ Structure AVANT (incorrect)

```tsx
// src/App.tsx

<Route path="/app" element={<AppLayout/>}>  // ← Layout avec sidebar
  <Route index element={<DashboardPage/>}/>
  <Route path="artistes">...</Route>
  
  {/* Timeline DANS AppLayout = avec sidebar ❌ */}
  <Route path="lineup/timeline" element={<LineupTimelinePage/>}/>
  
  <Route path="production">...</Route>
</Route>
```

**Résultat** : Timeline affichée avec sidebar (280px de perdu)

---

## ✅ Structure APRÈS (correct)

```tsx
// src/App.tsx

{/* Timeline HORS AppLayout = sans sidebar ✅ */}
<Route path="/app/lineup/timeline" element={<LineupTimelinePage/>}/>

<Route path="/app" element={<AppLayout/>}>  // ← Layout avec sidebar
  <Route index element={<DashboardPage/>}/>
  <Route path="artistes">...</Route>
  <Route path="production">...</Route>
  {/* ... toutes les autres routes */}
</Route>
```

**Résultat** : Timeline affichée **sans sidebar**, full-width

---

## 📊 Hiérarchie des routes

```
/
├── /landing (PublicLayout - pas de sidebar, pas de TopBar)
│   └── LandingPage
│
├── /app/lineup/timeline (Pas de layout parent - juste TopBar)
│   └── LineupTimelinePage (standalone, full-width)
│
└── /app (AppLayout - avec sidebar + TopBar)
    ├── / (Dashboard)
    ├── /artistes
    ├── /production
    ├── /administration
    ├── /contacts
    └── /settings
```

---

## 🎨 Layouts disponibles

### 1. `PublicLayout`
**Utilisation** : Pages publiques (landing, login)
```tsx
<PublicLayout>
  {/* Pas de TopBar, pas de sidebar */}
  <Outlet />
</PublicLayout>
```

### 2. `AppLayout`
**Utilisation** : Pages principales de l'app
```tsx
<AppLayout>
  <Sidebar />  {/* 280px */}
  <div>
    <TopBar />
    <main>
      <Outlet />  {/* Contenu de la page */}
    </main>
  </div>
</AppLayout>
```

### 3. **Standalone** (pas de layout parent)
**Utilisation** : Pages spéciales (Timeline)
```tsx
{/* Directement dans la route, sans layout parent */}
<Route path="/app/lineup/timeline" element={<LineupTimelinePage/>}/>

// LineupTimelinePage gère son propre layout :
function LineupTimelinePage() {
  return (
    <div className="min-h-screen flex flex-col">
      <TopBar />  {/* TopBar uniquement */}
      <Header />  {/* Header custom */}
      <Content /> {/* Contenu full-width */}
    </div>
  );
}
```

---

## 🔑 Points clés

### Pourquoi sortir du AppLayout ?

1. **Gain d'espace** : +280px de largeur (sidebar supprimée)
2. **Vue d'ensemble** : Timeline complète visible sans scroll
3. **Focus** : Interface épurée pour le booking
4. **Responsive** : Meilleure adaptation aux écrans

### Pages qui devraient être en standalone

- ✅ **Timeline Booking** : Besoin de largeur maximale
- ⚠️ **Timeline technique** : Idem
- ⚠️ **Plans de scène** : Vue d'ensemble
- ⚠️ **Dashboards fullscreen** : Présentation

### Pages qui doivent rester dans AppLayout

- ✅ **Toutes les pages CRUD** (Artistes, Véhicules, etc.)
- ✅ **Paramètres**
- ✅ **Dashboard principal**
- ✅ **Pages de navigation classiques**

---

## 🚀 Comment créer une nouvelle page standalone

### Étape 1 : Créer la page avec son propre layout

```tsx
// src/pages/MyFullWidthPage.tsx

import TopBar from "../components/topbar/TopBar";
import { Button } from "../components/aura/Button";
import { ArrowLeft } from "lucide-react";
import { useNavigate } from "react-router-dom";

export default function MyFullWidthPage() {
  const navigate = useNavigate();
  
  return (
    <div className="min-h-screen flex flex-col bg-gray-50 dark:bg-gray-900">
      {/* TopBar globale */}
      <TopBar />
      
      {/* Header custom */}
      <div className="bg-white dark:bg-gray-800 border-b px-6 py-4">
        <div className="flex items-center gap-4">
          <Button
            variant="secondary"
            size="sm"
            onClick={() => navigate(-1)}
          >
            <ArrowLeft className="w-4 h-4" />
            Retour
          </Button>
          
          <h1 className="text-2xl font-bold">Ma Page Full-Width</h1>
        </div>
      </div>
      
      {/* Contenu full-width */}
      <div className="flex-1 p-6">
        {/* Votre contenu ici */}
      </div>
    </div>
  );
}
```

### Étape 2 : Ajouter la route HORS de AppLayout

```tsx
// src/App.tsx

{/* Page Full-Width */}
<Route path="/app/my-fullwidth-page" element={<MyFullWidthPage/>}/>

{/* App Routes (avec sidebar) */}
<Route path="/app" element={<AppLayout/>}>
  {/* ... autres routes */}
</Route>
```

### Étape 3 : Naviguer vers la page

```tsx
// Depuis n'importe où
navigate('/app/my-fullwidth-page');

// Ou avec un Link
<Link to="/app/my-fullwidth-page">Ouvrir</Link>
```

---

## 📱 Navigation

### Depuis une page normale → Timeline
```tsx
// Dans BookingPage.tsx (ou autre)
<Button onClick={() => navigate('/app/lineup/timeline')}>
  Ouvrir Timeline
</Button>
```

### Depuis Timeline → Retour Booking
```tsx
// Dans LineupTimelinePage.tsx
<Button onClick={() => navigate('/app/administration/booking')}>
  <ArrowLeft /> Retour Booking
</Button>
```

---

## ✅ Vérification

Pour vérifier que la page est bien standalone :

1. **Ouvrir** : http://localhost:5173/app/lineup/timeline
2. **Vérifier** :
   - ❌ Pas de sidebar visible
   - ✅ TopBar présente (Event Selector, Search, Notifs)
   - ✅ Bouton "Retour Booking" visible
   - ✅ Largeur maximale utilisée
   - ✅ Pas de double layout

---

## 🎯 Résultat

✅ **Timeline = Page standalone**
- Route : `/app/lineup/timeline`
- Layout : Propre (TopBar + Header + Content)
- Sidebar : ❌ Non (full-width)
- Largeur : 100% de l'écran

✅ **Autres pages = Dans AppLayout**
- Routes : `/app/*` (sauf timeline)
- Layout : AppLayout (Sidebar + TopBar)
- Sidebar : ✅ Oui (280px)
- Largeur : Écran - 280px

**Page Timeline maintenant en full-width ! 🎨✨**

