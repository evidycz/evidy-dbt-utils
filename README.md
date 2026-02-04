# evidy-dbt-utils

A collection of dbt utility macros used by Evidy.

## Installation

To use this package in your dbt project, add the following to your `packages.yml` file:

```yaml
packages:
  - git: "https://github.com/evidycz/evidy-dbt-utils.git"
    revision: 1.1.0 # Match the version in dbt_project.yml
```

Then run `dbt deps` to install the package.

## Contents

### Macros

### `convert_currency` ([source](macros/convert_currency.sql))

Converts a monetary amount from its source currency to a target currency using exchange rates. It handles `null` values by coalescing them to `0` and allows for flexible source currency column names.

**Parameters:**
- `column_name` (required): The SQL expression or column name for the amount to convert (e.g., `'amount'` or `'t.amount'`).
- `target_currency` (required): The target currency code (e.g., `'CZK'`, `'EUR'`, `'USD'`, `'HUF'`).
- `convert_from` (optional): A list of allowed source currency codes. Defaults to `['CZK', 'EUR', 'USD', 'HUF']`.
- `currency_column` (optional): The column containing the source currency code. Defaults to `'currency'`.

**Rates Table Requirement:**
The rates table (e.g., `rates`) must have a specific structure to work with this macro:
- `date_day`: A date column used for joining.
- `[source_currency]_to_[target_currency]`: Columns for each exchange rate (e.g., `eur_to_czk`, `usd_to_czk`).

### `clean_url_domain` ([source](macros/clean_url.sql))

Cleans a raw URL column to extract the root domain. It removes protocols (`http://`, `https://`), common subdomains (`www.`, `m.`), and everything after the domain (paths, query parameters).

**Parameters:**
- `column_name` (required): The SQL expression or column name containing the URL string.

## Example Usage

### `convert_currency`

```sql
select
    order_id,
    amount as amount_native,
    currency,
    {{ evidy_dbt_utils.convert_currency(
        column_name='amount',
        target_currency='EUR',
        currency_column='currency'
    ) }} as amount_eur
from {{ ref('stg_orders') }} as t
left join {{ ref('rates') }} as r
    on r.date_day = t.order_date
```

In this example, the `rates` model is expected to have a `date_day` column and exchange rate columns like `czk_to_eur`, `usd_to_eur`, etc., depending on the source currencies present in your data.

### `clean_url_domain`

```sql
select
    original_url,
    {{ evidy_dbt_utils.clean_url_domain('original_url') }} as cleaned_domain
from {{ ref('stg_web_traffic') }}
```
