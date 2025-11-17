@echo off
echo ================================================
echo TEST SYSTÈME DE GESTION D'ÉVÈNEMENTS
echo ================================================
echo.

echo 📋 Fichiers créés/modifiés:
echo.
echo ✅ src/utils/slug.ts
echo ✅ src/api/eventsApi.ts
echo ✅ src/features/settings/events/EventQuickAddModal.tsx
echo ✅ src/features/settings/events/EventForm.tsx
echo ✅ src/pages/settings/SettingsEventsPage.tsx
echo ✅ TEST_EVENTS_SYSTEM.md (ce guide)
echo.

echo ================================================
echo TESTS À EXÉCUTER
echo ================================================
echo.

echo 🔹 Test 1: Création rapide
echo    1. Ouvrir http://localhost:5180/app
echo    2. Cliquer sur "Nouveau" dans le sélecteur d'évènements (header)
echo    3. Créer "Demo 2026" (dates: 2026-08-15 à 2026-08-16)
echo    4. Vérifier: toast succès + sélection automatique
echo.

echo 🔹 Test 2: Création avancée
echo    1. Aller dans /app/settings/events
echo    2. Cliquer sur "Ajouter un évènement"
echo    3. Remplir:
echo       - Nom: "Festival Test 2026"
echo       - Dates: 2026-08-15 à 2026-08-17
echo       - Couleur: Rouge
echo       - Jours: 2 jours (11:00-02:00, 11:00-01:00)
echo       - Scènes: "Main Stage" 12000, "Club Stage" 2500
echo    4. Enregistrer
echo    5. Vérifier: tables events, event_days, event_stages
echo.

echo 🔹 Test 3: Édition
echo    1. Cliquer sur "Éditer" sur un évènement
echo    2. Modifier couleur + ajouter une scène
echo    3. Enregistrer
echo    4. Vérifier: mise à jour DB + store
echo.

echo 🔹 Test 4: Suppression
echo    1. Cliquer sur l'icône poubelle
echo    2. Confirmer
echo    3. Vérifier: évènement supprimé + liste rechargée
echo.

echo 🔹 Test 5: Règle minuit
echo    1. Créer un jour avec close_at (02:00) ^< open_at (11:00)
echo    2. Vérifier: pas d'erreur de validation
echo    3. Helper text visible
echo.

echo 🔹 Test 6: CompanyId manquant
echo    1. Supprimer company_id de localStorage
echo    2. Tenter de créer un évènement
echo    3. Vérifier: toast d'erreur "Sélectionnez une entreprise"
echo.

echo 🔹 Test 7: Évènement actuel
echo    1. Sélectionner un évènement via EventSelector
echo    2. Aller dans /app/settings/events
echo    3. Vérifier: Card en haut avec badge "Évènement actuel"
echo.

echo ================================================
echo VÉRIFICATIONS TECHNIQUES
echo ================================================
echo.

echo 🔸 TypeScript:
echo    npx tsc --noEmit
echo.

echo 🔸 Structure DB:
echo    SELECT * FROM events;
echo    SELECT * FROM event_days ORDER BY event_id, display_order;
echo    SELECT * FROM event_stages ORDER BY event_id, display_order;
echo.

echo 🔸 LocalStorage:
echo    - selected_event_id
echo    - company_id
echo.

echo 🔸 Store (Zustand):
echo    - useEventStore().currentEvent
echo    - useEventStore().setCurrentEvent()
echo.

echo ================================================
echo COMMANDES UTILES
echo ================================================
echo.

echo npm run dev          : Démarrer le serveur
echo npm run build        : Build production
echo npx tsc --noEmit     : Vérifier TypeScript
echo.

echo ================================================
echo URLs
echo ================================================
echo.

echo 🌐 App:              http://localhost:5180/app
echo 🌐 Settings Events:  http://localhost:5180/app/settings/events
echo 🌐 Settings:         http://localhost:5180/app/settings
echo.

echo ================================================
echo NOTES IMPORTANTES
echo ================================================
echo.

echo 📌 Règle "après minuit":
echo    Un concert à 00:15 le 16 août reste rattaché au jour du 15 août
echo    via event_day_id. Pas de décalage de date dans artist_performances.
echo.

echo 📌 Multi-tenant:
echo    Tous les évènements sont liés à un company_id.
echo    Vérifier que useEventStore() ou localStorage contient le company_id.
echo.

echo 📌 Slug:
echo    Si RPC generate_slug n'existe pas, fallback sur slugify() client.
echo.

echo 📌 Replace vs Update:
echo    - replaceEventDays: DELETE + INSERT (tous les jours)
echo    - replaceEventStages: DELETE + INSERT (toutes les scènes)
echo    - Évite les doublons et synchronise display_order
echo.

echo ================================================
echo CHECKLIST FINALE
echo ================================================
echo.

echo [ ] Test 1: Création rapide
echo [ ] Test 2: Création avancée
echo [ ] Test 3: Édition
echo [ ] Test 4: Suppression
echo [ ] Test 5: Règle minuit
echo [ ] Test 6: CompanyId manquant
echo [ ] Test 7: Évènement actuel
echo [ ] TypeScript OK
echo [ ] DB OK
echo [ ] Dark/Light mode OK
echo [ ] Toasts OK
echo.

echo ================================================
echo READY TO TEST!
echo ================================================
echo.
echo Ouvrez http://localhost:5180/app et commencez les tests.
echo Consultez TEST_EVENTS_SYSTEM.md pour plus de détails.
echo.

pause
