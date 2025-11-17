#!/bin/bash

# Script d'audit d'uniformité du design system AURA
# Usage: ./audit-uniformite.sh [chemin_optionnel]

echo "🔍 === AUDIT D'UNIFORMITÉ DESIGN SYSTEM AURA ==="
echo ""

TARGET_PATH="${1:-src/pages}"

echo "📂 Analyse du répertoire: $TARGET_PATH"
echo ""

# 1. Icônes non standard
echo "❌ === ICÔNES NON STANDARD ==="
echo ""
echo "🔸 Edit au lieu de Edit2:"
grep -rn "import.*\bEdit\b" "$TARGET_PATH" --include="*.tsx" --include="*.ts" | grep -v "Edit2" || echo "  ✅ Aucun"
echo ""

echo "🔸 Trash au lieu de Trash2:"
grep -rn "import.*\bTrash\b" "$TARGET_PATH" --include="*.tsx" --include="*.ts" | grep -v "Trash2" || echo "  ✅ Aucun"
echo ""

echo "🔸 PlusCircle au lieu de Plus:"
grep -rn "PlusCircle" "$TARGET_PATH" --include="*.tsx" --include="*.ts" || echo "  ✅ Aucun"
echo ""

# 2. window.confirm
echo "❌ === WINDOW.CONFIRM (utiliser ConfirmDialog) ==="
grep -rn "window\.confirm\|[^/]confirm(" "$TARGET_PATH" --include="*.tsx" --include="*.ts" | grep -v "Confirm" || echo "  ✅ Aucun"
echo ""

# 3. Icônes mal placées (dans children au lieu de leftIcon)
echo "❌ === ICÔNES MAL PLACÉES (utiliser leftIcon) ==="
echo ""
echo "🔸 Plus avec className:"
grep -rn "<Plus.*className.*mr" "$TARGET_PATH" --include="*.tsx" || echo "  ✅ Aucun"
echo ""

echo "🔸 Edit2 avec className:"
grep -rn "<Edit2.*className.*mr" "$TARGET_PATH" --include="*.tsx" || echo "  ✅ Aucun"
echo ""

echo "🔸 Trash2 avec className:"
grep -rn "<Trash2.*className.*mr" "$TARGET_PATH" --include="*.tsx" || echo "  ✅ Aucun"
echo ""

# 4. Hovers non standard
echo "❌ === HOVERS NON STANDARD (utiliser var(--color-hover-row)) ==="
grep -rn "hover:bg-gray-50\|hover:bg-gray-750" "$TARGET_PATH" --include="*.tsx" | head -10 || echo "  ✅ Aucun"
echo ""

# 5. Boutons avec variant="primary" explicite (inutile)
echo "⚠️  === VARIANT PRIMARY EXPLICITE (redondant) ==="
grep -rn 'variant="primary"' "$TARGET_PATH" --include="*.tsx" | head -10 || echo "  ✅ Aucun"
echo ""

# Résumé
echo "📊 === RÉSUMÉ ==="
echo ""

EDIT_COUNT=$(grep -r "import.*\bEdit\b" "$TARGET_PATH" --include="*.tsx" 2>/dev/null | grep -v "Edit2" | wc -l)
TRASH_COUNT=$(grep -r "import.*\bTrash\b" "$TARGET_PATH" --include="*.tsx" 2>/dev/null | grep -v "Trash2" | wc -l)
PLUS_CIRCLE_COUNT=$(grep -r "PlusCircle" "$TARGET_PATH" --include="*.tsx" 2>/dev/null | wc -l)
CONFIRM_COUNT=$(grep -r "window\.confirm\|[^/]confirm(" "$TARGET_PATH" --include="*.tsx" 2>/dev/null | grep -v "Confirm" | wc -l)

echo "Icônes Edit (devrait être Edit2): $EDIT_COUNT"
echo "Icônes Trash (devrait être Trash2): $TRASH_COUNT"
echo "Icônes PlusCircle (devrait être Plus): $PLUS_COUNT"
echo "window.confirm (devrait être ConfirmDialog): $CONFIRM_COUNT"
echo ""

if [ $((EDIT_COUNT + TRASH_COUNT + PLUS_CIRCLE_COUNT + CONFIRM_COUNT)) -eq 0 ]; then
  echo "✅ Toutes les pages respectent les standards !"
else
  echo "⚠️  Certaines pages nécessitent une mise à jour"
  echo ""
  echo "📚 Consultez MIGRATION_GUIDE_UNIFORMITE.md pour les corrections"
fi

echo ""
echo "🎨 Design System AURA - Audit terminé"










