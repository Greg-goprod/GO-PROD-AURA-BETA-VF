# Dépannage Page Blanche - Timeline Booking

## 🚨 Diagnostic de page blanche

### 1. Vérifications immédiates

**Console du navigateur (F12)** :
- Ouvrir les outils de développement
- Onglet "Console"
- Recharger la page
- Noter toutes les erreurs JavaScript

**Erreurs courantes** :
- `Failed to resolve import` → Problème de chemins d'import
- `Cannot read property of undefined` → Composant non trouvé
- `Module not found` → Dépendance manquante
- `SyntaxError` → Erreur de syntaxe dans le code

### 2. Test avec page simplifiée

**Étape 1** : Remplacer par version de test
```bash
# Exécuter le script de test
./test-simple-page.bat
```

**Étape 2** : Tester l'URL
- Aller sur `http://localhost:5175/app/lineup/timeline`
- Si la page de test s'affiche → Problème dans les composants complexes
- Si page blanche persiste → Problème de route ou serveur

**Étape 3** : Restaurer la version originale
```bash
# Restaurer la version complète
./restore-original-page.bat
```

### 3. Vérifications systématiques

#### A. Fichiers critiques
- ✅ `src/pages/LineupTimelinePage.tsx`
- ✅ `src/features/timeline/timelineApi.ts`
- ✅ `src/lib/supabaseClient.ts`
- ✅ `src/lib/utils.ts`

#### B. Composants AURA
- ✅ `src/components/aura/Card.tsx`
- ✅ `src/components/aura/Button.tsx`
- ✅ `src/components/aura/Badge.tsx`
- ✅ `src/components/aura/Modal.tsx`
- ✅ `src/components/aura/Toast.tsx`
- ✅ `src/components/aura/EmptyState.tsx`
- ✅ `src/components/aura/Input.tsx`

#### C. Composants Timeline
- ✅ `src/features/timeline/components/TimelineGrid.tsx`
- ✅ `src/features/timeline/components/PerformanceCard.tsx`
- ✅ `src/features/timeline/components/DailySummaryCards.tsx`
- ✅ `src/features/timeline/components/CustomTimePicker.tsx`

#### D. Dépendances
- ✅ `@dnd-kit/core`
- ✅ `@dnd-kit/modifiers`
- ✅ `@dnd-kit/sortable`

#### E. Route
- ✅ `/app/lineup/timeline` dans App.tsx
- ✅ Import de LineupTimelinePage

### 4. Solutions par type d'erreur

#### Erreur d'import
```typescript
// Vérifier les chemins
import { Card } from "../components/aura/Card";        // ✅ Depuis pages/
import { Card } from "../../../components/aura/Card";  // ✅ Depuis features/timeline/components/
import { supabase } from "../../lib/supabaseClient";   // ✅ Depuis features/timeline/
```

#### Erreur de composant
```typescript
// Vérifier que le composant existe et est exporté
export function Card({ children, className }) {
  return <div className={className}>{children}</div>;
}
```

#### Erreur de dépendance
```bash
# Réinstaller les dépendances
npm install @dnd-kit/core @dnd-kit/modifiers @dnd-kit/sortable
npm run dev
```

#### Erreur de route
```typescript
// Vérifier dans App.tsx
import LineupTimelinePage from './pages/LineupTimelinePage';

<Route path="lineup/timeline" element={<LineupTimelinePage />} />
```

### 5. Test progressif

#### Étape 1 : Page de base
```typescript
export default function LineupTimelinePage() {
  return <div>Test Timeline</div>;
}
```

#### Étape 2 : Ajouter un composant
```typescript
import { Card } from "../components/aura/Card";

export default function LineupTimelinePage() {
  return (
    <Card>
      <h1>Test Timeline</h1>
    </Card>
  );
}
```

#### Étape 3 : Ajouter l'API
```typescript
import { fetchEventDays } from "../features/timeline/timelineApi";

export default function LineupTimelinePage() {
  const [days, setDays] = useState([]);
  
  useEffect(() => {
    fetchEventDays().then(setDays);
  }, []);
  
  return <div>Days: {days.length}</div>;
}
```

#### Étape 4 : Ajouter les composants complexes
- TimelineGrid
- PerformanceCard
- DailySummaryCards
- CustomTimePicker

### 6. Scripts de diagnostic

#### Diagnostic complet
```bash
./diagnose-blank-page.bat
```

#### Test page simplifiée
```bash
./test-simple-page.bat
```

#### Restauration
```bash
./restore-original-page.bat
```

### 7. Logs de debug

#### Console du navigateur
```javascript
// Ajouter des logs dans LineupTimelinePage
console.log("LineupTimelinePage mounted");
console.log("EventId:", eventId);
console.log("HasEvent:", hasEvent);
console.log("DemoMode:", demoMode);
```

#### Logs Vite
- Vérifier la sortie du terminal `npm run dev`
- Noter les erreurs de compilation
- Vérifier les warnings

### 8. Solutions d'urgence

#### Redémarrage complet
```bash
# Arrêter le serveur (Ctrl+C)
# Nettoyer le cache
rm -rf node_modules/.vite
# Relancer
npm run dev
```

#### Mode développement
```bash
# Vérifier que le serveur fonctionne
curl http://localhost:5175
# Ou ouvrir http://localhost:5175 dans le navigateur
```

#### Test d'autres pages
- Tester `http://localhost:5175/app/booking`
- Tester `http://localhost:5175/app/artistes`
- Si ces pages fonctionnent → Problème spécifique à Timeline

### 9. Contact support

**En cas de problème persistant** :
1. Copier les erreurs exactes de la console
2. Noter l'URL qui pose problème
3. Indiquer les étapes de reproduction
4. Fournir la sortie de `./diagnose-blank-page.bat`

