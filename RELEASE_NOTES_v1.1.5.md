# Budget Module v1.1.5 - Release Notes

**Date de release** : 28 décembre 2025

## 🎯 Nouveautés principales

### Lissage temporel basé sur jours ouvrés
- Distribution proportionnelle des montants "à facturer" selon les jours ouvrés (lundi-vendredi)
- Formule : `montant_mois = (montant_total × jours_ouvres_mois) / total_jours_ouvres`
- Date de livraison précise utilisée comme limite haute du lissage

**Exemple** : 
Commande de 24 000€ livrée le 28/02/2026
- Décembre 2025 : proportion des jours ouvrés
- Janvier 2026 : proportion des jours ouvrés  
- Février 2026 : proportion des jours ouvrés jusqu'au 28

### Interface améliorée - Section Signé
- ℹ️ Info-bulles détaillant "à facturer / total"
- 📊 Totaux à chaque niveau (client, commande, global)
- 🎨 Harmonisation avec Payé / En attente

## 🔧 Améliorations techniques

- `getWorkingDaysInMonth()`
- `getWorkingDaysInMonthUntilDay()`
- `calculateLissedAmount()` refactorisée
- Structures enrichies pour `getToInvoiceDetails()`

## 📚 Documentation

- `docs/LISSAGE_TEMPOREL.md` : détails du lissage
- `RECETTE.md` : checklist de validation
- `USER_TEST_GUIDE.md` : 10 tests utilisateurs

## 📦 Installation

- Dolibarr 19.0.0+ / PHP 7.1+
- Mise à jour depuis v1.1.4 sans migration DB

## 🔗 Liens utiles

- [Support](https://github.com/neevek84/dolibarr-budget-support/issues)
- [Release GitHub](https://github.com/neevek84/dolibarr-budget/releases/tag/v1.1.5)
