# Guide Complet des Fonctionnalités - Module Budget v1.2.0

**Dernière mise à jour** : 16 janvier 2026  
**Module** : Budget pour Dolibarr ERP/CRM  
**Compatibilité** : Dolibarr 19.0+ | PHP 7.1+  
**Licence** : GPL v3+

---

## 📚 Table des matières

1. [Fonctionnalités Métier](#fonctionnalités-métier)
2. [Fonctionnalités Techniques Avancées](#fonctionnalités-techniques-avancées)
3. [Outils de Développement](#outils-de-développement)
4. [Architecture & Conventions](#architecture--conventions)
5. [Configuration Avancée](#configuration-avancée)

---

## 🎯 Fonctionnalités Métier

### 1. Gestion Multi-Budgets

**Description** : Créez et gérez plusieurs budgets simultanément

**Fonctionnalités** :
- ✅ Budgets privés (par utilisateur) ou publics (partagés)
- ✅ Période flexible : définissez mois de début et fin d'exercice
- ✅ Copie/duplication d'un budget existant
- ✅ Gestion des permissions (lecture/écriture/suppression)

**Code** :
- Classe : `BudgetMain` ([class/budgetmain.class.php](class/budgetmain.class.php))
- Table : `llx_budget_main`
- Permissions : `Permission499051001/002/003`

---

### 2. Revenus & Dépenses avec Hiérarchie

**Description** : Suivi détaillé des revenus réalisés avec drill-down par tiers et factures

**Structure hiérarchique** :
```
Revenus
├── Forecast (prévisions saisies)
├── Payé
│   ├── Client A
│   │   ├── Facture FA-001
│   │   └── Facture FA-002
│   └── Client B
│       └── Facture FA-003
├── En attente de paiement
│   └── Client C
│       └── Facture FA-004 (non payée)
└── Signé (à facturer)
    ├── Client D
    │   ├── Commande CO-001 ✅ [Auto]
    │   └── Commande CO-002 ℹ️ [Manuel]
    └── ⋯ Autres (13)
        └── Client E (< 500€)
```

**Fonctionnalités** :
- ✅ Expand/collapse pour chaque niveau
- ✅ Totaux de ligne automatiques à tous les niveaux
- ✅ Icônes de statut (✅ vert, ℹ️ orange, ⚠️ rouge)
- ✅ Liens cliquables vers factures/commandes/projets
- ✅ Info-bulles avec détails (montant à facturer / total)

**Code** :
- Méthode : `BudgetReal::getRevenueActual()` → Retourne structure hiérarchique
- Vue : [budget_forecast.php](budget_forecast.php) lignes 640-1100
- Template : `printMonthCellsWithTotal()` → Calcul automatique des totaux

---

### 3. Regroupement Tiers/Fournisseurs (Vue BUDGET v1.1.7)

**Description** : Hiérarchie complète dans la vue BUDGET avec regroupement par tiers (revenus) ou fournisseurs (dépenses)

**Structure hiérarchique à 3 niveaux** :
```
Type (Revenus/Dépenses)
└── Tiers/Fournisseur (avec seuil "Autres")
    └── Lignes de détail (montants saisis)
```

**Fonctionnalités v1.1.7** :
- ✅ Regroupement automatique par `fk_soc` (tiers pour revenus, fournisseur pour dépenses)
- ✅ Application seuils configurables :
  - `BUDGET_SMALL_REVENUE_THRESHOLD` : 500€ (revenus)
  - `BUDGET_SMALL_EXPENSE_THRESHOLD` : 110€ (dépenses)
- ✅ Groupe "Autres" pour tiers/fournisseurs < seuil
- ✅ Collapse/expand à 2 niveaux (Type → Tiers, Tiers → Lignes)
- ✅ Modale unifiée avec forecast (radio buttons, autocomplete)
- ✅ Toggle automatique Type → Tiers/Fournisseur dans modale
- ✅ Totaux de ligne à tous les niveaux hiérarchie

**Code** :
- Vue : [budget_edit.php](budget_edit.php) lignes 257-780
- JavaScript : `toggleType()`, `toggleTier()`, `setupThirdPartyAutocomplete()`, `setupSupplierAutocomplete()`
- CSS : Classes `.budget-row-type`, `.budget-row-tier`, `.budget-row-line`
- Configuration : `admin/setup.php` → Seuils "Autres"

### 4. Regroupement "Autres" (Amélioration v1.1.6-1.1.7)

**Description** : Regroupe automatiquement les tiers < seuil dans une section "Autres"

**Comportement** :
- 💶 **Seuil configurable** (défaut: 500€) dans Setup > Modules > Budget > Configuration
- 📊 Appliqué aux 3 familles : Payé, En attente, Signé
- 📁 Section "Autres" en **dernier** de chaque famille
- 🔍 Expand/collapse pour voir détail des tiers regroupés
- 🔢 Compteur : `⋯ Autres (13)` indique le nombre de tiers

**Visuel** :
```
▼ Payé                           82 180,30€
  └─▶ SILKHOM                    38 850,00€
  └─▶ PROJETLYS                   3 600,00€
  └─▶ ⋯ Autres (13)               1 970,20€
       ├── Client A (250€)
       ├── Client B (180€)
       └── ... (11 autres)
```

**Configuration** :
- Paramètre : `BUDGET_SMALL_REVENUE_THRESHOLD` (en euros)
- Page : Setup > Modules > Budget > Configuration
- Code : `groupSmallRevenues()` ([budget_forecast.php](budget_forecast.php) ligne 120)

**Traductions** :
- `SmallRevenueThreshold` = "Seuil de regroupement 'Autres'"
- `Others` = "Autres"

---

### 4. Override Manuel par Commande (v1.1.5)

**Description** : Ventilation manuelle du montant à facturer par mois

**Fonctionnalités** :
- 🖱️ Clic sur icône ✏️ à droite de chaque commande
- 📅 Répartition mensuelle manuelle ou automatique
- 🔁 Duplication du premier mois sur toute l'année
- ⚙️ Mode auto : lissage par jours ouvrés (lundi-vendredi)
- ✅ Validation en temps réel (déjà ventilé / reste à ventiler)
- 🎨 Couleur dynamique : vert (OK), orange (partiel), rouge (dépassement)

**Interface modale** :
```
┌─────────────────────────────────────────────────┐
│ Ventilation manuelle - CO2511-0015             │
├─────────────────────────────────────────────────┤
│ Mode: ⚪ Auto  🔘 Manuel                        │
│                                                 │
│ À facturer:       1 000,00 €                   │
│ Déjà ventilé:       800,00 € ⚠️                │
│ Reste à ventiler:   200,00 €                   │
│                                                 │
│ Décembre 2025:  [200,00] €                     │
│ Janvier 2026:   [300,00] €                     │
│ Février 2026:   [300,00] €                     │
│                                                 │
│ [Dupliquer 1ère valeur]  [Annuler]  [Enregistrer] │
└─────────────────────────────────────────────────┘
```

**Code** :
- Modale : [budget_forecast.php](budget_forecast.php) lignes 1300-1390
- Logique : [js/budget_forecast.js](js/budget_forecast.js) `openOverride()`, `redistributeAuto()`
- Table : `llx_budget_forecast_overrides`

---

### 5. Lissage Temporel par Jours Ouvrés (v1.1.5)

**Description** : Distribution proportionnelle basée sur jours travaillés (lundi-vendredi)

**Formule** :
```
montant_mois = (montant_total × jours_ouvrés_mois) / total_jours_ouvrés
```

**Exemple concret** :
```
Commande: 24 000€
Date livraison: 28 février 2026
Exercice: avril 2025 - mars 2026

Calcul:
- Déc 2025: 23 jours ouvrés → 7 200,00€
- Jan 2026: 22 jours ouvrés → 6 880,00€
- Fév 2026: 20 jours ouvrés → 9 920,00€
Total: 65 jours → 24 000,00€
```

**Méthodes** :
- `getWorkingDaysInMonth($month, $year)` → Compte lundi-vendredi
- `getWorkingDaysInMonthUntilDay($month, $year, $day)` → Jusqu'à date précise
- `calculateLissedAmount()` → Applique la distribution

**Code** :
- Classe : [class/budgetreal.class.php](class/budgetreal.class.php) lignes 617-755
- JavaScript : [js/budget_forecast.js](js/budget_forecast.js) lignes 260-287

---

### 6. Validation Hiérarchique avec Icônes

**Description** : Propagation des icônes de validation du niveau commande → tiers → section

**Logique de propagation** :

| Niveau | Icône | Condition |
|--------|-------|-----------|
| **Commande** | ✅ Vert | Ventilé = À facturer (tolérance 0,02€) |
| | ⚠️ Rouge | Ventilé > À facturer (dépassement) |
| | ℹ️ Orange | Ventilé < À facturer (partiel) |
| **Tiers** | ⚠️ Rouge | AU MOINS UNE commande rouge |
| | ✅ Vert | TOUTES les commandes vertes |
| | ℹ️ Orange | Sinon (partielles, aucune rouge) |
| **Signé** | ⚠️ Rouge | AU MOINS UN tiers a commande rouge |
| | ✅ Vert | TOUS les tiers ont commandes vertes |
| | ℹ️ Orange | Sinon |

**Code** :
- Calcul : [budget_forecast.php](budget_forecast.php) lignes 1095-1160
- Injection : JavaScript inline lignes 1260-1280

---

### 7. Forecast Dépenses Élargi (v1.2.0 — Epic #36)

**Objectif** : Couvrir TOUS les flux sortants côté forecast, en miroir de la section Revenus. Avant v1.2.0, seules les factures fournisseurs (réel) et le forecast manuel étaient pris en compte — l'engagé et la récurrence étaient des angles morts du pilotage de trésorerie.

**Structure de la section Dépenses (post-v1.2.0)** :
```
[v] DÉPENSES — total
    [>] Forecast (lignes manuelles)
    [>] Engagé (P1) — commandes fournisseurs validées, lissées
    [>] Récurrent (parent collapsible — P2-P5)
        [>] Factures récurrentes (P2)
        [>] Emprunts (P3, si module loan activé)
        [>] Charges sociales (P4)
        [>] Salaires (projection N-3 mois) (P5)
    [>] Dépenses réalisées (factures payées + non payées)
```

**5 catégories de projection avec sources Dolibarr natives** :

| Catégorie  | Méthode `BudgetReal`                            | Source SQL                                | Logique de placement                       |
|------------|--------------------------------------------------|-------------------------------------------|--------------------------------------------|
| Engagé     | `getEngagedSupplierOrdersDetails()`              | `commande_fournisseur` + `element_element`| Lissage jours ouvrés sur durée commande   |
| Rec. invoice| `getRecurringSupplierInvoicesDetails()`         | `facture_fourn_rec`                       | Occurrences `date_when` + k * frequency   |
| Emprunts   | `getRecurringLoansDetails()`                     | `loan_schedule` + `loan`                  | Sur `datep` de chaque échéance future     |
| Charges    | `getRecurringChargesDetails()`                   | `chargesociales`                          | Sur `date_ech` (ou mois courant si vide)  |
| Salaires   | `getRecurringSalariesDetails()`                  | `salary` (historique 3 derniers mois)     | Moyenne N-3 mois projetée                 |

**Table d'override unifiée** :
- `llx_budget_expense_overrides` discriminée par `source` ∈ {`engaged`, `rec_invoice`, `loan`, `charge`, `salary`}.
- 3 modes : `auto` (calcul automatique), `manual` (montant ajusté), `excluded` (projection retirée pour ce mois).
- Helper statique `BudgetExpenseOverride` : `fetch / apply / save / reset`.
- UI : crayon bleu sur chaque cellule mois éditable des projections, modal mono-mois.

**Règles métier validées** (Epic #36) :
- ✅ Lissage commandes fourn = durée réelle complète, à cheval sur exercices.
- ✅ Date dépassée → mois courant + pastille rouge ⚠️.
- ✅ Aucune date utilisable → mois courant + pastille orange (point de vigilance).
- ✅ Salaires : pattern N-3 mois est suffisant (pas de table de récurrence dédiée).
- ✅ Anti-doublon salaires : réel masque la projection sur même `fk_user`/mois.
- ✅ Module Loan optionnel via `isModEnabled('loan')`.
- ✅ Charges sans `date_ech` → mois courant + tooltip « date à confirmer ».

**Code** :
- Classes : [class/budgetreal.class.php](class/budgetreal.class.php), [class/budgetexpenseoverride.class.php](class/budgetexpenseoverride.class.php) (helper statique)
- Helpers de rendu : [lib/budget.lib.php](lib/budget.lib.php) — `budgetRenderExpenseProjectionBlock()` + `budgetAggregateExpenseProjection()`
- SQL : `sql/llx_budget_expense_overrides.sql` (+ `.key.sql`) + `sql/upgrade_to_1.2.0.sql`
- Action handler : `save_expense_override` dans [budget_forecast.php](budget_forecast.php)

---

### 7 bis. Paiements divers (v1.3.1)

**Source** : `llx_payment_various` (Banque > Paiements divers) — via `BudgetReal::getVariousPaymentsDetails($month, $year, $sens)`.

| Sens | Côté budget | Slotting | Regroupement |
|------|-------------|----------|--------------|
| `1` (crédit) | Revenus | `datep` (date de paiement) | Compte comptable (`accountancy_code`) |
| `0` (débit)  | Dépenses | `datep` (date de paiement) | Compte comptable (`accountancy_code`) |

- Libellé du compte résolu sur le plan comptable actif (`CHARTOFACCOUNTS`) ; paiements sans compte regroupés sous « Sans compte comptable ».
- **Réalisé** : ajoutés au « payé » de `getRevenueActual()` / `getExpenseActual()` (+ clés `various`, `various_details`) → comparaison, impression, évolution, YTD et snapshots les intègrent sans code spécifique.
- **Forecast** : bloc « Paiements divers » dans Revenus et dans Dépenses, rendu par `budgetRenderExpenseProjectionBlock()` (non éditable : ce sont des montants réels), inclus dans les totaux et le Solde.
- **Exports** : lignes `revenue_various` / `expense_various` (CSV, Excel, XML `various_payments`).
- **Clonage depuis le réalisé** : une ligne par compte comptable (revenu et dépense).

**Choix de conception** :
- ✅ Montant pris tel que saisi (un paiement divers n'a pas de ventilation HT/TVA).
- ✅ Pas de tiers → hors filtre Forecast tiers/fournisseur (bandeau d'avertissement mis à jour).
- ✅ Pas de projection : un paiement divers est toujours réel (réglé à la saisie).

---

### 8. Baseline (Snapshot Forecast)

**Description** : Capture l'état du forecast à un instant T pour comparaison future

**Fonctionnalités** :
- 📸 Snapshot automatique mensuel (via cronjob)
- 🏷️ Création baseline manuelle avec titre
- 🔍 Comparaison baseline vs forecast actuel
- 📊 Vue modale avec mode (auto/manuel), totaux, forecast revenues

**Cronjob** :
```bash
# Exécution mensuelle le 1er du mois
*/30 * * * * /usr/bin/php /path/to/dolibarr/scripts/cron/cron_run_jobs.php
```

**Code** :
- Classe : [class/budgetsnapshot.class.php](class/budgetsnapshot.class.php)
- Cronjob : [scripts/cron_budget_snapshot.php](scripts/cron_budget_snapshot.php)
- Table : `llx_budget_forecast_snapshot`

---

## 🔧 Fonctionnalités Techniques Avancées

### 1. Template de Totaux de Ligne

**Objectif** : Garantir calcul automatique des totaux à tous niveaux hiérarchiques

**Fonction template** :
```php
/**
 * Affiche cellules mensuelles avec total automatique
 * @param array $months Liste des mois
 * @param array|callable $month_amounts Montants par mois ou callback
 * @param string $bg_color Couleur de fond
 * @param mixed $price_scale Échelle d'affichage
 * @param object $langs Traductions
 * @param bool $is_bold Gras (default: false)
 */
printMonthCellsWithTotal($months, $month_amounts, $bg_color, $price_scale, $langs, $is_bold);
```

**Utilisation** :
```php
// Avec callback
$month_amounts = function($m) use ($soc_data) {
    $amount = 0;
    foreach ($soc_data['invoices'] as $invoice) {
        if ($invoice['month'] == $m) $amount += $invoice['amount'];
    }
    return $amount;
};
printMonthCellsWithTotal($months, $month_amounts, '#e8f5e9', $price_scale, $langs, true);

// Avec tableau
printMonthCellsWithTotal($months, $others_totals, '#fff9c4', $price_scale, $langs, true);
```

**Avantages** :
- ✅ Un seul point de maintenance
- ✅ Calcul automatique du total
- ✅ Gestion cohérente du formatage
- ✅ Pas de risque d'oublier le total

---

### 2. Gestion CSP (Content Security Policy)

**Problème** : Dolibarr 19+ impose CSP strict → inline scripts/handlers interdits

**Solution** : Event delegation avec fichier JS externe

**Pattern utilisé** :
```javascript
// ❌ INTERDIT (inline)
<button onclick="doSomething()">Click</button>

// ✅ AUTORISÉ (delegation)
<button data-action="do-something" data-id="123">Click</button>

// budget_forecast.js
document.addEventListener('click', (e) => {
    const target = e.target.closest('[data-action]');
    if (!target) return;
    
    const action = target.dataset.action;
    if (action === 'do-something') {
        doSomething(target.dataset.id);
    }
});
```

**Fichiers** :
- Script : [js/budget_forecast.js](js/budget_forecast.js)
- Documentation : [CSP_COMPLIANCE_SUMMARY.md](CSP_COMPLIANCE_SUMMARY.md)

---

### 3. Système de Données Globales Injectées

**Objectif** : Passer données PHP → JavaScript de manière CSP-compliant

**Pattern** :
```php
// budget_forecast.php
print '<script type="text/javascript">';
print 'window.budgetOrderData = ' . json_encode($order_data_js, JSON_UNESCAPED_UNICODE) . ';';
print '</script>';
```

```javascript
// budget_forecast.js
function openOverride(orderId) {
    const data = window.budgetOrderData[orderId];
    // Utiliser data...
}
```

**Données injectées** :
- `window.budgetOrderData` : Infos commandes (ref, total_to_invoice, date_livraison, months)
- `window.budgetBaselineData` : Info baseline (mode, revenues_total, forecast_revenues)

---

## 🛠️ Outils de Développement

### 1. Système de Release Automatisé

**Scripts disponibles** :

| Script | Description | Usage |
|--------|-------------|-------|
| `release.sh` | Release complète (commit, tag, zip) | `./release.sh` |
| `demo_release.sh` | Test sans commit git | `./demo_release.sh` |
| `auto_release.sh` | Release avec détection auto de version | `./auto_release.sh` |
| `full_release.sh` | Release + validation + tests | `./full_release.sh` |

**Alias recommandés** (ajouter à `.bashrc` / `.zshrc`) :
```bash
alias budget-release='cd /path/to/budget && ./release.sh'
alias budget-demo='cd /path/to/budget && ./demo_release.sh'
alias budget-validate='cd /path/to/budget && ./validate_v1.1.4.sh'
alias budget-zip='cd /path/to/budget && rm -f module_budget-*.zip && zip -r module_budget-$(date +%Y%m%d).zip . -x "./.git/*" "./.github/*" "./module_budget-*.zip"'
```

**Processus release** :
1. Mise à jour `ChangeLog.md`
2. Mise à jour version dans `core/modules/modBudget.class.php`
3. Commit avec message standard
4. Tag git `v1.1.x`
5. Création `module_budget-1.1.x.zip`

**Documentation** : [AUTO_RELEASE_GUIDE.md](AUTO_RELEASE_GUIDE.md), [RELEASE_SYSTEM.md](RELEASE_SYSTEM.md)

---

### 2. Validation & Tests

**Scripts de validation** :

```bash
# Validation structure module
./validate_v1.1.4.sh

# Tests fonctionnels complets
# Voir RECETTE.md (20 scénarios de test)
```

**Checklist Dolistore** :
```bash
# Conformité Dolistore avant soumission
cat DOLISTORE_CHECKLIST.md
```

**Guides de test** :
- [RECETTE.md](RECETTE.md) : 20 scénarios fonctionnels
- [USER_TEST_GUIDE.md](USER_TEST_GUIDE.md) : 10 tests manuels hiérarchie
- [COMPLIANCE_CHECK.md](COMPLIANCE_CHECK.md) : Validation technique

---

### 3. Documentation Agent AI

**Fichier** : [.github/copilot-instructions.md](.github/copilot-instructions.md)

**Contenu** :
- Architecture complète du module
- Patterns de développement (Dolibarr-specific)
- Workflow de release
- Conventions de nommage
- Questions de clarification pour agents

**Usage** : Onboarding instantané pour nouveaux développeurs ou agents AI

---

## 🏗️ Architecture & Conventions

### 1. Structure Base de Données (Two-Pass Loading)

**Standard Dolibarr CRITIQUE** :

**PASSE 1** : Création de TOUTES les tables
```
sql/llx_budget_main.sql
sql/llx_budget_lines.sql
sql/llx_budget_amounts.sql
sql/llx_budget_forecast_amounts.sql
sql/llx_budget_forecast_overrides.sql
sql/llx_budget_forecast_snapshot.sql
sql/llx_c_type_rev.sql
sql/llx_zbudget_legacy.sql
```

**PASSE 2** : Ajout de TOUTES les contraintes
```
sql/llx_budget_main.key.sql
sql/llx_budget_lines.key.sql
sql/llx_budget_amounts.key.sql
sql/llx_budget_forecast_amounts.key.sql
sql/llx_budget_forecast_overrides.key.sql
sql/llx_budget_forecast_snapshot.key.sql
sql/llx_c_type_rev.key.sql
sql/llx_zbudget_legacy.key.sql
```

**⚠️ JAMAIS mélanger `.sql` et `.key.sql` !**

**Raison** : Dolibarr lit les fichiers par ordre alphabétique. Si un `.key.sql` est lu avant que toutes les tables soient créées, les FK échouent.

**Documentation** : [ChangeLog.md](ChangeLog.md) v1.1.3

---

### 2. Permissions & Module ID

**Module ID** : `499051` (official KREATIV PROJECT MANAGEMENT)

**Permissions** :
```php
$this->rights_class = 'budget';

Permission499051001 = Lecture
Permission499051002 = Écriture  
Permission499051003 = Suppression
```

**Vérification** :
```php
if (!$user->hasRight('budget', 'read')) {
    accessforbidden();
}
```

---

### 3. Traductions (i18n)

**Structure** :
```
langs/
├── fr_FR/
│   └── budget.lang
└── en_US/
    └── budget.lang
```

**Clés obligatoires** :
- Module : `ModuleBudgetName`, `BudgetDescription`
- Permissions : `Permission499051001/002/003`
- Actions : `BudgetCreated`, `BudgetUpdated`, `ErrorCreatingBudget`

**Usage** :
```php
$langs->trans("BudgetName")
{@budget:BudgetName}
```

---

### 4. Conventions de Nommage

| Élément | Convention | Exemple |
|---------|-----------|---------|
| **Table** | `llx_modulename_objecttype` | `llx_budget_main` |
| **Classe** | `ModuleName` + `ObjectType` | `BudgetMain` |
| **Fichier classe** | lowercase | `budgetmain.class.php` |
| **Permission** | `Permission{MODULE_ID}{NUM}` | `Permission499051001` |
| **Traduction** | PascalCase | `SmallRevenueThreshold` |

---

## ⚙️ Configuration Avancée

### 1. Paramètres Globaux

| Paramètre | Description | Défaut | Table |
|-----------|-------------|--------|-------|
| `BUDGET_SMALL_REVENUE_THRESHOLD` | Seuil regroupement "Autres" (€) | 500 | `llx_const` |

**Modification** :
- UI : Setup > Modules > Budget > Configuration
- Code : `getDolGlobalString('BUDGET_SMALL_REVENUE_THRESHOLD', '500')`

---

### 2. Cronjob Configuration

**Activer cronjob CLI** :
```php
// conf/conf.php
$dolibarr_cron_allow_cli = 1;
```

**Créer tâche dans Dolibarr** :
```
Home > Setup > Cron Jobs > Add Job

Module: Budget
Label: Snapshot mensuel forecast
Command: /path/to/htdocs/custom/budget/scripts/cron_budget_snapshot.php
Schedule: 0 0 1 * * (1er du mois à minuit)
```

**Ou via crontab** :
```bash
0 0 1 * * /usr/bin/php /path/to/dolibarr/scripts/cron/cron_run_jobs.php
```

---

### 3. Logs d'Installation

**Emplacement** : `documents/budget/logs/install.log`

**Contenu** :
- Timestamp début/fin installation
- Liste fichiers SQL traités
- Temps d'exécution par fichier
- Erreurs SQL détaillées
- Durée totale

**Usage** : Diagnostic problèmes lenteur (Docker notamment)

---

## 📊 Métriques du Module

**Version actuelle** : 1.1.5  
**Lignes de code PHP** : ~8 000  
**Lignes de code JavaScript** : ~320  
**Tables BD** : 8  
**Classes principales** : 6  
**Pages utilisateur** : 5  
**Scripts maintenance** : 4  
**Traductions** :
- Français : 278+ clés
- Anglais : 299+ clés

**Compatibilité testée** :
- Dolibarr 19.0.0 à 19.0.5
- PHP 7.1, 7.4, 8.0, 8.1, 8.2

---

## 🚀 Roadmap

### v1.1.6 (En cours)
- ✅ Regroupement "Autres" avec seuil configurable
- 🔄 Refonte modale ajout revenu (sélection tiers)
- 📋 Agrégation revenues <500€/budget

### v1.2.0 (Planifié)
- 📊 Export Excel complet (revenus/dépenses hiérarchiques)
- 📈 Graphiques interactifs (Chart.js)
- 🔔 Alertes budget (seuils dépassés)
- 📧 Notifications email (forecast vs réalisé)

---

## 📞 Support & Contributions

**Issues** : https://github.com/neevek84/dolibarr-budget-support/issues  
**Documentation** : [docs/](docs/)  
**Contributeurs** : Voir [CONTRIBUTING.md](CONTRIBUTING.md)

---

**Maintenu par** : KREATIV PROJECT MANAGEMENT SASU  
**Licence** : GNU General Public License v3.0 or later  
**Copyright** : © 2025 KREATIV PROJECT MANAGEMENT SASU
