# Module Budget pour Dolibarr ERP/CRM

**Version 1.1.5** | **Compatible Dolibarr 19+** | **PHP 7.1+**

Module de gestion budgétaire avancée pour Dolibarr permettant le suivi des revenus et dépenses avec comparaison budget/réalisé et prévisions (forecast).

## 🚀 Fonctionnalités

### Gestion des budgets
- **Multi-budgets** : Créez plusieurs budgets par exercice fiscal
- **Multi-utilisateurs** : Budgets privés ou publics partagés
- **Période flexible** : Définition libre de la période budgétaire (mois de début/fin)
- **Duplication** : Copiez un budget existant pour créer un nouveau

### Revenus et Dépenses
- **Lignes budgétaires** par type (revenu/dépense)
- **Lien comptable** : Association aux comptes du plan comptable (classe 6 et 7)
- **Saisie mensuelle** des montants budgétés
- **Copie rapide** : Dupliquer la première valeur sur toute l'année

### Comparaison Budget vs Réalisé
- **Factures payées** : Extraction automatique depuis la comptabilité
- **Factures en attente** : Suivi des factures non payées
- **Commandes signées** : Montants à facturer (lissés selon date de livraison)
- **Opportunités** : Devis ouverts (selon date de validité)

### Forecast (Prévisions)
- **Vue combinée** : Passé (réalisé en lecture seule) + Futur (modifiable)
- **Forecast par ligne** : Ajustez les prévisions mensuelles
- **Lignes dédiées** : Ajoutez des lignes spécifiques au forecast
- **Actualisation** : Mise à jour des prévisions selon la réalité

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
