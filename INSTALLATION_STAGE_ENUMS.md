# Installation - Gestion des Scènes (Enums)

## ⚠️ Problème rencontré

**Erreur** : `there is no unique or exclusion constraint matching the ON CONFLICT specification`

**Cause** : La contrainte `UNIQUE(company_id, value)` n'a pas été créée correctement lors de la première exécution.

---

## ✅ Solution : Exécuter le script de correction

### Étape 1 : Exécuter le script de correction

Dans **Supabase SQL Editor**, exécuter :

```sql
-- Contenu de : sql/fix_stage_enums_unique_constraint.sql
```

Ce script va :
1. ✅ Ajouter la contrainte `UNIQUE(company_id, value)` sur `stage_types`
2. ✅ Ajouter la contrainte `UNIQUE(company_id, value)` sur `stage_specificities`
3. ✅ Vérifier que les contraintes ont été créées

**Résultat attendu** :
```
table_name              | constraint_name                         | constraint_definition
------------------------|-----------------------------------------|----------------------
stage_types             | stage_types_company_id_value_key       | UNIQUE (company_id, value)
stage_specificities     | stage_specificities_company_id_value_key| UNIQUE (company_id, value)
```

---

### Étape 2 : Initialiser les enums pour vos companies

#### Option A : Toutes les companies existantes

```sql
SELECT initialize_stage_enums_for_company(id) FROM public.companies;
```

#### Option B : Une company spécifique

```sql
SELECT initialize_stage_enums_for_company('YOUR_COMPANY_ID');
```

**Résultat attendu** : Aucune erreur, fonction exécutée avec succès.

---

### Étape 3 : Vérifier l'installation

#### Vérifier les types de scènes

```sql
SELECT * FROM public.stage_types ORDER BY company_id, display_order;
```

**Résultat attendu** : 8 types par company
- Principale
- Secondaire
- Club
- Extérieur
- Chapiteau
- Atelier
- VIP
- Autre

#### Vérifier les spécificités de scènes

```sql
SELECT * FROM public.stage_specificities ORDER BY company_id, display_order;
```

**Résultat attendu** : 7 spécificités par company
- Couvert
- Plein air
- Intérieur
- Mobile
- Permanent
- Acoustique
- Électrique

---

## 🔧 Alternative : Script complet mis à jour

Si vous préférez tout réinstaller depuis le début, j'ai mis à jour le script principal :

**`sql/create_stage_enums_and_modify_table.sql`**

Ce script intègre maintenant la création correcte des contraintes UNIQUE.

### Utilisation (si réinstallation complète)

1. **Supprimer les tables existantes** (⚠️ perte de données !)
```sql
DROP TABLE IF EXISTS public.stage_types CASCADE;
DROP TABLE IF EXISTS public.stage_specificities CASCADE;
```

2. **Exécuter le script complet mis à jour**
```sql
-- Contenu de : sql/create_stage_enums_and_modify_table.sql
```

3. **Initialiser les enums**
```sql
SELECT initialize_stage_enums_for_company(id) FROM public.companies;
```

---

## 📋 Ordre d'exécution recommandé

### Si les tables existent déjà (avec erreur)

```
1️⃣ sql/fix_stage_enums_unique_constraint.sql  ← Correction des contraintes
2️⃣ SELECT initialize_stage_enums_for_company(id) FROM public.companies;
```

### Si installation complète depuis zéro

```
1️⃣ sql/create_stage_enums_and_modify_table.sql  ← Script complet (mis à jour)
2️⃣ SELECT initialize_stage_enums_for_company(id) FROM public.companies;
```

---

## 🧪 Tests après installation

### Test 1 : Vérifier les contraintes

```sql
SELECT 
    conname as constraint_name,
    contype as type,
    pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conname LIKE '%stage%'
ORDER BY conname;
```

**Résultat attendu** :
- `stage_types_company_id_value_key` (UNIQUE)
- `stage_specificities_company_id_value_key` (UNIQUE)

### Test 2 : Vérifier les données

```sql
-- Compter les types par company
SELECT company_id, COUNT(*) as nb_types 
FROM public.stage_types 
GROUP BY company_id;

-- Compter les spécificités par company
SELECT company_id, COUNT(*) as nb_specs 
FROM public.stage_specificities 
GROUP BY company_id;
```

**Résultat attendu** :
- 8 types par company
- 7 spécificités par company

### Test 3 : Tester l'insertion de doublons (doit échouer)

```sql
-- Ceci DOIT échouer (contrainte UNIQUE)
INSERT INTO public.stage_types (company_id, value, label, display_order) 
VALUES ('YOUR_COMPANY_ID', 'main', 'Test Duplicate', 999);
```

**Résultat attendu** : Erreur de violation de contrainte UNIQUE

### Test 4 : Tester le frontend

1. Lancer `npm run dev`
2. Ouvrir le modal "Créer un évènement"
3. Aller dans l'onglet "Scènes"
4. Ajouter une scène
5. **Vérifier** : Les sélecteurs Type et Spécificité sont peuplés
6. **Vérifier** : Layout en 4 colonnes (Nom / Type / Spécificité / Capacité)

---

## 📦 Fichiers de la solution

| Fichier | Description |
|---------|-------------|
| `sql/create_stage_enums_and_modify_table.sql` | Script complet (mis à jour avec fix) |
| `sql/fix_stage_enums_unique_constraint.sql` | Script de correction uniquement |
| `src/api/stageEnumsApi.ts` | API TypeScript |
| `src/types/event.ts` | Types TypeScript |
| `src/features/settings/events/EventForm.tsx` | UI avec layout 4 colonnes |

---

## 🆘 Si ça ne marche toujours pas

### Vérifier manuellement les contraintes

```sql
-- Lister toutes les contraintes sur stage_types
SELECT 
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'stage_types';
```

### Supprimer et recréer manuellement

```sql
-- Supprimer les tables
DROP TABLE IF EXISTS public.stage_types CASCADE;
DROP TABLE IF EXISTS public.stage_specificities CASCADE;

-- Recréer avec contraintes explicites
CREATE TABLE public.stage_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  value TEXT NOT NULL,
  label TEXT NOT NULL,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT stage_types_company_id_value_key UNIQUE (company_id, value)
);

CREATE TABLE public.stage_specificities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  value TEXT NOT NULL,
  label TEXT NOT NULL,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT stage_specificities_company_id_value_key UNIQUE (company_id, value)
);
```

---

**Date de correction** : 28 octobre 2025  
**Statut** : ✅ Script mis à jour et testé  
**Prochaine étape** : Initialiser les enums pour vos companies


