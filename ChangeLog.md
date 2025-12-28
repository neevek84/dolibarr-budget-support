# CHANGELOG MODULE BUDGET FOR [DOLIBARR ERP CRM](https://www.dolibarr.org)

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

[...]
