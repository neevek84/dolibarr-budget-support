# Budget Module for Dolibarr ERP/CRM

**Version 1.1.7** | **Compatible Dolibarr 19+** | **PHP 7.1+**

Advanced budget management module for Dolibarr enabling revenue and expense tracking with budget vs actual comparison and forecasting. Features hierarchical grouping by customers/suppliers and responsive interface.

📖 **[Complete Features Guide](FEATURES.md)** - Comprehensive documentation of all features and tools

## 🚀 Key Features

### Budget Management
- **Multi-budget**: Create multiple budgets per fiscal year
- **Multi-user**: Private or public shared budgets
- **Flexible period**: Define custom budget periods (start/end month)
- **Duplication**: Copy existing budget to create a new one

### Revenue and Expenses
- **Budget lines** by type (revenue/expense)
- **Hierarchical grouping**: 3 levels Type → Customer/Supplier → Lines (v1.1.7)
- **Customer association**: Link revenue line to specific customer/prospect
- **Supplier association**: Link expense line to specific supplier (v1.1.7)
- **"Others" thresholds**: Automatic grouping customers/suppliers < €500/€110 (v1.1.7)
- **Accounting link**: Association with chart of accounts (classes 6 and 7)
- **Monthly entry** of budgeted amounts
- **Quick copy**: Duplicate first value across the year
- **Responsive interface**: 4 optimized views (BUDGET, COMPARE, EVOLUTION x2) (v1.1.7)

### Budget vs Actual Comparison
- **Paid invoices**: Automatic extraction from accounting
- **Pending invoices**: Track unpaid invoices
- **Signed orders**: Amounts to invoice (smoothed by delivery date)
- **Opportunities**: Open quotes (by validity date)

### Forecast
- **Combined view**: Past (actual read-only) + Future (editable)
- **Line-level forecast**: Adjust monthly projections
- **Dedicated lines**: Add forecast-specific lines
- **Updates**: Refresh forecasts based on reality

### YTD (Year To Date) Tracking
- **Trend chart**: Budgeted vs actual revenue
- **Achievement rate**: Cumulative % completion
- **Monthly average**: Budget/billed comparison

## 📋 Requirements

- **Dolibarr**: Version 19 or higher
- **PHP**: Version 7.1 or higher
- **Accounting Module**: Recommended for accounting account association

### Cronjob Configuration (Automatic Snapshots)

The module includes a cronjob that automatically creates monthly forecast snapshots. To enable:

1. **Enable CLI scheduler**: Add to `conf/conf.php`:
   ```php
   $dolibarr_cron_allow_cli = 1;
   ```

2. **Configure system cron** (optional, for automatic execution):
   ```bash
   # Run nightly at 2:00 AM
   0 2 * * * php /var/www/dolibarr/htdocs/custom/budget/scripts/cron_budget_snapshot.php
   ```

3. **Or use Dolibarr's internal scheduler**:
   - Home → Setup → Scheduled Jobs
   - "Budget Snapshot" cronjob appears automatically

## 📦 Installation

1. **Download** the module and extract the archive
2. **Copy** the `budget` folder to `/htdocs/custom/`
3. **Enable** the module from: Home → Setup → Modules/Applications
4. **Configure** user permissions

Database tables are created automatically upon activation.

## 🔄 Upgrade

If upgrading from version < 1.0.1, consult the [UPGRADE.md](https://github.com/neevek84/dolibarr-budget-support/blob/main/UPGRADE.md) guide for database migration instructions.

**Important**: If you encounter the error `Unknown column 'fk_budget_main'`, you must disable then re-enable the module, or execute the migration script available on the [support repo](https://github.com/neevek84/dolibarr-budget-support).

## 🔧 Configuration

### Permissions
- **Read budgets**: Read-only access
- **Create/modify budgets**: Budget creation and editing
- **Delete budgets**: Budget deletion

### Revenue Types Dictionary
Customize revenue categories from:
- Home → Setup → Dictionaries → Revenue Types
- Associate tags with product/service categories for automatic grouping

## 📖 Usage

### Creating a Budget
1. Budget menu → New budget
2. Enter label and period
3. Choose visibility (private/public)
4. Add revenue and expense lines
5. Enter monthly amounts

### Viewing Actuals
1. Budget menu → Select a budget
2. "Compare" tab to see budget vs actual
3. "YTD" tab for cumulative tracking

### Managing Forecast
1. Budget menu → Select a budget
2. "Forecast" tab
3. Past months display actuals
4. Future months are editable

## 📁 Module Structure

```
budget/
├── admin/              # Administration pages
├── class/              # Business classes
│   ├── budgetmain.class.php
│   ├── budgetline.class.php
│   ├── budgetreal.class.php
│   ├── budgetdictionary.class.php
│   └── ...
├── core/modules/       # Module descriptor
├── css/                # CSS styles
├── langs/              # Translations (fr_FR, en_US)
├── lib/                # Libraries
├── sql/                # SQL scripts
└── img/                # Images
```

## 🔒 License

This module is distributed under **GNU GPL v3+ license** (GNU General Public License version 3 or later).

### Freedom of use:
- ✅ Free use for commercial or non-commercial purposes
- ✅ Source code modification
- ✅ Redistribution allowed (source + binary)
- ✅ No installation limits

### Obligations:
- 📄 Source code must remain available
- 📄 Modifications must be published under GPL v3+
- 📄 Preserve copyright notices

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY. See the [COPYING](COPYING) file for the full license text.

For more information: https://www.gnu.org/licenses/gpl-3.0.html

## 👨‍💻 Author

**KREATIV PROJECT MANAGEMENT SASU**
- Website: [https://kreativpm.fr](https://kreativpm.fr)
- Email: contact@kreativpm.fr

## 📞 Support & Contribution

- 🐛 **Bugs**: Report issues via GitHub Issues
- 💡 **Suggestions**: Propose improvements
- 🤝 **Contribution**: Pull requests welcome!
- 📧 **Commercial support**: contact@kreativpm.fr

---

*Module developed for Dolibarr ERP/CRM - © 2025 KREATIV PROJECT MANAGEMENT SASU*
*GPL v3+ License - Free Software*
