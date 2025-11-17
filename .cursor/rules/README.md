# 📚 Documentation des Règles AURA

## 📋 Index des Documents

### 1. 🎨 [Design System AURA](./design-system-aura.mdc)
**Standards visuels et composants**
- Composants UI (Button, Input, Modal, etc.)
- Palette de couleurs et dark mode
- Tableaux et formulaires
- Badges et icônes
- Layout et responsive

### 2. 🎯 [Standards CRM](./crm-standards.mdc)
**Règles spécifiques au module CRM**
- Composants CRM (Sélecteurs, PhotoUploader)
- Structure des pages Entreprises et Contacts
- Gestion des relations N-N
- Affichage des données (badges, téléphones)
- Recherche, filtres et tri

### 3. 🖼️ [Icônes](./icones.mdc)
**Règles d'utilisation des icônes**
- UNIQUEMENT Lucide React
- Jamais d'emojis (sauf demande explicite)
- Vérifier patterns existants

### 4. ⚙️ [Workflow de Développement](./dev-workflow.mdc)
**Process et bonnes pratiques**
- Checklist pré-développement
- Règles de code TypeScript/React
- Conventions Supabase
- Tests et validation
- Git et commits

---

## 🚀 Quick Start

### Avant de coder quoi que ce soit :

1. **Vérifier l'existant**
   ```bash
   # Chercher si un composant existe déjà
   grep -r "ComponentName" src/components/
   ```

2. **Relire les règles concernées**
   - Design System AURA → pour UI/UX
   - Standards CRM → pour fonctionnalités CRM
   - Workflow → pour process de dev

3. **Checklist rapide**
   - [ ] Composant Aura existant utilisé ?
   - [ ] Icônes Lucide uniquement ?
   - [ ] Dark mode supporté ?
   - [ ] Couleurs AURA respectées (violet primary) ?
   - [ ] Textes lisibles (gray-900/gray-100) ?
   - [ ] Pattern cohérent avec l'existant ?

---

## 🎯 Règles d'or AURA

### Les 5 commandements

1. **Cohérence avant innovation**
   - Toujours suivre les patterns existants
   - Pas de nouveau composant si un similaire existe

2. **Dark mode systématique**
   - Toutes les classes avec variante `dark:`
   - Contraste vérifié dans les 2 modes

3. **Lucide React pour les icônes**
   - Pas d'emojis, pas d'autres libs
   - Import : `import { Icon } from 'lucide-react'`

4. **Composants Aura en priorité**
   - Button, Input, Modal, ConfirmDialog, etc.
   - PhoneInput pour tous les téléphones

5. **TypeScript strict**
   - Types partout, pas de `any`
   - `import type` pour les types

---

## 📞 Support

### En cas de doute
1. Chercher dans les fichiers de règles ci-dessus
2. Grep dans le codebase pour des exemples
3. Vérifier les composants Aura existants
4. Demander confirmation avant d'innover

### Mise à jour des règles
Ces documents doivent évoluer avec le projet :
- Ajouter de nouveaux patterns quand ils émergent
- Documenter les décisions importantes
- Garder les exemples à jour

---

## 🔄 Dernière mise à jour
Date : 2024-11-09
Version : 1.0

