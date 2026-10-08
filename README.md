# Module Budget pour Dolibarr ERP/CRM

**Version 1.3.1** | **Compatible Dolibarr 19+** | **PHP 7.1+**

Module de gestion budgétaire avancée pour Dolibarr permettant le suivi des revenus et dépenses avec comparaison budget/réalisé et prévisions (forecast). Avec regroupement hiérarchique par tiers/fournisseurs, interface responsive et exports PDF/CSV/Excel/XML.

📖 **[Guide Complet des Fonctionnalités](FEATURES.md)** - Documentation exhaustive de toutes les fonctionnalités et outils

## 🚀 Fonctionnalités Principales

### Gestion des budgets
- **Multi-budgets** : Créez plusieurs budgets par exercice fiscal
- **Multi-utilisateurs** : Budgets privés ou publics partagés
- **Période flexible** : Définition libre de la période budgétaire (mois de début/fin)
- **Duplication** : Copiez un budget existant pour créer un nouveau
- **Statut dynamique** : Badge À venir / En cours / Terminé / Archivé sur la liste des budgets (v1.1.9, 1.1.10)
- **Archivage** : archiver/désarchiver manuellement, purge définitive via bouton, vue liste séparée, budgets archivés exclus des crons (v1.1.10)
- **Période variable** : budgets plus courts ou plus longs que 12 mois entièrement supportés (v1.1.10)
- **Focus futur** : toggle « Période complète / À partir du mois en cours » pour se concentrer sur les mois éditables (v1.1.10)

### Revenus et Dépenses
- **Lignes budgétaires** par type (revenu/dépense)
- **Regroupement hiérarchique** : 3 niveaux Type → Tiers/Fournisseur → Lignes (v1.1.7)
- **Association tiers** : Liez une ligne de revenu à un client/prospect spécifique
- **Association fournisseur** : Liez une ligne de dépense à un fournisseur spécifique (v1.1.7)
- **Seuils "Autres"** : Regroupement automatique tiers/fournisseurs < 500€/110€ (v1.1.7)
- **Lien comptable** : Association aux comptes du plan comptable (classe 6 et 7)
- **Saisie mensuelle** des montants budgétés
- **Copie rapide** : Dupliquer la première valeur sur toute l'année
- **Interface responsive** : 4 vues optimisées (BUDGET, COMPARER, EVOLUTION x2) (v1.1.7)

### Exports
- **Export PDF** : toutes les vues (Forecast, Budget & Baseline, Comparer, Rapport YTD) (v1.1.8)
- **Export CSV / Excel / XML** : données complètes avec respect des filtres actifs (v1.1.8)
- **Format A4** : impression optimisée, compatible Cmd+P → Enregistrer en PDF

### Comparaison Budget vs Réalisé
- **Factures payées** : Extraction automatique depuis la comptabilité
- **Factures en attente** : Suivi des factures non payées
- **Commandes signées** : Montants à facturer (lissés selon date de livraison)
- **Opportunités** : Devis ouverts (selon date de validité)
- **Paiements divers** : crédits en revenus, débits en dépenses (v1.3.1)

### Forecast (Prévisions)
- **Vue combinée** : Passé (réalisé en lecture seule) + Futur (modifiable)
- **Forecast par ligne** : Ajustez les prévisions mensuelles
- **Lignes dédiées** : Ajoutez des lignes spécifiques au forecast
- **Actualisation** : Mise à jour des prévisions selon la réalité

### Forecast Dépenses élargi (v1.2.0)
Couverture complète des flux sortants côté dépenses, en miroir de la section Revenus :
- **Engagé** : commandes fournisseurs validées non encore facturées, lissées sur la durée de la commande (jours ouvrés). Date de livraison dépassée → mois courant + alerte rouge. Aucune date utilisable → mois courant + point de vigilance.
- **Récurrent → Factures récurrentes** : projection des templates `facture_fourn_rec` sur leurs mois d'occurrence (pas de lissage). Arrêt automatique à `nb_gen_max`.
- **Récurrent → Emprunts** : échéances futures non payées (`loan_schedule`), projetées sur leur date d'échéance. Sous-section activée seulement si le module Loan est actif.
- **Récurrent → Charges sociales** : charges non payées projetées sur leur `date_ech`. Sans date d'échéance → mois courant + pastille « date à confirmer ».
- **Récurrent → Salaires (projection)** : moyenne mensuelle des 3 derniers mois clos par salarié, projetée sur les mois futurs. Masque automatique si un salaire réel existe pour ce mois.
- **Override unifié** : table `llx_budget_expense_overrides` discriminée par `source`. Crayon d'édition manuelle sur chaque cellule, modes auto/manual/excluded.
- **Solde de trésorerie** intégré : tous les flux entrent dans le calcul du Balance projeté.
- **Captures réelles étendues** : `getExpenseActual()` inclut désormais salaires payés/non payés, NDF, charges sociales et échéances de prêt (bénéficie à budget_compare / budget_print / budget_forecast_evolution).
- **Récurrent → Contrats fournisseurs** (v1.2.1) : abonnements gérés via le module Contrat (lignes actives, tiers fournisseur), prix de ligne traité comme montant mensuel récurrent.

### Corrections v1.2.1
- **Avoirs clients** : les montants négatifs (avoirs) n'étaient plus affichés (ni dans les totaux) car masqués par un seuil positif strict — corrigé.
- **Emprunts non payés** : une échéance de prêt due mais non réglée n'apparaissait dans aucun total réalisé — corrigé (`getExpenseActual()`).
- **Clonage de budget** : le clonage produisait des lignes mal rattachées (mauvais noms de champs) — corrigé et refondu, voir ci-dessous.

### Clonage de budget (v1.2.1)
- **Popup à 2 modes** : au clic sur l'icône/bouton clone, choix entre « Reprendre le dernier budget » (copie budget + forecast à l'identique) et « Reprendre les données réalisées » (reconstruit les lignes depuis le réalisé constaté, par compte comptable côté dépenses et par tiers côté revenus).
- **Période cible éditable**, pré-remplie sur l'exercice suivant par défaut.
- Pas de garde-fou anti-doublon : plusieurs budgets sur le même exercice restent possibles.

### Budgets liés à un projet (v1.3.0)
- Un budget peut être rattaché à un projet Dolibarr, avec restriction d'accès réelle (créateur, partage explicite, droit `budget->readall`, ou public).
- Partage pré-rempli depuis l'équipe du projet lié, modifiable librement.

### Filtre Forecast (v1.3.0)
- Filtre par tiers/fournisseur sur la vue Forecast, avec option "sans tiers"/"sans fournisseur".

### Paiements divers (v1.3.1)
- Les **paiements divers** (Banque > Paiements divers) sont pris en compte : crédits côté **Revenus**, débits côté **Dépenses**, à leur date de paiement.
- Bloc « Paiements divers » dédié dans le Forecast (regroupé par compte comptable, lien vers chaque paiement), intégré aux totaux et au solde.
- Inclus dans le réalisé de toutes les vues : comparaison, impression/PDF, exports CSV/Excel/XML, évolution, YTD, et clonage « Reprendre les données réalisées ».

### Suivi YTD (Year To Date)
- **Graphique d'évolution** : Revenus budgétés vs réalisés
- **Taux d'atteinte** : % de réalisation cumulé
- **Moyenne mensuelle** : Comparaison budget/facturé

## 📋 Prérequis

- **Dolibarr** : Version 19 ou supérieure
- **PHP** : Version 7.1 ou supérieure
- **Module Comptabilité** : Recommandé pour l'association aux comptes comptables

### Configuration pour le Cronjob (Snapshots automatiques)

Le module inclut un cronjob qui crée automatiquement des snapshots mensuels du forecast. Pour l'activer :

1. **Activer le planificateur CLI** : Ajouter dans `conf/conf.php` :
   ```php
   $dolibarr_cron_allow_cli = 1;
   ```

2. **Configurer le cron système** (optionnel, pour exécution automatique) :
   ```bash
   # Exécuter toutes les nuits à 2h00
   0 2 * * * php /var/www/dolibarr/htdocs/custom/budget/scripts/cron_budget_snapshot.php
   ```

3. **Ou utiliser le planificateur interne Dolibarr** :
   - Accueil → Configuration → Tâches planifiées
   - Le cronjob "Budget Snapshot" apparaît automatiquement

## 📦 Installation

1. **Téléchargez** le module et décompressez l'archive
2. **Copiez** le dossier `budget` dans `/htdocs/custom/`
3. **Activez** le module depuis : Accueil → Configuration → Modules/Applications
4. **Configurez** les permissions utilisateurs

Les tables de base de données sont créées automatiquement à l'activation.

## 🔄 Mise à jour

Si vous mettez à jour depuis une version < 1.0.1, consultez le guide [UPGRADE.md](https://github.com/neevek84/dolibarr-budget-support/blob/main/UPGRADE.md) pour les instructions de migration de la base de données.

**Important** : Si vous rencontrez l'erreur `Unknown column 'fk_budget_main'`, vous devez désactiver puis réactiver le module, ou exécuter le script de migration disponible sur le [repo support](https://github.com/neevek84/dolibarr-budget-support).

## 🔧 Configuration

### Permissions
- **Lire les budgets** : Accès en lecture seule
- **Créer/modifier les budgets** : Création et édition des budgets
- **Supprimer les budgets** : Suppression des budgets

### Dictionnaire Types de revenus
Personnalisez les catégories de revenus depuis :
- Accueil → Configuration → Dictionnaires → Types de revenus
- Associez des tags aux catégories de produits/services pour un regroupement automatique

## 📖 Utilisation

### Créer un budget
1. Menu Budget → Nouveau budget
2. Renseignez le libellé et la période
3. Choisissez la visibilité (privé/public)
4. Ajoutez des lignes de revenus et dépenses
5. Saisissez les montants mensuels

### Consulter le réalisé
1. Menu Budget → Sélectionnez un budget
2. Onglet "Comparer" pour voir budget vs réalisé
3. Onglet "YTD" pour le suivi cumulé

### Gérer le forecast
1. Menu Budget → Sélectionnez un budget
2. Onglet "Forecast"
3. Les mois passés affichent le réalisé
4. Les mois futurs sont modifiables

## 📁 Structure du module

```
budget/
├── admin/              # Pages d'administration
├── class/              # Classes métier
│   ├── budgetmain.class.php
│   ├── budgetline.class.php
│   ├── budgetreal.class.php
│   ├── budgetdictionary.class.php
│   └── ...
├── core/modules/       # Descripteur du module
├── css/                # Styles CSS
├── langs/              # Traductions (fr_FR, en_US)
├── lib/                # Bibliothèques
├── sql/                # Scripts SQL
└── img/                # Images
```

## 🔒 Licence

Ce module est distribué sous **licence GNU GPL v3+** (GNU General Public License version 3 ou ultérieure).

### Liberté d'utilisation :
- ✅ Utilisation libre pour usage commercial ou non
- ✅ Modification du code source
- ✅ Redistribution autorisée (source + binaire)
- ✅ Pas de limite d'installations

### Obligations :
- 📄 Le code source doit rester disponible
- 📄 Les modifications doivent être publiées sous GPL v3+
- 📄 Conserver les mentions de copyright

Ce programme est distribué dans l'espoir qu'il sera utile, mais SANS AUCUNE GARANTIE. Voir le fichier [COPYING](COPYING) pour le texte complet de la licence.

Pour plus d'informations : https://www.gnu.org/licenses/gpl-3.0.html

## 👨‍💻 Auteur

**KREATIV PROJECT MANAGEMENT SASU**
- Site web : [https://kreativpm.fr](https://kreativpm.fr)
- Email : contact@kreativpm.fr

## 📞 Support & Contribution

- 🐛 **Bugs** : Signalez les problèmes via GitHub Issues
- 💡 **Suggestions** : Proposez des améliorations
- 🤝 **Contribution** : Pull requests bienvenues !
- 📧 **Support commercial** : contact@kreativpm.fr

---

*Module développé pour Dolibarr ERP/CRM - © 2025 KREATIV PROJECT MANAGEMENT SASU*
*Licence GPL v3+ - Logiciel Libre*
