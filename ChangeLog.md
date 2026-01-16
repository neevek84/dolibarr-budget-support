# CHANGELOG MODULE BUDGET FOR [DOLIBARR ERP CRM](https://www.dolibarr.org)

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
