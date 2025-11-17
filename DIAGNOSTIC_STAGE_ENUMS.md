# Diagnostic - Enums de scènes ne se chargent pas

## 🔍 Problème
Les containers de gestion des types et spécificités de scènes apparaissent, mais ne récupèrent pas les données depuis Supabase.

## 📋 Vérifications à effectuer

### 1. Vérifier les logs dans la console du navigateur

**Ouvrir la console** : `Ctrl+Shift+I` ou `F12` → Onglet "Console"

**Logs à chercher** :
```
🔍 StageEnumsManager - Chargement des enums pour company: <uuid>
📡 API: Récupération stage_types pour company: <uuid>
✅ stage_types data: [...]
📡 API: Récupération stage_specificities pour company: <uuid>
✅ stage_specificities data: [...]
```

**Si vous voyez** :
- ❌ `Erreur Supabase stage_types: {...}` → Problème de requête Supabase
- `data: []` → Les tables sont vides
- `data: null` → Les tables n'existent pas ou erreur RLS

---

### 2. Vérifier que les tables existent dans Supabase

**Dans Supabase SQL Editor**, exécuter le script de diagnostic :

📄 **Fichier** : `sql/check_stage_enums_tables.sql`

**Ce script vérifie** :
1. ✅ Les tables `stage_types` et `stage_specificities` existent
2. ✅ Le nombre de lignes dans chaque table
3. ✅ Les données d'exemple
4. ✅ Les policies RLS
5. ✅ Les contraintes UNIQUE

**Résultats attendus** :
```
table_name           | table_schema
---------------------|-------------
stage_types          | public
stage_specificities  | public

table_name           | row_count
---------------------|----------
stage_types          | 8 (ou plus)
stage_specificities  | 7 (ou plus)
```

---

### 3. Si les tables n'existent pas

**Exécuter dans l'ordre** :

#### Étape 1 : Créer les tables
```sql
-- Exécuter le fichier sql/create_stage_enums_and_modify_table.sql
-- (Contenu complet dans ce fichier)
```

#### Étape 2 : Ajouter les contraintes UNIQUE
```sql
-- Exécuter le fichier sql/fix_stage_enums_unique_constraint.sql

DO $$
BEGIN
    -- Pour stage_types
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'stage_types_company_id_value_key'
    ) THEN
        ALTER TABLE public.stage_types 
            ADD CONSTRAINT stage_types_company_id_value_key UNIQUE (company_id, value);
    END IF;
    
    -- Pour stage_specificities
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'stage_specificities_company_id_value_key'
    ) THEN
        ALTER TABLE public.stage_specificities 
            ADD CONSTRAINT stage_specificities_company_id_value_key UNIQUE (company_id, value);
    END IF;
END $$;
```

#### Étape 3 : Initialiser les valeurs par défaut
```sql
-- Remplacer <YOUR_COMPANY_ID> par votre ID de company
-- (Visible dans la console : "Chargement des enums pour company: <uuid>")

SELECT initialize_stage_enums_for_company('<YOUR_COMPANY_ID>');

-- Ou pour toutes les companies :
SELECT initialize_stage_enums_for_company(id) FROM public.companies;
```

---

### 4. Si les tables existent mais sont vides

**Utiliser le bouton "Initialiser les valeurs par défaut"** dans l'interface :
- Aller sur `http://localhost:5180/app/settings/events`
- Descendre jusqu'à la section "Configuration des scènes"
- Cliquer sur le bouton bleu "Initialiser les valeurs par défaut"
- Vérifier les logs dans la console

**Ou exécuter manuellement** :
```sql
-- Récupérer votre company_id
SELECT id, name FROM public.companies;

-- Initialiser pour cette company
SELECT initialize_stage_enums_for_company('<YOUR_COMPANY_ID>');

-- Vérifier que les données sont créées
SELECT COUNT(*) FROM public.stage_types WHERE company_id = '<YOUR_COMPANY_ID>';
SELECT COUNT(*) FROM public.stage_specificities WHERE company_id = '<YOUR_COMPANY_ID>';
```

---

### 5. Si erreur RLS (Row Level Security)

**Vérifier les policies** :
```sql
SELECT * FROM pg_policies 
WHERE tablename IN ('stage_types', 'stage_specificities');
```

**Si aucune policy n'existe, désactiver temporairement RLS** :
```sql
ALTER TABLE public.stage_types DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.stage_specificities DISABLE ROW LEVEL SECURITY;
```

**Ou créer des policies permissives** :
```sql
-- Policy pour stage_types
CREATE POLICY "Allow all for stage_types" 
ON public.stage_types 
FOR ALL 
USING (true) 
WITH CHECK (true);

-- Policy pour stage_specificities
CREATE POLICY "Allow all for stage_specificities" 
ON public.stage_specificities 
FOR ALL 
USING (true) 
WITH CHECK (true);
```

---

## 🎯 Checklist de résolution

- [ ] **Étape 1** : Ouvrir la console du navigateur (F12)
- [ ] **Étape 2** : Recharger la page `/app/settings/events`
- [ ] **Étape 3** : Chercher les logs `🔍 StageEnumsManager` dans la console
- [ ] **Étape 4** : Noter le `company_id` affiché
- [ ] **Étape 5** : Exécuter `sql/check_stage_enums_tables.sql` dans Supabase
- [ ] **Étape 6** : Si les tables n'existent pas → Exécuter les scripts SQL
- [ ] **Étape 7** : Si les tables sont vides → Cliquer sur "Initialiser" ou exécuter `SELECT initialize_stage_enums_for_company()`
- [ ] **Étape 8** : Recharger la page et vérifier les containers

---

## 📊 Données par défaut attendues

### Types de scènes (8)
1. main → Principale
2. secondary → Secondaire
3. club → Club
4. outdoor → Extérieur
5. tent → Chapiteau
6. workshop → Atelier
7. vip → VIP
8. other → Autre

### Spécificités (7)
1. covered → Couvert
2. open_air → Plein air
3. indoor → Intérieur
4. mobile → Mobile
5. permanent → Permanent
6. acoustic → Acoustique
7. electric → Électrique

---

## 🚨 Erreurs courantes

### Erreur : "relation stage_types does not exist"
**Solution** : Exécuter `sql/create_stage_enums_and_modify_table.sql`

### Erreur : "there is no unique or exclusion constraint"
**Solution** : Exécuter `sql/fix_stage_enums_unique_constraint.sql`

### Erreur : "permission denied for table stage_types"
**Solution** : Vérifier les policies RLS ou désactiver RLS temporairement

### Les données n'apparaissent pas mais pas d'erreur
**Solution** : Vérifier que `company_id` est correct dans les logs, puis réinitialiser

---

## 📝 Commandes rapides

```sql
-- Tout-en-un : Vérifier et afficher les données
SELECT 
    'Types de scènes' as category,
    COUNT(*) as total,
    company_id
FROM public.stage_types
GROUP BY company_id
UNION ALL
SELECT 
    'Spécificités' as category,
    COUNT(*) as total,
    company_id
FROM public.stage_specificities
GROUP BY company_id;

-- Voir toutes les données pour une company
SELECT 'TYPE' as type, id, value, label, display_order 
FROM public.stage_types 
WHERE company_id = '<YOUR_COMPANY_ID>'
UNION ALL
SELECT 'SPEC' as type, id, value, label, display_order 
FROM public.stage_specificities 
WHERE company_id = '<YOUR_COMPANY_ID>'
ORDER BY type, display_order;
```

---

**Date** : 28 octobre 2025  
**Fichiers de diagnostic** : 
- `sql/check_stage_enums_tables.sql`
- `sql/create_stage_enums_and_modify_table.sql`
- `sql/fix_stage_enums_unique_constraint.sql`


