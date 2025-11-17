# Dépannage Timeline Booking

## 🚨 Erreurs courantes et solutions

### 1. Erreur "Failed to resolve import"
**Problème** : Les composants AURA ne sont pas trouvés
**Solution** : Vérifier les chemins d'import relatifs

```typescript
// ❌ Incorrect (trop de ../)
import { Card } from "../../../../components/aura/Card";

// ✅ Correct (depuis src/pages/)
import { Card } from "../components/aura/Card";

// ✅ Correct (depuis src/features/timeline/components/)
import { Card } from "../../../components/aura/Card";
```

**Structure des chemins** :
- `src/pages/LineupTimelinePage.tsx` → `../components/aura/`
- `src/features/timeline/components/*.tsx` → `../../../components/aura/`
- `src/features/timeline/timelineApi.ts` → `../../lib/supabaseClient`

### 2. Erreur "@dnd-kit not found"
**Problème** : Dépendances DnD non installées
**Solution** :
```bash
npm install @dnd-kit/core @dnd-kit/modifiers @dnd-kit/sortable
npm run dev
```

### 3. Erreur "Badge variant not found"
**Problème** : Badge utilise `color` au lieu de `variant`
**Solution** :
```typescript
// ❌ Incorrect
<Badge variant="secondary">Text</Badge>

// ✅ Correct
<Badge color="gray">Text</Badge>
```

### 4. Timeline ne se charge pas
**Problème** : Erreurs dans les composants
**Solution** :
1. Vérifier la console du navigateur
2. Tester en mode démo d'abord
3. Vérifier les imports dans tous les fichiers

### 5. Drag & Drop ne fonctionne pas
**Problème** : Zones de drop mal configurées
**Solution** :
1. Vérifier que `DndContext` entoure la grille
2. Vérifier les `data-*` attributes sur les zones de drop
3. Consulter la console pour erreurs DnD

### 6. Erreur "Failed to resolve import ../../lib/utils"
**Problème** : Le fichier `src/lib/utils.ts` n'existe pas
**Solution** : Créer le fichier utils.ts ou modifier le composant

```typescript
// Option 1: Créer src/lib/utils.ts avec fonction cn
export function cn(...classes: (string | undefined | null | false)[]): string {
  return classes.filter(Boolean).join(' ');
}

// Option 2: Modifier le composant pour ne pas utiliser cn
const inputClasses = `${baseClasses} ${errorClasses} ${className || ""}`;
```

### 7. Erreur "Failed to resolve import ../../lib/supabaseClient"
**Problème** : Chemin incorrect vers supabaseClient
**Solution** : Vérifier le chemin depuis timelineApi.ts

```typescript
// ❌ Incorrect (trop de ../)
import { supabase } from "../../../lib/supabaseClient";

// ✅ Correct (depuis src/features/timeline/)
import { supabase } from "../../lib/supabaseClient";
```

## 🔍 Vérifications rapides

### Composants AURA requis
- ✅ `src/components/aura/Card.tsx`
- ✅ `src/components/aura/Button.tsx`
- ✅ `src/components/aura/Badge.tsx`
- ✅ `src/components/aura/Modal.tsx`
- ✅ `src/components/aura/Toast.tsx`
- ✅ `src/components/aura/EmptyState.tsx`
- ✅ `src/components/aura/Input.tsx`

### Composants Timeline requis
- ✅ `src/features/timeline/timelineApi.ts`
- ✅ `src/features/timeline/components/TimelineGrid.tsx`
- ✅ `src/features/timeline/components/PerformanceCard.tsx`
- ✅ `src/features/timeline/components/DailySummaryCards.tsx`
- ✅ `src/features/timeline/components/CustomTimePicker.tsx`

### Page principale
- ✅ `src/pages/LineupTimelinePage.tsx`
- ✅ Route `/app/lineup/timeline` dans App.tsx
- ✅ Bouton Timeline dans BookingPage

## 🧪 Tests de validation

### 1. Test de base
```bash
# Vérifier que le serveur démarre
npm run dev

# Vérifier les URLs
http://localhost:5174/app/booking
http://localhost:5174/app/lineup/timeline
```

### 2. Test mode démo
1. Aller sur `/app/lineup/timeline` sans event_id
2. EmptyState devrait s'afficher
3. Cliquer "Activer le mode démo"
4. Timeline devrait se charger avec données fictives

### 3. Test drag & drop
1. Glisser une carte performance
2. Déposer dans une autre cellule
3. Toast "Performance déplacée (démo)" devrait apparaître

### 4. Test modaux
1. Clic sur cellule vide → PerformanceModal
2. Clic sur icône horloge → CustomTimePicker
3. Clic sur icône poubelle → Confirmation suppression

## 📊 Logs de debug

### Console du navigateur
```javascript
// Vérifier les données chargées
console.log("Days:", days);
console.log("Stages:", stages);
console.log("Performances:", performances);

// Vérifier les erreurs DnD
console.log("DnD errors:", /* erreurs dans console */);
```

### Logs Vite
- Erreurs d'import → Vérifier les chemins
- Erreurs de compilation → Vérifier la syntaxe
- Warnings → Généralement non bloquants

## 🚀 Solutions rapides

### Redémarrage complet
```bash
# Arrêter le serveur (Ctrl+C)
# Puis relancer
npm run dev
```

### Nettoyage cache
```bash
# Supprimer node_modules et reinstaller
rm -rf node_modules package-lock.json
npm install
npm run dev
```

### Vérification fichiers
```bash
# Vérifier que tous les fichiers existent
./test-timeline-system.bat
```

## 📞 Support

### En cas de problème persistant
1. **Console** : Copier les erreurs exactes
2. **Fichiers** : Vérifier que tous les fichiers existent
3. **Dépendances** : Vérifier l'installation des packages
4. **Imports** : Vérifier les chemins relatifs

### Fichiers de diagnostic
- `test-timeline-system.bat` : Vérification complète
- `TEST_TIMELINE_GUIDE.md` : Guide de test détaillé
- `TIMELINE_BOOKING_DOCS.md` : Documentation technique
