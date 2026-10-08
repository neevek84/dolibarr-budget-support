# CHANGELOG MODULE BUDGET FOR [DOLIBARR ERP CRM](https://www.dolibarr.org)

## [1.3.1] - 2026-10-08

### ✨ NOUVEAU

**Paiements divers (Banque > Paiements divers) dans les Revenus et les Dépenses**
- Nouvelle méthode `BudgetReal::getVariousPaymentsDetails($month, $year, $sens)` — lit `llx_payment_various` (sens `1` = crédit → revenu, sens `0` = débit → dépense), slottés sur leur date de paiement (`datep`), regroupés par compte comptable (`accountancy_code`, libellé résolu sur le plan comptable actif `CHARTOFACCOUNTS`).
- **Réalisé** : les crédits sont ajoutés au « payé » de `getRevenueActual()` et les débits au « payé » de `getExpenseActual()` (clés `various` / `various_details` exposées en plus). Comparaison budget/réalisé, impression, évolution du forecast, suivi YTD et snapshots les intègrent donc automatiquement.
- **Forecast** : nouveau bloc repliable « Paiements divers » dans la section Revenus et dans la section Dépenses (compte comptable → paiements, lien vers la fiche du paiement divers), intégré aux totaux de section et à la ligne Solde.
- **Impression / PDF** : ligne « Paiements divers » côté revenus et côté dépenses, incluse dans les totaux et le résultat net.
- **Exports CSV / Excel / XML** : lignes `revenue_various` / `expense_various` (nœuds XML `various_payments`), incluses dans les totaux et le résultat net.
- **Clonage « Reprendre les données réalisées »** : une ligne budgétaire par compte comptable de paiements divers (revenu et dépense), rattachée au compte comptable quand il existe dans le plan actif.

### ℹ️ À SAVOIR
- Un paiement divers n'a ni tiers ni statut : il est considéré comme réglé dès sa saisie, et son montant est pris tel que saisi (pas de ventilation HT/TVA).
- Le filtre Forecast par tiers/fournisseur ne s'applique pas aux paiements divers (comme pour Engagé/Récurrent) — le bandeau d'avertissement le mentionne.
- Aucune migration SQL : simple remplacement des fichiers.

## [1.3.0] - 2026-08-25

### ✨ NOUVEAU

**Budgets liés à un projet + partage explicite**
- Un budget peut désormais être lié à un projet Dolibarr (`fk_projet`, optionnel, modifiable à la création et à l'édition).
- Vraie restriction d'accès : un budget lié à un projet n'est visible que de son créateur, des utilisateurs partagés explicitement (`llx_budget_share`), des titulaires du nouveau droit `budget->readall`, ou de tous si le budget est public (`is_public` prime toujours).
- UI de partage pré-remplie depuis les contacts internes du projet lié (nom + rôle), librement modifiable, y compris pour partager hors de l'équipe projet.
- La vérification est appliquée à la fois dans la liste des budgets et à l'ouverture directe par id — pas seulement un filtre d'affichage.

**Filtre Forecast par tiers/fournisseur (Issue #8)**
- `budget_forecast.php` propose désormais un filtre par tiers (revenus) et par fournisseur (dépenses), avec option "voir les lignes sans tiers/fournisseur".
- Reprend la logique fonctionnelle d'une branche abandonnée (`feature/forecast-filtered`), réimplémentée proprement sur le fichier actuel plutôt qu'en fork.
- ⚠️ Limitation assumée : le filtre s'applique aux blocs « Dépenses réalisées » et Revenus (Payé / En attente / Signé). Les blocs **Engagé** et **Récurrent** ainsi que la ligne **Solde** restent calculés sur l'ensemble des données ; un bandeau d'avertissement le signale explicitement dès qu'un filtre est actif.

**Recette / migration**
- ⚠️ **Réactivation du module obligatoire** : après remplacement des fichiers, il faut **désactiver puis réactiver** le module Budget pour que `sql/upgrade_to_1.3.0.sql` s'exécute. Sans cette étape, la colonne `llx_budget_main.fk_projet` et la table `llx_budget_share` n'existent pas, et **toute création de budget échoue** (`Unknown column 'fk_projet'` sur l'INSERT de `BudgetMain::create()`).
- Migration : `upgrade_to_1.3.0.sql` est idempotent (`ADD COLUMN IF NOT EXISTS` / `CREATE TABLE IF NOT EXISTS`) et ne touche pas aux données existantes ; les budgets déjà en base restent sans projet lié et visibles exactement comme avant.
- Installation fraîche : two-pass loading (`llx_budget_share.sql` puis `.key.sql`) selon convention Dolibarr.

## [1.2.1] - 2026-08-18

### 🐛 CORRECTIFS

- **Avoirs clients invisibles dans le réalisé** : `printMonthCellsWithTotal()` masquait tout montant non strictement `> 0.01`, ce qui traitait silencieusement un avoir (montant négatif chez Dolibarr) comme nul — la ligne apparaissait dans la liste sans son montant, et sans réduire le total affiché. Condition changée pour `abs($amount) > 0.01` (lib/budget.lib.php).
- **Même correctif appliqué aux totaux « Revenus signés »** (client/commande) dans budget_forecast.php, par cohérence défensive.
- **Emprunts non payés absents du réalisé** : `getExpenseActual()` ne comptabilisait que les échéances de prêt **payées**. Ajout d'une requête symétrique « non payées et échues » sur `llx_loan_schedule` (bornée à `datep <= NOW()` pour ne pas faire doublon avec la projection P3 des échéances futures).
- **Clonage de budget cassé** : le handler de clonage réellement branché à l'UI (`budget_card.php`) assignait des propriétés inexistantes sur `BudgetLine` (`fk_budget`, `fk_category`, `fk_account` au lieu de `fk_budget_main`, `revenue_type`, `fk_accounting_account`), produisant des lignes mal rattachées. Corrigé en consolidant sur `BudgetMain::duplicate()` (seule implémentation, désormais correcte et complète) ; la route morte `budgetindex.php?action=duplicate` (jamais atteignable depuis l'UI) est supprimée.

### ✨ NOUVEAU

**Refonte du clonage de budget**
- La popup de clonage (icône/bouton, `budget_card.php` et `budgetindex.php`) propose désormais un choix explicite : **« Reprendre le dernier budget »** (copie budget + forecast du budget source, comportement historique corrigé) ou **« Reprendre les données réalisées »** (reconstruit les lignes du nouveau budget depuis le réalisé constaté sur la période source — une ligne par compte comptable côté dépenses, par tiers côté revenus).
- La période du nouveau budget est proposée par défaut décalée d'un exercice (N+1), éditable avant validation ; aucun garde-fou anti-doublon de période (plusieurs budgets sur le même exercice restent possibles, usage volontaire).

**P9 — Contrats fournisseurs récurrents / abonnements**
- Nouvelle méthode `BudgetReal::getRecurringContractsDetails()` — projette les lignes de contrats fournisseurs actives (`llx_contratdet.statut = 4`, module Contrat) dont le tiers a le flag `fournisseur = 1`.
- Le `total_ht` de la ligne est traité comme un prix mensuel récurrent, appliqué chaque mois entre la date d'ouverture et la date de fin de validité (indéfiniment si pas de date de fin).
- Override manuel supporté via `BudgetExpenseOverride::SOURCE_CONTRACT` (nouvelle constante ; correctif de la whitelist `$valid_sources` dans budget_forecast.php qui l'aurait sinon silencieusement rejeté).
- Intégré à la section « Récurrent » de budget_forecast.php (total combiné dépenses, sous-section collapsible, ligne de solde).

## [1.2.0] - 2026-05-21

### 💰 FORECAST DÉPENSES ÉLARGI (Epic #36)

Couverture complète des flux sortants côté forecast, en miroir de la section Revenus. La section « Dépenses » distingue désormais Forecast manuel, Engagé, Récurrent (parent collapsible groupant 4 catégories) et Dépenses réalisées.

**P1 — Engagé (Issue #28)**
- Nouvelle méthode `BudgetReal::getEngagedSupplierOrdersDetails()` — commandes fournisseurs validées (`fk_statut IN (1,2,3)`) non encore facturées, lissées via `calculateLissedAmount()` sur `date_livraison` (fallback `date_commande`).
- Règle du « à cheval sur 2 exercices » : lissage sur la durée réelle complète, non bornée à l'exercice.
- Date dépassée → mois courant + pastille rouge ⚠️.
- Aucune date utilisable → mois courant + pastille orange (point de vigilance).
- Reste-à-facturer via `element_element` (sourcetype=`order_supplier`, targettype=`invoice_supplier`).

**P2 — Factures fournisseurs récurrentes (Issue #29)**
- Nouvelle méthode `BudgetReal::getRecurringSupplierInvoicesDetails()` — projection des templates `llx_facture_fourn_rec` (suspended=0, frequency>0).
- Itère les occurrences depuis `date_when` selon `frequency` + `unit_frequency` ('d'/'m'/'y'), arrêt sur `nb_gen_max`.
- Plusieurs occurrences dans le même mois → cumulées.

**P3 — Emprunts (Issue #30)**
- Nouvelle méthode `BudgetReal::getRecurringLoansDetails()` — échéances futures non payées (`llx_loan_schedule` joint à `llx_loan`).
- Conditionnel sur `isModEnabled('loan')`.
- Échéances passées : captées en réel via `payment_loan` (nouvelle ligne dans `getExpenseActual`).

**P4 — Charges sociales (Issue #31)**
- Nouvelle méthode `BudgetReal::getRecurringChargesDetails()` — `llx_chargesociales` (`paye=0`) projetées sur `date_ech`.
- Charges sans `date_ech` → mois courant + pastille « date à confirmer ».
- Charges passées payées : captées en réel via `paiementcharge`.

**P5 — Salaires projetés (Issue #32)**
- Nouvelle méthode `BudgetReal::getRecurringSalariesDetails()` — heuristique « moyenne N-3 mois clos » par `fk_user`.
- Anti-doublon : si un salaire réel existe pour `(fk_user, year, month)`, la projection est masquée pour ce mois.
- Salaires passés : captés en réel via `payment_salary` + `salary` unpaid.

**P6 — Table d'override unifiée (Issue #33)**
- Nouvelle table `llx_budget_expense_overrides` (entity, fk_budget_main, source, fk_source, year, month, amount, mode).
- `source` ∈ {`engaged`, `rec_invoice`, `loan`, `charge`, `salary`}.
- 3 modes : `auto`, `manual`, `excluded`.
- Helper statique `BudgetExpenseOverride` : `fetch()`, `apply()`, `save()`, `reset()`.
- Cascade-purge dans `BudgetMain::delete()`.
- SQL d'installation `sql/llx_budget_expense_overrides.sql` + `.key.sql` (FK vers `budget_main` ON DELETE CASCADE).
- SQL de migration `sql/upgrade_to_1.2.0.sql` (idempotent).

**P7 — Refonte UI Dépenses + override manuel (Issue #34)**
- Nouveau parent collapsible « Récurrent » groupant les 4 sous-blocs P2-P5, indentation hiérarchique cohérente.
- Crayon d'override sur chaque cellule mois éditable des projections (Engagé + Récurrent).
- Modal `expenseOverrideModal` (mono-mois) : sélecteur Auto/Manuel/Exclure + champ montant.
- Action handler `save_expense_override`, validation par constantes de classe.
- Helpers de rendu factorés dans `lib/budget.lib.php` : `budgetRenderExpenseProjectionBlock()` + `budgetAggregateExpenseProjection()`.

**Extension transverse `getExpenseActual()`**
- Captures réelles ajoutées pour : `payment_salary` + `salary` unpaid, `payment_expensereport` + `expensereport` unpaid, `paiementcharge` + `chargesociales` unpaid, `payment_loan` (conditionnel sur module loan).
- Signature inchangée → tous les callers existants (budget_compare, budget_print, budget_forecast_evolution, budget_snapshot, cron mensuel) bénéficient automatiquement.

**Décisions de cadrage actées**
- ✅ Salaires : pattern N-3 mois suffit comme forecast (pas de table de récurrence dédiée).
- ✅ Commande fourn sans date utilisable : mois courant + point de vigilance.
- ✅ Lissage commandes fourn : durée réelle complète, à cheval sur exercices.
- ✅ Module Loan : sous-section conditionnée à `isModEnabled('loan')`.
- ✅ Anti-doublon salaires : réel masque la projection.
- ✅ i18n : parité fr/en, toutes les chaînes via `$langs->trans()`.

**Recette / migration**
- Nouvelle [RECETTE.md](RECETTE.md) — scénarios par phase + tests d'installation + tests de migration depuis 1.1.10.
- Migration : `upgrade_to_1.2.0.sql` crée la table sans toucher aux données existantes.
- Installation fraîche : two-pass loading (`.sql` puis `.key.sql`) selon convention Dolibarr.

## [1.1.10] - 2026-04-24

### 🗃️ ARCHIVAGE DES BUDGETS (Issue #8 dérivée, PR #24)

**Liste des budgets — section archivée :**
- 📂 **Deux tableaux** dans l'onglet « Liste » : Budgets actifs (en haut) + Budgets archivés (section repliable en bas, compteur)
- 🏷️ **4e état de badge** : « Archivé » (violet) — unifié pour les archivés manuels et les budgets à période terminée
- 📦 **Icône Archiver** sur chaque budget actif (form POST + token CSRF)
- 📥 **Icône Désarchiver** sur les archivés manuels uniquement
- 🗑️ **Icône Purger** définitivement — supprime le budget + toutes ses données liées (lignes, montants, forecasts, snapshots, overrides) en transaction cascade avec confirmation JS
- Boutons Archiver / Désarchiver également accessibles depuis l'onglet Information de la fiche budget

**Règle hybride actifs/archivés :**
- Actifs = `status = 1` ET période non terminée
- Archivés = `status = 0` (manuel) OU période terminée (`today > year_end/month_end`)

**Lecture seule pour budgets archivés/terminés :**
- Bandeau d'information en tête de fiche, Budget & Baseline, Forecast, Évolution Forecast
- Tous les boutons d'écriture (Save / Add / Edit / Delete ligne) désactivés — les exports PDF/CSV/Excel/XML restent accessibles
- Rejet côté serveur de toute action POST via `$permissiontoadd = false`
- Bouton « Désarchiver pour modifier » dans le bandeau (si archivé manuellement)

**Cron mensuel inchangé :** `scripts/cron_budget_snapshot.php` filtrait déjà `WHERE status = 1` et skippait les budgets hors période. Les budgets archivés ou terminés sont automatiquement exclus des snapshots mensuels.

### 📐 BUDGETS À PÉRIODE VARIABLE (Issue #25, PR #26)

Les vues affichaient systématiquement 12 colonnes même pour des budgets plus courts (ex : Dec 2025 → Mars 2026 = 4 mois), avec saisie possible hors période.

- **Nouveau helper `budgetGetPeriodMonths($budget, $filter)`** centralisé dans `lib/budget.lib.php`. Retourne `{month, year, yyyymm, index, status}` sur la durée réelle. Filtres : `full`, `past`, `past_and_current`, `future`, `current_and_future`.
- **Toutes les vues migrées** : Forecast, Budget & Baseline, Comparer, Évolution Forecast, Print, Export (CSV/Excel/XML), ainsi que `BudgetMain::duplicate()`
- Les classes purement calendaires (`BudgetReal`, `BudgetSnapshot`) gardent leurs boucles 12 mois (fonctionnelles par nature — année calendaire complète)

### 🔮 FOCUS SUR LE FUTUR — TOGGLE « À PARTIR DU MOIS EN COURS » (Issue #22, PR #27)

Un module de forecast vise le futur éditable : le toggle masque les mois échus pour concentrer la saisie.

- Toggle visible sur Forecast, Budget & Baseline, Comparer — **pas sur Évolution Forecast** (vue historique par nature)
- Choix persisté en session (`$_SESSION['budget_view_mode']`), cohérent entre onglets
- Valeurs : `full` (défaut) ou `current_and_future`
- Les pages d'impression/export restent toujours sur la période complète

### 🔒 SÉCURITÉ & ROBUSTESSE

- **CSRF** : les actions archive / unarchive / purge ne sont plus déclenchables via GET (lien). Formulaires POST + token obligatoire, rejet `HTTP 405` si la méthode n'est pas POST.
- **`BudgetMain::delete()`** : wrapping `try/catch` + `dol_syslog(..., LOG_ERR)` sur chaque échec SQL. Log `LOG_INFO` en cas de cascade réussie, facilite le diagnostic post-incident.
- **`budget_forecast.php` handler override** : remplace `isset($_POST[...])` par `GETPOST(...)` pour garantir la sanitization standard Dolibarr.
- **`BudgetMain::duplicate()`** : suffixe « (Copie) » → `' (' . $langs->trans('Clone') . ')'` — plus de texte français en dur dans une classe censément i18n.

### 🎨 CSS / CSP

Nouvelles classes dans `css/budget.css.php` pour remplacer les `style="..."` inline (violation CSP potentielle) :
- `.budget-icon-button` + `.budget-icon-button--danger` : boutons d'action inline dans la liste
- `.js-inline-action-form` : forms POST inline
- `.budget-banner-readonly` + `.budget-banner-icon` + `.budget-banner-form` : bandeau lecture seule
- `.budget-view-mode-toggle` + `.button-toggle-active` : toggle période

### 🔧 TECHNIQUE

- **Migration SQL `upgrade_to_1.1.10.sql`** défensive : `ALTER TABLE ... ADD COLUMN IF NOT EXISTS status` + trigger conditionnel via `INFORMATION_SCHEMA` dans `modBudget.class.php`
- **Helpers** dans `lib/budget.lib.php` : `budgetGetPeriodMonths()`, `budgetRenderArchivedBanner()`, `budgetAssertWritable()`, `budgetResolveViewMode()`, `budgetRenderViewModeToggle()`
- **JS externe `js/budget_index.js`** (CSP-safe) pour toggle section archivée + confirmation JS avant purge
- **21 clés de traduction** ajoutées (FR + EN) : 18 archive + 3 view-mode

### 📦 FICHIERS MODIFIÉS

| Fichier | Changement |
|---------|-----------|
| `sql/upgrade_to_1.1.10.sql` | Nouveau — garantit la colonne `status` sur `llx_budget_main` |
| `class/budgetmain.class.php` | `$status`, `archive/unarchive/isArchived/isTerminated/isReadOnly`, `delete()` cascade + try/catch, `duplicate()` i18n |
| `budgetindex.php` | Deux tableaux, actions archive/unarchive/purge **POST**, badge archivé |
| `lib/budget.lib.php` | Helpers période, banner, toggle, assert writable |
| `budget_forecast.php` | Migration mois variable + toggle + read-only + `GETPOST` overrides |
| `budget_edit.php` | Migration mois variable + toggle + read-only |
| `budget_compare.php` | Migration mois variable + toggle |
| `budget_forecast_evolution.php` | Migration mois variable + read-only (pas de toggle) |
| `budget_card.php` | Read-only + boutons archive/unarchive **POST** |
| `budget_print.php`, `budget_export_download.php` | Migration mois variable |
| `css/budget.css.php` | Classes pour icônes + bandeau + toggle (CSP-safe) |
| `js/budget_index.js` | Nouveau — toggle + confirmation purge CSP-safe |
| `langs/fr_FR/budget.lang`, `langs/en_US/budget.lang` | +21 clés |
| `core/modules/modBudget.class.php` | Migration 1.1.10 + version → 1.1.10 |

---

## [1.1.9] - 2026-04-23

### ✨ ÉVOLUTION

**Liste des budgets enrichie :**
- 📅 **Colonne Début** : date de début de période (1er jour du mois/année de début)
- 📅 **Colonne Fin** : date de fin de période (dernier jour du mois/année de fin)
- 🏷️ **Colonne Statut** : badge coloré calculé dynamiquement selon la date du jour
  - **À venir** (gris) : période pas encore commencée
  - **En cours** (orange) : période en cours
  - **Terminé** (vert) : période échue
- ✅ Aucun changement de schéma — statut dérivé des champs `year_start` / `month_start` / `year_end` / `month_end`

### 🐛 CORRECTIONS

**Suppression de ligne forecast :**
- 🔧 Le bouton « Supprimer » dans la modale d'édition de ligne ne fonctionnait plus depuis le refactor CSP (action JS `deleteline` envoyée alors que le handler PHP attendait `confirm_delete_line`)
- ✅ Action alignée + confirmation restaurée avant suppression (CSP-safe via attribut `data-confirm`)

**Problèmes en production (ajout de ligne forecast) :**
- 🔧 Cache-busting étendu à `budget_forecast_core.js` et `budget_table_state.js` via `filemtime()` — invalide automatiquement le cache navigateur à chaque modification de fichier
- ✅ Corrige les erreurs « `line_type est vide` » et le bouton « Dupliquer la première valeur » qui effaçait la ligne : ces bugs venaient d'un ancien JS servi depuis le cache navigateur après déploiement

**Nettoyage onglet Forecast (Filtres) :**
- 🗑️ L'onglet « Forecast (Filtres) » pointait vers un fichier supprimé (`budget_forecast_filtered.php` retiré en 927aa85 mais l'onglet oublié dans `lib/budget.lib.php`) → l'onglet est retiré de main, le dev continue sur la branche `feature/forecast-filtered` (Issue #8 WIP)

### 📦 FICHIERS MODIFIÉS

| Fichier | Changement |
|---------|-----------|
| `budgetindex.php` | 3 nouvelles colonnes : Début / Fin / Statut |
| `budget_forecast.php` | Cache-busting JS + `data-confirm` bouton Supprimer |
| `js/budget_forecast_core.js` | Action `confirm_delete_line` + confirmation restaurée |
| `lib/budget.lib.php` | Suppression onglet « Forecast (Filtres) » |
| `langs/fr_FR/budget.lang`, `langs/en_US/budget.lang` | 4 clés (BudgetStart/End/Status/Completed), nettoyage 11 clés Filters/* |
| `core/modules/modBudget.class.php` | version → 1.1.9 |

---

## [1.1.8] - 2026-04-21

### ✨ EXPORTS PDF / CSV / EXCEL / XML

**Export PDF toutes vues (Issue #21) :**
- 🖨️ **budget_print.php** : vue imprimable optimisée pour Forecast, Comparer et Budget & Baseline
- 🖨️ **budget_ytd_print.php** : page d'impression dédiée format A4 pour le Rapport YTD
- 📄 Boutons "Exporter PDF" disponibles dans toutes les vues principales
- 🎨 Compatible impression navigateur (Cmd+P → Enregistrer en PDF)
- 💱 Respect de l'échelle monétaire sélectionnée (€, K€, M€)
- 📊 Hiérarchie détaillée avec expand/collapse (signé/payé/en attente)

**Exports CSV / Excel / XML :**
- 📊 Export CSV, Excel (XLSX) et XML disponibles sur toutes les vues
- 🔍 Les filtres actifs (tiers, fournisseur, période) sont respectés dans les exports
- 📁 **budget_export_download.php** : page dédiée avec options de configuration
- 🔤 Encodage UTF-8 correct (accents et caractères spéciaux)

### 🐛 CORRECTIONS

**Corrections feedback utilisateur (février 2026) :**
- ✅ **Override supprimé encore visible** : une ligne supprimée dans le forecast (override) n'apparaît plus dans l'onglet "Comparer"
- ✅ **Conservation du repli** : les lignes ne se replient plus lors d'une modification ou d'un ajout (budget_table_state.js)
- ✅ **Préfixe DB personnalisé** : `class/budgetmain.class.php` utilise désormais `MAIN_DB_PREFIX` — corrige l'erreur de création de budget sur les installations avec préfixe non-standard (ex. `llxjo_`)
- ✅ **Réinitialisation des tables** : `admin/reset_tables.php` incluait `budget_forecast_overrides` dans la liste de suppression — corrige l'erreur de contrainte FK lors du reset
- ✅ **Dictionnaire types de revenus** : requête SQL utilise désormais `MAIN_DB_PREFIX` (compatible préfixe non-standard)

### 🔧 TECHNIQUE

**Amélioration `_load_tables()` :**
- ✅ Exécution en 2 passes : tables d'abord, contraintes FK ensuite
- ✅ Scripts `upgrade_*.sql` exclus de l'initialisation initiale
- ✅ Compatible toutes versions Dolibarr (19 → 22+)

### 📦 FICHIERS MODIFIÉS

| Fichier | Changement |
|---------|-----------|
| `budget_print.php` | Export PDF Forecast / Comparer / Budget & Baseline |
| `budget_ytd_print.php` | Export PDF rapport YTD format A4 |
| `budget_export_download.php` | Exports CSV / Excel / XML avec filtres |
| `class/budgetmain.class.php` | MAIN_DB_PREFIX pour compatibilité préfixe DB |
| `admin/reset_tables.php` | Ajout budget_forecast_overrides dans DROP |
| `core/modules/modBudget.class.php` | MAIN_DB_PREFIX dictionnaire + _load_tables() 2 passes |
| `js/budget_table_state.js` | Persistance état expand/collapse |

---

## [1.1.7] - 2026-01-16

### ✨ HARMONISATION VUE BUDGET & FORECAST

**Regroupement hiérarchique par tiers/fournisseurs (Issue #14) :**
- 🔄 **Structure à 3 niveaux** : Type → Tiers/Fournisseur → Lignes détail
- ❌ **Supprimé** : niveau "Catégorie comptable" (simplifié)
- 👥 **Revenus** : regroupement par tiers (client)
- 🏪 **Dépenses** : regroupement par fournisseur
- 🎯 Application des **seuils configurables "Autres"**
  - `BUDGET_SMALL_REVENUE_THRESHOLD` (défaut: 500€)
  - `BUDGET_SMALL_EXPENSE_THRESHOLD` (défaut: 110€)
- 📊 Affichage "Sans tiers" / "Sans fournisseur" pour lignes sans association

**Modale budget_edit.php alignée sur forecast :**
- 🔘 Type : **radio buttons** (Revenu/Dépense)
- 👤 **Tiers/Fournisseur** : autocomplete avec datalist
- ⚡ Toggle automatique selon type sélectionné
- ✏️ Label : input texte libre
- 📏 Tableau montants optimisé (inputs 60px vs 80px)
- 📱 Responsive : première colonne sticky + scroll horizontal uniquement sur mois

**Fonctionnalités JavaScript :**
- `toggleType()` : collapse/expand par type
- `toggleTier()` : collapse/expand par tiers/fournisseur  
- `setupThirdPartyAutocomplete()` : autocomplete tiers
- `setupSupplierAutocomplete()` : autocomplete fournisseurs
- Initialisation automatique au chargement DOM

**Traitement données :**
- Sauvegarde `fk_soc` dans BudgetLine (tiers OU fournisseur selon type)
- Actions `addline` et `updateline` mises à jour
- Chargement tiers/fournisseurs depuis `llx_societe`

### 🐛 CORRECTIONS

**Vue COMPARER (Issue #9) :**
- 📱 Responsive appliqué : sticky première colonne + wrapper scroll

**Vue EVOLUTION FORECAST (Issue #10) :**
- 📱 Responsive appliqué aux 2 tableaux (revenus + dépenses)
- 🔧 Correctif sélecteur échelle prix (Issue #13) : wrapper form ajouté
- 📊 Lignes "Forecast actuel" et "Dépense YTD" ajoutées au tableau dépenses

**Modale ajout dépense (Issue #11) :**
- 🏪 Sélecteur fournisseur avec autocomplete
- 💰 Données financières réelles affichées (factures fournisseur)
- ⚡ Toggle automatique Tiers ↔ Fournisseur

### 📐 CSS & RESPONSIVE

**Système responsive unifié :**
- Classes : `.budget-responsive-wrapper` + `.budget-responsive-table`
- Première colonne sticky avec ombre (min-width adaptatif)
- Scroll horizontal uniquement sur colonnes de mois
- 3 breakpoints : desktop, tablet (≤1024px), mobile (≤768px)
- Typographie optimisée : 12px → 11px (desktop)
- Troncation texte : `text-overflow: ellipsis` + title tooltips

**Largeurs colonnes optimisées :**
- Desktop : 100-120px
- Tablet : 85-100px
- Mobile : 70-85px

### 🔧 CONFORMITÉ DOLIBARR

- ✅ Pas d'erreurs PHP détectées
- ✅ Structure fichiers conforme
- ✅ Permissions via `Permission499051001/002/003`
- ✅ Traductions FR/EN complètes (`WithoutThirdParty`, `WithoutSupplier`)
- ✅ Headers GPL v3+ sur tous fichiers PHP

---

## [1.1.6] - 2026-01-15

### ✨ NOUVELLE FONCTIONNALITÉ - Sélection du tiers pour lignes de revenu

**Association tiers-budget (Issue #4) :**
- 🏢 Nouveau champ "Tiers" dans la modale d'ajout/édition de ligne de revenu
- 👥 Sélecteur avec autocomplétion affichant tous les tiers (clients, prospects)
- 🔗 Colonne `fk_soc` ajoutée à `llx_budget_lines` pour lien vers `llx_societe`
- 📊 Permet le regroupement et l'analyse par client dans les vues forecast/compare
- 🎯 Base pour futures fonctionnalités (regroupement par tiers, filtres, etc.)

**Refonte UX de la modale :**
- 🔘 Type (Revenu/Dépense) : **boutons radio** au lieu de select
- 🔘 Type de revenu (Produits/Services) : **boutons radio** (visible si Revenu sélectionné)
- ✏️ Libellé : **champ texte libre** pour saisie personnalisée
- 💼 Tiers : **affichage conditionnel** (visible uniquement pour Revenus, optionnel)
- 🔢 Code comptable : **filtrage automatique** selon type sélectionné
  - Type Revenu → codes classe 7 (7xxx)
  - Type Dépense → codes classe 6 (6xxx)

### 🔧 MIGRATION AUTOMATIQUE v1.1.6

**Système de mise à jour intelligent :**
- 🤖 **Détection automatique** de la version installée lors activation module
- 📊 Vérification via `INFORMATION_SCHEMA` de la présence colonne `fk_soc`
- ⚙️ Exécution automatique de `sql/upgrade_to_1.1.6.sql` si nécessaire
- 📝 Logging détaillé dans `documents/budget/logs/install.log`
- ✅ **Préservation garantie** de toutes les données existantes (budgets, lignes, montants)

**Procédure pour utilisateurs :**
1. Désactiver le module Budget
2. Remplacer les fichiers par v1.1.6
3. Activer le module → migration automatique
4. Vérifier logs si besoin

**Fichiers de migration :**
- `sql/upgrade_to_1.1.6.sql` : Script SQL de migration
- `UPGRADE_TO_1.1.6.md` : Instructions détaillées + procédure manuelle de secours
- `core/modules/modBudget.class.php` : Méthode `_runUpgradeScripts()`

### 📊 BASE DE DONNÉES

**Nouvelles structures :**
- `llx_budget_lines.fk_soc` (INTEGER NULL) : Lien vers tiers (après `fk_accounting_account`)
- `llx_budget_forecast_overrides` : Table pour futures fonctionnalités de surcharge

**Migration SQL appliquée :**
```sql
ALTER TABLE llx_budget_lines 
ADD COLUMN fk_soc INTEGER NULL DEFAULT NULL 
AFTER fk_accounting_account;

CREATE TABLE IF NOT EXISTS llx_budget_forecast_overrides (...);
```

### 🐛 CORRECTIONS

**Modale ajout ligne :**
- ✅ Bouton "Ajouter une ligne" ouvre correctement la modale (`.js-open-addline-modal`)
- ✅ Suppression duplications champs Libellé et Code Comptable
- ✅ Filtrage SQL tiers corrigé (syntaxe Dolibarr `s.client IN (...)`)
- ✅ Gestion événements radio buttons pour affichage conditionnel
- ✅ Fonction `updateAccountingAccountsList()` adaptée aux radio buttons

**JavaScript :**
- `budget_forecast_core.js` : Listener bouton ajout ligne
- Toggle automatique champs selon type sélectionné
- Filtrage codes comptables en temps réel

### 🌐 TRADUCTIONS

**Nouvelles clés (fr_FR + en_US) :**
- `TypeForecast` : Type de forecast
- `RevenueType` : Type de revenu
- `Products` : Produits
- `Services` : Services
- `ThirdParty` : Tiers
- `SelectThirdParty` : Sélectionner un tiers
- `OptionalForRevenue` : Optionnel - Permet le regroupement par client
- `EnterLabel` : Entrez le libellé

### 📦 FICHIERS MODIFIÉS

**Backend :**
- `class/budgetline.class.php` : CRUD pour `fk_soc`, JOIN avec `llx_societe`
- `budget_forecast.php` : Modale HTML refonte, POST handlers simplifiés
- `core/modules/modBudget.class.php` : Migration automatique

**Frontend :**
- `js/budget_forecast_core.js` : Logique radio buttons, filtres dynamiques

**Base de données :**
- `sql/llx_budget_lines.sql` : Ajout colonne `fk_soc`
- `sql/llx_budget_lines.key.sql` : Foreign key vers `llx_societe`
- `sql/upgrade_to_1.1.6.sql` : Script migration

**Documentation :**
- `UPGRADE_TO_1.1.6.md` : Guide migration utilisateurs
- `ChangeLog.md` : Cette entrée
- `.github/copilot-instructions.md` : Instructions développement v1.1.6

### 🔗 ISSUES RÉSOLUES

- **#4** : v1.1.6 - Refonte modale ajout revenu (sélection du tiers)

### ⚠️ NOTES DE MISE À JOUR

**Pour les administrateurs :**
- Migration **AUTOMATIQUE** lors activation module
- Aucune intervention manuelle requise (sauf problème)
- Toutes données préservées (ALTER TABLE ADD COLUMN)
- Logs disponibles : `documents/budget/logs/install.log`

**Compatibilité :**
- Dolibarr 19.0.0+
- PHP 7.1+
- MySQL/MariaDB uniquement (INFORMATION_SCHEMA)

---

## [1.1.5] - 2025-12-28

### 🎯 AMÉLIORATION - Lissage temporel basé sur jours ouvrés

**Lissage par jours ouvrés (lundi-vendredi) :**
- 📅 Distribution du montant à facturer proportionnelle aux jours ouvrés par mois
- 🔢 Formule : `montant_mois = (montant_total × jours_ouvres_mois) / total_jours_ouvres`
- 📍 Date de livraison précise utilisée comme limite haute du lissage
- ⏰ Exemple : Commande 24 000€ livrée le 28/02/2026 → Répartie sur déc 2025 / jan 2026 / fév 2026 proportionnellement

**Amélioration UI section Signé :**
- ℹ️ Info-bulles sur chaque ligne client : "X € à facturer / Y € total"
- ℹ️ Info-bulles sur chaque ligne commande : "X € à facturer / Y € total"
- 📊 Totaux de ligne affichés dans colonne Total pour clients et commandes
- 🎨 Format unifié avec les sections Payé et En attente

**Implémentation :**
- Nouvelle méthode privée `getWorkingDaysInMonth($month, $year)` → Compte jours lun-ven du mois
- Nouvelle méthode privée `getWorkingDaysInMonthUntilDay($month, $year, $day)` → Compte jusqu'à un jour donné
- Méthode `calculateLissedAmount()` refactorisée pour utiliser le lissage par jours ouvrés
- Structure de données enrichie : ajout de `total_to_invoice` et `total_ht` dans retour `getToInvoiceDetails()`

**Fichiers modifiés :**
- `class/budgetreal.class.php` : +2 méthodes privées, 1 méthode refactorisée
- `budget_forecast.php` : +Info-bulles, +Totaux de ligne, agrégation par order_id unique

---

## Version 1.1.4 (2025-12-24)

### ✨ NOUVELLE FONCTIONNALITÉ - Hiérarchie de revenus avec détails tiers/factures

**Vue hiérarchique des revenus au mois (page Forecast) :**
- 📊 Section "Payé" → Développer pour voir les tiers → Cliquer sur chaque facture
- 📊 Section "En attente" → Développer pour voir les tiers → Cliquer sur chaque facture non payée
- 📊 Section "Signé" → Développer pour voir les clients → Commandes en cours (avec projets) → Factures créées

**Améliorations data layer :**
- Nouvelle méthode `getToInvoiceDetails()` retourne commandes groupées par client avec détails
- Nouvelle méthode privée `calculateLissedAmount()` gère le lissage temporel des montants
- Méthode `getRevenueActual()` retourne structures détaillées (paid_details, unpaid_details, to_invoice_details)

---

## Version 1.1.3 (2025-12-08)

### 🔍 AMÉLIORATION - Logs d'installation détaillés

**Nouveau système de logging :**
- 📝 Logs d'installation complets générés dans `documents/budget/logs/install.log`
- ⏱️ Mesure du temps d'exécution pour chaque étape
- 🔎 Détails sur chaque fichier SQL traité (taille, nombre de requêtes, durée)
- ⚠️ Messages d'erreur détaillés en cas de problème
- 🐳 Permet de diagnostiquer les problèmes de lenteur en Docker

**Informations loggées :**
- Début et fin de l'installation avec timestamps
- Liste des fichiers SQL détectés
- Temps d'exécution de chaque fichier SQL
- Erreurs de base de données si présentes
- Durée totale de l'installation

**Utilisation :**
Le fichier de log est automatiquement créé lors de l'activation du module.
Il se trouve dans : `documents/budget/logs/install.log`

### 🐛 CORRECTION CRITIQUE - Respect du standard Dolibarr pour le chargement SQL

**Problème résolu définitivement :**
- 🔧 Les fichiers SQL ne respectaient pas le standard Dolibarr pour l'ordre de chargement
- 🔧 Causait des erreurs de clés étrangères car les `.key.sql` étaient mélangés avec les `.sql`
- 🔧 Retour au standard Dolibarr : 2 passes séparées

**Standard Dolibarr appliqué :**

**PASSE 1 - Création de TOUTES les tables :**
```
llx_budget_main.sql
llx_c_type_rev.sql
llx_c_type_rev_data.sql
llx_budget_lines.sql
llx_budget_amounts.sql
llx_budget_forecast_amounts.sql
llx_budget_forecast_snapshot.sql
llx_zbudget_legacy.sql
```

**PASSE 2 - Ajout de TOUTES les clés/FK (après que toutes les tables existent) :**
```
llx_budget_main.key.sql
llx_c_type_rev.key.sql
llx_budget_lines.key.sql
llx_budget_amounts.key.sql
llx_budget_forecast_amounts.key.sql
llx_budget_forecast_snapshot.key.sql
llx_zbudget_legacy.key.sql
```

**Avantages :**
- ✅ Compatible avec le moteur d'installation standard de Dolibarr
- ✅ Toutes les tables existent avant de créer les FK
- ✅ Pas de problème de dépendances circulaires
- ✅ Conforme aux conventions Dolibarr
- ✅ Logs détaillés pour diagnostic

---

## Version 1.1.2 (2025-12-07)

### 🐛 CORRECTION CRITIQUE

**Problème d'installation des tables SQL**
- 🔧 **FIX MAJEUR** : Renommage de `llx_budget.sql` en `llx_zbudget_legacy.sql`
- 🔧 Le fichier legacy était chargé AVANT `llx_budget_main.sql` (ordre alphabétique)
- 🔧 Causait l'erreur "Unknown column 'fk_budget_main'" même sur installations fraîches
- ✅ Maintenant `llx_budget_main` est créé en PREMIER, puis les autres tables

**Ce fix résout définitivement :**
- ❌ Erreur lors de l'ajout de lignes de budget sur installation fraîche
- ❌ Problème de dépendances entre tables lors de l'activation du module
- ✅ Installation fraîche fonctionne maintenant sans erreur

**Action requise si vous avez déjà installé v1.1.0 ou v1.1.1 :**
1. Désinstallez complètement le module (supprime les tables)
2. Installez la v1.1.2
3. Activez le module

---

## Version 1.1.1 (2025-12-07)

### 🐛 Corrections

**Migration depuis anciennes versions**
- Ajout d'un script de migration SQL `sql/upgrade_to_1.1.0.sql` pour les mises à jour depuis versions < 1.0.1
- Script idempotent qui ajoute les colonnes manquantes (fk_budget_main, fk_budget_line) si nécessaire
- Ajout des index et contraintes de clés étrangères

**Documentation**
- Création du guide de mise à jour `UPGRADE.md` avec 3 solutions détaillées
- Clarification dans README.md : installations fraîches en v1.1.0/1.1.1 fonctionnent correctement
- Note importante : le guide de migration concerne uniquement les utilisateurs mettant à jour depuis < 1.0.1

**Résolution du problème "Unknown column 'fk_budget_main'"**
- Fix pour les utilisateurs ayant installé une version < 1.0.1 puis mis à jour vers 1.1.0
- Les nouveaux utilisateurs installant directement la v1.1.0 ou v1.1.1 ne sont pas affectés

---

## Version 1.1.0 (2025-12-04)

### ✨ Nouvelles fonctionnalités

**Sélecteur d'échelle monétaire (€ / K€ / M€)**
- Ajout d'un sélecteur permettant d'afficher les montants en euros, milliers d'euros ou millions d'euros
- Disponible sur toutes les vues avec tableaux : Forecast, Budget & Baseline, Comparer, Évolution Forecast, Reporting
- Persistance du choix en session utilisateur

**Clonage de budget**
- Bouton "Cloner" ajouté dans la liste des budgets (colonne Actions)
- Bouton "Cloner" ajouté dans la fiche budget
- Duplique le budget avec toutes ses lignes et montants

**Affichage des revenus négatifs**
- Les montants négatifs sont maintenant affichés dans le tableau Forecast
- Permet d'ajuster les projections (ex: correction de forecast signé d'un mois à l'autre)

---

## Version 1.0.1 (2025-12-03)

### 🐛 Corrections

**Installation SQL**
- Correction du chemin de chargement des tables SQL à l'activation du module
- Restructuration des fichiers SQL au format standard Dolibarr (llx_table.sql + llx_table.key.sql)
- Ajout des fichiers SQL séparés pour chaque table avec index et clés étrangères

**Tables**
- llx_budget_main : Table principale des budgets
- llx_budget_lines : Lignes de budget (revenus/dépenses)
- llx_budget_amounts : Montants mensuels budgétés
- llx_budget_forecast_amounts : Montants mensuels prévisionnels
- llx_budget_forecast_snapshot : Snapshots mensuels avec baselines
- llx_c_type_rev : Dictionnaire des types de revenus

**Cronjob**
- Conversion du cronjob de type 'command' vers type 'method' (plus besoin de PHP CLI)
- Le cronjob utilise maintenant une méthode de classe Dolibarr comme les autres modules

**Forecast**
- Amélioration de la création du snapshot initial : si le budget débute avant aujourd'hui, le snapshot est créé sur le mois courant (permet la mise en place du module en cours de budget)

**Interface**
- Maintien du mode édition après ajout/modification/suppression de ligne
- Nettoyage de la page de configuration (suppression des paramètres de démonstration)
- Ajout des informations de configuration du cronjob dans la page setup
- Correction de l'icône Font Awesome dans le menu principal
- Masquage des boutons Modifier/Ajouter/Enregistrer si l'utilisateur n'a pas les droits d'écriture
- Suppression de la colonne Action dans la liste des budgets
- Suppression des boutons Retour inutiles sur toutes les pages
- Déplacement des boutons d'action au-dessus du tableau (Budget & Baseline)

---

## Version 1.0.0 (2025-12-03)

### 🎉 Version initiale

**Gestion des budgets**
- Création de budgets avec période personnalisable (mois de début/fin)
- Support multi-utilisateurs avec budgets privés ou publics
- Duplication de budgets existants

**Lignes budgétaires**
- Lignes de revenus et dépenses par budget
- Association optionnelle aux comptes comptables (classes 6 et 7)
- Saisie des montants mensuels avec copie rapide
- Réorganisation des lignes par glisser-déposer

**Comparaison Budget vs Réalisé**
- Extraction automatique des factures clients payées
- Suivi des factures en attente de paiement
- Calcul des commandes signées à facturer (lissage selon date de livraison)
- Suivi des opportunités (devis ouverts selon date de validité)

**Forecast (Prévisions)**
- Vue combinée passé (réalisé, lecture seule) + futur (modifiable)
- Ajout de lignes dédiées au forecast
- Modification des prévisions par mois et par ligne
- Icônes d'ajout et modification sur chaque ligne

**Suivi YTD (Year To Date)**
- Graphique d'évolution des revenus budgétés vs réalisés
- Calcul du taux d'atteinte cumulé
- Moyennes mensuelles budget/facturé

**Dictionnaire**
- Types de revenus personnalisables
- Système de tags pour catégorisation automatique

**Traductions**
- Français (fr_FR) complet
- Anglais (en_US) complet

**Technique**
- Compatible Dolibarr 19+
- PHP 7.1+
- Tables : llx_budget_main, llx_budget_lines, llx_budget_amounts, llx_budget_forecast_amounts, llx_c_type_rev
- Installation automatique des tables à l'activation
- Permissions : lecture, écriture, suppression

---

*Copyright (C) 2025 KREATIV PROJECT MANAGEMENT SASU*
*Licence GPL v3+ - GNU General Public License version 3 ou ultérieure*
*Ce logiciel est un logiciel libre sous licence GPL v3+*
